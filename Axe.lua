local Utility = require("Utility")

local Axe = {}

Axe.optionAutoItem = Menu.AddOption({"Hero Specific", "Axe"}, "Auto Use Items", "Auto use items like blademail, lotus when calling")
Axe.optionBlinkHelper = Menu.AddOption({"Hero Specific", "Axe"}, "Blink Helper", "Auto blink to best position when calling")
Axe.optionAutoInitiate = Menu.AddOption({"Hero Specific", "Axe"}, "Auto Initiate", "Auto initiate once see enemy heroes (can be turn on/off by key)")
Axe.key = Menu.AddKeyOption({"Hero Specific", "Axe"}, "Auto Initiate Key", Enum.ButtonCode.KEY_E)
Axe.font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

local shouldAutoInitiate = false

-- blink to best position before call
function Axe.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Axe.optionBlinkHelper) then return true end
	if not orders or not orders.ability then return true end

	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "axe_berserkers_call" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) then return true end

    if not NPC.HasItem(myHero, "item_blink", true) then return true end
    local blink = NPC.GetItem(myHero, "item_blink", true)
    if not blink or not Ability.IsCastable(blink, 0) then return true end

    local call_radius = 300
    local blink_radius = 1200

    local enemyHeroes = NPC.GetHeroesInRadius(myHero, blink_radius, Enum.TeamType.TEAM_ENEMY)
    if not enemyHeroes or #enemyHeroes <= 0 then return true end

    local pos = Utility.BestPosition(enemyHeroes, call_radius)
    if pos then
    	Ability.CastPosition(blink, pos)
    end

    return true
end

-- auto use items when calling enemy heroes (blademail, lotus, etc)
function Axe.OnUpdate()
	if not Menu.IsEnabled(Axe.optionAutoItem) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or not NPC.HasModifier(myHero, "modifier_axe_berserkers_call_armor") then return end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) then return end

    -- local mod = NPC.GetModifier(myHero, "modifier_axe_berserkers_call_armor")
    -- if mod and GameRules.GetGameTime() - Modifier.GetCreationTime(mod) > 0.1 then return end

    local call_radius = 300
    local enemyHeroes = NPC.GetHeroesInRadius(myHero, call_radius, Enum.TeamType.TEAM_ENEMY)
    if #enemyHeroes > 0 then
	    Axe.PopItems(myHero)
	end

end

-- auto initiate when enemy heroes are near 
-- (this mode can be turn on/off by pressing key)
function Axe.OnDraw()
	if not Menu.IsEnabled(Axe.optionAutoInitiate) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_axe" then return end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	if Menu.IsKeyDownOnce(Axe.key) then
		shouldAutoInitiate = not shouldAutoInitiate
	end

	if not shouldAutoInitiate then return end

	-- draw text when auto initiate key is up
	local pos = NPC.GetAbsOrigin(myHero)
	local x, y, visible = Renderer.WorldToScreen(pos)
	Renderer.SetDrawColor(0, 255, 0, 255)
	Renderer.DrawTextCentered(Axe.font, x, y, "Auto", 1)

	if not NPC.HasItem(myHero, "item_blink", true) then return end
    local blink = NPC.GetItem(myHero, "item_blink", true)
    if not blink or not Ability.IsCastable(blink, 0) then return end

    local call = NPC.GetAbilityByIndex(myHero, 0)
    if not call or not Ability.IsCastable(call, NPC.GetMana(myHero)) then return end

    local call_radius = 300
    local blink_radius = 1200

    local enemyHeroes = NPC.GetHeroesInRadius(myHero, blink_radius, Enum.TeamType.TEAM_ENEMY)
    if not enemyHeroes or #enemyHeroes <= 0 then return end

    local pos = Utility.BestPosition(enemyHeroes, call_radius)
    if pos then
    	Ability.CastPosition(blink, pos)
    end
    Ability.CastNoTarget(call)

end

-- pop all useful items
function Axe.PopItems(myHero)
	if not myHero then return end

    -- blade mail
    if NPC.HasItem(myHero, "item_blade_mail", true) then
    	local item = NPC.GetItem(myHero, "item_blade_mail", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- buckler
    if NPC.HasItem(myHero, "item_buckler", true) then
    	local item = NPC.GetItem(myHero, "item_buckler", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- hood of defiance
    if NPC.HasItem(myHero, "item_hood_of_defiance", true) then
    	local item = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- pipe of insight
    if NPC.HasItem(myHero, "item_pipe", true) then
    	local item = NPC.GetItem(myHero, "item_pipe", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- crimson guard
    if NPC.HasItem(myHero, "item_crimson_guard", true) then
    	local item = NPC.GetItem(myHero, "item_crimson_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- shiva's guard
    if NPC.HasItem(myHero, "item_shivas_guard", true) then
    	local item = NPC.GetItem(myHero, "item_shivas_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- lotus orb
    if NPC.HasItem(myHero, "item_lotus_orb", true) then
    	local item = NPC.GetItem(myHero, "item_lotus_orb", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

    -- mjollnir
    if NPC.HasItem(myHero, "item_mjollnir", true) then
    	local item = NPC.GetItem(myHero, "item_mjollnir", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

end

return Axe