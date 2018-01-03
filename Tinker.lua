local Utility = require("Utility")

local Tinker = {}

Tinker.optionEnable = Menu.AddOption({"Hero Specific", "Tinker"}, "Kill Steal", "Auto use spells or dagon for KS")
Tinker.optionLastHitHarass = Menu.AddOption({"Hero Specific", "Tinker"}, "Harass last hitting", "Auto cast laser to harass enemies' last hitting")
Tinker.optionBlinkAway = Menu.AddOption({"Hero Specific", "Tinker"}, "Blink Away", "Blink to mouse position right after casting laser")
Tinker.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
Tinker.optionOneKeySpell = Menu.AddOption({"Hero Specific", "Tinker"}, "One Key Spell", "On/Off")
Tinker.key = Menu.AddKeyOption({ "Hero Specific","Tinker" }, "One Key Spell Key", Enum.ButtonCode.KEY_D)

Tinker.manaThreshold = 75
Tinker.healthThreshold = 50

function Tinker.OnUnitAnimation(animation)
	if not Menu.IsEnabled(Tinker.optionLastHitHarass) then return end
	if not animation then return end

	local myHero = Heroes.GetLocal()
	if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

	local laser = NPC.GetAbility(myHero, "tinker_laser")
	if not laser or not Ability.IsCastable(laser, NPC.GetMana(myHero)) then return end

	if not animation.unit or not NPC.IsHero(animation.unit) or Entity.IsSameTeam(myHero, animation.unit) then return end
	if NPC.IsIllusion(animation.unit) or not Utility.CanCastSpellOn(animation.unit) then return end
	if not NPC.IsEntityInRange(myHero, animation.unit, Utility.GetCastRange(myHero, laser)) then return end

	if animation.sequenceName and string.match(animation.sequenceName, "attack.*anim") then
		Ability.CastTarget(laser, animation.unit)
	end
end

function Tinker.OnUpdate()
	local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_tinker" then return end

    if Menu.IsEnabled(Tinker.optionOneKeySpell) and Menu.IsKeyDown(Tinker.key) then
        Tinker.OneKey(myHero)
	end

	if Menu.IsEnabled(Tinker.optionBlinkAway) then
        Tinker.BlinkAway(myHero)
	end
end

function Tinker.OneKey(myHero)
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

	local dagon
    local item1 = NPC.GetItem(myHero, "item_dagon", true)
    local item2 = NPC.GetItem(myHero, "item_dagon_2", true)
    local item3 = NPC.GetItem(myHero, "item_dagon_3", true)
    local item4 = NPC.GetItem(myHero, "item_dagon_4", true)
    local item5 = NPC.GetItem(myHero, "item_dagon_5", true)

    if item1 and Ability.IsCastable(item1, NPC.GetMana(myHero)) then dagon = item1 end
    if item2 and Ability.IsCastable(item2, NPC.GetMana(myHero)) then dagon = item2 end
    if item3 and Ability.IsCastable(item3, NPC.GetMana(myHero)) then dagon = item3 end
    if item4 and Ability.IsCastable(item4, NPC.GetMana(myHero)) then dagon = item4 end
    if item5 and Ability.IsCastable(item5, NPC.GetMana(myHero)) then dagon = item5 end

	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not Entity.IsSameTeam(myHero, enemy) and Utility.CanCastSpellOn(enemy) then

			if dagon and Ability.IsCastable(dagon, NPC.GetMana(myHero)) and NPC.IsEntityInRange(myHero, enemy, Utility.GetCastRange(myHero, dagon)) then
				Ability.CastTarget(dagon, enemy)
			end

			if missile and Ability.IsCastable(missile, NPC.GetMana(myHero)) and NPC.IsEntityInRange(myHero, enemy, missile_radius) then
				Ability.CastNoTarget(missile)
			end

			local target = Tinker.GetLaserCastTarget(myHero, enemy)
			if target and laser and Ability.IsCastable(laser, NPC.GetMana(myHero)) and NPC.IsEntityInRange(myHero, enemy, Utility.GetCastRange(myHero, laser)) then
				Ability.CastTarget(laser, target)
			end
        end
	end
end

