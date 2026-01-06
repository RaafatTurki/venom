local env = require("helpers.utils").read_dotenv()

require "avante".setup {
  provider = "codex",
  acp_providers = {
    ["codex"] = {
      command = "codex-acp",
      env = {
        NODE_NO_WARNINGS = "1",
        OPENAI_API_KEY = env.OPENAI_API_KEY,
      },
    },
  },
}
