import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("llama-cpp", {
    name: "Local Llama.cpp",
    baseUrl: "http://127.0.0.1:8080/v1",
    apiKey: "dummy",
    api: "openai-completions",
    models: [
      {
        id: "qwen3.5-27b-q4km",
        name: "Qwen3.5 27B Q4_K_M (262K ctx, 37.6 t/s)",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 262144,
        maxTokens: 32768
      },
      {
        id: "qwen3.5-27b-q5kxl",
        name: "Qwen3.5 27B Q5_K_XL (131K ctx, 31.0 t/s)",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 131072,
        maxTokens: 32768
      },
      {
        id: "qwen3.6-27b-q4km",
        name: "Qwen3.6 27B Q4_K_M (131K ctx, 38.3 t/s)",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 131072,
        maxTokens: 32768
      },
      {
        id: "glm-4.7-flash-q4km",
        name: "GLM-4.7 Flash Q4_K_M (131K ctx, 128.9 t/s)",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 131072,
        maxTokens: 32768
      }
    ]
  });
}
