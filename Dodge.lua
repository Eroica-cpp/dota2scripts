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

function Dodge.Defend(myHero)
	if not myHero then return end
	local myMana = NPC.GetMana(myHero)

	if NPC.GetUnitName(myHero) == "npc_dota_hero_life_stealer" then
		local rage = NPC.GetAbilityByIndex(myHero, 0)
		if rage and Ability.IsCastable(rage, myMana) then
			Ability.CastNoTarget(rage)
		end
	end
	
end

return Dodge