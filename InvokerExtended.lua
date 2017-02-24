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
end	end

-- auto cast alacrity after cold snap
function InvokerExtended.AutoAlacrity(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local invokeManaCost = NPC.HasItem(myHero, "item_ultimate_scepter", true) and 0 or 60

	local alacrity = NPC.GetAbility(myHero, "invoker_alacrity")
	local cold_snap = NPC.GetAbility(myHero, "invoker_cold_snap")
	local hasUsedColdSnap = false
	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
			hasUsedColdSnap = true
		end
	end

	if alacrity and Ability.IsCastable(alacrity, myMana-invokeManaCost) and hasUsedColdSnap then
		if not hasInvoked(myHero, alacrity) then
			Ability.CastNoTarget(W)
			Ability.CastNoTarget(W)
			Ability.CastNoTarget(E)
			Ability.CastNoTarget(R)
			sleep(0.05)
		end
		Ability.CastTarget(alacrity, myHero, true)
		Ability.CastNoTarget(E)
		Ability.CastNoTarget(E)
		Ability.CastNoTarget(E)
		sleep(0.05)
	end

end

-- To be done
function InvokerExtended.AutoSunStrike(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
	-- Log.Write("ok for now !!")
end

-- return current state of QWE ("QWE", "QQQ", "EEE", etc)
function getQWEState(myHero)
	local modTable = NPC.GetModifiers(myHero)
	local Q_num, W_num, E_num = 0, 0, 0
	
	for i, mod in ipairs(modTable) do
		if Modifier.GetName(mod) == "modifier_invoker_quas_instance" then
			Q_num = Q_num + 1
		elseif Modifier.GetName(mod) == "modifier_invoker_wex_instance" then
			W_num = W_num + 1
		elseif Modifier.GetName(mod) == "modifier_invoker_exort_instance" then
			E_num = E_num + 1
		end
	end

	local QWE_text = ""
	while Q_num > 0 do QWE_text = QWE_text .. "Q"; Q_num = Q_num - 1 end
	while W_num > 0 do QWE_text = QWE_text .. "W"; W_num = W_num - 1 end
	while E_num > 0 do QWE_text = QWE_text .. "E"; E_num = E_num - 1 end

	return QWE_text
end

-- return whether a spell has been invoked.
function hasInvoked(myHero, spell)
	if not myHero or not spell then return false end
	local spell_1 = NPC.GetAbilityByIndex(myHero, 3)
	local spell_2 = NPC.GetAbilityByIndex(myHero, 4)
	return (spell == spell_1) or (spell == spell_2)
end

-- 0.05s delay works good for me
local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return InvokerExtended