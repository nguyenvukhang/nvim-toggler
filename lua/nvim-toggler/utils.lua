local utils = {}

-- returns a boolean of the success of the assertion
utils.assert = function(v, message)
  if not v then
    print(message)
    return false
  end
  return true
end

utils.err = {
  UNSUPPORTED_VALUE = 'toggler: unsupported value.',
  UNSUPPORTED_MODE = 'toggler: unsupported mode.',
  DUPLICATE_INVERSE = 'toggler: inverse config has duplicates.',
}

return utils
