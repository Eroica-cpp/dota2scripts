local Detect = {}

local option = Menu.AddOption({ "Awareness" }, "Detect", "Alerts you when certain abilities are used.")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

Detect.heroEvents = 
{
    {  
        name = "damage_flash",
        msg = "hero right click",
        duration = 1,
        unique = false
    },
    {  
        name = "nyx_assassin_vendetta_start",
        msg = "Nyx has used Vendetta",
        duration = 15,
        unique = true
    },
    {
        name = "smoke_of_deceit",
        msg = "Smoke of Deceit has been used",
        duration = 35,
        unique = false
    }
}

Detect.teamEvents =
{
    -- unique because this particle gets created for every enemy team hero.
    {  
        name = "mirana_moonlight_recipient",
        msg = "Mirana has used her ult",
        duration = 15,
        unique = true
    }
}

local msg = {}

-- heroname2position[npc_name] = {pos = Vector(), time = Int}
local heroname2position = {}

-- spellname2heroname[spellname] = heroname
local spellname2heroname = {}

local tmpPos
local tmpName

local path = "resource/flash3/images/miniheroes/"
local cache = {}

-- know particle's index, spellname; have chance to know entity
function Detect.OnParticleCreate(particle)
    if not particle then return end
    -- Log.Write("1. OnParticleCreate: " .. tostring(particle.index) .. " " .. particle.name .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(Entity.GetAbsOrigin(particle.entity)))
end

-- know particle's index, position
function Detect.OnParticleUpdate(particle)
    if not particle then return end
    -- Log.Write("2. OnParticleUpdate: " .. tostring(particle.index) .. " " .. tostring(particle.position))
    -- Detect.Update(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    tmpPos = particle.position
    if tmpPos and tmpPos:GetX() == 350 then tmpPos = nil end
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end

    -- Log.Write("3. OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
    -- Detect.Update(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    -- tmpName = NPC.GetUnitName(particle.entity)
    tmpPos = particle.position
    if tmpPos and tmpPos:GetX() == 350 then tmpPos = nil end
end

-- npc_name -> {pos, showtime}
function Detect.Update(name, pos, time)
    if not heroname2position then return end

    if not heroname2position[name] then 
        heroname2position[name].pos = pos
        heroname2position[name].time = time
        return
    end
    
    if time > position[name].time then
        heroname2position[name].pos = pos
        heroname2position[name].time = time
    end
end

function Detect.OnDraw()
    -- local myHero = Heroes.GetLocal()
    -- if not myHero then return end

    local name = "npc_dota_hero_lina"
    -- Detect.DrawHero(name, tmpPos)
end

-- draw hero's icon on map or ground
function Detect.DrawHero(heroName, pos)
    if not heroName or not pos then return end

    local handler = cache[heroName]
    if not handler then
        local shortName = string.gsub(heroName, "npc_dota_hero_", "")
        handler = Renderer.LoadImage(path .. shortName .. ".png")
        cache[heroName] = handler
    end

    local size1 = 50
    Renderer.SetDrawColor(255, 255, 255, 255)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.DrawImage(handler, x-math.floor(size1/2), y-math.floor(size1/2), size1, size1)

    local size2 = 20
    Renderer.SetDrawColor(0, 255, 127)
    local map_pos = Detect.WorldToMap(pos)
    local x, y = math.floor(map_pos:GetX()), math.floor(map_pos:GetY())
    Renderer.DrawImage(handler, x, y, size2, size2)

    Log.Write(x .. " " .. y)
    -- local cursorPos = Input.GetWorldCursorPos()
    -- Log.Write(cursorPos:GetX() .. " " .. cursorPos:GetY())
end

-- map: position in world -> position in map (screen)
-- origin in my screen: (6, 575) -> (198, 755)
-- mini word origin: (-3220, -2842) -> (4222, 2838)
-- world origin: (-7600, -7400) -> (8000, 7400)
function Detect.WorldToMap(pos)
    local world_point1 = Vector(-7600, -7400)
    local world_point2 = Vector(8000, 7400)
    local map_point1 = Vector(6, 575)
    local map_point2 = Vector(198, 755)

    local length_world = (world_point2 - world_point1):Length()
    local length_map = (map_point2 - map_point1):Length()

    -- position in map
    return map_point1 + (pos - world_point1):Scaled(length_map/length_world)
end

return Detect