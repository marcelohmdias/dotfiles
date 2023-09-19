local Utils = {}

--- Create a mapper function for keys shortcuts
--- @param data table Mouse events config
--- @return function
function Utils:create_bind_events(data)
  --- @param event table Event config
  --- @param mods string Key modifier
  --- @param action function Callback action
  return function(event, mods, action)
    table.insert(data, {
      event = event,
      mods = mods,
      action = action,
    })
  end
end

--- Create a mapper function for keys shortcuts
--- @param data table Key config
--- @return function
function Utils:create_map_keys(data)
  --- @param key string keyboard key
  --- @param mods string Key modifier
  --- @param action function Callback action
  return function(key, mods, action)
    table.insert(data, {
      key = key,
      mods = mods,
      action = action,
    })
  end
end

--- Create a mapper function for term action
--- @param data table Action config
--- @param name string Action name
--- @return function
function Utils:creae_map_actions(data, name)
  data[name] = {}
  --- @param keys table Map of keys
  --- @param action function Callback action
  return function(keys, action)
    for k, v in ipairs(keys) do
      table.insert(data[name], {
        key = v,
        action = action,
      })
    end
  end
end

return Utils
