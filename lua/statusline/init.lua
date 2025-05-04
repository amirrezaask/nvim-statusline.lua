local M = {}
M.sections = {}
_G.statusline = {}

_G.statusline.filetype_icon = function()
  local filetype = vim.bo.filetype or "Unknown"
  local icon
  pcall(function()
    icon = require("nvim-web-devicons").get_icon(filetype)
  end)
  return icon or ""
end

function _G.statusline.mode()
  local mode = vim.api.nvim_get_mode().mode
  local mode_map = {
    ["n"] = "Normal",
    ["i"] = "Insert",
    ["v"] = "Visual",
    ["V"] = "Visual Line",
    ["\22"] = "Visual Block", -- \22 is Ctrl-V
    ["c"] = "Command",
    ["R"] = "Replace",
    ["s"] = "Select",
    ["S"] = "Select Line",
    ["\19"] = "Select Block", -- \19 is Ctrl-S
    ["t"] = "Terminal",
    ["no"] = "Operator Pending",
    ["niI"] = "Normal (Insert)",
    ["niR"] = "Normal (Replace)",
    ["niV"] = "Normal (Virtual Replace)",
    ["nt"] = "Normal (Terminal)",
    ["rm"] = "More Prompt",
    ["r?"] = "Confirm",
    ["!"] = "Shell",
  }

  return mode_map[mode] or "Unknown"
end

M.sections.space = " "

M.sections.bracket = function(s)
  return "[" .. s .. "]"
end

_G.statusline.git_status = function()
  if not vim.b.gitsigns_status or vim.b.gitsigns_status == "" then
    return ""
  else
    return "[" .. vim.b.gitsigns_status .. "]"
  end
end

_G.statusline.git_head = function()
  local branch_icon = ""
  if not vim.b.gitsigns_head or vim.b.gitsigns_head == "" then
    return ""
  else
    return vim.b.gitsigns_head
  end
end

M.sections.git_head = "%{v:lua.statusline.git_head()}"
M.sections.git_status = "%{v:lua.statusline.git_status()}"
M.sections.mode = "[%{v:lua.statusline.mode()}]"
M.sections.filetype_icon = "%{v:lua.statusline.filetype_icon()}"
M.sections.filetype = "%y"
M.sections.filename = "%r%h%w%q%F"
M.sections.line = "%l"
M.sections.column = "%c"
M.sections.modified = "%m"
M.sections.line_col = M.sections.line .. " :" .. M.sections.column

local default_sections = {
  left = { M.sections.mode, M.sections.git_head, M.sections.git_status },
  center = { M.sections.filename, M.sections.modified },
  right = { M.sections.bracket(M.sections.line_col) .. M.sections.filetype },
  delimiter = " ",
}

---@class statusline.Config
---@field left table<string>
---@field center table<string>
---@field right table<string>
---@field delimiter string

---@param opts statusline.Config
M.setup = function(opts)
  opts = opts or default_sections
  local left = table.concat(opts.left or {}, opts.delimiter)
  local center = table.concat(opts.center or {}, opts.delimiter)
  local right = table.concat(opts.right or {}, opts.delimiter)

  vim.o.statusline = table.concat({ left, center, right }, "%=")
end

return M
