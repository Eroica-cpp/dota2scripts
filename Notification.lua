local Utility = require("Utility")
local Map = require("Map")

local Notification = {}

local optionRoshan = Menu.AddOption({"Awareness", "Notification"}, "Roshan", "Notify teammates (print on the screen) when someone's roshing.")

-- function Notification.OnUpdate()
--     if not Menu.IsEnabled(optionRoshan) then return end
--
--     local myHero = Heroes.GetLocal()
--     if not myHero then return end
--     Chat.Say("DOTAChannelType_GameAllies", "dota wtf")
-- end

function Notification.OnParticleUpdate(particle)
    if not particle or not particle.index then return end
    if not particle.position or not Map.IsValidPos(particle.position) then return end

    if Menu.IsEnabled(optionRoshan) and Map.InRoshan(particle.position) then
        Chat.Say("DOTAChannelType_GameAllies", "Someone is roshing!")
    end
end

-- function Notification.OnParticleUpdateEntity(particle)
--     if not particle then return end
--     if not particle.entity or not NPC.IsHero(particle.entity) then return end
--     if not particle.position or not Map.IsValidPos(particle.position) then return end
--
--     if Menu.IsEnabled(optionRoshan) and Map.InRoshan(particle.position) then
--         Chat.Say("DOTAChannelType_GameAllies", "Someone is roshing!")
--     end
-- end

return Notification
