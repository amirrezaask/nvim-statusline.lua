local M = {}

---@enum statusline.IconsProvider
M.icons_providers = { Mini = "mini", NvimWebDevicons = "nvim-web-devicons" }

local options = {
  use_icons = true,
  icons_provider = M.icons_providers.NvimWebDevicons,
}

vim.cmd [[
  hi default link StatusLineNormal TabLineSel
  hi default link StatusLineInsert Search
  hi default link StatusLineVisual Character
  hi default link StatusLineCommand FloatTitle
  hi default link StatusLineReplace Error
  hi default link StatusLineSelect StatusLineVisual
  hi default link StatusLineTerminal StatusLineInsert
  hi default link StatusLineGitBranch Conditional
  hi default link StatusLineGitStatus Conditional
]]

M.internal = {}

M.internal.filetype_icon = function()
  if not options.use_icons then
    return ""
  end
  local filetype = vim.bo.filetype or "Unknown"

  local icon

  if options.icons_provider == M.icons_providers.NvimWebDevicons then
    pcall(function()
      icon = require("nvim-web-devicons").get_icon(filetype)
    end)
  end

  if options.icons_provider == M.icons_providers.Mini then
    pcall(function()
      icon = require("mini.icons").get("filetype", filetype)
    end)
  end

  return icon or ""
end

function M.internal.mode()
  local mode = vim.api.nvim_get_mode().mode
  local mode_map = {
    ["n"] = { name = "Normal", hl = "StatuslineNormal" },
    ["i"] = { name = "Insert", hl = "StatuslineInsert" },
    ["v"] = { name = "Visual", hl = "StatuslineVisual" },
    ["V"] = { name = "Visual Line", hl = "StatuslineVisual" },
    ["\22"] = { name = "Visual Block", hl = "StatuslineVisual" }, -- \22 is Ctrl-V
    ["c"] = { name = "Command", hl = "StatuslineCommand" },
    ["R"] = { name = "Replace", hl = "StatuslineReplace" },
    ["s"] = { name = "Select", hl = "StatuslineSelect" },
    ["S"] = { name = "Select Line", hl = "StatuslineSelect" },
    ["\19"] = { name = "Select Block", hl = "StatuslineSelect" }, -- \19 is Ctrl-S
    ["t"] = { name = "Terminal", hl = "StatuslineTerminal" },
    ["no"] = { name = "Operator Pending", hl = "StatuslineNormal" },
    ["niI"] = { name = "Normal (Insert)", hl = "StatuslineNormal" },
    ["niR"] = { name = "Normal (Replace)", hl = "StatuslineNormal" },
    ["niV"] = { name = "Normal (Virtual Replace)", hl = "StatuslineNormal" },
    ["nt"] = { name = "Normal (Terminal)", hl = "StatuslineNormal" },
    ["rm"] = { name = "More Prompt", hl = "StatuslineNormal" },
    ["r?"] = { name = "Confirm", hl = "StatuslineNormal" },
    ["!"] = { name = "Shell", hl = "StatuslineNormal" },
  }

  local mode_info = mode_map[mode] or { name = "Unknown", hl = "StatuslineNormal" }
  return "%#" .. mode_info.hl .. "#" .. " " .. mode_info.name .. " " .. "%#StatusLine#"
end

local branch_icon = ""

M.internal.git_status = function()
  if not vim.b.gitsigns_status or vim.b.gitsigns_status == "" then
    return ""
  else
    return "%#StatusLineGitStatus#" .. branch_icon .. " " .. vim.b.gitsigns_status .. "%#StatusLine#"
  end
end

M.internal.git_head = function()
  if not vim.b.gitsigns_head or vim.b.gitsigns_head == "" then
    return ""
  else
    local branch = vim.b.gitsigns_head
    if #branch > 20 then
      branch = string.sub(branch, 1, 20) .. "…"
    end
    return "%#StatusLineGitBranch#" .. branch_icon .. " " .. branch .. "%#StatusLine#"
  end
end

M.components = {}

M.components.space = " "

M.components.bracket = function(s)
  return "[" .. s .. "]"
end

M.components.git_head = "%{%v:lua.require('vitaline').internal.git_head()%}"
M.components.git_status = "%{%v:lua.require('vitaline').internal.git_status()%}"
M.components.mode = "%{%v:lua.require('vitaline').internal.mode()%}"
M.components.filetype_icon = "%{v:lua.require('vitaline').internal.filetype_icon()}"
M.components.filetype = "%y"
M.components.filename = "%r%h%w%q%F"
M.components.line = "%l"
M.components.column = "%c"
M.components.modified = "%m"
M.components.line_col = M.components.line .. " :" .. M.components.column

local default_setup = {
  left = { M.components.mode, M.components.git_head },
  center = { M.components.filetype_icon, M.components.filename, M.components.modified },
  right = { M.components.git_status, M.components.bracket(M.components.line_col) },
  delimiter = " ",
}

---@class statusline.Config
---@field left table<string>
---@field center table<string>
---@field right table<string>
---@field delimiter string
---@field options table
---@param opts statusline.Config?
M.setup = function(opts)
  pcall(function()
    require("mini.icons").setup()
  end)
  opts = opts or default_setup
  if #opts == 0 then
    opts = default_setup
  end
  opts.options = opts.options or {}
  for k, v in pairs(options) do
    if opts.options[k] ~= nil then
      options[k] = v
    end
  end
  local left = table.concat(opts.left or {}, opts.delimiter)
  local center = table.concat(opts.center or {}, opts.delimiter)
  local right = table.concat(opts.right or {}, opts.delimiter)

  vim.o.statusline = table.concat({ left, center, right }, "%=")
end

return M
