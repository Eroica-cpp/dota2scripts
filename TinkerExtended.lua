local TinkerExtended = {}

TinkerExtended.AutoLaser = Menu.AddOption({"Hero Specific", "Tinker"}, "Auto Laser for KS", "")
TinkerExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function TinkerExtended.OnUpdate()

	if not Menu.IsEnabled( TinkerExtended.AutoLaser ) then return end
	if not GameRules.GetGameState() == 5 then return end

	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end

	local manaPoint = NPC.GetMana(myHero)

	local laser = NPC.GetAbilityByIndex(myHero, 0)
	local lens = NPC.GetItem(myHero, "item_aether_lens", true)
	local laser_cast_range = 650 -- didnt consider tinker's extra 75 cast range talent in level 20

	if lens then
		laser_cast_range = laser_cast_range + 220
	end

	-- TEST CODE
	local pos = NPC.GetAbsOrigin(myHero)
	local x, y, visible = Renderer.WorldToScreen(pos)
	local text = "TEST!!!"
	Renderer.SetDrawColor(255, 255, 0, 255)
	-- Renderer.DrawTextCentered(TinkerExtended.font, x, y, text, 1)
	-- TEST CODE

	for n, npc in pairs(NPC.GetHeroesInRadius(myHero, laser_cast_range, Enum.TeamType.TEAM_ENEMY)) do
		
		if Entity.IsHero(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
		
			local laserLevel = Ability.GetLevel(laser)
			local laserDmg = 80 * laserLevel
			-- Renderer.DrawTextCentered(TinkerExtended.font, x, y, laserLevel, 1)
			if Entity.GetHealth(npc) < laserDmg and Ability.IsCastable(laser, manaPoint) then
				Ability.CastTarget(laser, npc)
			end
		
		end

	end

end

return TinkerExtended