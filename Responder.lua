local Responder = {}

function Responder.Defend(myHero)
	if not myHero then return end
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	local myMana = NPC.GetMana(myHero)

	-- life stealer's rage
	if NPC.GetUnitName(myHero) == "npc_dota_hero_life_stealer" then
		local rage = NPC.GetAbilityByIndex(myHero, 0)
		if rage and Ability.IsCastable(rage, myMana) then
			Ability.CastNoTarget(rage)
		end
	end

	-- juggernaut's spin
	if NPC.GetUnitName(myHero) == "npc_dota_hero_juggernaut" then
		local spin = NPC.GetAbilityByIndex(myHero, 0)
		if spin and Ability.IsCastable(spin, myMana) then
			Ability.CastNoTarget(spin)
		end
	end

	-- weaver's shukuchi
	if NPC.GetUnitName(myHero) == "npc_dota_hero_weaver" then
		local shukuchi = NPC.GetAbilityByIndex(myHero, 1)
		if shukuchi and Ability.IsCastable(shukuchi, myMana) then
			Ability.CastNoTarget(shukuchi)
		end
	end

	-- omni's repel
	if NPC.GetUnitName(myHero) == "npc_dota_hero_omniknight" then
		local repel = NPC.GetAbilityByIndex(myHero, 1)
		if repel and Ability.IsCastable(repel, myMana) then
			Ability.CastTarget(repel, myHero)
		end
	end

	-- slark's dark pact
	if NPC.GetUnitName(myHero) == "npc_dota_hero_slark" then
		local pact = NPC.GetAbilityByIndex(myHero, 0)
		if pact and Ability.IsCastable(pact, myMana) then
			Ability.CastNoTarget(pact)
		end
	end

	-- ember's fist (T)
	if NPC.GetUnitName(myHero) == "npc_dota_hero_ember_spirit" then
		local fist = NPC.GetAbilityByIndex(myHero, 1)
		local level = Ability.GetLevel(fist)
		local cast_range = 700 
		local radius = level > 0 and 250+100*(level-1) or 0
		local enemyUnits = NPC.GetUnitsInRadius(myHero, cast_range, Enum.TeamType.TEAM_ENEMY)
		if fist and Ability.IsCastable(fist, myMana) and #enemyUnits > 0 then
			local pos = Utility.BestPosition(enemyUnits, radius)
			
			if pos and NPC.IsPositionInRange(myHero, pos, cast_range, 0) then 
				Ability.CastPosition(fist, pos) 
			end
		end
	end

end

return Responder