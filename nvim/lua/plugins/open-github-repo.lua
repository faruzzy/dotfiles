return {
  "fowlie/open-github-repo",
  ft = "lua", -- might work elsewhere too, but not tested
  config = function()
    require("open-github-repo")
    vim.keymap.set('n', '<leader>gh', '<Cmd>OpenGitHubRepo<CR>')
  end,
}
