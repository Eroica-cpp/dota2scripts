local Utility = require("Utility")

local Lina = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Lina"}, "Auto KS (upgraded version)", "Auto kill steal using dragon slave and/or laguana blade.")
local optionKillStealCounter = Menu.AddOption({"Hero Specific", "Lina"}, "Show KS Counter", "Show how many hits remains to kill steal.")
local optionAutoLightStrikeArray = Menu.AddOption({"Hero Specific", "Lina"}, "Auto Light Strike Array", "Auto cast Light Strike Array if enemy is (1) TPing; (2) channelling; (3) slowed; (4) stunned/hexed/rooted/taunted with proper timing; or (5) eul combo")

local KS_target
local KS_time
local array_target
local array_time
local cast_point = 0.45 -- the cast point for both dragon slave and laguana blade.

local spell_damage_table = {}

function Lina.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        Lina.KillSteal()
    end

    if Menu.IsEnabled(optionAutoLightStrikeArray) then
        Lina.AutoLightStrikeArray()
    end

    Lina.item_cyclone()
end

-- show how many hits left to KS
function Lina.OnDraw()
    if not Menu.IsEnabled(optionKillStealCounter) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and spell_damage_table[NPC.GetUnitName(enemy)] 
            and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local oneHitDamage = Utility.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local hitsLeft = math.ceil((Entity.GetHealth(enemy) - spell_damage_table[NPC.GetUnitName(enemy)]) / oneHitDamage)

            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)
            local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

            -- red : can kill; green : cant kill
            if hitsLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(font, x, y, hitsLeft, 1)
            end

        end
    end
end

-- Auto cast Light Strike Array if enemy is (1) TPing; (2) channelling; or (3) stunned/hexed/rooted/taunted with proper timing
function Lina.AutoLightStrikeArray()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lina_light_strike_array")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and NPC.IsEntityInRange(myHero, enemy, range) then

            local cast_position = Entity.GetAbsOrigin(enemy)

            -- lina_light_strike_array the enemy who is channelling a spell or TPing
            if Utility.IsChannellingAbility(enemy) and Utility.CanCastSpellOn(enemy) then
                Ability.CastPosition(spell, cast_position)
                array_target = enemy
                array_time = GameRules.GetGameTime()
                return
            end

            -- lina_light_strike_array the enemy who is slowed
            if Utility.GetMoveSpeed(enemy) < 200 and Utility.CanCastSpellOn(enemy) then
                Ability.CastPosition(spell, cast_position)
                array_target = enemy
                array_time = GameRules.GetGameTime()
                return
            end

            -- lina_light_strike_array the enemy who is hexed/stunned/rooted/taunted with proper timing
            local delay = 0.5 + cast_point + NPC.GetTimeToFacePosition(myHero, Entity.GetAbsOrigin(enemy))
            if Utility.GetHexTimeLeft(enemy) > delay or Utility.GetFixTimeLeft(enemy) > delay and Utility.CanCastSpellOn(enemy)  then
                Ability.CastPosition(spell, cast_position)
                array_target = enemy
                array_time = GameRules.GetGameTime()
                return
            end

            -- lina_light_strike_array the enemy who was invulnerable (e.g., cyclone) with proper timing
            if Utility.GetInvulnerableTimeLeft(enemy) < delay + 0.05 and Utility.GetInvulnerableTimeLeft(enemy) > delay then
                Ability.CastPosition(spell, cast_position)
                array_target = enemy
                array_time = GameRules.GetGameTime()
                return
            end
        end
    end
end

