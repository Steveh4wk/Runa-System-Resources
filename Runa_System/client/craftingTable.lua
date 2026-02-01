-- ==============================================
-- RUNA SYSTEM - Rune Crafting Table Client
-- ==============================================

local isCraftingMenuOpen = false
local craftingTableCoords = Config.FixedPositions.CraftingTable or vector3(2081.370117, 3343.610107, 46.860001)
local ox_target = nil

-- ==============================================
-- INITIALIZATION
-- ==============================================

RegisterNetEvent('Runa_System:client:start', function()
  createCraftingTarget()
  print('[Runa Crafting] Target created at coords: ' .. tostring(craftingTableCoords))
end)

RegisterNetEvent('Runa_System:client:stop', function()
  removeCraftingTarget()
end)

-- ==============================================
-- TARGET CREATION
-- ==============================================

function createCraftingTarget()
  if not Config.Crafting.Enabled then return end
  
  -- Create ox_target for the crafting table
  local model = Config.CraftingTable.ModelHash or `prop_table_02`
  
  -- Create the prop
  local prop = CreateObject(model, craftingTableCoords.x, craftingTableCoords.y, craftingTableCoords.z, false, false, false)
  SetEntityHeading(prop, 70.0)
  FreezeEntityPosition(prop, true)
  
  -- Create target
  ox_target = exports.ox_target:addLocalEntity(prop, {
    {
      name = 'runa_crafting',
      label = 'Rune Forge',
      icon = 'fa-solid fa-hammer',
      onSelect = function()
        if isCraftingMenuOpen then return end
        openCraftingMenu()
      end,
      distance = 2.5
    }
  })
  
  print('[Runa Crafting] Target created successfully')
end

function removeCraftingTarget()
  if ox_target then
    exports.ox_target:removeTarget(ox_target)
    ox_target = nil
  end
  isCraftingMenuOpen = false
end

-- ==============================================
-- CRAFTING MENU
-- ==============================================

function openCraftingMenu()
  if not Config.Crafting.Enabled then 
    print('[Runa Crafting] Crafting is disabled in config')
    return 
  end
  
  -- Get player's inventory
  local inventory = exports.ox_inventory:Inventory()
  if not inventory then
    print('[Runa Crafting] Failed to get inventory')
    return
  end
  
  -- Filter runes from inventory
  local runes = filterRunesFromInventory(inventory)
  
  -- Send data to UI
  SendNUIMessage({
    type = 'openCrafting',
    inventory = runes
  })
  
  SetNuiFocus(true, true)
  isCraftingMenuOpen = true
  print('[Runa Crafting] Menu opened with ' .. #runes .. ' runes')
end

function closeCraftingMenu()
  SendNUIMessage({
    type = 'closeCrafting'
  })
  
  SetNuiFocus(false, false)
  isCraftingMenuOpen = false
  print('[Runa Crafting] Menu closed')
end

-- ==============================================
-- INVENTORY FILTERING
-- ==============================================

function filterRunesFromInventory(inventory)
  local runes = {}
  
  -- Rune base types with their level suffix
  local runeTypes = {
    ['runa_speed'] = { base = 'runa_speed', level = 0 },
    ['runa_speed+1'] = { base = 'runa_speed', level = 1 },
    ['runa_speed+2'] = { base = 'runa_speed', level = 2 },
    ['runa_speed+3'] = { base = 'runa_speed', level = 3 },
    ['runa_speed+4'] = { base = 'runa_speed', level = 4 },
    ['runa_speed+5'] = { base = 'runa_speed', level = 5 },
    ['runa_hp'] = { base = 'runa_hp', level = 0 },
    ['runa_hp+1'] = { base = 'runa_hp', level = 1 },
    ['runa_hp+2'] = { base = 'runa_hp', level = 2 },
    ['runa_hp+3'] = { base = 'runa_hp', level = 3 },
    ['runa_hp+4'] = { base = 'runa_hp', level = 4 },
    ['runa_hp+5'] = { base = 'runa_hp', level = 5 },
    ['runa_mp'] = { base = 'runa_mp', level = 0 },
    ['runa_mp+1'] = { base = 'runa_mp', level = 1 },
    ['runa_mp+2'] = { base = 'runa_mp', level = 2 },
    ['runa_mp+3'] = { base = 'runa_mp', level = 3 },
    ['runa_mp+4'] = { base = 'runa_mp', level = 4 },
    ['runa_mp+5'] = { base = 'runa_mp', level = 5 },
    ['runa_danno'] = { base = 'runa_danno', level = 0 },
    ['runa_danno+1'] = { base = 'runa_danno', level = 1 },
    ['runa_danno+2'] = { base = 'runa_danno', level = 2 },
    ['runa_danno+3'] = { base = 'runa_danno', level = 3 },
    ['runa_danno+4'] = { base = 'runa_danno', level = 4 },
    ['runa_danno+5'] = { base = 'runa_danno', level = 5 },
    ['runa_cdr'] = { base = 'runa_cdr', level = 0 },
    ['runa_cdr+1'] = { base = 'runa_cdr', level = 1 },
    ['runa_cdr+2'] = { base = 'runa_cdr', level = 2 },
    ['runa_cdr+3'] = { base = 'runa_cdr', level = 3 },
    ['runa_cdr+4'] = { base = 'runa_cdr', level = 4 },
    ['runa_cdr+5'] = { base = 'runa_cdr', level = 5 }
  }
  
  for _, item in ipairs(inventory) do
    if not item then goto continue end
    
    local itemName = item.name
    if not itemName then goto continue end
    
    local itemType = runeTypes[itemName]
    if itemType then
      local metadata = item.metadata or {}
      local level = metadata.level or itemType.level
      
      -- Skip maxed runes
      if level < 5 then
        table.insert(runes, {
          name = itemName,
          label = item.label or itemName,
          count = item.count or 1,
          metadata = metadata,
          level = level,
          type = itemType.base
        })
      end
    end
    
    ::continue::
  end
  
  return runes
end

-- ==============================================
-- NUI CALLBACKS
-- ==============================================

RegisterNUICallback('closeCrafting', function(data, cb)
  closeCraftingMenu()
  cb({})
end)

RegisterNUICallback('executeUpgrade', function(data, cb)
  print('[DEBUG] executeUpgrade called from UI with data: ' .. json.encode(data))
  
  if not data or not data.type then
    print('[ERROR] Invalid upgrade data received')
    cb({ success = false, error = 'Invalid data' })
    return
  end
  
  local runeType = data.type
  local runeLevel = data.level or 0
  
  print('[DEBUG] Triggering upgrade for: ' .. runeType .. ' level: ' .. runeLevel)
  
  -- Trigger server-side upgrade
  TriggerServerEvent('Runa_System:server:upgradeRune', runeType, runeLevel)
  
  cb({ success = true })
end)

-- ==============================================
-- UPGRADE RESULT HANDLER
-- ==============================================

RegisterNetEvent('Runa_System:client:upgradeResult', function(result)
  print('[DEBUG] Upgrade result received: success=' .. tostring(result.success) .. ', newLevel=' .. tostring(result.newLevel))
  
  -- Send result to UI
  SendNUIMessage({
    type = 'showUpgradeResult',
    success = result.success,
    newLevel = result.newLevel
  })
end)

-- ==============================================
-- NOTIFICATION HANDLER
-- ==============================================

RegisterNetEvent('Runa_System:client:notification', function(data)
  SendNUIMessage({
    type = 'showNotification',
    title = data.title or 'Notification',
    message = data.message or '',
    duration = data.duration or 3000
  })
end)
