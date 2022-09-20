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
  -- load hash from base
  local hash = {}
  for k, v in pairs(base) do
    hash[k] = true
    hash[v] = true
  end

  local result = base or {} -- fallback to blank table
  tbl = validate_tbl(tbl) -- validate incoming tbl

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

return utils
