local utils = {}

-- returns a boolean of the success of the assertion
utils.assert = function(v, message)
  if not v then
    vim.notify(message, vim.log.levels.WARN)
    return false
  end
  return true
end

utils.err = {
  UNSUPPORTED_VALUE = 'toggler: unsupported value.',
  UNSUPPORTED_MODE = 'toggler: unsupported mode.',
  DUPLICATE_INVERSE = 'toggler: inverse config has duplicates.',
}

-- remove duplicates key/value == value/key if exists
utils.remove_duplicates = function(list)
  local cleaned_list = {}

  for key, value in pairs(list) do
    if not list[value] then
      cleaned_list[key] = value
    elseif not cleaned_list[value] and not cleaned_list[key] then
      cleaned_list[key] = value
    end
  end

  return cleaned_list
end

return utils
