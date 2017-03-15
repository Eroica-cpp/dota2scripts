local Axe = {}

Axe.optionAutoItem = Menu.AddOption({"Hero Specific", "Axe"}, "Auto Use Items", "Auto use items like blademail, lotus when calling")
Axe.optionBlinkHelper = Menu.AddOption({"Hero Specific", "Axe"}, "Blink Helper", "Auto blink to best position when calling")

-- blink to best position before call
function Axe.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Axe.optionBlinkHelper) then return true end
	if not orders or not orders.ability then return true end

	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "axe_berserkers_call" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    local call_radius = 300
    local blink_radius = 1200

    return true
end

-- auto use items when calling enemy heroes (blademail, lotus, etc)
function Axe.OnUpdate()
	if not Menu.IsEnabled(Axe.optionAutoItem) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or not NPC.HasModifier(myHero, "modifier_axe_berserkers_call_armor") then return end

    local call_radius = 300
    local enemyHeroes = NPC.GetHeroesInRadius(myHero, call_radius, Enum.TeamType.TEAM_ENEMY)
    if #enemyHeroes > 0 then
	    Axe.PopItems(myHero)
	end

end

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