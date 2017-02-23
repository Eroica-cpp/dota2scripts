local InvokerExtended = {}

InvokerExtended.autoSunStrikeOption = Menu.AddOption({"Hero Specific", "Invoker Extended"}, "Auto Sun Strike", "On/Off")
InvokerExtended.autoAlacrityOption = Menu.AddOption({"Hero Specific", "Invoker Extended"}, "Auto Alacrity", "On/Off")
InvokerExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function InvokerExtended.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return end

	local Q = NPC.GetAbilityByIndex(myHero, 0)
	local W = NPC.GetAbilityByIndex(myHero, 1)
	local E = NPC.GetAbilityByIndex(myHero, 2)
	local R = NPC.GetAbilityByIndex(myHero, 5)

	if Menu.IsEnabled(InvokerExtended.autoAlacrityOption) then
		InvokerExtended.AutoAlacrity(myHero, Q, W, E, R)
	end

	if Menu.IsEnabled(InvokerExtended.autoSunStrikeOption) then
		InvokerExtended.AutoSunStrike(myHero, Q, W, E, R)
	end
end

function InvokerExtended.AutoAlacrity(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local alacrity = NPC.GetAbility(myHero, "invoker_alacrity")

end

function InvokerExtended.AutoSunStrike(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
	Log.Write("ok for now !!")
end

return InvokerExtended