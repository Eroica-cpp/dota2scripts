-- ==================================
-- File Name : Phoenix.lua
-- Author    : Eroica
-- Version   : 2.0
-- Date      : 2017.3.21
-- ==================================

local Phoenix = {}

Phoenix.optionFireSpirit = Menu.AddOption({"Hero Specific","Phoenix"},"Auto Fire Spirit", "auto cast fire spirit while diving if enabled")

local msg_queue = {}

function Phoenix.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Phoenix.optionFireSpirit) then return true end
	if not orders or not orders.ability then return true end

	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "phoenix_supernova" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return true end

    local fire_spirit = NPC.GetAbility(myHero, "phoenix_fire_spirits")
    local launch_fire_spirit = NPC.GetAbility(myHero, "phoenix_launch_fire_spirit")
    local supernova = NPC.GetAbility(myHero, "phoenix_supernova")
	
	local manaCost_supernova = Ability.GetManaCost(supernova)
	local myMana = NPC.GetMana(myHero)

	if Ability.IsCastable(fire_spirit, myMana-manaCost_supernova) then
		Ability.CastNoTarget(fire_spirit)
	end

	if not Ability.IsCastable(launch_fire_spirit, 0) then return true end
	if not Ability.IsCastable(supernova, myMana) then return true end
    
    local range = 1400
    local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    for i, enemy in ipairs(enemyHeroes) do
    	if Ability.IsCastable(launch_fire_spirit, myMana) then
    		Ability.CastPosition(launch_fire_spirit, NPC.GetAbsOrigin(enemy))
    	end
    end

    return true
end

function Phoenix.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_phoenix" then return end

	if Menu.IsEnabled(Phoenix.optionFireSpirit) then
		Phoenix.AutoFireSpirit(myHero)
	end

end

function Phoenix.AutoFireSpirit(myHero)
	
	local dive = NPC.GetAbilityByIndex(myHero, 0)
	local fireSpirit = NPC.GetAbilityByIndex(myHero, 1)

	if not Ability.IsCastable(fireSpirit, NPC.GetMana(myHero)) or not Ability.IsInAbilityPhase(dive) then return end

	for i = 1, Heroes.Count() do
		local npc = Heroes.Get(i)
		if not NPC.IsIllusion(npc) and not Entity.IsSameTeam(npc, myHero) then
			
			local enemyPos = NPC.GetAbsOrigin(npc)
			if not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsEntityInRange(npc, myHero, Ability.GetCastRange(fireSpirit)) then
				Ability.CastPosition(fireSpirit, enemyPos)
				sleep(0.01)
			end
		end
	end
end

local clock = os.clock
function sleep(n)  -- seconds
	local t0 = clock()
	while clock() - t0 <= n do end
end

return Phoenix