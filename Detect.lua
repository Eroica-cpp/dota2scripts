local Detect = {}

local option = Menu.AddOption({ "Awareness" }, "Detect", "Alerts you when certain abilities are used.")

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

function Detect.OnParticleCreate(particle)
    if not Menu.IsEnabled(option) or not particle then return end

    --Log.Write(particle.name .. "=" .. string.format("0x%x", particle.particleNameIndex))
    Log.Write(particle.name .. " " .. tostring(particle.position))
end

return Detect