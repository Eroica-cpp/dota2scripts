local AbyssalHelper = {}

AbyssalHelper.option = Menu.AddOption({"Utility", "Abyssal Blade Helper"}, "Use Blink Dagger", "use blink dagger if out of range")

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
		local pos = NPC.GetAbsOrigin(orders.target)
		Ability.CastPosition(blink, pos)
		return true
	end

	return true
end

return AbyssalHelper