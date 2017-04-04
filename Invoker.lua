local Invoker = {}

Invoker.autoSunStrikeOption = Menu.AddOption({"Hero Specific", "Invoker Extended"}, "Auto Sun Strike", "On/Off")

Invoker.optionColdSnapCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Cold Snap Combo", "cast alacrity and urn before cold snap")
Invoker.optionMeteorBlastCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Meteor & Blast Combo", "cast defending blast after chaos meteor")
Invoker.optionIceWallEMPCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Ice Wall & EMP Combo", "cast EMP after ice wall")

function Invoker.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return end
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return end
    if NPC.IsChannellingAbility(myHero) then return end

    local Q = NPC.GetAbilityByIndex(myHero, 0)
    local W = NPC.GetAbilityByIndex(myHero, 1)
    local E = NPC.GetAbilityByIndex(myHero, 2)
    local R = NPC.GetAbilityByIndex(myHero, 5)

    if Menu.IsEnabled(Invoker.autoSunStrikeOption) then
        Invoker.AutoSunStrike(myHero, Q, W, E, R)
    end    

    if Menu.IsEnabled(Invoker.optionMeteorBlastCombo) then
        Invoker.MeteorBlastCombo(myHero, Q, W, E, R)
    end

end

function Invoker.OnPrepareUnitOrders(orders)
    if not orders or not orders.ability then return true end
    if not Entity.IsAbility(orders.ability) then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return true end
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return true end

    local Q = NPC.GetAbilityByIndex(myHero, 0)
    local W = NPC.GetAbilityByIndex(myHero, 1)
    local E = NPC.GetAbilityByIndex(myHero, 2)
    local R = NPC.GetAbilityByIndex(myHero, 5)
    
    if Menu.IsEnabled(Invoker.optionColdSnapCombo) and Ability.GetName(orders.ability) == "invoker_cold_snap" then
        Invoker.ColdSnapCombo(myHero, Q, W, E, R, orders.target)
        return true
    end

    if Menu.IsEnabled(Invoker.optionIceWallEMPCombo) and Ability.GetName(orders.ability) == "invoker_ice_wall" then
        Invoker.IceWallEMPCombo(myHero, Q, W, E, R)
        return true
    end

    return true
end

-- combo: cold snap -> urn
-- combo: cold snap -> alacrity
function Invoker.ColdSnapCombo(myHero, Q, W, E, R, target)
    if not myHero or not target then return end

    local urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    if urn and Ability.IsCastable(urn, 0) and Item.GetCurrentCharges(urn) > 0 then
        Ability.CastTarget(urn, target)
    end

    if not Q or not W or not E then return end
    if not Ability.IsCastable(Q, 0) or not Ability.IsCastable(W, 0) or not Ability.IsCastable(E, 0) then return end
    
    local coldSnap = NPC.GetAbility(myHero, "invoker_cold_snap")
    local alacrity = NPC.GetAbility(myHero, "invoker_alacrity")
    if not alacrity or not Ability.IsCastable(alacrity, NPC.GetMana(myHero) - Ability.GetManaCost(R) - Ability.GetManaCost(coldSnap)) then return end

    -- pop cold snap to first slot
    if coldSnap ~= NPC.GetAbilityByIndex(myHero, 3) and Ability.IsCastable(R, NPC.GetMana(myHero)) then
    	-- QQQ R
        Ability.CastNoTarget(Q); Ability.CastNoTarget(Q); Ability.CastNoTarget(Q); Ability.CastNoTarget(R)
    end

    if not Invoker.HasInvoked(myHero, alacrity) then
        if not Ability.IsCastable(R, NPC.GetMana(myHero)) then 
            return
        else
        	-- WWE R
            Ability.CastNoTarget(W); Ability.CastNoTarget(W); Ability.CastNoTarget(E); Ability.CastNoTarget(R)
        end
    end

    Ability.CastTarget(alacrity, myHero)
    -- EEE
    Ability.CastNoTarget(E); Ability.CastNoTarget(E); Ability.CastNoTarget(E)
end

