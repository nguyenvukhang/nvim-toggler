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

-- key/value is valid if not empty and not include control
-- and whitespace characters
local function is_valid_key_value(key, value)
  if value == '' or key == '' then
    return false
  elseif value:match('[%s%c]') or key:match('[%s%c]') then
    return false
  end
  return true
end

-- remove duplicates and invalid pairs key/value
utils.sanitize_list = function(list)
  local cleaned_list = {}
  local uniq_values = {}

  for key, value in pairs(list) do
    if not uniq_values[value] and is_valid_key_value(key, value) then
      if not list[value] then
        cleaned_list[key] = value
      elseif not cleaned_list[value] and not cleaned_list[key] then
        cleaned_list[key] = value
      end
      uniq_values[value] = true
    end
  end

  return cleaned_list
end

return utils
