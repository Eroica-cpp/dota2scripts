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

	local maxDamage = 0

	local num = #enemies
	for i = 1, num do
		for j = i, num do
			if enemies[i] and enemies[j] then
				local vec1 = NPC.GetAbsOrigin(enemies[i])
				local vec2 = NPC.GetAbsOrigin(enemies[j])
				local mid = (vec1 + vec2):Scaled(0.5)

				local damage = Legion.GetOverwhelmingDamage(myHero, overwhelming, mid)
				maxDamage = math.max(damage, maxDamage)
			end
		end
	end

	Log.Write("maxDamage: " .. maxDamage)
end

function Legion.GetOverwhelmingDamage(myHero, overwhelming, pos)
	if not overwhelming or not pos then return 0 end

	local level = Ability.GetLevel(overwhelming)
	if level <= 0 then return 0 end

	local damage_base = 40 + 20 * (level - 1)
	local damage_per_creep = 14 + 4 * (level - 1)
	local damage_per_hero = 30 * level
	
	local res = damage_base

	local radius = 330
	local enemies = NPCs.InRadius(pos, radius, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemies) do
		if NPC.IsHero(enemy) and not NPC.IsIllusion(enemy) then
			res = res + damage_per_hero
		else
			res = res + damage_per_creep
		end
	end

	return res
end

return Legion