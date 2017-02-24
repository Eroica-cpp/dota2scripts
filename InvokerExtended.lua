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


function InvokerExtended.AutoAlacrity(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local alacrity = NPC.GetAbility(myHero, "invoker_alacrity")

	-- if alacrity then
	-- 	modTable = NPC.GetModifiers(myHero)
	-- 	for i, mod in ipairs(modTable) do
	-- 		Log.Write(i .. ": " .. Modifier.GetName(mod))
	-- 	end
	-- end
	Log.Write("QWE state: " .. getQWEState(myHero))

	-- if alacrity and Ability.IsCastable(alacrity, myMana) then
	-- 	Ability.CastNoTarget(W)
	-- 	Ability.CastNoTarget(W)
	-- 	Ability.CastNoTarget(E)
	-- 	Ability.CastNoTarget(R)
	-- 	Ability.CastTarget(alacrity, myHero, false)
	-- 	Ability.CastNoTarget(E)
	-- 	Ability.CastNoTarget(E)
	-- 	Ability.CastNoTarget(E)
	-- 	sleep(0.01)
	-- end

end

-- To be done
function InvokerExtended.AutoSunStrike(myHero, Q, W, E, R)
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
	
	local myMana = NPC.GetMana(myHero)
	local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
	-- Log.Write("ok for now !!")
end

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

local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return InvokerExtended