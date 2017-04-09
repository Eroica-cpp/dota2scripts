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
    Log.Write("OnParticleCreate: " .. tostring(particle.index) .. " " .. particle.name .. " " .. NPC.GetUnitName(particle.entity))
end

-- know particle's index, position
function Detect.OnParticleUpdate(particle)
    if not particle then return end
    Log.Write("OnParticleUpdate: " .. tostring(particle.index) .. " " .. tostring(particle.position))
    -- Detect.UpdatePos(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    tmpPos = particle.position
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end

    Log.Write("OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
    -- Detect.UpdatePos(NPC.GetUnitName(particle.entity), particle.position, GameRules.GetGameTime())
    -- tmpName = NPC.GetUnitName(particle.entity)
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
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    local name = "npc_dota_hero_lina"
    Detect.DrawMiniHero(name, Entity.GetAbsOrigin(myHero))
end

function Detect.DrawMiniHero(heroName, pos)
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
end

return Detect