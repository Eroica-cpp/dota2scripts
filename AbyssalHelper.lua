local AbyssalHelper = {}

AbyssalHelper.option = Menu.AddOption({"Utility", "Abyssal Blade Helper"}, "Use Blink Dagger", "use blink dagger if out of range")

function AbyssalHelper.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(AbyssalHelper.option) then return true end
	if not orders or not orders.npc or not orders.ability then return true end
	
	if not Entity.IsAbility(orders.ability) then return true end
	if Ability.GetName(orders.ability) ~= "item_abyssal_blade" then return true end
	

	return true
end

return AbyssalHelper