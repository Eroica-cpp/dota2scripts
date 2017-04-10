local Draw = {}

-- draw a new map right next to build-in map
-- new map position: (230, 630) -> (370, 765)
local map_size = 120
local map_origin = Vector(230, 630)

local path = "resource/flash3/images/miniheroes/"
local cache = {}

function Draw.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    local name = "npc_dota_hero_lina"
    local pos = Entity.GetAbsOrigin(myHero)
    -- Draw.DrawHero(name, pos)
end


-- draw hero's icon on map or ground
function Draw.DrawHero(heroName, pos)
    if not heroName or not pos then return end

    local handler = cache[heroName]
    if not handler then
        local shortName = string.gsub(heroName, "npc_dota_hero_", "")
        handler = Renderer.LoadImage(path .. shortName .. ".png")
        cache[heroName] = handler
    end

    local size = 50
    Renderer.SetDrawColor(255, 255, 255, 255)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.DrawImage(handler, x-math.floor(size/2), y-math.floor(size/2), size, size)

    local x, y = Draw.WorldToMap(pos)
    Draw.DrawOnMap(handler, x, y)

end

function Draw.DrawOnMap(handler, x, y)
    if Input.IsCursorInRect(map_origin:GetX(), map_origin:GetY(), map_size, map_size) and Input.IsKeyDown(Enum.ButtonCode.KEY_LALT) then
        local cursor_x, cursor_y = Renderer.WorldToScreen(Input.GetWorldCursorPos())
        map_origin = Vector(cursor_x - map_size/2, cursor_y - map_size/2)
    end

    Renderer.SetDrawColor(255, 255, 255, 255)
    Renderer.DrawFilledRect(map_origin:GetX(), map_origin:GetY(), map_size, map_size)

    if not handler or not x or not y then return end
    Renderer.DrawImage(handler, x, y)
end

-- map: position in world -> position in map (screen)
-- origin in my screen: (6, 575) -> (198, 755)
-- mini word origin: (-3220, -2842) -> (4222, 2838)
-- world origin: (-7600, -7400) -> (8000, 7400)
function Draw.WorldToMap(pos)
    local world_origin = Vector(-7600, -7400)
    local world_end = Vector(8000, 7400)

    local world_len = (world_end - world_origin):Length()
    local map_len = map_size * math.sqrt(2)

    local map_pos = map_origin + (pos - world_origin):Scaled(map_len/world_len)
    return map_pos:GetX(), map_pos:GetY()
end

return Draw