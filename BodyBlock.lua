local Block = {}

Block.option = Menu.AddOption({"Utility","Body Block"},"Body Block", "auto block creep or hero when key is down")
Block.key = Menu.AddKeyOption({ "Utility", "Body Block" }, "Turn On/Off Key", Enum.ButtonCode.KEY_4)
Block.font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

local shouldBlock = false

function Block.OnUpdate()
	if not Menu.IsEnabled(Block.option) then return end
	if not shouldBlock then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local radius = 300
	local units = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_BOTH)
	local target
	if units then target = units[1] end
	if not target then return end

	Log.Write(NPC.GetUnitName(target))

end

function Block.OnDraw()
	if not Menu.IsEnabled(Block.option) then return end

	if Menu.IsKeyDownOnce(Block.key) then
		shouldBlock = not shouldBlock
	end

	if not shouldBlock then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local pos = Entity.GetAbsOrigin(myHero)
	local x, y, visible = Renderer.WorldToScreen(pos)
	local delta = 30
	Renderer.SetDrawColor(0, 255, 0, 255)
	Renderer.DrawTextCentered(Block.font, x, y+delta, "Block", 1)

end

return Block