-- ==================================
-- File Name : Phoenix.lua
-- Author    : Eroica
-- Version   : 1.0
-- Date      : 2017.2.17
-- ==================================

local Phoenix = {}

Phoenix.optionEnabled = Menu.AddOption({"Hero Specific","Phoenix"},"Auto Fire Spirit", "auto cast fire spirit when enabled")

enemyPosList = {}

function Phoenix.OnUpdate()

	if not Menu.IsEnabled(Phoenix.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_phoenix" then return end
	local myMana = NPC.GetMana(myHero)

	local dive = NPC.GetAbilityByIndex(myHero, 0)
	local fireSpirit = NPC.GetAbilityByIndex(myHero, 1)
	local fireSpiritLevel = Ability.GetLevel(fireSpirit)
	local radius = 3000

	if fireSpiritLevel <= 0 or (not Ability.IsInAbilityPhase(dive)) then return end

	local unitsAround = NPC.GetHeroesInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)

	for i, enemy in ipairs(unitsAround) do
		local enemyPos = NPC.GetAbsOrigin(enemy)
		if Ability.IsCastable(fireSpirit, myMana) and not enemyPosList[enemyPos] then
			Ability.CastPosition(fireSpirit, enemyPos)
			enemyPosList[enemyPos] = true
		end
	end

end

return Phoenix