-- KS using lina_dragon_slave and lina_laguna_blade
function Lina.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local lina_dragon_slave = NPC.GetAbility(myHero, "lina_dragon_slave")
    local lina_laguna_blade = NPC.GetAbility(myHero, "lina_laguna_blade")
    if not lina_dragon_slave and not lina_laguna_blade then return end

    local range_lina_dragon_slave = Ability.GetCastRange(lina_dragon_slave)
    local range_lina_laguna_blade = Ability.GetCastRange(lina_laguna_blade)

    local mana_lina_dragon_slave = 0
    if lina_dragon_slave then
        mana_lina_dragon_slave = 85 + 15 * Ability.GetLevel(lina_dragon_slave)
    end

    local damage_lina_dragon_slave = 0
    if lina_dragon_slave and  Ability.IsCastable(lina_dragon_slave, NPC.GetMana(myHero)) then
        damage_lina_dragon_slave = 10 + 75 * Ability.GetLevel(lina_dragon_slave)
    end

    local damage_lina_laguna_blade = 0
    if lina_laguna_blade and  Ability.IsCastable(lina_laguna_blade, NPC.GetMana(myHero)) then
        damage_lina_laguna_blade = 300 + 200 * Ability.GetLevel(lina_laguna_blade)
    end

    local total_damage = damage_lina_dragon_slave + damage_lina_laguna_blade

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) then

            local true_damage_lina_dragon_slave = Utility.GetRealDamage(myHero, enemy, damage_lina_dragon_slave)
            local true_damage_lina_laguna_blade = Utility.GetRealDamage(myHero, enemy, damage_lina_laguna_blade)
            if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
                true_damage_lina_laguna_blade = damage_lina_laguna_blade
            end

            local true_damage = true_damage_lina_dragon_slave + true_damage_lina_laguna_blade
            spell_damage_table[NPC.GetUnitName(enemy)] = true_damage

            -- KS using lina_dragon_slave only
            if true_damage_lina_dragon_slave >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point
                and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range_lina_dragon_slave)
                and Ability.IsCastable(lina_dragon_slave, NPC.GetMana(myHero)) then

                Ability.CastTarget(lina_dragon_slave, enemy)
                KS_target = enemy
                KS_time = GameRules.GetGameTime()
                return
            end

            -- KS using lina_laguna_blade only
            if true_damage_lina_laguna_blade >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point
                and Utility.IsSafeToCast(myHero, enemy, true_damage_lina_laguna_blade)
                and (Utility.CanCastSpellOn(enemy) or NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed"))
                and not Utility.IsLinkensProtected(enemy)
                and NPC.IsEntityInRange(myHero, enemy, range_lina_laguna_blade) 
                and Ability.IsCastable(lina_laguna_blade, NPC.GetMana(myHero)) then

                Ability.CastTarget(lina_laguna_blade, enemy)
                KS_target = enemy
                KS_time = GameRules.GetGameTime()
                return
            end

            -- KS using both lina_dragon_slave and lina_laguna_blade
            if true_damage >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point
                and Utility.IsSafeToCast(myHero, enemy, true_damage_lina_laguna_blade)
                and Utility.CanCastSpellOn(enemy)
                and not Utility.IsLinkensProtected(enemy)
                and NPC.IsEntityInRange(myHero, enemy, range_lina_laguna_blade) 
                and Ability.IsCastable(lina_laguna_blade, NPC.GetMana(myHero)-mana_lina_dragon_slave) then

                Ability.CastTarget(lina_dragon_slave, enemy)
                Ability.CastTarget(lina_laguna_blade, enemy)
                KS_target = enemy
                KS_time = GameRules.GetGameTime()
                return
            end
        end
    end
end

-- Auto use item_cyclone on enemy hero once available (specific version for Lina)
-- Doesn't use on enemy who is lotus orb protected or AM with aghs.
function Lina.item_cyclone()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_lina" then return end
    if not Utility.IsSuitableToUseItem(myHero) then return end

    local item = NPC.GetItem(myHero, "item_cyclone", true)
    if not item or not Ability.IsCastable(item, NPC.GetMana(myHero)) then return end

    local range = Utility.GetCastRange(myHero, item) -- 800
    local enemyAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)

    local minDistance = 99999
    local target = nil
    for i, enemy in ipairs(enemyAround) do
        if not NPC.IsIllusion(enemy) and not Utility.IsDisabled(enemy)
            and Utility.GetFixTimeLeft(enemy) <= 0
            and not NPC.IsSilenced(enemy)
            and (not KS_target or NPC.GetUnitName(enemy) ~= NPC.GetUnitName(KS_target)
                or GameRules.GetGameTime() - KS_time >= 1)
            and (not array_target or NPC.GetUnitName(enemy) ~= NPC.GetUnitName(array_target)
                or GameRules.GetGameTime() - array_time >= 1.5)
            and Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy)
            and not Utility.IsLotusProtected(enemy) then
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
            if dis < minDistance then
                minDistance = dis
                target = enemy
            end
        end
    end

    -- cast item_cyclone on nearest enemy in range
    if target then Ability.CastTarget(item, target) end
end

return Lina
