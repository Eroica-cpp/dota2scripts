-- File: Bristleback.lua
-- Author: EroicaCpp (https://eroicacpp.com/dota2/)
-- Version: 1.0
-- Date: June 9, 2017

local Utility = require("Utility")

local Bristleback = {}

local optionAutoGoo = Menu.AddOption({"Hero Specific", "Bristleback"}, "Auto Goo", "Auto cast Goo once a enemy is in range")
local optionAutoQuill = Menu.AddOption({"Hero Specific", "Bristleback"}, "Auto Quill", "Auto cast Quill once enemies are in range")
local key = Menu.AddKeyOption({"Hero Specific", "Bristleback"}, "Activate Auto Spells Key", Enum.ButtonCode.KEY_E)
local font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

function Bristleback.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or not NPC.GetUnitName(myHero) == "npc_dota_hero_bristleback" then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end

    if Menu.IsEnabled(optionAutoGoo) then
        Bristleback.AutoGoo(myHero)
    end

    if Menu.IsEnabled(optionAutoQuill) then
        Bristleback.AutoQuill(myHero)
    end
end

function Bristleback.AutoGoo(myHero)
    local goo = NPC.GetAbility(myHero, "bristleback_viscous_nasal_goo")
    if not goo or not Ability.IsCastable(goo, NPC.GetMana(myHero)) then return end

    local range = 600
    local enemies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    for i, npc in ipairs(enemies) do
        if not NPC.IsIllusion(npc) and Utility.CanCastSpellOn(npc) then
            if NPC.HasItem(myHero, "item_ultimate_scepter", true) then
                Ability.CastNoTarget(goo); return
            elseif not Utility.IsLotusProtected(npc) then
                Ability.CastTarget(goo, npc); return
            end
        end
    end
end

function Bristleback.AutoQuill(myHero)
    local quill = NPC.GetAbility(myHero, "bristleback_quill_spray")
    if not quill or not Ability.IsCastable(quill, NPC.GetMana(myHero)) then return end

    local range = 700
    local enemies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    for i, npc in ipairs(enemies) do
        if not NPC.IsIllusion(npc) then
            Ability.CastNoTarget(quill); return
        end
    end
end

return Bristleback
