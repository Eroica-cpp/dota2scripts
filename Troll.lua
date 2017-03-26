local Troll = {}

Troll.optionEnable = Menu.AddOption({"Hero Specific", "Troll Warlord"}, "Auto Swap", "Auto Swap between range and melee")

function Troll.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Troll.optionEnable) then return true end
	if not orders then return true end

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_troll_warlord" then return true end
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return true end

	local swap = NPC.GetAbilityByIndex(myHero, 0)
	if not swap or not Ability.IsCastable(swap, 0) then return true end

	-- swap to melee when running
	if not Ability.GetToggleState(swap) and 
		(orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION 
			or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET 
			or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE) 
		then
		Ability.Toggle(swap, true)
		return true
	end

	-- auto swap between melee and range
	local melee_attack_range = 150
	local range = melee_attack_range + 100
	if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET then
		if NPC.IsEntityInRange(myHero, orders.target, range) and not Ability.GetToggleState(swap) then
			Ability.Toggle(swap, true)
			return true
		end

		if not NPC.IsEntityInRange(myHero, orders.target, range) and Ability.GetToggleState(swap) then
			Ability.Toggle(swap, true)
			return true
		end
	end

	return true
end

return Troll