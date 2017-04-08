local AbilityAlert = {}

AbilityAlert.option = Menu.AddOption({ "Awareness" }, "Ability Alert", "Alerts you when certain abilities are used.")
AbilityAlert.font = Renderer.LoadFont("Tahoma", 22, Enum.FontWeight.EXTRABOLD)
AbilityAlert.mapFont = Renderer.LoadFont("Tahoma", 16, Enum.FontWeight.NORMAL)

-- current active alerts.
AbilityAlert.alerts = {}

AbilityAlert.ambiguous =
{
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

AbilityAlert.teamSpecific = 
{
    -- unique because this particle gets created for every enemy team hero.
    {  
        name = "mirana_moonlight_recipient",
        msg = "Mirana has used her ult",
        duration = 15,
        unique = true
    }
}

-- Returns true if an alert was created, false otherwise.
function AbilityAlert.InsertAmbiguous(particle)
    for i, enemyAbility in ipairs(AbilityAlert.ambiguous) do
        if particle.name == enemyAbility.name then
            local newAlert = {
                index = particle.index,
                name = enemyAbility.name,
                msg = enemyAbility.msg,
                endTime = os.clock() + enemyAbility.duration,
            }

            table.insert(AbilityAlert.alerts, newAlert)

            return true
        end
    end

    return false
end

-- Returns true if an alert was created (or an existing one was extended), false otherwise.
function AbilityAlert.InsertTeamSpecific(particle)
    local myHero = Heroes.GetLocal()
    if not myHero then return false end

    if particle.entity == nil then return end
    if Entity.IsSameTeam(myHero, particle.entity) then return end

    for i, enemyAbility in ipairs(AbilityAlert.teamSpecific) do
        if particle.name == enemyAbility.name then
            local newAlert = {
                index = particle.index,
                name = enemyAbility.name,
                msg = enemyAbility.msg,
                endTime = os.clock() + enemyAbility.duration,
            }

            if not enemyAbility.unique then
                table.insert(AbilityAlert.alerts, newAlert)
                
                return true
            else 
                -- Look for an existing alert.
                for k, alert in ipairs(AbilityAlert.alerts) do
                    if alert.msg == newAlert.msg then
                        alert.endTime = newAlert.endTime -- Just extend the existing time.

                        return true
                    end
                end

                -- Insert the new alert.
                table.insert(AbilityAlert.alerts, newAlert)

                return true
            end
        end
    end

    return false
end

--
-- Callbacks
--
function AbilityAlert.OnParticleCreate(particle)
    --Log.Write(particle.name .. "=" .. string.format("0x%x", particle.particleNameIndex))

    if not Menu.IsEnabled(AbilityAlert.option) then return end

    if not AbilityAlert.InsertAmbiguous(particle) then
        AbilityAlert.InsertTeamSpecific(particle)
    end
end

function AbilityAlert.OnParticleUpdate(particle)
    if particle.controlPoint ~= 0 then return end

    for k, alert in ipairs(AbilityAlert.alerts) do
        if particle.index == alert.index then
            alert.position = particle.position
        end
    end
end

function AbilityAlert.OnDraw()
    for i, alert in ipairs(AbilityAlert.alerts) do
        local timeLeft = math.max(alert.endTime - os.clock(), 0)

        if timeLeft <= 0 then
            table.remove(AbilityAlert.alerts, i)
        else
            -- Fade out the last 5 seconds of the alert.
            local alpha = math.floor(255 * math.min(timeLeft / 5, 1))

            -- Some really obnoxious color to grab your attention.
            Renderer.SetDrawColor(255, 0, 255, alpha)

            local w, h = Renderer.GetScreenSize()

            Renderer.DrawTextCentered(AbilityAlert.font, w / 2, h / 2 + (i - 1) * 22, alert.msg, 1)

            if alert.position then 
                local x, y, onScreen = Renderer.WorldToScreen(alert.position)

                if onScreen then
                    Renderer.DrawTextCentered(AbilityAlert.mapFont, x, y, alert.name, 1)
                    --Renderer.DrawFilledRect(x - 5, y - 5, 10, 10)
                end
            end
        end
    end
end

return AbilityAlert
