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
		local radius = 150
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

end

return Dodge