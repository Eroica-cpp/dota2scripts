local AutoFarm = {}

AutoFarm.optionEnabled = Menu.AddOption({"Utility","Auto Farm"},"Auto Farm", "auto farm lane creep or neutral creep")
AutoFarm.key = Menu.AddKeyOption({ "Utility", "Auto Farm" }, "Turn On/Off Key", Enum.ButtonCode.KEY_T)
AutoFarm.font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

local shouldGoFarm = false

function AutoFarm.OnUpdate()
	if Menu.IsEnabled(AutoFarm.optionEnabled) and Menu.IsKeyDownOnce(AutoFarm.key) then
		shouldGoFarm = not shouldGoFarm
	end
end

function AutoFarm.OnDraw()
	if not Menu.IsEnabled(AutoFarm.optionEnabled) then return end
	if not shouldGoFarm then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	for i = 1, NPCs.Count() do
		local npc = NPCs.Get(i)
		-- Log.Write(tostring(NPC.GetUnitName(npc)) .. " " .. tostring(Entity.GetOwner(npc)) .. " " .. tostring(Entity.OwnedBy(npc, myHero)))
		if npc and npc ~= myHero and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
			goFarm(npc)
		end
	end

end

function goFarm(npc)
	if not npc or not Entity.IsAlive(npc) then return end

	-- draw when farming key up
	local pos = NPC.GetAbsOrigin(npc)
	local x, y, visible = Renderer.WorldToScreen(pos)
	Renderer.SetDrawColor(0, 255, 0, 255)
	Renderer.DrawTextCentered(AutoFarm.font, x, y, "Auto", 1)

	local myPlayer = Players.GetLocal()
	if not myPlayer then return end

	-- local attackRange = NPC.GetAttackRange(npc)

	-- attack enemy hero if possible
	local heroRadius = 500
	local enemyHeroesAround = NPC.GetHeroesInRadius(npc, heroRadius, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyHeroesAround) do
		if enemy 
			and Entity.IsAlive(enemy) 
			and not Entity.IsDormant(enemy) 
			and NPC.IsKillable(enemy)
			then
			Player.AttackTarget(myPlayer, npc, enemy, true)
			return
		end
	end	

	local creepRadius = 1200
	local unitsAround = NPC.GetUnitsInRadius(npc, creepRadius, Enum.TeamType.TEAM_BOTH)
	-- last hit
	for i, creep in ipairs(unitsAround) do
		local physicalDamage = NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(creep)
		if Entity.IsAlive(creep) 
			and not Entity.IsDormant(creep) 
			and not Entity.IsSameTeam(npc, creep) 
			and NPC.IsKillable(creep)
			and Entity.GetHealth(creep) <= physicalDamage
			then
			Player.AttackTarget(myPlayer, npc, creep, true)
			return
		end
	end

	-- hit creeps (not last hit)
	for i, creep in ipairs(unitsAround) do
		local physicalDamage = NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(creep)
		if Entity.IsAlive(creep) 
			and not Entity.IsDormant(creep) 
			and not Entity.IsSameTeam(npc, creep) 
			and NPC.IsKillable(creep)
			and Entity.GetHealth(creep) > 2 * physicalDamage
			then
			Player.AttackTarget(myPlayer, npc, creep, true)
			return			
		end
	end

	-- auto follow friend hero or creep
	for i, creep in ipairs(unitsAround) do
		if Entity.IsSameTeam(npc, creep) 
			and Entity.IsAlive(creep) 
			and (NPC.IsCreep(creep) or NPC.IsHero(creep))
			and creep ~= Heroes.GetLocal() 
			then
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET, creep, Vector(0,0,0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
			return
		end
	end

end

-- 0.02s delay works good for me
local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return AutoFarm