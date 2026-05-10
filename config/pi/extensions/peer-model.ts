import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const baseUrl = process.env.PI_PEER_BASE_URL ?? "http://127.0.0.1:8080/v1";
const model = process.env.PI_PEER_MODEL ?? "local";
const apiKey = process.env.PI_PEER_API_KEY;

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_peer_model",
    label: "Ask Peer Model",
    description:
      "Ask a local peer model for a second opinion, critique, plan, or answer.",
    parameters: Type.Object({
      prompt: Type.String({
        description: "The question or task to send to the peer model.",
      }),
      system: Type.Optional(
        Type.String({
          description: "Optional system instruction for the peer model.",
        }),
      ),
      temperature: Type.Optional(
        Type.Number({
          description: "Sampling temperature. Defaults to 0.2.",
        }),
      ),
      max_tokens: Type.Optional(
        Type.Number({
          description: "Maximum tokens to generate. Defaults to 512.",
        }),
      ),
    }),
    async execute(_toolCallId, params, signal) {
      const messages = [
        {
          role: "system",
          content:
            params.system ??
            "You are a concise peer reviewer. Give direct, technical feedback.",
        },
        { role: "user", content: params.prompt },
      ];

      const response = await fetch(`${baseUrl}/chat/completions`, {
        method: "POST",
        signal,
        headers: {
          "content-type": "application/json",
          ...(apiKey ? { authorization: `Bearer ${apiKey}` } : {}),
        },
        body: JSON.stringify({
          model,
          messages,
          temperature: params.temperature ?? 0.2,
          max_tokens: params.max_tokens ?? 512,
          stream: false,
        }),
      });

      if (!response.ok) {
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: `Peer model request failed: HTTP ${response.status} ${await response.text()}`,
            },
          ],
          details: { status: response.status },
        };
      }

      const data = (await response.json()) as {
        choices?: Array<{ message?: { content?: string } }>;
      };
      const text = data.choices?.[0]?.message?.content ?? "";

      return {
        content: [{ type: "text", text }],
        details: { baseUrl, model },
      };
    },
  });

  pi.registerCommand("peer", {
    description: "Ask the configured peer model directly",
    handler: async (args, ctx) => {
      if (!args.trim()) {
        ctx.ui.notify("Usage: /peer <question>", "warning");
        return;
      }

      const result = await fetch(`${baseUrl}/chat/completions`, {
        method: "POST",
        signal: ctx.signal,
        headers: {
          "content-type": "application/json",
          ...(apiKey ? { authorization: `Bearer ${apiKey}` } : {}),
        },
        body: JSON.stringify({
          model,
          messages: [{ role: "user", content: args }],
          temperature: 0.2,
          max_tokens: 512,
          stream: false,
        }),
      });

      if (!result.ok) {
        ctx.ui.notify(`Peer model failed: HTTP ${result.status}`, "error");
        return;
      }

      const data = (await result.json()) as {
        choices?: Array<{ message?: { content?: string } }>;
      };
      pi.sendMessage({
        customType: "peer-model",
        content: data.choices?.[0]?.message?.content ?? "(empty)",
        display: true,
        details: { baseUrl, model },
      });
    },
  });
}
