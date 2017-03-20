local Spectre = {}

Spectre.optionDagger = Menu.AddOption({"Hero Specific", "Spectre"}, "Auto Dagger", "Auto cast dagger for life steal")
Spectre.optionHaunt = Menu.AddOption({"Hero Specific", "Spectre"}, "Auto Haunt", "Auto haunt if can kill")

function Spectre.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_spectre" then return end
	
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	if Menu.IsEnabled(Spectre.optionDagger) then
		Spectre.AutoDagger(myHero)
	end

	if Menu.IsEnabled(Spectre.optionHaunt) then
		Spectre.AutoHaunt(myHero)
	end
end

-- auto dagger for life steal
function Spectre.AutoDagger(myHero)
	if not myHero then return end
	local dagger = NPC.GetAbilityByIndex(myHero, 0)
	if not dagger or not Ability.IsCastable(dagger, NPC.GetMana(myHero)) then return end

	local level = Ability.GetLevel(dagger)
	local damage = 50 * level

	local range = 2000
	local enemyAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyAround) do
		if not NPC.IsIllusion(enemy) and NPC.IsKillable(enemy) 
			and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy)
			and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
			
			local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
			if Entity.GetHealth(enemy) <= true_damage then
				Ability.CastTarget(dagger, enemy)
			end
		end
	end
end

-- auto haunt if can kill, then haunt back
function Spectre.AutoHaunt(myHero)
end

return Spectre