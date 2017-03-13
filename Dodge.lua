local Dodge = {}

Dodge.option = Menu.AddOption({"Utility", "Dodge Spells and Items"}, "Dodge Projectile", "On/Off")

function Dodge.OnProjectile(projectile)
	if not Menu.IsEnabled(Dodge.option) then return end
	if not projectile.source or not projectile.target then return end
	if not projectile.dodgeable then return end
	if not Entity.IsHero(projectile.source) then return end

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
	-- Log.Write(animation.sequenceName)
end

function Dodge.Defend(myHero)
	if not myHero then return end
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