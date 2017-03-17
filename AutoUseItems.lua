local AutoUseItems = {}

AutoUseItems.optionQuellingBlade = Menu.AddOption({"Item Specific"}, "Quelling Blade", "Auto use quelling blade to deward")

function AutoUseItems.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end

    if Menu.IsEnabled(AutoUseItems.optionQuellingBlade) then
    	AutoUseItems.item_quelling_blade(myHero)
    end

end

-- auto use quelling_blade to deward
function AutoUseItems.item_quelling_blade(myHero)
	if not NPC.HasItem(myHero, "item_quelling_blade", true) then return end
	local item = NPC.GetItem(myHero, "item_quelling_blade", true)

	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
		local cast_range = 450
		local units = NPC.GetUnitsInRadius(myHero, cast_range, Enum.TeamType.TEAM_ENEMY)
		for i, npc in ipairs(units) do
			if NPC.GetUnitName(npc) == "npc_dota_observer_wards" or NPC.GetUnitName(npc) == "npc_dota_sentry_wards" then
				Ability.CastTarget(item, npc)
				break
			end
		end
	end
end

return AutoUseItems