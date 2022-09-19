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

-- key/value is valid if not empty, and does not include control
-- nor whitespace characters
local function is_valid(k, v)
  local function valid(x)
    return x ~= '' and not x:match('[%s%c]')
  end
  return valid(k) and valid(v)
end

-- validate each key-value pair
local validate_tbl = function(tbl)
  local valid = {}
  for k, v in pairs(tbl) do
    if is_valid(k, v) then
      valid[k] = v
    end
  end
  return valid
end

-- remove duplicates
local sanitize_tbl = function(base, tbl)
  local result = base or {} -- fallback to blank table
  tbl = validate_tbl(tbl) -- validate incoming tbl
  local hash = {}

  for k, v in pairs(tbl) do
    if not hash[k] and not hash[v] then
      result[k] = v
      hash[k] = true
      hash[v] = true
    end
  end

  return result
end

-- prioritizes user over defaults
-- returns a tbl ready to have a reverse lookup generated
--
-- def_tbl  - default table
-- user_tbl - user's table
utils.merge = function(def_tbl, user_tbl)
  user_tbl = sanitize_tbl({}, user_tbl)
  if vim.tbl_isempty(def_tbl) then
    return user_tbl
  else
    return sanitize_tbl(user_tbl, def_tbl)
  end
end

local test_sanitize_tbl = function(recevied, expected)
  local received = sanitize_tbl({}, recevied)
  local log = vim.inspect({ received = received, expected = expected })
  for k, v in pairs(expected) do
    local rk, ek, rv, ev = received[k], expected[k], received[v], expected[v]
    if rk ~= ek then
      vim.notify(log, vim.log.levels.WARN)
      return
    end
    if rv ~= ev then
      vim.notify(log, vim.log.levels.WARN)
      return
    end
  end
end

vim.api.nvim_create_user_command('NvimTogglerTest', function()
  test_sanitize_tbl({ ['a'] = 'c', ['b'] = 'c' }, { ['a'] = 'c' })
  test_sanitize_tbl({ ['a'] = 'b', ['b'] = 'c' }, { ['a'] = 'b' })
  print('end of test.')
end, {})

return utils
