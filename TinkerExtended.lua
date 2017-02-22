local TinkerExtended = {}

TinkerExtended.optionEnable = Menu.AddOption({"Hero Specific", "Tinker"}, "Auto Use Spell for KS", "On/Off")
TinkerExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
TinkerExtended.oneKeySpell = Menu.AddKeyOption({ "Hero Specific","Tinker" }, "Spell Key", Enum.ButtonCode.KEY_D)
TinkerExtended.autoSoulRing = Menu.AddKeyOption({ "Hero Specific","Tinker" }, "Rearm Key", Enum.ButtonCode.KEY_T)
TinkerExtended.manaThreshold = 75
TinkerExtended.healthThreshold = 50

function TinkerExtended.OnUpdate()
	if not Menu.IsEnabled(TinkerExtended.optionEnable) then return end
	
    if Menu.IsKeyDown(TinkerExtended.oneKeySpell) then
        TinkerExtended.OneKey()
	end
    
    if Menu.IsKeyDown(TinkerExtended.autoSoulRing) then
        TinkerExtended.Rearm()
    end

end

-- auto use soul ring when rearm
function TinkerExtended.Rearm()

    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end
    if NPC.IsStunned(myHero) then return end
    if Entity.GetHealth(myHero) <= TinkerExtended.healthThreshold then return end

    local soul_ring = NPC.GetItem(myHero, "item_soul_ring", true)
    if soul_ring and Ability.IsReady(soul_ring) then
        Ability.CastNoTarget(soul_ring, true)
    end
    
    local rearm = NPC.GetAbilityByIndex(myHero, 3)
    if Ability.IsCastable(rearm, NPC.GetMana(myHero)) and not Ability.IsInAbilityPhase(rearm) and not Ability.IsChannelling(rearm) then 
        Ability.CastNoTarget(rearm, true)
        sleep(0.1)
    end    

end

-- using mutex or lastUsedAbility seemingly doesnt work.
function TinkerExtended.OneKey()

    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end
    if NPC.IsStunned(myHero) then return end
    local myMana = NPC.GetMana(myHero)
    if myMana <= TinkerExtended.manaThreshold then return end

    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return end
    
    -- =====================================
    -- Item section
    -- =====================================
    -- item : hex
    local hex = NPC.GetItem(myHero, "item_sheepstick", true)
    if hex and Ability.IsCastable(hex, myMana) and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(hex)) then 
        Ability.CastTarget(hex, enemy)
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
    if shiva and Ability.IsCastable(shiva, myMana) then 
        Ability.CastNoTarget(shiva)
    end    

    -- item : dagon
    local dagon = NPC.GetItem(myHero, "item_dagon", true)
    for i = 2, 5 do
        local tmp = NPC.GetItem(myHero, "item_dagon_" .. i, true)
        if tmp then dagon = tmp end
    end
    if dagon and Ability.IsCastable(dagon, myMana) and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(dagon)) then 
        Ability.CastTarget(dagon, enemy)
    end

    -- =====================================
    -- Spell section
    -- =====================================
    if NPC.IsSilenced(myHero) then return end

    -- spell : missile
    local missile = NPC.GetAbilityByIndex(myHero, 1)
    if Ability.IsCastable(missile, myMana) then -- and NPC.IsEntityInRange(enemy, myHero, Ability.GetCastRange(missile)) then 
        Ability.CastNoTarget(missile)
    end

    -- spell : laser (has to cast laser at last because casting laser has animation delay)
    local laser = NPC.GetAbilityByIndex(myHero, 0)
    local target = getLaserCastTarget(myHero, enemy)
    if target and Ability.IsCastable(laser, myMana) then
        Ability.CastTarget(laser, target)    
    end
    
end

