-- unit.fortify_modifiers["itemname"] = {MODIFIER_NAME = 1}
-- item.fortify_modifiers = {{MODIFIER_NAME = 1}, {MODIFIER_NAME = 2}}
-- item.built_in_modifiers = {MODIFIER_NAME = 1, MODIFIER_NAME = 2}

function CheckSlot( unit, slot )
	local modifierCount = unit:GetModifierCount()
	for i=0,modifierCount do
		local modifier = unit:GetModifierNameByIndex(i)
		if modifier then
			if string.match(modifier, "_equipped_"..slot) then
				unit:RemoveModifierByName(modifier)
				UnEquip( unit, modifier )
				break
			end
		end
	end
end

function UnEquip( unit, buffName )
	if string.match(buffName, "_equipped_") then
    	unit:RemoveModifierByName(buffName)
    	print(buffName)

    	local itemName = string.gsub (string.gsub (buffName, "modifier", "item"), "_equipped_%a+", "")

    	local new_item = CreateItem(itemName, unit, unit)
    	ZIV.INVENTORY[unit:GetPlayerOwnerID()]:AddItem(new_item)

    	if unit.fortify_modifiers and unit.fortify_modifiers[itemName] and unit:HasAbility("ziv_passive_hero") then
			for id,gem_table in pairs(unit.fortify_modifiers[itemName]) do
				for k,v in pairs(gem_table) do
					if unit:HasModifier(k) then
						if unit:HasModifier(k) == false then
							unit:FindAbilityByName("ziv_passive_hero"):ApplyDataDrivenModifier(unit,unit,k,{})
						end

						local new_count = unit:GetModifierStackCount(k, unit) - v
						unit:SetModifierStackCount(k, unit, new_count)
						if new_count <= 0 then
							unit:RemoveModifierByName(k)
						end
					end
				end
			end

			new_item.fortify_modifiers = unit.fortify_modifiers[itemName]
			unit.fortify_modifiers[itemName] = nil
		end
  	end
end

function Equip( keys )
	local caster = keys.caster
	local ability = keys.ability

	local itemName = ability:GetName()

	CheckSlot( caster, ZIV.ItemKVs[itemName]["Slot"] )

	for i=1,2 do
		local custom_skill = ZIV.ItemKVs[itemName]["CustomSkill"..tostring(i)]
		if custom_skill then
			for k,v in pairs(custom_skill) do
				caster:RemoveAbility(k)
				caster:AddAbility(v):UpgradeAbility(true)
			end
		end
	end

	if ability.fortify_modifiers and caster:HasAbility("ziv_passive_hero") then
		local fortify_modifiers_ability = caster:FindAbilityByName("ziv_passive_hero")

		for id,gem_table in pairs(ability.fortify_modifiers) do
			for k,v in pairs(gem_table) do
				if k ~= "gem" then
					if caster:HasModifier(k) then
						caster:SetModifierStackCount(k, caster, v + caster:GetModifierStackCount(k, caster))
					else
						fortify_modifiers_ability:ApplyDataDrivenModifier(caster, caster, k, {})
						caster:SetModifierStackCount(k, caster, v)
					end
				end
			end
		end

		caster.fortify_modifiers = caster.fortify_modifiers or {}
		caster.fortify_modifiers[itemName] = ability.fortify_modifiers
	end

	Timers:CreateTimer(0.03, function (  )
      	UTIL_Remove(ability)
    end)
end

-- Equipping
function ZIV:OnBuffClicked(keys)
  	local playerID = keys.pID
  	local unit = EntIndexToHScript(keys.entityID)
  	local buffName = keys.buffName

  	UnEquip( unit, buffName )
end

-- Fortifying equipment
function ZIV:OnFortify( keys )
  	local playerID = keys.pID
  	local item = EntIndexToHScript(keys.item)
  	local tool = EntIndexToHScript(keys.tool)

  	local toolKV = ZIV.ItemKVs[tool:GetName()]

  	item.fortify_modifiers = item.fortify_modifiers or {}

  	local new_modifiers = GetRandomFortifyModifiers( toolKV["FortifyModifiers"], tonumber(toolKV["FortifyModifiersCount"]) or 0 )
  	new_modifiers["gem"] = tool:GetName()
  	
  	if string.match(tool:GetName(), "rune") and tool.fortify_modifiers then
  		for k,v in pairs(tool.fortify_modifiers) do
  			for k2,v2 in pairs(v) do
  				if k2 ~= "gem" then
  					new_modifiers[k2] = (new_modifiers[k2] or 0) + v2
  				end
  			end
  		end
  	end

  	table.insert(item.fortify_modifiers, new_modifiers)

  	PrintTable(item.fortify_modifiers)

  	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "ziv_fortify_item_result", { item = keys.item, modifiers = new_modifiers } )

  	Crafting:UsePart( tool, 1, tonumber(playerID) )
end

function ZIV:OnFortifyGetModifiers( keys )
  	local playerID = keys.pID
  	local item = EntIndexToHScript(keys.item)

  	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "ziv_fortify_get_modifiers", { item = keys.item, modifiers = (item.fortify_modifiers or {}) } )
end

function GetRandomFortifyModifiers( modifiers_kv, count )
	local modifiers = {}

	if not modifiers_kv or not count then return modifiers end

	for i=1,count do
		local modifier = ""
		local value = 0
		local seed = math.random(1, GetTableLength(modifiers_kv))

		local x = 1
		for modifier_name,modifier_values in pairs(modifiers_kv) do
			if x == seed then
				modifier = modifier_name
				value = math.random(tonumber(modifier_values["min"]), tonumber(modifier_values["max"]))
				break
			end
			x = x + 1
		end
		
		modifiers[modifier] = value
	end

	return modifiers
end