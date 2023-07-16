local Utils = {}

function Utils:map_keys(data)
  return function (key, mods, action)
    table.insert(data, {
      key = key,
      mods = mods,
      action = action
    })
  end
end

function Utils:map_actions(data, name)
  data[name] = {}
  return function (keys, action)
    for k,v in ipairs(keys) do
      table.insert(data[name], {
        key = v,
        action = action
      })
    end
  end
end

return Utils
