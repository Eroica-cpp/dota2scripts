local Legion = {}

Legion.optionOverwhelming = Menu.AddOption({"Hero Specific", "Legion Commander"}, "Overwhelming for KS", "Auto cast overwhelming odds for life steal")

function Legion.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_legion_commander" then return end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

    if Menu.IsEnabled(Legion.optionOverwhelming) then
    	Legion.OverwhelmingOdds(myHero)
    end
end

-- auto cast overwhelming odds to best position to KS
function Legion.OverwhelmingOdds(myHero)
	if not myHero then return end

    local overwhelming = NPC.GetAbilityByIndex(myHero, 0)
    if not overwhelming or not Ability.IsCastable(overwhelming, NPC.GetMana(myHero)) then return end

	local range = 1000
	local radius = 330

	local enemies = NPC.GetUnitsInRadius(myHero, range+radius, Enum.TeamType.TEAM_ENEMY)
	if not enemies or #enemies <= 0 then return end

	local num = #enemies
	for i = 1, num do
		for j = i+1, num do
			if enemies[i] and enemies[j] then
				local vec1 = NPC.GetAbsOrigin(enemies[i])
				local vec2 = NPC.GetAbsOrigin(enemies[j])
				local mid = (vec1 + vec2):Scaled(0.5)
			end
		end
	end
end

return Legion