local Magnus = {}

Magnus.optionEmpower = Menu.AddOption({"Hero Specific", "Magnus"}, "Auto Empower", "auto cast empower on allies or magnus himself")

function Magnus.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_magnataur" then return end
	
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.IsChannellingAbility(myHero) then return end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	if Menu.IsEnabled(Magnus.optionEmpower) then
		Magnus.AutoEmpower(myHero)
	end
end

function Magnus.AutoEmpower(myHero)
	Log.Write("yo")
end

return Magnus