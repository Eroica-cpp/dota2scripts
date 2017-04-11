local Draw = require("Draw")

local Detect = {}

local option = Menu.AddOption({ "Awareness" }, "Detect", "Alerts you when certain abilities are used.")

local enemyList = {}

-- index -> {name = Str; entity = Object; pos = Vector(), time = Int}
local posInfo = {}

-- index -> spellname
local particleInfo = {}

-- spellname -> heroname
local spellName2heroName = {}

-- know particle's index, spellname; have chance to know entity
function Detect.OnParticleCreate(particle)
    if not particle or not particle.index then return end
    Log.Write("1. OnParticleCreate: " .. tostring(particle.index) .. " " .. particle.name .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(Entity.GetAbsOrigin(particle.entity)))
    particleInfo[particle.index] = particle.name

    if particle.entity then
        Detect.Update(NPC.GetUnitName(particle.entity), particle.entity, Entity.GetAbsOrigin(particle.entity), GameRules.GetGameTime())
    end
end

-- know particle's index, position
function Detect.OnParticleUpdate(particle)
    if not particle or not particle.index then return end
    if not particleInfo[particle.index] then return end

    local spellname = particleInfo[particle.index]
    local name = spellName2heroName[spellname]
    Log.Write("2. OnParticleUpdate: " .. tostring(particle.index) .. " " .. tostring(particle.position))
    Detect.Update(name, nil, particle.position, GameRules.GetGameTime())
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end

    Log.Write("3. OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
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

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    -- update enemy list
    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        local name = NPC.GetUnitName(enemy)
        if not enemyList[name] and not Entity.IsSameTeam(myHero, enemy) and not NPC.IsIllusion(enemy) then
            enemyList[name] = enemy
        end
    end

    -- threshold for elapsed time
    local threshold = 3

    Draw.DrawMap()

    for i, info in ipairs(posInfo) do
        if info and info.name and info.pos and info.time and math.abs(GameRules.GetGameTime() - info.time) <= threshold then

            -- no need to draw visible enemy hero on the ground
            if not enemyList[info.name] or Entity.IsDormant(enemyList[info.name]) then
                Draw.DrawHeroOnGround(info.name, info.pos)
            end

            Draw.DrawHeroOnMap(info.name, info.pos)
        end
    end
end

return Detect