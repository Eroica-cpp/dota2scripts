-- =============================
-- Usage:
-- Draw.DrawMap()
-- Draw.DrawHeroOnMap(name, pos)
-- Draw.DrawHeroOnGround(name, pos)
-- =============================

local Draw = {}

-- draw a new map right next to build-in map
-- new map position: (238, 606) -> (370, 765)
local map_size = 160
local map_origin = Vector(238, 606)

local path = "resource/flash3/images/miniheroes/"
local cache = {}

function Draw.DrawHeroOnGround(heroName, pos)
    if not heroName or not pos then return end

    local handler = cache[heroName]
    if not handler then
        local shortName = string.gsub(heroName, "npc_dota_hero_", "")
        handler = Renderer.LoadImage(path .. shortName .. ".png")
        cache[heroName] = handler
    end

    Renderer.SetDrawColor(255, 255, 255, 255)    
    local size = 50
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.DrawImage(handler, math.floor(x-size/2), math.floor(y-size/2), size, size)
end

function Draw.DrawHeroOnMap(heroName, pos)
    if not heroName or not pos then return end

    local handler = cache[heroName]
    if not handler then
        local shortName = string.gsub(heroName, "npc_dota_hero_", "")
        handler = Renderer.LoadImage(path .. shortName .. ".png")
        cache[heroName] = handler
    end

    Renderer.SetDrawColor(255, 255, 255, 255)
    local size = 28
    local x, y = Draw.WorldToMap(pos)
    Renderer.DrawImage(handler, math.floor((x-size/2)), math.floor(y-size/2), size, size)
end

function Draw.DrawMap()
    if Input.IsCursorInRect(map_origin:GetX(), map_origin:GetY(), map_size, map_size) and Input.IsKeyDown(Enum.ButtonCode.KEY_LALT) then
        local cursor_x, cursor_y = Renderer.WorldToScreen(Input.GetWorldCursorPos())
        map_origin = Vector(cursor_x - map_size/2, cursor_y - map_size/2)
    end

    Renderer.SetDrawColor(255, 255, 255, 255)
    Renderer.DrawFilledRect(map_origin:GetX(), map_origin:GetY(), map_size, map_size)
end

-- map: position in world -> position in map (screen)
-- mini world origin: (-3220, -2842) -> (4222, 2838)
-- world origin: (-7600, -7400) -> (8000, 7400)
function Draw.WorldToMap(pos)
    local world_origin = Vector(-7600, -7400)
    local world_end = Vector(8000, 7400)

    local world_len = (world_end - world_origin):Length()
    local map_len = map_size * math.sqrt(2)

    local dir = (pos - world_origin):Scaled(map_len/world_len)

    local map_x = map_origin:GetX() + dir:GetX()
    local map_y = map_origin:GetY() + (map_size - dir:GetY())

    return math.floor(map_x), math.floor(map_y)
end

return Draw