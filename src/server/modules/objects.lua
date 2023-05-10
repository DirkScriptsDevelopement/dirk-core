

Core.Objects = {

  Physicals = {}, 

  CreatePhysical = function(name,data) --## Will create a physical object in the world a player will spawn/despawn when they get close to 
    local self = {}
    self.name            = name 
    self.model           = data.model
    self.position        = data.position
    self.interactions    = data.interactions or {}
    self.metadata        = data.metadata or {}
    self.canSpawn        = data.canSpawn or false
    self.canInteract     = data.canInteract or false

    self.globalState = function(data)
      for k,v in pairs(data) do 
        self[k] = v
      end
      TriggerClientEvent("Dirk-Core:Physicals:State", -1, self.name, data)
    end

    --## Remove this entity from ever spawning will have to be called again to add it back to this table

    self.removePhysical = function()
      TriggerClientEvent("Dirk-Core:Physicals:RemovePhysical", -1, self.name)
      Core.Objects.Physicals[self.name] = nil
    end

    self.Searched = function(src)
      if not self.metadata.searched then 
        self.metadata.searched = true
        self.globalState({
          metadata = self.metadata,
        })
        --## Loop Search Loot
        
      else
        Core.UI.Notify(src, "There is nothing in here.")
      end
    end

    self.Grabbed = function(src)
      if not self.metadata.grabbed then 
        --## loop table
      else
        Core.UI.Notify(src, "There is nothing to grab here")
      end
    end

    Core.Objects.Physicals[name] = self

    local clientData = {}
    for k,v in pairs(self) do 
      if type(v) ~= "function" then 
        clientData[k] = v
      end
    end
    TriggerClientEvent("Dirk-Core:Physicals:AddPhysical", -1, self.name, clientData)
    return self 
  end, 
}

RegisterNetEvent("Dirk-Core:Physicals:Grabbed", function(name)
  local src = source
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].Grabbed(src)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:Searched", function(name)
  local src = source
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].Searched(src)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:State", function(name, data)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].globalState(data)
  end
end)

RegisterNetEvent("Dirk-Core:Physicals:RemovePhysical", function(name)
  if Core.Objects.Physicals[name] then 
    Core.Objects.Physicals[name].removePhysical()
  end
end)

-- RegisterNetEvent("Dirk-Core:Physicals:AddPhysical", function(name,data)
--   if Core.Objects.Physicals[name] then Core.Objects.Physicals[name].remove(); end 
--   Core.Objects.CreatePhysical(name,data)
-- end)

Citizen.CreateThread(function()
  while not Config.Framework do Wait(500); end 
  Core.Callback("Dirk-Core:Physicals:GetPhysicals", function(source,cb)
    local ret = {}
    for k,v in pairs(Core.Objects.Physicals) do 
      if type(v) ~= "function" then 
        ret[k] = v
      end
    end
    cb(ret)
  end)
  
  
  while not Core.Player do Wait(500); end
  Core.Callback("Dirk-Core:HasItem", function(src,cb,item,a)
    cb(Core.Player.HasItem(src, item,a))
  end)


  while not Core.Inventories do Wait(500); end
  Core.Callback("Dirk:Inventory:Open", function(src,cb,id)
    local tInv = Core.Inventory.GetById(id)
    if not tInv then cb(nil, nil) return false; end
    if tInv.inUse then cb(nil,nil) return false; end
    tInv.ChangeUse(true)



    local invs = {
      {
        id = "Player",
        label = "My Inventory",
        items = cleanse(Core.Player.Inventory(src)),
      },
      {
        id = tInv.ID,
        label = tInv.Name,
        items = cleanse(tInv.Items),
      },
    }
    cb(invs)
  end)



end)



RegisterCommand("testPhysical", function(source,args)
  Core.Objects.CreatePhysical("myTest", {
    model = "prop_acc_guitar_01_d1",
    position = vector4(199.54, -1018.05, 29.35, 286.58),
    interactions = {
      Carry = {Weight = 150, oPos = vector3(0,0,0), oRot = vector3(0,0,0)}, 
      Search = {},
      Grab   = {}, 
    },
    canSpawn = true,
    canInteract = true,
  })
end)