local Dodge = {}

Dodge.option = Menu.AddOption({"Utility", "Dodge Spells and Items"}, "Dodge Projectile", "On/Off")

function Dodge.OnProjectile(projectile)
	if not Menu.IsEnabled(Dodge.option) then return end
	if not projectile.source or not projectile.target then return end
	if not projectile.dodgeable then return end
	if not Entity.IsHero(projectile.source) then return end
	if projectile.isAttack then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	if projectile.target ~= myHero then return end
	if Entity.IsSameTeam(projectile.source, projectile.target) then return end

	Dodge.Defend(myHero)
end

function Dodge.OnLinearProjectileCreate(projectile)
	if not Menu.IsEnabled(Dodge.option) then return end
	-- Log.Write(projectile.name)
end

function Dodge.OnUnitAnimation(animation)
	if not Menu.IsEnabled(Dodge.option) then return end
	if not animation or not animation.unit then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	Log.Write(animation.sequenceName .. " " .. NPC.GetUnitName(animation.unit))

	-- 1. anti-mage's mana void
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_antimage" then
		local radius = 600 + 500/2
		if animation.sequenceName == "basher_cast4_mana_void_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 2. bane's nightmare and fiend's grip
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_bane" then
		local radius1 = 825
		if animation.sequenceName == "nightmare" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			Dodge.Defend(myHero)
		end

		local radius2 = 800
		if animation.sequenceName == "fiends_grip_cast" and NPC.IsEntityInRange(myHero, animation.unit, radius2) then
			Dodge.Defend(myHero)
		end		
	end	

	-- 3. batrider's lasso
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_batrider" then
		local radius = 200
		if animation.sequenceName == "lasso_start_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Log.Write("12341231")
			Dodge.Defend(myHero)
		end
	end	

	-- slardar's crush
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_slardar" then
		local radius = 350
		if animation.sequenceName == "crush_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end
		
	-- centaur's stomp
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_centaur" then
		local radius = 315
		if animation.sequenceName == "cast_hoofstomp_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- legion's duel
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_legion_commander" then
		local radius = 300
		if animation.sequenceName == "dualwield_legion_commander_duel_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- magnus's rp
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_magnataur" then
		local radius = 410
		if animation.sequenceName == "polarity_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- void's chrono
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_faceless_void" then
		local radius = 600 + 425/2
		if animation.sequenceName == "chronosphere_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- engima's black hole
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_enigma" then
		local radius = 275 + 420/2
		if animation.sequenceName == "cast4_black_hole_chasm" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- warlock's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_warlock" then
		local radius = 1200 + 600/2
		if animation.sequenceName == "warlock_cast4_rain_chaos_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- doom
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_doom_bringer" then
		local radius = 550
		if animation.sequenceName == "cast_doom" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- lion's finger
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lion" then
		local radius = 900
		if animation.sequenceName == "finger_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- lina's laguna blade
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lina" then
		local radius = 725
		if animation.sequenceName == "laguna_blade_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- luna's lucent
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_luna" then
		local radius = 800
		if animation.sequenceName == "moonfall_cast1_lucent_beam_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- tinker's laser
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_tinker" then
		local radius = 725 + 220
		if animation.sequenceName == "laser_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

end

function Dodge.Defend(myHero)
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
		local cast_range = 700 
		local enemyUnits = NPC.GetUnitsInRadius(myHero, cast_range, Enum.TeamType.TEAM_ENEMY)
		if fist and Ability.IsCastable(fist, myMana) and #enemyUnits > 0 then
			local pos = nil
			for i, enemy in ipairs(enemyUnits) do pos = NPC.GetAbsOrigin(enemy) end
			
			if pos and NPC.IsPositionInRange(myHero, pos, cast_range, 0) then 
				Ability.CastPosition(fist, pos) 
			end
		end
	end

end

return Dodge