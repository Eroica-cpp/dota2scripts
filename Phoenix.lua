-- ==================================
-- File Name : Phoenix.lua
-- Author    : Eroica
-- Version   : 3.0
-- Date      : 2017.5.12
-- ==================================

local Phoenix = {}

Phoenix.optionFireSpirit = Menu.AddOption({"Hero Specific","Phoenix"},"Auto Fire Spirit", "auto cast fire spirit while diving if enabled")
Phoenix.optionSunRay = Menu.AddOption({"Hero Specific","Phoenix"},"Sun Ray Helper", "sun ray sticks to nearest hero to cursor (ally or enemy)")

function Phoenix.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Phoenix.optionFireSpirit) then return true end
	if not orders or not orders.ability then return true end
	if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

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
    		Ability.CastPosition(launch_fire_spirit, Entity.GetAbsOrigin(enemy))
    	end
    end

    return true
end

function Phoenix.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_phoenix" then return end

	if Menu.IsEnabled(Phoenix.optionFireSpirit) then
		Phoenix.FireSpirit(myHero)
	end

	if Menu.IsEnabled(Phoenix.optionSunRay) then
		Phoenix.SunRay(myHero)
	end

end

function Phoenix.SunRay(myHero)
	if not NPC.HasModifier(myHero, "modifier_phoenix_sun_ray") then return end

	local npc = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
	if not npc then return end

	local pos = Entity.GetAbsOrigin(npc)
	local vec1 = Entity.GetRotation(myHero):GetForward()
	local vec2 = pos - Entity.GetAbsOrigin(myHero)
	local cos_theta = vec1:Dot(vec2) / (vec1:Length() * vec2:Length())

	-- make sure dont rotate too rapidly
	if cos_theta <= math.sqrt(2)/2 then return end

	Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, npc, pos, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

function Phoenix.FireSpirit(myHero)
	local dive = NPC.GetAbilityByIndex(myHero, 0)
	local fireSpirit = NPC.GetAbilityByIndex(myHero, 1)

	if not Ability.IsCastable(fireSpirit, NPC.GetMana(myHero)) or not Ability.IsInAbilityPhase(dive) then return end

	for i = 1, Heroes.Count() do
		local npc = Heroes.Get(i)
		if not NPC.IsIllusion(npc) and not Entity.IsSameTeam(npc, myHero) then
			
			local enemyPos = Entity.GetAbsOrigin(npc)
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