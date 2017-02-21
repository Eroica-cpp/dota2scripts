local TinkerExtended = {}

TinkerExtended.optionEnable = Menu.AddOption({"Hero Specific", "Tinker"}, "Auto Use Spell", "On/Off")
TinkerExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
TinkerExtended.optionKey = Menu.AddKeyOption({ "Hero Specific","Tinker" }, "Spell Key", Enum.ButtonCode.KEY_D)
TinkerExtended.threshold = 75

-- using mutex to avoid bugs
local mutex = true

function TinkerExtended.OnUpdate()
	if not Menu.IsEnabled(TinkerExtended.optionEnable) then return end
	if Menu.IsKeyDown(TinkerExtended.optionKey) then
		TinkerExtended.OneKey()
	end
end

function TinkerExtended.OneKey()

    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end
    if NPC.IsStunned(myHero) then return end
    local myMana = NPC.GetMana(myHero)
    if myMana <= TinkerExtended.threshold then return end

    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return end
    
    -- =====================================
    -- Item section
    -- =====================================
    -- item : hex
    local hex = NPC.GetItem(myHero, "item_sheepstick", true)
    if mutex and hex and Ability.IsCastable(hex, myMana) and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(hex)) then 
        mutex = false
        Ability.CastTarget(hex, enemy)
        mutex = true
    end

    -- item : ethereal blade
    -- local ethereal = NPC.GetItem(myHero, "item_ethereal_blade", true)
    -- if mutex and ethereal and Ability.IsCastable(ethereal, myMana) and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(ethereal)) then 
    --     mutex = false
    --     Ability.CastTarget(ethereal, enemy)
    --     mutex = true
    -- end

    -- item : shivas guard
    local shiva = NPC.GetItem(myHero, "item_shivas_guard", true)
    if mutex and shiva and Ability.IsCastable(shiva, myMana) then 
        mutex = false
        Ability.CastNoTarget(shiva)
        mutex = true
    end    

    -- item : dagon
    local dagon = NPC.GetItem(myHero, "item_dagon", true)
    for i = 2, 5 do
        local tmp = NPC.GetItem(myHero, "item_dagon_" .. i, true)
        if tmp then dagon = tmp end
    end
    if mutex and dagon and Ability.IsCastable(dagon, myMana) and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(dagon)) then 
        mutex = false
        Ability.CastTarget(dagon, enemy)
        mutex = true
    end

    -- =====================================
    -- Spell section
    -- =====================================
    if NPC.IsSilenced(myHero) then return end

    -- spell : missile
    local missile = NPC.GetAbilityByIndex(myHero, 1)
    if mutex and Ability.IsCastable(missile, myMana) then -- and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(missile)) then 
        mutex = false
        Ability.CastNoTarget(missile)
        mutex = true
    end

    -- spell : laser (has to put castLaser() at last because casting laser has delay)
    if mutex then
        mutex = false
        castLaser(myHero)
        mutex = true
    end

end

-- Auto Spell for KS
-- function TinkerExtended.OnDraw()

-- 	if not Menu.IsEnabled( TinkerExtended.optionEnable ) then return end
-- 	if not GameRules.GetGameState() == 5 then return end

-- 	local myHero = Heroes.GetLocal()
-- 	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end

-- 	local manaPoint = NPC.GetMana(myHero)

-- 	local laser = NPC.GetAbilityByIndex(myHero, 0)
-- 	local missile = NPC.GetAbilityByIndex(myHero, 1)
-- 	local lens = NPC.GetItem(myHero, "item_aether_lens", true)
-- 	local laser_cast_range = 650 -- didnt consider tinker's extra 75 cast range talent in level 20
-- 	local missile_cast_range = 2500
-- 	local magicDamageFactor = 0.75

-- 	if lens then
-- 		laser_cast_range = laser_cast_range + 220
-- 		missile_cast_range = missile_cast_range + 220
-- 	end

-- 	for n, npc in pairs(NPC.GetHeroesInRadius(myHero, missile_cast_range, Enum.TeamType.TEAM_ENEMY)) do
		
-- 		if Entity.IsHero(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
		
-- 			local laserLevel = Ability.GetLevel(laser)
-- 			local laserDmg = 80 * laserLevel
			
-- 			local missileLevel = Ability.GetLevel(missile)
-- 			local missileDmg = 125 + 75 * (missileLevel - 1)
-- 			if missileLevel == 0 then missileDmg = 0 end
-- 			missileDmg = missileDmg * magicDamageFactor
			
-- 			local hitDmg = NPC.GetDamageMultiplierVersus(myHero, npc) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(npc))
			
-- 			local enemyHealth = Entity.GetHealth(npc)
-- 			local enemyHealthLeft = enemyHealth - laserDmg - missileDmg
-- 			local hitsLeft = math.ceil(enemyHealthLeft / hitDmg)

-- 			local pos = NPC.GetAbsOrigin(npc)
-- 			local x, y, visible = Renderer.WorldToScreen(pos)
-- 			Renderer.SetDrawColor(255, 255, 0, 255)
-- 			Renderer.DrawTextCentered(TinkerExtended.font, x, y, hitsLeft, 1)

-- 			local comboManaCost = Ability.GetManaCost(laser) + Ability.GetManaCost(missile)

-- 			if (enemyHealthLeft <= 0 and comboManaCost < manaPoint) and (Ability.IsCastable(laser, manaPoint) and Ability.IsCastable(missile, manaPoint)) and NPC.IsEntityInRange(myHero, npc, laser_cast_range) then
-- 				Ability.CastNoTarget(missile, false)
-- 				Ability.CastTarget(laser, npc)
-- 			end

-- 			if enemyHealth < laserDmg and Ability.IsCastable(laser, manaPoint) and NPC.IsEntityInRange(myHero, npc, laser_cast_range) then
-- 				Ability.CastTarget(laser, npc)
-- 			end

-- 			if enemyHealth < missileDmg and Ability.IsCastable(missile, manaPoint) and NPC.IsEntityInRange(myHero, npc, missile_cast_range) then
-- 				Ability.CastNoTarget(missile, false)
-- 			end			
		
-- 		end

-- 	end

-- end

-- Auto cast laser to nearest enemy in range
-- If has agh scepter, can also cast laser to a enemy unit in range so as to reflect to enemy.
function castLaser(myHero)
	if not myHero or NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local laser = NPC.GetAbilityByIndex(myHero, 0)
	local laserCastRange = Ability.GetCastRange(laser) -- Ability.GetCastRange() already considers bonus cast range.
	local laserRefractRange = 650

	if not Ability.IsCastable(laser, NPC.GetMana(myHero)) then return end

	local hasAghScepter = NPC.HasItem(myHero, "item_ultimate_scepter", true)

	-- -- dont have agh scepter
	if not hasAghScepter then
		local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
		if enemy and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsEntityInRange(enemy, myHero, laserCastRange) then
			Ability.CastTarget(laser, enemy)
		end
		return
	end

	-- has agh scepter
	local enemyUnits = NPC.GetUnitsInRadius(myHero, laserCastRange, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(enemyUnits) do
        -- NPC.GetHeroesInRadius(npc, radius, team) gets heroes around but not npc itself, and team side is from npc's view
		local enemyHeroesAround = NPC.GetHeroesInRadius(npc, laserRefractRange, Enum.TeamType.TEAM_FRIEND)
		if npc and (#enemyHeroesAround > 0 or NPC.IsHero(npc)) and not NPC.IsStructure(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsEntityInRange(myHero, npc, laserCastRange) then
			Ability.CastTarget(laser, npc)
			return
		end
	end

end

local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return TinkerExtended