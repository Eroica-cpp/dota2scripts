local ShadowFiend = {}

ShadowFiend.autoRaze = Menu.AddOption({"Hero Specific", "Shadow Fiend"}, "Auto Raze for KS", "On/Off")
ShadowFiend.awareness = Menu.AddOption({"Hero Specific", "Shadow Fiend"}, "Awareness", "Show Kill Potential")

function ShadowFiend.OnDraw()

    if not Menu.IsEnabled(ShadowFiend.awareness) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_nevermore" then return end
    local myMana = NPC.GetMana(myHero)
    local magicDamageFactor = 0.75

    local raze_short = NPC.GetAbilityByIndex(myHero, 0)
    local raze_mid = NPC.GetAbilityByIndex(myHero, 1)
    local raze_long = NPC.GetAbilityByIndex(myHero, 2)

    local raze_level = Ability.GetLevel(raze_short)
    local raze_damage = (raze_level > 0) and 100+75*(raze_level-1) or 0
    local true_raze_damage = raze_damage * magicDamageFactor
    local raze_radius = 250
    local raze_mana_cost = 90
    local short_range, mid_range, long_range = 200, 450, 700


    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local enemyHp = Entity.GetHealth(enemy)
            local physicalDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local hitsLeft = math.ceil((enemyHp - true_raze_damage) / physicalDamage)

            -- draw
            local pos = NPC.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)

            -- red : can kill; green : cant kill
            if hitsLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(OutworldDevourer.font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(OutworldDevourer.font, x, y, hitsLeft, 1)
            end

        end -- end of if statement
    end -- end of for loop

end

return ShadowFiend