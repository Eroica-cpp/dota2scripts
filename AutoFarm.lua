local AutoFarm = {}

AutoFarm.optionEnabled = Menu.AddOption({"Utility","Auto Farm"},"Auto Farm", "auto farm lane creep or neutral creep")
AutoFarm.key = Menu.AddKeyOption({ "Utility", "Auto Farm" }, "Turn On/Off Key", Enum.ButtonCode.KEY_T)
AutoFarm.font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

shouldGoFarm = false

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
			sleep(0.01)

			local pos = NPC.GetAbsOrigin(npc)
			local x, y, visible = Renderer.WorldToScreen(pos)
			Renderer.SetDrawColor(0, 255, 0, 255)
			Renderer.DrawTextCentered(AutoFarm.font, x, y, "Auto", 1)

		end
	end

end

function goFarm(npc)
	if not npc or not Entity.IsAlive(npc) then return end

	Log.Write("Im farming!! " .. tostring(NPC.GetUnitName(npc)))

	local myPlayer = Players.GetLocal()
	if not myPlayer then return end

	local attackRange = NPC.GetAttackRange(npc)
	local enemyHeroesAround = NPC.GetHeroesInRadius(npc, attackRange, Enum.TeamType.TEAM_ENEMY)

	if #enemyHeroesAround > 0 then
		local enemy = enemyHeroesAround[1]
		if enemy then
			Player.AttackTarget(myPlayer, npc, enemy, true)
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