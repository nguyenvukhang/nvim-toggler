--[[
handles vim.opt.iskeyword (or alternatively `:set iskeyword`)
so that inversions of "!=" to "==" works
--]]
local Keys = { chars = {}, custom_keywords = {} }
local original = vim.deepcopy(vim.opt.iskeyword)

Keys.load = function()
  vim.opt.iskeyword = Keys.custom_keywords
end

Keys.reset = function()
  vim.opt.iskeyword = original
end

Keys.add_char = function(c)
  Keys.chars[c] = true
end

Keys.get_all_chars = function()
  local ch = {}
  for _, c in pairs(Keys.custom_keywords:get()) do
    if c:len() == 1 then
      ch[c] = true
    else
      -- handle char ranges
      local a, b = c:gmatch('(%d+)-.*')(), c:gmatch('.*-(%d+)')()
      for i = a, b do
        ch[vim.fn.nr2char(i)] = true
      end
    end
  end
  return ch
end

Keys.is_keyword = function(c)
  return Keys.get_all_chars()[c] == true
end

Keys.update_keys = function()
  for c in pairs(Keys.chars) do
    vim.opt.iskeyword:append(c)
  end
  Keys.custom_keywords = vim.deepcopy(vim.opt.iskeyword)
  Keys.reset()
end

return Keys
