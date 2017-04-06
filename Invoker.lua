local Utility = require("Utility")

local Invoker = {}

local optionColdSnapCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Cold Snap Combo", "cast alacrity and urn before cold snap")
local optionMeteorBlastCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Meteor & Blast Combo", "cast defending blast after chaos meteor")
local optionIceWallEMPCombo = Menu.AddOption({"Hero Specific", "Invoker"}, "Ice Wall & EMP Combo", "cast EMP after ice wall")
local optionInstanceHelper = Menu.AddOption({"Hero Specific", "Invoker"}, "Instance Helper", "auto switch instances, EEE when attacking, WWW when running")
local optionSunStrike = Menu.AddOption({"Hero Specific", "Invoker"}, "Sun Strike for KS", "auto cast sun strike on predicted position if can kill an enemy")

local isInvokingSpell = false
local lastInvokeTime = 0

function Invoker.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return end
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return end
    if NPC.IsChannellingAbility(myHero) then return end

    Invoker.UpdateInvokingStatus(myHero)

    -- test
    if Input.IsKeyDown(Enum.ButtonCode.KEY_X) then
        local source = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        Invoker.Defend(myHero, source)
    end
    -- test

    if Menu.IsEnabled(optionSunStrike) then
        Invoker.SunStrike(myHero)
    end    

    if Menu.IsEnabled(optionMeteorBlastCombo) then
        Invoker.MeteorBlastCombo(myHero)
    end
end

function Invoker.OnPrepareUnitOrders(orders)
    if not orders or not orders.ability then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return true end
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return true end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return true end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return true end
    if NPC.IsChannellingAbility(myHero) then return true end
    
    if Menu.IsEnabled(optionColdSnapCombo) and Entity.IsAbility(orders.ability) and Ability.GetName(orders.ability) == "invoker_cold_snap" then
        Invoker.ColdSnapCombo(myHero, orders.target)
        return true
    end

    if Menu.IsEnabled(optionIceWallEMPCombo) and Entity.IsAbility(orders.ability) and Ability.GetName(orders.ability) == "invoker_ice_wall" then
        Invoker.IceWallEMPCombo(myHero)
        return true
    end

    if Menu.IsEnabled(optionInstanceHelper) then
        Invoker.InstanceHelper(myHero, orders.order)
        return true
    end

    return true
end

-- update invoking status
-- check whether is invoking spell to avoid miss switch instance.
function Invoker.UpdateInvokingStatus(myHero)
    local elapse_time = 1
    if math.abs(GameRules.GetGameTime() - lastInvokeTime) > elapse_time then
        isInvokingSpell = false
    end

    -- if one of Q, W, E, R keys is pressed
    if Input.IsKeyDown(Enum.ButtonCode.KEY_Q) or Input.IsKeyDown(Enum.ButtonCode.KEY_W) or Input.IsKeyDown(Enum.ButtonCode.KEY_E) or Input.IsKeyDown(Enum.ButtonCode.KEY_R) then
        isInvokingSpell = true
        lastInvokeTime = GameRules.GetGameTime()
    end
end

function Invoker.InstanceHelper(myHero, order)
	if not myHero or not order then return end
    if isInvokingSpell then return end

	-- if about to move
	if order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		if Entity.GetHealth(myHero) < Entity.GetMaxHealth(myHero) then
			Invoker.PressKey(myHero, "QQQ")
		else
			Invoker.PressKey(myHero, "WWW")
		end
	end

	-- if about to attack
	if order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE or order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET then
		local E = NPC.GetAbility(myHero, "invoker_exort")
        if E and Ability.IsCastable(E, 0) then
            Invoker.PressKey(myHero, "EEE")
        else
            Invoker.PressKey(myHero, "WWW")
        end
	end
end

-- combo: cold snap -> urn
-- combo: cold snap -> alacrity
function Invoker.ColdSnapCombo(myHero, target)
    if not myHero or not target then return end

    local urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    if urn and Ability.IsCastable(urn, 0) and Item.GetCurrentCharges(urn) > 0 then
        Ability.CastTarget(urn, target)
    end
   
    local coldSnap = NPC.GetAbility(myHero, "invoker_cold_snap")
    local alacrity = NPC.GetAbility(myHero, "invoker_alacrity")
    local invoke = NPC.GetAbility(myHero, "invoker_invoke")
    if not alacrity or not coldSnap or not invoke then return end
    if not Ability.IsCastable(alacrity, NPC.GetMana(myHero) - Ability.GetManaCost(invoke) - Ability.GetManaCost(coldSnap)) then return end

    -- pop cold snap to first slot
    if coldSnap ~= NPC.GetAbilityByIndex(myHero, 3) then
    	Invoker.PressKey(myHero, "QQQR")
    end

    if not Invoker.HasInvoked(myHero, alacrity) then
    	Invoker.PressKey(myHero, "WWER")
    end

	Ability.CastTarget(alacrity, myHero)
    Invoker.PressKey(myHero, "EEE")
end

