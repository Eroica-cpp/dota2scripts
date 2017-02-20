local CooldownDisplay = {}

CooldownDisplay.option = Menu.AddOption({ "Awareness", "Cooldown Display" }, "Cooldown Display", "Displays enemy hero cooldowns in an easy and intuitive way.")
CooldownDisplay.boxSizeOption = Menu.AddOption({ "Awareness", "Cooldown Display" }, "Cooldown Display Size", "", 21, 64, 1)
CooldownDisplay.needsInit = true
CooldownDisplay.spellIconPath = "resource/flash3/images/spellicons/"
CooldownDisplay.cachedIcons = {}

CooldownDisplay.colors = {}

function CooldownDisplay.InsertColor(alias, r_, g_, b_)
    table.insert(CooldownDisplay.colors, { name = alias, r = r_, g = g_, b = b_})
end

CooldownDisplay.InsertColor("Green", 0, 255, 0)
CooldownDisplay.InsertColor("Yellow", 234, 255, 0)
CooldownDisplay.InsertColor("Red", 255, 0, 0)
CooldownDisplay.InsertColor("Blue", 0, 0, 255)
CooldownDisplay.InsertColor("White", 255, 255, 255)
CooldownDisplay.InsertColor("Black", 0, 0, 0)

CooldownDisplay.levelColorOption = Menu.AddOption({ "Awareness", "Cooldown Display" }, "Cooldown Display Level Color", "", 1, #CooldownDisplay.colors, 1)

for i, v in ipairs(CooldownDisplay.colors) do
    Menu.SetValueName(CooldownDisplay.levelColorOption, i, v.name)
end

function CooldownDisplay.InitDisplay()
    CooldownDisplay.boxSize = Menu.GetValue(CooldownDisplay.boxSizeOption)
    CooldownDisplay.innerBoxSize = CooldownDisplay.boxSize - 2
    CooldownDisplay.levelBoxSize = math.floor(CooldownDisplay.boxSize * 0.1875)

    CooldownDisplay.font = Renderer.LoadFont("Tahoma", math.floor(CooldownDisplay.innerBoxSize * 0.643), Enum.FontWeight.BOLD)
end

-- callback
function CooldownDisplay.OnMenuOptionChange(option, old, new)
    if option == CooldownDisplay.boxSizeOption then
        CooldownDisplay.InitDisplay()
    end
end

function CooldownDisplay.DrawDisplay(hero)
    local pos = Entity.GetAbsOrigin(hero)
    pos:SetY(pos:GetY() - 50.0)

    local x, y, vis = Renderer.WorldToScreen(pos)

    if not vis then return end

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)

        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
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
    local abilityName = Ability.GetName(ability)
    local imageHandle = CooldownDisplay.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(CooldownDisplay.spellIconPath .. abilityName .. ".png")
        CooldownDisplay.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * CooldownDisplay.boxSize) + 2

    local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }

    if not castable then
        if Ability.GetLevel(ability) == 0 then
            imageColor = { 125, 125, 125 }
            outlineColor = { 255, 0, 0 }
        elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
            imageColor = { 150, 150, 255 }
            outlineColor = { 0, 0, 255 }
        else
            imageColor = { 255, 150, 150 }
            outlineColor = { 255, 0, 0 }
        end
    end

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, CooldownDisplay.boxSize, CooldownDisplay.boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, CooldownDisplay.boxSize, CooldownDisplay.boxSize)

    local cdLength = Ability.GetCooldownLength(ability)

    if not Ability.IsReady(ability) and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) / cdLength
        local cooldownSize = math.floor(CooldownDisplay.innerBoxSize * cooldownRatio)

        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX + 1, y + (CooldownDisplay.innerBoxSize - cooldownSize) + 1, CooldownDisplay.innerBoxSize, cooldownSize)

        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawText(CooldownDisplay.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    end

    CooldownDisplay.DrawAbilityLevels(ability, realX, y)
end

function CooldownDisplay.DrawAbilityLevels(ability, x, y)
    local level = Ability.GetLevel(ability)

    x = x + 1
    y = ((y + CooldownDisplay.boxSize) - CooldownDisplay.levelBoxSize) - 1

    local color = CooldownDisplay.colors[Menu.GetValue(CooldownDisplay.levelColorOption)]

    for i = 1, level do
        Renderer.SetDrawColor(color.r, color.g, color.b, 255)
        Renderer.DrawFilledRect(x + ((i - 1) * CooldownDisplay.levelBoxSize), y, CooldownDisplay.levelBoxSize, CooldownDisplay.levelBoxSize)
        
        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawOutlineRect(x + ((i - 1) * CooldownDisplay.levelBoxSize), y, CooldownDisplay.levelBoxSize, CooldownDisplay.levelBoxSize)
    end
end

function CooldownDisplay.OnDraw()
    if not Menu.IsEnabled(CooldownDisplay.option) then return end

    local myHero = Heroes.GetLocal()

    if not myHero then return end

    if CooldownDisplay.needsInit then
        CooldownDisplay.InitDisplay()
        CooldownDisplay.needsInit = false
    end

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        
        if not Entity.IsSameTeam(myHero, hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) then
            CooldownDisplay.DrawDisplay(hero)
        end
    end
end

return CooldownDisplay