-- combo: ice wall -> EMP
function Invoker.IceWallEMPCombo(myHero, Q, W, E, R)
    if not Q or not W or not E then return end
    if not Ability.IsCastable(Q, 0) or not Ability.IsCastable(W, 0) or not Ability.IsCastable(E, 0) then return end

	local iceWall = NPC.GetAbility(myHero, "invoker_ice_wall")
	local emp = NPC.GetAbility(myHero, "invoker_emp")
	if not emp or not Ability.IsCastable(emp, NPC.GetMana(myHero) - Ability.GetManaCost(R) - Ability.GetManaCost(iceWall)) then return end

	-- pop ice wall to first slot
    if iceWall ~= NPC.GetAbilityByIndex(myHero, 3) and Ability.IsCastable(R, NPC.GetMana(myHero)) then
    	-- QQE R
        Ability.CastNoTarget(Q); Ability.CastNoTarget(Q); Ability.CastNoTarget(E); Ability.CastNoTarget(R)
    end

    if not Invoker.HasInvoked(myHero, emp) then
        if not Ability.IsCastable(R, NPC.GetMana(myHero)) then 
            return
        else
            -- WWW R
            Ability.CastNoTarget(W); Ability.CastNoTarget(W); Ability.CastNoTarget(W); Ability.CastNoTarget(R)
        end
    end

    local cursorPos = Input.GetWorldCursorPos()
    local pos = (NPC.GetAbsOrigin(myHero) + cursorPos):Scaled(0.5)
    Ability.CastPosition(emp, pos)
end

-- combo: meteor -> blast
function Invoker.MeteorBlastCombo(myHero, Q, W, E, R)
    if not Q or not W or not E then return end
    if not Ability.IsCastable(Q, 0) or not Ability.IsCastable(W, 0) or not Ability.IsCastable(E, 0) then return end

	-- check nearby enemy who is affected by chaos meteor
	local pos
	local radius = 1000
	local enemyAround = NPC.GetHeroesInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyAround) do
		if NPC.HasModifier(enemy, "modifier_invoker_chaos_meteor_burn") then
			pos = NPC.GetAbsOrigin(enemy)
		end
	end

	if not pos then return end

    local meteor = NPC.GetAbility(myHero, "invoker_chaos_meteor")
    local blast = NPC.GetAbility(myHero, "invoker_deafening_blast")
    if not blast or not Ability.IsCastable(blast, NPC.GetMana(myHero) - Ability.GetManaCost(R) - Ability.GetManaCost(meteor)) then return end

    -- pop chaos meteor to first slot
    if meteor ~= NPC.GetAbilityByIndex(myHero, 3) and Ability.IsCastable(R, NPC.GetMana(myHero)) then
    	-- WEE R
        Ability.CastNoTarget(W); Ability.CastNoTarget(E); Ability.CastNoTarget(E); Ability.CastNoTarget(R)
    end

    if not Invoker.HasInvoked(myHero, blast) then
        if not Ability.IsCastable(R, NPC.GetMana(myHero)) then 
            return
        else
        	-- QWE R
            Ability.CastNoTarget(Q); Ability.CastNoTarget(W); Ability.CastNoTarget(E); Ability.CastNoTarget(R)
        end
    end

    Ability.CastPosition(blast, pos)
end

-- To be done
function Invoker.AutoSunStrike(myHero, Q, W, E, R)
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end
    
    local myMana = NPC.GetMana(myHero)
    local invokeManaCost = NPC.HasItem(myHero, "item_ultimate_scepter", true) and 0 or 60
    local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
    if not sunstrike then return end
    
    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local pos = NPC.GetAbsOrigin(enemy)

            -- auto cast sunstrike when enemy is in a fixed position
            if inFixedPosition(enemy) then
                if not Invoker.HasInvoked(myHero, sunstrike) and Ability.IsCastable(sunstrike, myMana-invokeManaCost) and Ability.IsCastable(R, myMana) then
                    Ability.CastNoTarget(E)
                    Ability.CastNoTarget(E)
                    Ability.CastNoTarget(E)
                    Ability.CastNoTarget(R)
                    Ability.CastPosition(sunstrike, pos)
                end
                if Invoker.HasInvoked(myHero, sunstrike)and Ability.IsCastable(sunstrike, myMana) then
                    Ability.CastPosition(sunstrike, pos)
                end
            end


        end
    end

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
function Invoker.HasInvoked(myHero, spell)
    if not myHero or not spell then return false end
    local spell_1 = NPC.GetAbilityByIndex(myHero, 3)
    local spell_2 = NPC.GetAbilityByIndex(myHero, 4)
    return (spell == spell_1) or (spell == spell_2)
end

-- return true if npc is stunned, rooted, duel by LC, etc
function inFixedPosition(npc)
    return NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED) 
    or NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED)
    or NPC.HasModifier(npc, "modifier_legion_commander_duel")
    or NPC.HasModifier(npc, "modifier_axe_berserkers_call")
    or NPC.HasModifier(npc, "modifier_faceless_void_chronosphere")
    or NPC.HasModifier(npc, "modifier_enigma_black_hole_pull")
end

return Invoker