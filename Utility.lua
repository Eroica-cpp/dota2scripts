local Utility = {}

Utility.AncientCreepNameList = {"npc_dota_neutral_black_dragon", "npc_dota_neutral_black_drake", "npc_dota_neutral_granite_golem", "npc_dota_neutral_rock_golem", "npc_dota_neutral_thunderhide", "npc_dota_neutral_rumblehide", "npc_dota_neutral_prowler_shaman", "npc_dota_neutral_prowler_acolyte"}

-- return best position to cast certain spells 
-- eg. axe's call, void's chrono, enigma's black hole
-- input  : unitsAround, radius 
-- return : positon (a vector)
function Utility.BestPosition(unitsAround, radius)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return NPC.GetAbsOrigin(unitsAround[1]) end

	-- find all mid points of every two enemy heroes, 
	-- then find out the best position among these.
	-- O(n^3) complexity
	local maxNum = 1
	local bestPos = NPC.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = NPC.GetAbsOrigin(unitsAround[i])
				local pos2 = NPC.GetAbsOrigin(unitsAround[j])
				local mid = pos1:__add(pos2):Scaled(0.5)
				
				local heroesNum = 0
				for k = 1, enemyNum do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesNum = heroesNum + 1
					end
				end

				if heroesNum > maxNum then
					maxNum = heroesNum
					bestPos = mid
				end

			end
		end
	end

	return bestPos
end

-- return predicted position
function Utility.GetPredictedPosition(npc, delay)
    local pos = NPC.GetAbsOrigin(npc)
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = NPC.GetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

-- return true if is protected by lotus orb or AM's aghs
function Utility.IsLotusProtected(npc)
	if NPC.HasModifier(npc, "modifier_item_lotus_orb_active") then return true end

	local shield = NPC.GetAbility(npc, "antimage_spell_shield")
	if shield and Ability.IsReady(shield) and NPC.HasItem(npc, "item_ultimate_scepter", true) then
		return true
	end

	return false
end

-- situations that can't or no need to cast spell on enemy
function Utility.IsEligibleEnemy(npc)
	-- situations that no need to cast spell
	if NPC.IsIllusion(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStunned(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return false end
	
	-- situations that can't cast spell
	if Entity.IsDormant(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
	
	return true
end

-- situations that ally need to be saved
function Utility.NeedToBeSaved(npc)
	if not npc or NPC.IsIllusion(npc) or not Entity.IsAlive(npc) then return false end
	
	if NPC.IsStunned(npc) or NPC.IsSilenced(npc) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_DISARMED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_PASSIVES_DISABLED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_BLIND) then return true end

	if Entity.GetHealth(npc) <= 0.2 * Entity.GetMaxHealth(npc) then return true end

	return false
end

-- pop all defensive items
function Utility.PopDefensiveItems(myHero)
	if not myHero then return end

    -- blade mail
    if NPC.HasItem(myHero, "item_blade_mail", true) then
    	local item = NPC.GetItem(myHero, "item_blade_mail", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- buckler
    if NPC.HasItem(myHero, "item_buckler", true) then
    	local item = NPC.GetItem(myHero, "item_buckler", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- hood of defiance
    if NPC.HasItem(myHero, "item_hood_of_defiance", true) then
    	local item = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- pipe of insight
    if NPC.HasItem(myHero, "item_pipe", true) then
    	local item = NPC.GetItem(myHero, "item_pipe", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- crimson guard
    if NPC.HasItem(myHero, "item_crimson_guard", true) then
    	local item = NPC.GetItem(myHero, "item_crimson_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- shiva's guard
    if NPC.HasItem(myHero, "item_shivas_guard", true) then
    	local item = NPC.GetItem(myHero, "item_shivas_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- lotus orb
    if NPC.HasItem(myHero, "item_lotus_orb", true) then
    	local item = NPC.GetItem(myHero, "item_lotus_orb", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

    -- mjollnir
    if NPC.HasItem(myHero, "item_mjollnir", true) then
    	local item = NPC.GetItem(myHero, "item_mjollnir", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

end

function Utility.IsAncientCreep(npc)
    if not npc then return false end

    for i, name in ipairs(Utility.AncientCreepNameList) do
        if name and NPC.GetUnitName(npc) == name then return true end
    end

    return false
end

-- -- for test only
-- function Utility.OnUpdate()
--     local myHero = Heroes.GetLocal()
--     if not myHero then return end

--     local npc = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
--     if not npc then return end

--     Log.Write(NPC.GetUnitName(npc) .. " " .. tostring(Utility.IsAncientCreep(npc)))
-- end

return Utility