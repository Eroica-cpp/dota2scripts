local Nyx = {}

Nyx.optionCombo = Menu.AddOption({"Hero Specific", "Nyx Assassin"}, "Attack & Impale Combo", "use impale right after attack that break invisible")

-- use impale right after attack that break invisible
function Nyx.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(Nyx.optionCombo) then return true end
	if not orders or not orders.order then return true end

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_nyx_assassin" then return true end
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return true end

	if not NPC.HasModifier(myHero, "modifier_nyx_assassin_vendetta") then return true end
	if orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET and orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE then return true end

	local impale = NPC.GetAbilityByIndex(myHero, 0)
	if not impale or not Ability.IsCastable(impale, NPC.GetMana(myHero)) then return true end

	if not orders.target then return true end
	-- Player.AttackTarget(Players.GetLocal(), myHero, orders.target)
	-- Ability.CastPosition(impale, Entity.GetAbsOrigin(orders.target))
	return true
end

return Nyx