function Tinker.BlinkAway(myHero)
	if not Tinker.IsSuitableToUseItem(myHero) then return end

	local item = NPC.GetItem(myHero, "item_blink", true)
	if not item or not Ability.IsCastable(item, 0) then return end

	local laser = NPC.GetAbility(myHero, "tinker_laser")
	if not laser or Ability.IsReady(laser) then return end


	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
		if enemy and not Entity.IsSameTeam(myHero, enemy) and NPC.HasModifier(enemy, "modifier_tinker_laser_blind") then
			Ability.CastPosition(item, Input.GetWorldCursorPos())
			return
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

	local dagon
    local item1 = NPC.GetItem(myHero, "item_dagon", true)
    local item2 = NPC.GetItem(myHero, "item_dagon_2", true)
    local item3 = NPC.GetItem(myHero, "item_dagon_3", true)
    local item4 = NPC.GetItem(myHero, "item_dagon_4", true)
    local item5 = NPC.GetItem(myHero, "item_dagon_5", true)

	local dagonLevel = 0
    if item1 and Ability.IsCastable(item1, NPC.GetMana(myHero)) then dagon = item1; dagonLevel = 1 end
    if item2 and Ability.IsCastable(item2, NPC.GetMana(myHero)) then dagon = item2; dagonLevel = 2 end
    if item3 and Ability.IsCastable(item3, NPC.GetMana(myHero)) then dagon = item3; dagonLevel = 3 end
    if item4 and Ability.IsCastable(item4, NPC.GetMana(myHero)) then dagon = item4; dagonLevel = 4 end
    if item5 and Ability.IsCastable(item5, NPC.GetMana(myHero)) then dagon = item5; dagonLevel = 5 end

    local dagonDmg = 400 + 100 * (dagonLevel - 1)

    if not laser or not Ability.IsCastable(laser, myMana) then laserDmg = 0 end
    if not missile or not Ability.IsCastable(missile, myMana) then missileDmg = 0 end
    if not dagon or not Ability.IsCastable(dagon, myMana) then dagonDmg = 0 end

	for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
		and Utility.CanCastSpellOn(enemy) then

            local real_missileDmg = missileDmg * NPC.GetMagicalArmorDamageMultiplier(enemy)
            local real_dagonDmg = dagonDmg * NPC.GetMagicalArmorDamageMultiplier(enemy)
			local hitDmg = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))

			local enemyHealth = Entity.GetHealth(enemy)
			local enemyHealthLeft = enemyHealth - laserDmg - real_missileDmg - real_dagonDmg
			local hitsLeft = math.ceil(enemyHealthLeft / (hitDmg + 1))
            local comboLeft = math.ceil(enemyHealth / (laserDmg + real_missileDmg + real_dagonDmg + 1))

			local pos = Entity.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

            local hasRearm = Ability.GetLevel(rearm) > 0

            if hitsLeft <= 0 or comboLeft <= 1 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(Tinker.font, x, y, "Kill", 1)
			elseif hasRearm and comboLeft < 20 then
                Renderer.SetDrawColor(0, 255, 0, 255)
    			Renderer.DrawTextCentered(Tinker.font, x, y, "x"..comboLeft, 1)
            end

            -- auto cast laser for KS
            if enemyHealth <= laserDmg and Ability.IsCastable(laser, myMana) then
                local target = Tinker.GetLaserCastTarget(myHero, enemy)
                if target then
                    Ability.CastTarget(laser, target)
                    return
                end
            end

            -- auto cast missile for KS
			local missile_radius = 2500
            if enemyHealth < missileDmg and Ability.IsCastable(missile, myMana) and NPC.IsEntityInRange(myHero, enemy, missile_radius) then
                Ability.CastNoTarget(missile)
                return
            end

            -- auto cast both laser and missile for KS
			local comboManaCost = Ability.GetManaCost(laser) + Ability.GetManaCost(missile)
            if enemyHealthLeft <= 0 and comboManaCost <= myMana and Ability.IsCastable(laser, myMana) and Ability.IsCastable(missile, myMana) then
                local target = Tinker.GetLaserCastTarget(myHero, enemy)
                if target then
    				Ability.CastNoTarget(missile)
    				Ability.CastTarget(laser, target)
                    return
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

function Tinker.IsSuitableToUseItem(myHero)
    if NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    -- if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    -- if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

return Tinker
