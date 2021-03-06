function ZIV:OnDisconnect(keys)
  DebugPrint('[ZIV] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end

-- The overall game state has changed
function ZIV:OnGameRulesStateChange(keys)
  DebugPrint("[ZIV] GameRules State Changed")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main ziv functions
  ZIV:_OnGameRulesStateChange(keys)

  local newState = GameRules:State_Get()

  if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    Director:SetupMap()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function ZIV:OnNPCSpawned(keys)
  DebugPrint("[ZIV] NPC Spawned")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main ziv functions
  ZIV:_OnNPCSpawned(keys)

  local npc = EntIndexToHScript(keys.entindex)

  if npc.IsHero and not string.match(npc:GetUnitName(), "dummy") and not npc.worldPanel then

  end

  if npc.GetAbsOrigin then
    npc.initial_origin = npc:GetAbsOrigin()
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function ZIV:OnEntityHurt(keys)
  --DebugPrint("[ZIV] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end

    if entCause.OnDamageDealCallbacks then
      for i,v in ipairs(entCause.OnDamageDealCallbacks) do
        if v then
          v(entCause, entVictim, keys.damage)
          table.remove(entCause.OnDamageDealCallbacks, i)
          break
        end
      end
    end
  end
end

-- An item was picked up off the ground
function ZIV:OnItemPickedUp(keys)
  DebugPrint( '[ZIV] OnItemPickedUp' )
  DebugPrintTable(keys)

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname

  
  -- ForceUpdate()
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function ZIV:OnPlayerReconnect(keys)
  DebugPrint( '[ZIV] OnPlayerReconnect' )
  DebugPrintTable(keys) 
end

-- An item was purchased by a player
function ZIV:OnItemPurchased( keys )
  DebugPrint( '[ZIV] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function ZIV:OnAbilityUsed(keys)
  DebugPrint('[ZIV] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function ZIV:OnNonPlayerUsedAbility(keys)
  DebugPrint('[ZIV] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function ZIV:OnPlayerChangedName(keys)
  DebugPrint('[ZIV] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function ZIV:OnPlayerLearnedAbility( keys)
  DebugPrint('[ZIV] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function ZIV:OnAbilityChannelFinished(keys)
  DebugPrint('[ZIV] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function ZIV:OnPlayerLevelUp(keys)
  DebugPrint('[ZIV] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function ZIV:OnLastHit(keys)
  DebugPrint('[ZIV] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function ZIV:OnTreeCut(keys)
  DebugPrint('[ZIV] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function ZIV:OnRuneActivated (keys)
  DebugPrint('[ZIV] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function ZIV:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[ZIV] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function ZIV:OnPlayerPickHero(keys)
  DebugPrint('[ZIV] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function ZIV:OnTeamKillCredit(keys)
  DebugPrint('[ZIV] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function ZIV:OnEntityKilled( keys )
  DebugPrint( '[ZIV] OnEntityKilled Called' )
  DebugPrintTable( keys )

  ZIV:_OnEntityKilled( keys )
  

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  local attackerUnit = EntIndexToHScript( keys.entindex_attacker )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- The ability/item used to kill, or nil if not killed by an item/ability
  local killerAbility = nil

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless

  -- Killcam nuke
  if killedUnit:IsRealHero() then
    Timers:CreateTimer(0.03, function (  )
      PlayerResource:GetPlayer(killedUnit:GetPlayerOwnerID()):SetKillCamUnit(nil)
    end)
  end

  -- Loot and EXP
  if killedUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS and killedUnit:HasLoot() and attackerUnit:GetPlayerOwnerID() ~= -1 then
    Loot:Generate( killedUnit, attackerUnit )

    if killedUnit:IsBoss() then
      Account:AddBossEXP( attackerUnit:GetPlayerOwnerID() )
    else
      Account:AddCreepEXP( attackerUnit:GetPlayerOwnerID() )
    end
  end

  -- Hardcoded callback
  if killedUnit.on_kill then killedUnit:on_kill() end

  if killedUnit._OnDiedCallbacks then
    for k,v in pairs(killedUnit._OnDiedCallbacks) do
      v()
    end
  end

  -- Customly attached particles
  if killedUnit.particles then
    for k,v in pairs(killedUnit.particles) do
      ParticleManager:DestroyParticle(v, false)
    end
  end

  -- Count creeps
  if killedUnit.pack then
    Director.current_session_creep_count = Director.current_session_creep_count - 1
  end

  -- Cleanup wearables
  Timers:CreateTimer(6.0, function ()
    Wearables:RemoveTemporaryWearables( killedUnit )
  end)

  -- Deathsim particle and death sound
  local kv = ZIV.UnitKVs[killedUnit:GetUnitName()]

  if kv then
    if kv["deathsim"] then
      killedUnit:AddNoDraw()
      local dummy = CreateUnitByName("npc_dummy_unit",killedUnit:GetAbsOrigin(),false,killedUnit:GetOwnerEntity(),killedUnit:GetOwnerEntity(),killedUnit:GetTeamNumber())
      TimedEffect( kv["deathsim"], dummy, 4.0, 0 )
    end
    if kv["deathsound"] then
      EmitSoundOnLocationWithCaster(killedUnit:GetAbsOrigin(),"Building_DireTower.Destruction",killerEntity)
    end
  end
end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function ZIV:PlayerConnect(keys)
  DebugPrint('[ZIV] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function ZIV:OnConnectFull(keys)
  DebugPrint('[ZIV] OnConnectFull')
  DebugPrintTable(keys)

  ZIV:_OnConnectFull(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function ZIV:OnIllusionsCreated(keys)
  DebugPrint('[ZIV] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function ZIV:OnItemCombined(keys)
  DebugPrint('[ZIV] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function ZIV:OnAbilityCastBegins(keys)
  DebugPrint('[ZIV] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function ZIV:OnTowerKill(keys)
  DebugPrint('[ZIV] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function ZIV:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[ZIV] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function ZIV:OnNPCGoalReached(keys)
  DebugPrint('[ZIV] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function ZIV:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  local playerID = self.vUserIds[userID]:GetPlayerID()

  local text = keys.text
end

function ZIV:OnDragItemToWorld( keys )
  local unit = EntIndexToHScript(keys.unit)
  local item = EntIndexToHScript(keys.itemID)
  local position = Vector(keys.position["0"], keys.position["1"], keys.position["2"])

  PrintTable(keys)

  unit:DropItemAtPosition(position, item)
end

function ZIV:WriteToNettable( keys )
  local name = keys.name
  local key = keys.key
  local value = keys.value
  local api = keys.api or "CustomNetTables"

  if api ~= "CustomNetTables" then
    PlayerTables:SetTableValue( name, key, value )
  else
    CustomNetTables:SetTableValue( name, key, value )
  end
end