-- Auto Spell for KS
function TinkerExtended.OnDraw()

	if not Menu.IsEnabled(TinkerExtended.optionEnable) then return end
	
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return end

	local myMana = NPC.GetMana(myHero)
	local laser = NPC.GetAbilityByIndex(myHero, 0)
	local missile = NPC.GetAbilityByIndex(myHero, 1)
    local rearm = NPC.GetAbilityByIndex(myHero, 3)

	local magicDamageFactor = 0.75

    local laserLevel = Ability.GetLevel(laser)
    local laserDmg = 80 * laserLevel
    -- assumes that you add +100 laser damage talent at level 25
    if NPC.GetCurrentLevel(myHero) == 25 then
        laserDmg = laserDmg + 100
    end
    
    local missileLevel = Ability.GetLevel(missile)
    local missileDmg = (missileLevel > 0) and 125+75*(missileLevel-1) or 0
    missileDmg = missileDmg * magicDamageFactor

	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) 
            and not Entity.IsSameTeam(myHero, enemy) 
            and not Entity.IsDormant(enemy)
            and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
            and Entity.IsAlive(enemy) then		
			
			local hitDmg = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))
			
			local enemyHealth = Entity.GetHealth(enemy)
			local enemyHealthLeft = enemyHealth - laserDmg - missileDmg
			local hitsLeft = math.ceil(enemyHealthLeft / hitDmg)
            local comboLeft = math.ceil(enemyHealth / (laserDmg + missileDmg))

			local pos = NPC.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

            local hasRearm = Ability.GetLevel(rearm) > 0
			local drawText = hasRearm and "x"..comboLeft or hitsLeft
            
            if hitsLeft <= 0 or comboLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(TinkerExtended.font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
    			Renderer.DrawTextCentered(TinkerExtended.font, x, y, drawText, 1)
            end

            -- auto cast laser for KS
            if enemyHealth <= laserDmg and Ability.IsCastable(laser, myMana) then
                local target = getLaserCastTarget(myHero, enemy)
                if target then
                    Ability.CastTarget(laser, target) 
                    break
                end
            end

            -- auto cast missile for KS
            if enemyHealth < missileDmg and Ability.IsCastable(missile, myMana) and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(missile)) then
                Ability.CastNoTarget(missile)
                break
            end

            -- auto cast both laser and missile for KS
			local comboManaCost = Ability.GetManaCost(laser) + Ability.GetManaCost(missile)
            if enemyHealthLeft <= 0 and comboManaCost <= myMana and Ability.IsCastable(laser, myMana) and Ability.IsCastable(missile, myMana) then
                local target = getLaserCastTarget(myHero, enemy)
                if target then
    				Ability.CastNoTarget(missile)
    				Ability.CastTarget(laser, target)
                    break
                end
			end
		
		end -- end of the if statement

	end -- end of the for loop

end

-- If exists, return the enemy hero in the cast range of laser
-- If has agh scepter, return a enemy unit in the cast range of laser that can refract laser to a enemy
-- If no such enemy or unit, return nil
function getLaserCastTarget(myHero, enemy)
    
    if not myHero then return nil end
    
    local hasAghScepter = NPC.HasItem(myHero, "item_ultimate_scepter", true)    
    local laser = NPC.GetAbilityByIndex(myHero, 0)
    local laserCastRange = Ability.GetCastRange(laser) -- Ability.GetCastRange() already considers bonus cast range.
    local laserRefractRange = 650
    
    -- if dont have agh scepter
    if not hasAghScepter then 
        if NPC.IsEntityInRange(myHero, enemy, laserCastRange) then
            return enemy
        else 
            return nil
        end
    end

    -- if have agh scepter
    local enemyUnitsAround = NPC.GetUnitsInRadius(myHero, laserCastRange, Enum.TeamType.TEAM_ENEMY)
    for i, npc in ipairs(enemyUnitsAround) do
        if npc and NPC.IsEntityInRange(npc, enemy, laserRefractRange)
            and NPC.IsEntityInRange(npc, myHero, laserCastRange) 
            and not NPC.IsStructure(npc) 
            and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
            return npc
        end
    end

end

local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return TinkerExtended