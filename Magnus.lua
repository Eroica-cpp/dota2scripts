local Magnus = {}

Magnus.optionEmpower = Menu.AddOption({"Hero Specific", "Magnus"}, "Auto Empower", "auto cast empower on allies or magnus himself")

function Magnus.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_magnataur" then return end
	
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.IsChannellingAbility(myHero) then return end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	if Menu.IsEnabled(Magnus.optionEmpower) then
		Magnus.AutoEmpower(myHero)
	end
end

-- auto cast empower on himself or needed ally heroes
-- priority: magnus -> melee ally hero -> ranged ally hero
function Magnus.AutoEmpower(myHero)
	local empower = NPC.GetAbilityByIndex(myHero, 1)
	if not empower or not Ability.IsCastable(empower, NPC.GetMana(myHero)) then return end

	if not NPC.HasModifier(myHero, "modifier_magnataur_empower") then
		Ability.CastTarget(empower, myHero)
		return
	end

	local range = 800
	local alliesAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
	if not alliesAround or #alliesAround <= 0 then return end

	-- for melee ally hero
	for i, ally in ipairs(alliesAround) do
		if not NPC.HasModifier(ally, "modifier_magnataur_empower") 
			and not NPC.IsIllusion(ally) and not NPC.IsRanged(ally) then
			Ability.CastTarget(empower, ally)
			return
		end
	end

	-- for range ally hero
	for i, ally in ipairs(alliesAround) do
		if not NPC.HasModifier(ally, "modifier_magnataur_empower") and not NPC.IsIllusion(ally) then
			Ability.CastTarget(empower, ally)
			return
		end
	end
end

return Magnus