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

	for i = 1, Heroes.Count() do
		local npc = Heroes.Get(i)
		if npc and NPC.IsIllusion(npc) and Entity.GetOwner(myHero) == Entity.GetOwner(npc) then
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

end

-- 0.02s delay works good for me
local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return AutoFarm