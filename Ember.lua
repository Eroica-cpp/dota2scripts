local Ember = {}

Ember.fistChainCombo = Menu.AddOption({"Hero Specific", "Ember Spirit"}, "fist & chain combo", "On/Off")

function Ember.OnUpdate()

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_ember_spirit" then return end
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	local chain = NPC.GetAbilityByIndex(myHero, 0)
	local fist = NPC.GetAbilityByIndex(myHero, 1)
	
	local myMana = NPC.GetMana(myHero)
	local chain_radius = 400

	-- fist and chain combo
	if Menu.IsEnabled(Ember.fistChainCombo) 
		and NPC.HasModifier(myHero, "modifier_ember_spirit_sleight_of_fist_caster") 
		and Ability.IsCastable(chain, myMana) then

		local enemyAround = NPC.GetHeroesInRadius(myHero, chain_radius, Enum.TeamType.TEAM_ENEMY)
		if #enemyAround > 0 then
			Ability.CastNoTarget(chain)
		end

	end
end

return Ember