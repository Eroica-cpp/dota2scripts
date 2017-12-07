local Utility = require("Utility")

local Tinker = {}

Tinker.optionEnable = Menu.AddOption({"Hero Specific", "Tinker"}, "Auto Use Spell for KS", "On/Off")
Tinker.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
Tinker.optionOneKeySpell = Menu.AddOption({"Hero Specific", "Tinker"}, "One Key Spell", "On/Off")
Tinker.key = Menu.AddKeyOption({ "Hero Specific","Tinker" }, "One Key Spell Key", Enum.ButtonCode.KEY_D)

Tinker.manaThreshold = 75
Tinker.healthThreshold = 50

function Tinker.OnUpdate()
	local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end

    if Menu.IsEnabled(Tinker.optionOneKeySpell) and Menu.IsKeyDown(Tinker.key) then
        Tinker.OneKey(myHero)
	end
end

function Tinker.OneKey(myHero)
    if not myHero then return end

	local myMana = NPC.GetMana(myHero)
    if myMana <= Tinker.manaThreshold then return end


	-- item : shivas guard
    local shiva = NPC.GetItem(myHero, "item_shivas_guard", true)
    if shiva and Ability.IsCastable(shiva, myMana) and Utility.IsSuitableToUseItem(myHero) then
        Ability.CastNoTarget(shiva)
    end

	if not Utility.IsSuitableToCastSpell(myHero) then return end

	local laser = NPC.GetAbility(myHero, "tinker_laser")
	local missile = NPC.GetAbility(myHero, "tinker_heat_seeking_missile")
	local missile_radius = 2500

	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not Entity.IsSameTeam(myHero, enemy) and Utility.CanCastSpellOn(enemy) then

			local target = Tinker.GetLaserCastTarget(myHero, enemy)
			if target and laser and Ability.IsCastable(laser, NPC.GetMana(myHero)) then
				Ability.CastTarget(laser, target)
			end

			if missile and Ability.IsCastable(missile, NPC.GetMana(myHero)) and NPC.IsEntityInRange(myHero, enemy, missile_radius) then
				Ability.CastNoTarget(missile)
			end
        end
	end
end

-- 1. Auto Spell for KS
-- 2. Killable awareness (laser + missile + dagon)
function Tinker.OnDraw()

	if not Menu.IsEnabled(Tinker.optionEnable) then return end

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end

	local myMana = NPC.GetMana(myHero)
	local laser = NPC.GetAbility(myHero, "tinker_laser")
	local missile = NPC.GetAbility(myHero, "tinker_heat_seeking_missile")
    local rearm = NPC.GetAbility(myHero, "tinker_rearm")

    local laserLevel = Ability.GetLevel(laser)
    local laserDmg = 80 * laserLevel

    local level_25_laser_damage_talent = NPC.GetAbility(myHero, "special_bonus_unique_tinker")
    if Ability.GetLevel(level_25_laser_damage_talent) > 0 then
        laserDmg = laserDmg + 100
    end

    local missileLevel = Ability.GetLevel(missile)
    local missileDmg = 125 + 75 * (missileLevel - 1)

    local dagon = NPC.GetItem(myHero, "item_dagon", true)
    local dagonLevel = dagon and 1 or 0
    for i = 2, 5 do
        if NPC.GetItem(myHero, "item_dagon_" .. i, true) then dagonLevel = i end
    end
    local dagonDmg = 400 + 100 * (dagonLevel - 1)

    if not laser or not Ability.IsCastable(laser, myMana) then laserDmg = 0 end
    if not missile or not Ability.IsCastable(missile, myMana) then missileDmg = 0 end
    if not dagon or not Ability.IsCastable(dagon, myMana) then dagonDmg = 0 end

	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
		and Utility.CanCastSpellOn(enemy) then

            missileDmg = missileDmg * NPC.GetMagicalArmorDamageMultiplier(enemy)
            dagonDmg = dagonDmg * NPC.GetMagicalArmorDamageMultiplier(enemy)
			local hitDmg = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))

			local enemyHealth = Entity.GetHealth(enemy)
			local enemyHealthLeft = enemyHealth - laserDmg - missileDmg - dagonDmg
			local hitsLeft = math.ceil(enemyHealthLeft / (hitDmg + 1))
            local comboLeft = math.ceil(enemyHealth / (laserDmg + missileDmg + dagonDmg + 1))

			local pos = Entity.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

            local hasRearm = Ability.GetLevel(rearm) > 0
			local drawText = (hasRearm and comboLeft<20) and "x"..comboLeft or hitsLeft

            if hitsLeft <= 0 or comboLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(Tinker.font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
    			Renderer.DrawTextCentered(Tinker.font, x, y, drawText, 1)
            end

            -- auto cast laser for KS
            if enemyHealth <= laserDmg and Ability.IsCastable(laser, myMana) then
                local target = Tinker.GetLaserCastTarget(myHero, enemy)
                if target then
                    Ability.CastTarget(laser, target)
                    break
                end
            end

            -- auto cast missile for KS
			local missile_radius = 2500
            if enemyHealth < missileDmg and Ability.IsCastable(missile, myMana) and NPC.IsEntityInRange(myHero, enemy, missile_radius) then
                Ability.CastNoTarget(missile)
                break
            end

            -- auto cast both laser and missile for KS
			local comboManaCost = Ability.GetManaCost(laser) + Ability.GetManaCost(missile)
            if enemyHealthLeft <= 0 and comboManaCost <= myMana and Ability.IsCastable(laser, myMana) and Ability.IsCastable(missile, myMana) then
                local target = Tinker.GetLaserCastTarget(myHero, enemy)
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
function Tinker.GetLaserCastTarget(myHero, enemy)
    if not myHero or not enemy then return end

    local laser = NPC.GetAbility(myHero, "tinker_laser")
    local laserCastRange = Utility.GetCastRange(myHero, laser)
    local laserRefractRange = 650

	if NPC.IsEntityInRange(myHero, enemy, laserCastRange) then return enemy end
    if not NPC.HasItem(myHero, "item_ultimate_scepter", true) then return end

    local enemyUnitsAround = NPC.GetUnitsInRadius(enemy, laserRefractRange, Enum.TeamType.TEAM_FRIEND)
    for i, npc in ipairs(enemyUnitsAround) do
        if npc and NPC.IsEntityInRange(npc, myHero, laserCastRange)
            and Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy) then
            return npc
        end
    end
end

return Tinker
