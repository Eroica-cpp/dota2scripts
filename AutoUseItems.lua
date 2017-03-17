local AutoUseItems = {}

AutoUseItems.optionQuellingBlade = Menu.AddOption({"Item Specific"}, "Quelling Blade", "Auto use quelling blade to deward")
AutoUseItems.optionIronTalon = Menu.AddOption({"Item Specific"}, "Iron Talon", "Auto use iron talen to remove HP and deward")

function AutoUseItems.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end

    if Menu.IsEnabled(AutoUseItems.optionQuellingBlade) then
    	AutoUseItems.item_quelling_blade(myHero)
    end

    if Menu.IsEnabled(AutoUseItems.optionIronTalon) then
    	AutoUseItems.item_iron_talon(myHero)
    end

end

-- auto use iron talon to remove HP and deward
function AutoUseItems.item_iron_talon(myHero)
	if not NPC.HasItem(myHero, "item_iron_talon", true) then return end
	local item = NPC.GetItem(myHero, "item_iron_talon", true)
	if not Ability.IsCastable(item, 0) then return end
	
	-- deward
	local castRange_deward = 450
	local wards = NPC.GetUnitsInRadius(myHero, castRange_deward, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(wards) do
		if NPC.GetUnitName(npc) == "npc_dota_observer_wards" or NPC.GetUnitName(npc) == "npc_dota_sentry_wards" then
			Ability.CastTarget(item, npc)
			return
		end
	end

	-- remove HP
	local castRange_removeHP = 350
	local creeps = NPC.GetUnitsInRadius(myHero, castRange_removeHP, Enum.TeamType.TEAM_ENEMY)
	if not creeps or #creeps <= 0 then return end

	local maxHp = 0
	local target = nil
	for i, npc in ipairs(creeps) do
		local tmpHp = Entity.GetHealth(npc)
		local ratio = 0.5
		if tmpHp > maxHp and NPC.IsCreep(npc) 
			and (not NPC.IsAncient(npc)) and (not NPC.IsRoshan(npc)) 
			and tmpHp > ratio*Entity.GetMaxHealth(npc) then
			maxHp = tmpHp
			target = npc
		end
	end

	if target then Ability.CastTarget(item, target) end
end

-- auto use quelling_blade to deward
function AutoUseItems.item_quelling_blade(myHero)
	if not NPC.HasItem(myHero, "item_quelling_blade", true) then return end
	local item = NPC.GetItem(myHero, "item_quelling_blade", true)
	if not Ability.IsCastable(item, 0) then return end

	local cast_range = 450
	local units = NPC.GetUnitsInRadius(myHero, cast_range, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(units) do
		if NPC.GetUnitName(npc) == "npc_dota_observer_wards" or NPC.GetUnitName(npc) == "npc_dota_sentry_wards" then
			Ability.CastTarget(item, npc)
			return
		end
	end

end
return AutoUseItems