local M = {}

--- Stand-in for `LazyVim.root()`: nearest ancestor containing `.git` (or a
--- `lua` dir), falling back to cwd. No LSP-based detection.
---@param buf? integer
---@return string
function M.root(buf)
  return vim.fs.root(buf or 0, { ".git", "lua" }) or vim.uv.cwd()
end

return M
