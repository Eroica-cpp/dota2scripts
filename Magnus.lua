local Utility = require("Utility")

local Magnus = {}

Magnus.optionEmpower = Menu.AddOption({"Hero Specific", "Magnus"}, "Auto Empower", "auto cast empower on allies or magnus himself")
Magnus.optionBlinkHelper = Menu.AddOption({"Hero Specific", "Magnus"}, "Blink Helper", "Auto blink to best position before casting RP")

-- blink to best position before RP
function Magnus.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Magnus.optionBlinkHelper) then return true end
	if not orders or not orders.ability then return true end

	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "magnataur_reverse_polarity" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) then return true end

    if not NPC.HasItem(myHero, "item_blink", true) then return true end
    local blink = NPC.GetItem(myHero, "item_blink", true)
    if not blink or not Ability.IsCastable(blink, 0) then return true end

    local RP_radius = 410
    local blink_radius = 1200

    local enemyHeroes = NPC.GetHeroesInRadius(myHero, blink_radius, Enum.TeamType.TEAM_ENEMY)
    if not enemyHeroes or #enemyHeroes <= 0 then return true end

    local pos = Utility.BestPosition(enemyHeroes, RP_radius)
    if pos then
    	Ability.CastPosition(blink, pos)
    end

    return true
end

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

	-- avoid casting empower right before ultimate
	local enemiesAround = NPC.GetHeroesInRadius(myHero, 450, Enum.TeamType.TEAM_ENEMY)
	if enemiesAround and #enemiesAround > 0 then return end

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