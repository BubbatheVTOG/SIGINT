// Notify Herdr when the ask_user_question tool pauses for input.
// Complements @nguyenquangthai/pi-ask; does not modify it.
import { spawn } from "node:child_process";
import { appendFileSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TOOL_NAME = "ask_user_question";
const DEBUG_LOG = "/tmp/ask-herdr-notify.log";

function log(msg: string) {
  try {
    appendFileSync(DEBUG_LOG, `${new Date().toISOString()} ${msg}\n`);
  } catch {
    // ignore
  }
}

function notifyHerdr(
  title: string,
  body: string,
  sound: "request" | "done" | "none",
) {
  log(
    `notify: HERDR_ENV=${process.env.HERDR_ENV ?? "unset"} title=${JSON.stringify(title)}`,
  );
  if (process.env.HERDR_ENV !== "1") return;
  try {
    const child = spawn(
      "herdr",
      ["notification", "show", title, "--body", body, "--sound", sound],
      { stdio: ["ignore", "pipe", "pipe"] },
    );
    let out = "";
    child.stderr?.on("data", (d: Buffer) => {
      out += d.toString();
    });
    child.on("error", (err) => log(`spawn error: ${err.message}`));
    child.on("close", (code) => {
      if (code !== 0 || out.trim())
        log(`herdr exit=${code} stderr=${out.slice(0, 300)}`);
      else log("herdr notification OK");
    });
    child.unref();
  } catch (err) {
    log(`throw: ${err instanceof Error ? err.message : String(err)}`);
    // A notification failure must never break the tool call.
  }
}

function firstQuestionText(args: unknown): string {
  if (typeof args !== "object" || args === null) return "";
  const questions = (args as { questions?: unknown }).questions;
  if (!Array.isArray(questions) || questions.length === 0) return "";
  const first = questions[0];
  if (typeof first !== "object" || first === null) return "";
  const q = first as { question?: unknown; header?: unknown };
  const text =
    typeof q.question === "string" && q.question.trim() !== ""
      ? q.question
      : typeof q.header === "string"
        ? q.header
        : "";
  return text.length > 120 ? `${text.slice(0, 117)}...` : text;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_execution_start", async (event) => {
    log(`tool_execution_start: ${event.toolName}`);
    if (event.toolName !== TOOL_NAME) return;
    // Tell the herdr native-state integration (herdr-agent-state.ts) we are
    // waiting on the user so Herdr shows "blocked" via the socket channel.
    try {
      pi.events.emit("herdr:blocked", {
        active: true,
        label: "pi is waiting for an answer",
      });
    } catch (err) {
      log(
        `herdr:blocked emit failed: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
    const question = firstQuestionText(event.args);
    const body =
      question === "" ? "The agent needs a decision to continue." : question;
    notifyHerdr("pi is paused — question waiting", body, "request");
  });

  pi.on("tool_execution_end", async (event) => {
    log(`tool_execution_end: ${event.toolName}`);
    if (event.toolName !== TOOL_NAME) return;
    try {
      pi.events.emit("herdr:blocked", { active: false });
    } catch {
      // ignore
    }
    notifyHerdr("pi question answered", "Agent resumed.", "done");
  });
}
