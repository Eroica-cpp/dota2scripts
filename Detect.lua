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
    -- Detect.UpdatePos(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    tmpPos = particle.position
    if tmpPos and tmpPos:GetX() == 350 then tmpPos = nil end
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end

    -- Log.Write("3. OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
    -- Detect.UpdatePos(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    -- tmpName = NPC.GetUnitName(particle.entity)
    tmpPos = particle.position
    if tmpPos and tmpPos:GetX() == 350 then tmpPos = nil end
end

-- npc_name -> {pos, showtime}
function Detect.UpdatePos(name, pos, time)
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
    if tmpPos then
        -- Detect.DrawHero(name, tmpPos)
    end
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
    local x, y, visible = Renderer.WorldToScreen(Input.GetWorldCursorPos())
    Renderer.DrawImage(handler, x, y, size2, size2)

    local cursorPos = Input.GetWorldCursorPos()
    Log.Write(cursorPos:GetX() .. " " .. cursorPos:GetY())
end

-- origin in my screen: (6, 575) -> (198, 755)
-- world origin: (-3220, -2842) -> (4222, 2838)
function Detect.WorldToMap(pos)
    local x1, y1 = 6, 575
    local x2, y2 = 198, 755
    local width = x2 - x1
    local height = y2 - y1
end

return Detect