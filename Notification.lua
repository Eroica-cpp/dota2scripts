local Utility = require("Utility")
local Map = require("Map")

local Notification = {}

local optionRoshan = Menu.AddOption({"Awareness", "Notification"}, "Roshan", "Notify teammates (print on the screen) when someone's roshing.")
local optionParticleEffect = Menu.AddOption({"Awareness", "Notification"}, "Particle Effect", "Notify teammates (print on the screen) when certain particle effects happen.")

local ParticleEffectList = {
    mirana_moonlight_recipient = "Mirana has used her ultimate.",
    smoke_of_deceit = "Smoke of Deceit has been used.",
    nyx_assassin_vendetta_start = "Nyx has used Vendetta."
}

function Notification.OnParticleCreate(particle)
    if not particle then return end
    if Menu.IsEnabled(optionParticleEffect) and particle.name and ParticleEffectList[particle.name] then
        Chat.Say("DOTAChannelType_GameAllies", ParticleEffectList[particle.name])
    end
end

function Notification.OnParticleUpdate(particle)
    if not particle or not particle.index then return end
    if not particle.position or not Map.IsValidPos(particle.position) then return end

    if Menu.IsEnabled(optionRoshan) and Map.InRoshan(particle.position) then
        Chat.Say("DOTAChannelType_GameAllies", "Someone is roshing!")
    end
end

function Notification.OnParticleUpdateEntity(particle)
    if not particle then return end
    if not particle.position or not Map.IsValidPos(particle.position) then return end

    if Menu.IsEnabled(optionRoshan) and Map.InRoshan(particle.position) then
        Chat.Say("DOTAChannelType_GameAllies", "Someone is roshing!")
    end
end

return Notification
