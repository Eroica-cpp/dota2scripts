local AbyssalHelper = {}

AbyssalHelper.option = Menu.AddOption({"Utility", "Abyssal Blade Helper"}, "Use Blink Dagger", "use blink dagger if out of range")

-- use OnUpdate() to cancel animation backswing
function AbyssalHelper.OnUpdate()
	if not Menu.IsEnabled(AbyssalHelper.option) then return end

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.IsStunned(myHero) then return end
	
	if not NPC.HasItem(myHero, "item_abyssal_blade", true) then return end
	local abyssal = NPC.GetItem(myHero, "item_abyssal_blade", true)

	if not Ability.IsCastable(abyssal, NPC.GetMana(myHero)) then return end

	local abyssal_cast_range = 140
	local enemies = NPC.GetHeroesInRadius(myHero, abyssal_cast_range, Enum.TeamType.TEAM_ENEMY)
	if not enemies then return end

	local target = enemies[1]
	if target and not NPC.IsIllusion(target) and not Entity.IsDormant(target) and Entity.IsAlive(target) and not NPC.IsStunned(target) then
		Ability.CastTarget(abyssal, target)
	end

end

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

	-- anti-mage
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_antimage" then
		local blink = NPC.GetAbilityByIndex(orders.npc, 1)
		local level = Ability.GetLevel(blink)
		local cast_range = 925 + 75*(level-1)
		local mana = NPC.GetMana(orders.npc)
		
		if NPC.IsEntityInRange(orders.npc, orders.target, cast_range) 
			and Ability.IsCastable(blink, mana) then
			
			local pos = NPC.GetAbsOrigin(orders.target)
			Ability.CastPosition(blink, pos)

			return true
		end
	end

	return true
end

return AbyssalHelper