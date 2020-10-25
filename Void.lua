local Utility = require("Utility")

local Void = {}
local optionKillStealCounter = Menu.AddOption({"Hero Specific", "Void"}, "Show KS Counter", "Show how many hits remains to kill.")
local optionAutoTimeDilation = Menu.AddOption({"Hero Specific", "Void"}, "Auto Time Dilation", "Auto cast time dilation when enemy is around")

function Void.OnUpdate()
    if Menu.IsEnabled(optionAutoTimeDilation) then
        Void.AutoTimeDilation()
    end
end

function Void.AutoTimeDilation()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "faceless_void_time_dilation")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero) - 200) then return end
    local radius = 775

    -- only auto cast time dilation when chrono is on cool down
    local chrono = NPC.GetAbility(myHero, "faceless_void_chronosphere")
    if chrono and Ability.IsCastable(chrono, NPC.GetMana(myHero)) then
    	return
    end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, radius)
        and (Utility.GetFixTimeLeft(enemy) <= 0.3 or not Utility.IsDisabled(enemy)) then

            Ability.CastNoTarget(spell)
            return
        end
    end
end

-- show how many hits left to KS
function Void.OnDraw()
    if not Menu.IsEnabled(optionKillStealCounter) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_faceless_void" then return end
    -- if NPC.GetCurrentLevel(myHero) < 6 then return end

    local faceless_void_time_lock = NPC.GetAbility(myHero, "faceless_void_time_lock")
    local prob = 0
    local magicalDamage = 0
    if faceless_void_time_lock and Ability.GetLevel(faceless_void_time_lock) >= 1 then
	    prob = 0.08 + 0.04 * Ability.GetLevel(faceless_void_time_lock)
	    magicalDamage = 15 + 5 * Ability.GetLevel(faceless_void_time_lock)
	end

	-- the expectation of extra hits:
	-- expectation = prob + prob**2 + ... + prob**n, (n to \infty)
	expectation = prob / (1 - prob)

	local faceless_void_chronosphere = NPC.GetAbility(myHero, "faceless_void_chronosphere")
	local duration = 0
	if faceless_void_chronosphere and Ability.GetLevel(faceless_void_chronosphere) >= 1 then
		duration = 3.5 + 0.5 * Ability.GetLevel(faceless_void_time_lock)
	end
	local attacksPerChrono = math.floor(duration * NPC.GetAttacksPerSecond(myHero))

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
            and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local oneHitMagicalDamage = expectation * Utility.GetRealDamage(myHero, enemy, magicalDamage)
            local oneHitPhysicalDamage = (1 + expectation) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local oneHitDamage = oneHitMagicalDamage + oneHitPhysicalDamage
            local hitsLeft = math.ceil(Entity.GetHealth(enemy) / oneHitDamage)

            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)
            local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

            text = string.format("%d (%d)", hitsLeft, attacksPerChrono)
            -- red : can kill; green : cant kill
            if hitsLeft <= attacksPerChrono then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(font, x, y, text, 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(font, x, y, text, 1)
            end

        end
    end
end

return Void
