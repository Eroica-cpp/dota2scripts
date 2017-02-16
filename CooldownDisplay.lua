local CooldownDisplay = {}

CooldownDisplay.option = Menu.AddOption({ "Awareness" }, "Cooldown Display", "Displays enemy hero cooldowns in an easy and intuitive way.")

CooldownDisplay.boxSize = 16
CooldownDisplay.innerBoxSize = CooldownDisplay.boxSize - 2
CooldownDisplay.levelBoxSize = CooldownDisplay.boxSize - 13

CooldownDisplay.font = Renderer.LoadFont("Tahoma", CooldownDisplay.innerBoxSize - 5, Enum.FontWeight.BOLD)

function CooldownDisplay.DrawDisplay(hero)
    local pos = Entity.GetAbsOrigin(hero)
    pos:SetY(pos:GetY() - 50.0)

    local x, y, vis = Renderer.WorldToScreen(pos)

    if not vis then return end

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)
        
        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and (not Ability.IsPassive(ability) or Ability.GetManaCost(ability) > 0) then
            table.insert(abilities, ability)
        end
    end

    local startX = x - math.floor((#abilities / 2) * CooldownDisplay.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
    Renderer.DrawFilledRect(startX + 1, y - 1, (CooldownDisplay.boxSize * #abilities) + 2, CooldownDisplay.boxSize + 2)

    -- draw the actual ability squares now
    for i, ability in ipairs(abilities) do
        CooldownDisplay.DrawAbilitySquare(hero, ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (CooldownDisplay.boxSize * #abilities) + 2, CooldownDisplay.boxSize + 2)
end

function CooldownDisplay.DrawAbilitySquare(hero, ability, x, y, index)
    local realX = x + (index * CooldownDisplay.boxSize) + 2

    if Ability.IsCastable(ability, NPC.GetMana(hero), true) then
        Renderer.SetDrawColor(0, 255, 0)
    elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
        Renderer.SetDrawColor(0, 0, 255)
    else
        Renderer.SetDrawColor(255, 0, 0)
    end

    Renderer.DrawOutlineRect(realX, y, CooldownDisplay.boxSize, CooldownDisplay.boxSize)

    local cdLength = Ability.GetCooldownLength(ability)

    if not Ability.IsReady(ability) and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) / cdLength
        local cooldownSize = math.floor(CooldownDisplay.innerBoxSize * cooldownRatio)

        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX + 1, y + cooldownSize + 1, CooldownDisplay.innerBoxSize, CooldownDisplay.innerBoxSize - cooldownSize)

        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawText(CooldownDisplay.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    end

    CooldownDisplay.DrawAbilityLevels(ability, realX, y)
end

function CooldownDisplay.DrawAbilityLevels(ability, x, y)
    local level = Ability.GetLevel(ability)

    x = x + 1
    y = ((y + CooldownDisplay.boxSize) - CooldownDisplay.levelBoxSize) - 1

    for i = 1, level do
        Renderer.SetDrawColor(0, 255, 0, 255)
        Renderer.DrawFilledRect(x + ((i - 1) * CooldownDisplay.levelBoxSize), y, CooldownDisplay.levelBoxSize, CooldownDisplay.levelBoxSize)
        
        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawOutlineRect(x + ((i - 1) * CooldownDisplay.levelBoxSize), y, CooldownDisplay.levelBoxSize, CooldownDisplay.levelBoxSize)
    end
end

function CooldownDisplay.OnDraw()
    if not Menu.IsEnabled(CooldownDisplay.option) then return end

    local myHero = Heroes.GetLocal()

    if not myHero then return end

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        
        if not Entity.IsSameTeam(myHero, hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) then
            CooldownDisplay.DrawDisplay(hero)
        end
    end
end

return CooldownDisplay