-- package.loaded.Invoker = nil

local Draw = require("Draw")
local Dict = require("Dict")
local Map = require("Map")
local Invoker = require("Invoker")

local Detect = {}

local option = Menu.AddOption({ "Awareness" }, "Detect", "Alerts you when certain abilities are used.")
local optionInvokerMapHack = Menu.AddOption({"Hero Specific", "Invoker Extension"}, "Map Hack", "use information from particle efftects, to tornado tping enemy, or sun strike enemy if it is tping, farming or roshing.")
local optionEnemyAround = Menu.AddOption({ "Awareness" }, "Enemy Around", "Show how many enemy hero around")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

local heroList = {}

-- index -> {name = Str; entity = Object; pos = Vector(), time = Int}
local posInfo = {}

-- index -> spellname
local particleInfo = {}

-- only for few cases
-- index -> heroName
local particleHero = {}

-- For particle effects that cant be tracked by OnParticleUpdateEntity(),
-- but have name info from OnParticleCreate() and position info from OnParticleUpdate()
-- (has been replaced by Dict.Phrase2HeroName())
-- spellname -> heroname 
local spellName2heroName = {}

-- know particle's index, spellname; have chance to know entity
-- Entity.GetAbsOrigin(particle.entity) is not correct. It just shows last seen position.
-- NPC.GetUnitName(particle.entity) can be useful, like know blink start position, smoke position, etc
function Detect.OnParticleCreate(particle)
    if not particle or not particle.index then return end
    
    -- Log.Write("1. OnParticleCreate: " .. tostring(particle.index) .. " " .. particle.name .. " " .. NPC.GetUnitName(particle.entity))
    
    particleInfo[particle.index] = particle.name

    if particle.entity then 
        particleHero[particle.index] = NPC.GetUnitName(particle.entity)
    end
end

-- know particle's index, position
function Detect.OnParticleUpdate(particle)
    if not particle or not particle.index then return end
    if not particle.position or not Map.IsValidPos(particle.position) then return end
    
    -- Log.Write("2. OnParticleUpdate: " .. tostring(particle.index) .. " " .. tostring(particle.position))
    
    if not particleInfo[particle.index] then return end

    local spellname = particleInfo[particle.index]
    local name = Dict.Phrase2HeroName(spellname)
    if not name or name == "" then name = particleHero[particle.index] end
    
    Detect.Update(name, nil, particle.position, GameRules.GetGameTime())

    if Menu.IsEnabled(optionInvokerMapHack) then
        Invoker.MapHack(particle.position, spellname)
    end
end

-- know particle's index, position, entity
function Detect.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.entity or not NPC.IsHero(particle.entity) then return end
    if not particle.position or not Map.IsValidPos(particle.position) then return end

    -- Log.Write("3. OnParticleUpdateEntity: " .. tostring(particle.index) .. " " .. NPC.GetUnitName(particle.entity) .. " " .. tostring(particle.position))
    
    Detect.Update(NPC.GetUnitName(particle.entity), particle.entity, particle.position, GameRules.GetGameTime())

    Invoker.MapHack(particle.position, "")
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
    if not myHero then
        heroList, posInfo, particleInfo, particleHero = {}, {}, {}, {}
        return
    end

    local pos = Entity.GetAbsOrigin(myHero)
    local counter = 0
    local radius = 1500

    -- update hero list
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        local name = NPC.GetUnitName(hero)
        if not heroList[name] and not NPC.IsIllusion(hero) then
            heroList[name] = hero
        end
    end

    -- threshold for elapsed time
    local threshold = 3

    Draw.DrawMap()

    -- draw visible enemy on new map
    for name, enemy in pairs(heroList) do
        if enemy and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
            Draw.DrawHeroOnMap(name, Entity.GetAbsOrigin(enemy))
        end
    end

    -- draw enemy position given by particle effects
    for i, info in ipairs(posInfo) do
        if info and info.name and info.pos and info.time and math.abs(GameRules.GetGameTime() - info.time) <= threshold then

            -- no need to draw visible enemy hero on the ground
            if not heroList[info.name] or Entity.IsDormant(heroList[info.name]) then
                Draw.DrawHeroOnGround(info.name, info.pos)
            end

            -- no need to draw ally
            if not heroList[info.name] or not Entity.IsSameTeam(myHero, heroList[info.name]) then
                Draw.DrawHeroOnMap(info.name, info.pos)
            end
        end
    end

    -- show how many enemy hero around
    if not Menu.IsEnabled(optionEnemyAround) then
        -- TBD
    end
end

return Detect