local SupportedResources = {
  Inventory = {
    ['qb-inventory'] = "qb-inventory/html/images/",
    ['qs-inventory'] = "qs-inventory/html/images/",
    ['mf-inventory'] = "mf-inventory/nui/items/",
    ['ox_inventory'] = "ox_inventory/web/images/"
  },
  TargetSystem = {'qtarget', 'qb-target', 'ox_target'},
  TimeSystem = {'vSync', 'cd_easytime', 'qb-weathersync'},
  JailSystem = {'esx_jail', 'qb-prison'},
  ProgressBar = {'progressbar', 'ox_lib'},
  Framework   = {'es_extended', 'qb-core'},
  KeySystem   = {'qb-vehiclekeys', 'cd_garage'},
}

local FoundResources = {}

Citizen.CreateThread(function()
  for type,resources in pairs(SupportedResources) do 
    if type == "TargetSystem" then 
      local ox_target = GetResourceState('ox_target')
      if ox_target ~= "missing" and ox_target ~= "unknown" then
        Config[type] = 'ox_target'
        FoundResources[type] = 'ox_target'
      else 
        for index,resource in pairs(resources) do 
          local resState = GetResourceState(resource)
          if resState ~= "missing" and resState ~= "unknown" then
            Config[type] = resource
            FoundResources[type] = resource
          end
        end 
      end
    elseif type == "Inventory" then
      for resource,itemDir in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type] = resource 
          Config.ItemsIconsDir = itemDir
          FoundResources[type] = resource  
        end        
      end

    else
      for index,resource in pairs(resources) do 
        local resState = GetResourceState(resource)
        if resState ~= "missing" and resState ~= "unknown" then
          Config[type] = resource
          FoundResources[type] = resource
        end
      end
    end
  end

  for type,_ in pairs(SupportedResources) do 
    if FoundResources[type] then 
      print("^2Dirk-Core^7 | Found ^5"..FoundResources[type].."^7 for ^3"..type.."^7")
    else 
      print("^2Dirk-Core^7 | Found ^8NOTHING^7 for ^3"..type.."^7")
    end
  end

  if FoundResources.Framework then 
    if Config.Framework == "es_extended" then 
      if Config.ESXGetObjectEvent then 
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj; end)
      else 
        ESX = exports['es_extended']:getSharedObject()
      end
    elseif Config.Framework == "qb-core" then 
      QBCore = exports['qb-core']:GetCoreObject()
      RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject(); end)
    end
  end
end)
