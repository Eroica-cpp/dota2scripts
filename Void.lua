local Utility = require("Utility")

local Void = {}
local optionKillStealCounter = Menu.AddOption({"Hero Specific", "Void"}, "Show KS Counter", "Show how many hits remains to kill.")

-- show how many hits left to KS
function Void.OnDraw()
    if not Menu.IsEnabled(optionKillStealCounter) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_faceless_void" then return end
    -- if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "faceless_void_time_lock")
    local prob = 0
    local magicalDamage = 0
    if spell and Ability.GetLevel(spell) >= 1 then
	    prob = 0.08 + 0.04 * Ability.GetLevel(spell)
	    magicalDamage = 15 + 5 * Ability.GetLevel(spell)
	end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
            and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local oneHitMagicalDamage = prob * Utility.GetRealDamage(myHero, enemy, magicalDamage)
            local oneHitPhysicalDamage = (1 + prob) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local oneHitDamage = oneHitMagicalDamage + oneHitPhysicalDamage
            local hitsLeft = math.ceil(Entity.GetHealth(enemy) / oneHitDamage)

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

return Void
