local TinkerExtended = {}

TinkerExtended.AutoLaser = Menu.AddOption({"Hero Specific", "Tinker"}, "Auto Laser for KS", "")
TinkerExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function TinkerExtended.OnDraw()

	if not Menu.IsEnabled( TinkerExtended.AutoLaser ) then return end
	if not GameRules.GetGameState() == 5 then return end

	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end

	local manaPoint = NPC.GetMana(myHero)

	local laser = NPC.GetAbilityByIndex(myHero, 0)
	local missile = NPC.GetAbilityByIndex(myHero, 1)
	local lens = NPC.GetItem(myHero, "item_aether_lens", true)
	local laser_cast_range = 650 -- didnt consider tinker's extra 75 cast range talent in level 20
	local missile_cast_range = 2500
	local magicDamageFactor = 0.75

	if lens then
		laser_cast_range = laser_cast_range + 220
		missile_cast_range = missile_cast_range + 220
	end

	for n, npc in pairs(NPC.GetHeroesInRadius(myHero, missile_cast_range, Enum.TeamType.TEAM_ENEMY)) do
		
		if Entity.IsHero(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
		
			local laserLevel = Ability.GetLevel(laser)
			local laserDmg = 80 * laserLevel
			
			local missileLevel = Ability.GetLevel(missile)
			local missileDmg = 125 + 75 * (missileLevel - 1)
			if missileLevel == 0 then missileDmg = 0 end
			missileDmg = missileDmg * magicDamageFactor
			
			local hitDmg = NPC.GetDamageMultiplierVersus(myHero, npc) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(npc))
			
			local enemyHealth = Entity.GetHealth(npc)
			local enemyHealthLeft = enemyHealth - laserDmg - missileDmg
			local hitsLeft = math.ceil(enemyHealthLeft / hitDmg)

			local pos = NPC.GetAbsOrigin(npc)
			local x, y, visible = Renderer.WorldToScreen(pos)
			Renderer.SetDrawColor(255, 255, 0, 255)
			Renderer.DrawTextCentered(TinkerExtended.font, x, y, hitsLeft, 1)

			local comboManaCost = Ability.GetManaCost(laser) + Ability.GetManaCost(missile)

			if (enemyHealthLeft <= 0 and comboManaCost < manaPoint) and (Ability.IsCastable(laser, manaPoint) and Ability.IsCastable(missile, manaPoint)) and NPC.IsEntityInRange(myHero, npc, laser_cast_range) then
				Ability.CastNoTarget(missile, false)
				Ability.CastTarget(laser, npc)
			end

			if enemyHealth < laserDmg and Ability.IsCastable(laser, manaPoint) and NPC.IsEntityInRange(myHero, npc, laser_cast_range) then
				Ability.CastTarget(laser, npc)
			end

			if enemyHealth < missileDmg and Ability.IsCastable(missile, manaPoint) and NPC.IsEntityInRange(myHero, npc, missile_cast_range) then
				Ability.CastNoTarget(missile, false)
			end			
		
		end

	end

end

return TinkerExtended