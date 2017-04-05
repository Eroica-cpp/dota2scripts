-- =========================================
-- Author  : Eroica (eroicacmcs@gmail.com)
-- Desc    : Abyssal Blade Helper
-- Date    : 2017.3.14
-- Version : 1.0
-- =========================================

local AbyssalHelper = {}

AbyssalHelper.option = Menu.AddOption({"Utility"}, "Abyssal Blade Helper", "auto use blink dagger, AM's blink, or PA's strike if out of range")

function AbyssalHelper.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(AbyssalHelper.option) then return true end
	if not orders or not orders.npc or not orders.ability  or not orders.target then return true end
	
	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "item_abyssal_blade" then return true end

	local abyssal_cast_range = 140
	if NPC.IsEntityInRange(orders.npc, orders.target, abyssal_cast_range) then return true end

	-- use blink dagger if out of range
	local blink_cast_range = 1200
	if NPC.HasItem(orders.npc, "item_blink", true) 
		and NPC.IsEntityInRange(orders.npc, orders.target, blink_cast_range) then

		local blink = NPC.GetItem(orders.npc, "item_blink", true)
		local pos = Entity.GetAbsOrigin(orders.target)
		Ability.CastPosition(blink, pos)
		return true
	end

	-- anti-mage
	if NPC.GetUnitName(orders.npc) == "npc_dota_hero_antimage" then
		local blink = NPC.GetAbilityByIndex(orders.npc, 1)
		local level = Ability.GetLevel(blink)
		local cast_range = 925 + 75*(level-1)
		local mana = NPC.GetMana(orders.npc)
		
		if NPC.IsEntityInRange(orders.npc, orders.target, cast_range) 
			and Ability.IsCastable(blink, mana) then
			
			local pos = Entity.GetAbsOrigin(orders.target)
			Ability.CastPosition(blink, pos)

			return true
		end
	end

	-- PA
	if NPC.GetUnitName(orders.npc) == "npc_dota_hero_phantom_assassin" then
		local strike = NPC.GetAbilityByIndex(orders.npc, 1)
		local cast_range = 1000
		local mana = NPC.GetMana(orders.npc)

		if NPC.IsEntityInRange(orders.npc, orders.target, cast_range) 
			and Ability.IsCastable(strike, mana) then

			Ability.CastTarget(strike, orders.target)

			return true
		end
	end

	return true
end

return AbyssalHelper