-- combo: ice wall -> EMP
function Invoker.IceWallEMPCombo(myHero)
	local iceWall = NPC.GetAbility(myHero, "invoker_ice_wall")
	local emp = NPC.GetAbility(myHero, "invoker_emp")
	local invoke = NPC.GetAbility(myHero, "invoker_invoke")
	if not iceWall or not emp or not invoke then return end
	if not Ability.IsCastable(emp, NPC.GetMana(myHero) - Ability.GetManaCost(invoke) - Ability.GetManaCost(iceWall)) then return end

	-- pop ice wall to first slot
    if iceWall ~= NPC.GetAbilityByIndex(myHero, 3) then
    	Invoker.PressKey(myHero, "QQER")
    end

    if not Invoker.HasInvoked(myHero, emp) then
    	Invoker.PressKey(myHero, "WWWR")
    end

    local cursorPos = Input.GetWorldCursorPos()
    local pos = (Entity.GetAbsOrigin(myHero) + cursorPos):Scaled(0.5)
    Ability.CastPosition(emp, pos)
end

-- combo: meteor -> blast
function Invoker.MeteorBlastCombo(myHero)
    local meteor = NPC.GetAbility(myHero, "invoker_chaos_meteor")
    local blast = NPC.GetAbility(myHero, "invoker_deafening_blast")
    local invoke = NPC.GetAbility(myHero, "invoker_invoke")
    if not meteor or not blast or not invoke then return end
    if not Ability.IsCastable(blast, NPC.GetMana(myHero) - Ability.GetManaCost(invoke) - Ability.GetManaCost(meteor)) then return end

	-- check nearby enemy who is affected by chaos meteor
	local pos
	local radius = 1000
	local enemyAround = NPC.GetHeroesInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyAround) do
		if NPC.HasModifier(enemy, "modifier_invoker_chaos_meteor_burn") then
			pos = Entity.GetAbsOrigin(enemy)
		end
	end
	if not pos then return end

    -- pop chaos meteor to first slot
    if meteor ~= NPC.GetAbilityByIndex(myHero, 3) then
    	Invoker.PressKey(myHero, "WEER")
    end

    if not Invoker.HasInvoked(myHero, blast) then
    	Invoker.PressKey(myHero, "QWER")
    end

    if Ability.IsCastable(blast, NPC.GetMana(myHero)) then
	    Ability.CastPosition(blast, pos)
	end
end

-- auto cast sun strike for kill steal
function Invoker.SunStrike(myHero)
    local E = NPC.GetAbility(myHero, "invoker_exort")
    local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
    local invoke = NPC.GetAbility(myHero, "invoker_invoke")
    
    if not E or not sunstrike or not invoke then return end
    if not Ability.IsCastable(E, 0) or not Ability.IsCastable(sunstrike, NPC.GetMana(myHero) - Ability.GetManaCost(invoke)) then return end

    local exort_level = Ability.GetLevel(E)
    if NPC.HasItem(myHero, "item_ultimate_scepter", true) then exort_level = exort_level + 1 end
    local sunstrike_damage = 100 + 62.5 * (exort_level - 1)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
    	local enemyHp = Entity.GetHealth(enemy)
        if enemyHp <= sunstrike_damage and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
        	
        	local delay = 1.7 -- sun strike has 1.7s delay
        	local pos = Utility.GetPredictedPosition(enemy, delay)

		    if not Invoker.HasInvoked(myHero, sunstrike) then
		    	Invoker.PressKey(myHero, "EEER")
		    end

        	Ability.CastPosition(sunstrike, pos)
        	return
        end
    end
end

-- define defensive actions
function Invoker.Defend(myHero, source)
    if not myHero or not source then return end
    local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(source)):Length()

    local invoke = NPC.GetAbility(myHero, "invoker_invoke")
    if not invoke then return end
    
    -- 1. use tornado to defend if available
    local tornado = NPC.GetAbility(myHero, "invoker_tornado")
    if tornado and Ability.IsCastable(tornado, NPC.GetMana(myHero)-Ability.GetManaCost(invoke)) then
        
        local level = Ability.GetLevel(tornado)
        local range = 800 + 400 * (level - 1)

        if dis <= range then

            if not Invoker.HasInvoked(myHero, tornado) then
                Invoker.PressKey(myHero, "QWWR")
            end

            Ability.CastPosition(tornado, Entity.GetAbsOrigin(source))
            return
        end
    end
end

-- return current instances ("QWE", "QQQ", "EEE", etc)
function Invoker.GetInstances(myHero)
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

function Invoker.PressKey(myHero, keys)
	if not myHero or not keys then return end
	if Invoker.GetInstances(myHero) == keys then return end

    local Q = NPC.GetAbility(myHero, "invoker_quas")
    local W = NPC.GetAbility(myHero, "invoker_wex")
    local E = NPC.GetAbility(myHero, "invoker_exort")
    local R = NPC.GetAbility(myHero, "invoker_invoke")

    for i = 1, #keys do
    	local key = keys:sub(i,i)	
    	if key == "Q" and Q and Ability.IsCastable(Q, 0) then Ability.CastNoTarget(Q) end
    	if key == "W" and W and Ability.IsCastable(W, 0) then Ability.CastNoTarget(W) end
    	if key == "E" and E and Ability.IsCastable(E, 0) then Ability.CastNoTarget(E) end
    	if key == "R" and R and Ability.IsCastable(R, NPC.GetMana(myHero)) then Ability.CastNoTarget(R) end
    end
end

return Invoker