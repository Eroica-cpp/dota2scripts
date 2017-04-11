local Draw = require("Draw")

local Detect = {}

local option = Menu.AddOption({ "Awareness" }, "Detect", "Alerts you when certain abilities are used.")

Detect.heroEvents = {}

Detect.teamEvents = {}

-- index -> {name = Str; entity = Object; pos = Vector(), time = Int}
local posInfo = {}

-- spellname2heroname[spellname] = heroname
local spellname2heroname = {}

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
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end

    Log.Write("3. OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
    
    -- Detect.Update(name, entity, pos, time)
    Detect.Update(NPC.GetUnitName(particle.entity), particle.entity, particle.position, GameRules.GetGameTime())
end

function Detect.Update(name, entity, pos, time)
    if not posInfo then return end

    local info = {}
    for i, val in ipairs(posInfo) do
        if val.name == name then
            if name then info.name = name end
            if entity then info.entity = entity end
            if pos then info.pos = pos end
            if time then info.time = time end
            posInfo[i] = info
            return
        end
    end

    info.name, info.entity, info.pos, info.time = name, entity, pos, time
    table.insert(posInfo, info)
end

function Detect.OnDraw()
    if not Menu.IsEnabled(option) then return end
    if not Engine.IsInGame() then return end

    -- threshold for elapsed time
    local threshold = 3

    Draw.DrawMap()

    for i, info in ipairs(posInfo) do
        if info and info.name and info.entity and info.pos and info.time and math.abs(GameRules.GetGameTime() - info.time) <= threshold then

            -- no need to draw visible hero on the ground
            -- if Entity.IsDormant(info.entity) then
            Draw.DrawHeroOnGround(info.name, info.pos)
            -- end

            Draw.DrawHeroOnMap(info.name, info.pos)
        end
    end
end

return Detect