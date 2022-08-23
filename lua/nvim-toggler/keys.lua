--[[
handles vim.opt.iskeyword (or alternatively `:set iskeyword`)
so that inversions of "!=" to "==" works
--]]
local Keys = { kw_chars = {}, kw_flat = '' }
local original = vim.opt.iskeyword['_value']

Keys.load = function()
  vim.opt.iskeyword = Keys.kw_flat
end

Keys.reset = function()
  vim.opt.iskeyword = original
end

Keys.is_keyword = function(c)
  return Keys.kw_chars[c] == true
end

Keys.update = function(inverse_list)
  local u = {}
  for k in pairs(inverse_list) do
    k:gsub('.', function(c)
      u[c] = true
    end)
  end
  Keys.kw_chars = {}
  for c in pairs(u) do
    -- update kw_chars with the unpacked characters
    -- (vim.opt.iskeyword includes character ranges)
    if c:len() == 1 then
      Keys.kw_chars[c] = true
    else
      -- handle char ranges
      -- (example: "48-57" or "192-255")
      local t = vim.tbl_map(tonumber, vim.split(c, '-'))
      for i = t[1], t[2] do
        Keys.kw_chars[vim.fn.nr2char(i)] = true
      end
    end
  end
  Keys.kw_flat = table.concat(vim.tbl_keys(Keys.kw_chars), ',')
end

return Keys
