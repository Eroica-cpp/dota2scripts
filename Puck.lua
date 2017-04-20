local Utility = require("Utility")

local Puck = {}

local optionUltimateHelper = Menu.AddOption({"Hero Specific", "Puck"}, "Ultimate Helper", "Cast ultimate on best position once the order key is pressed")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Puck"}, "Kill Steal", "Cast spell (silence) on enemy to KS")
local optionPhaseShiftProtection = Menu.AddOption({"Hero Specific", "Puck"}, "Phase Shift Protection", "don't break phase shift unless using blink or pressing S")

function Puck.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_puck" then return end

	if Menu.IsEnabled(optionKillSteal) then
		Puck.KillSteal()
	end
end

function Puck.OnPrepareUnitOrders(orders)
    if not orders then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    if Menu.IsEnabled(optionPhaseShiftProtection) and NPC.HasModifier(myHero, "modifier_puck_phase_shift") then
    	-- interrupt phase shift when using blink
    	if orders.ability and Entity.IsAbility(orders.ability) and Ability.GetName(orders.ability) == "item_blink" then
    		return true
    	end

    	-- interrupt phase shift when pressing stop
    	if orders.order and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_STOP or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_HOLD_POSITION) then
    		return true
    	end

    	-- ignore other source of interruption
    	return false
    end

    if Menu.IsEnabled(optionUltimateHelper) and orders.ability and Entity.IsAbility(orders.ability)
    	and Ability.GetName(orders.ability) == "puck_dream_coil"
    	and orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then
    	
    	Puck.UltimateHelper(orders.position)
    	return false
    end

    return true
end

function Puck.UltimateHelper(default_pos)
	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local ultimate = NPC.GetAbility(myHero, "puck_dream_coil")
	if not ultimate or not Ability.IsCastable(ultimate, NPC.GetMana(myHero)) then return end

	local range = 750
	local radius = 375
	local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	local best_pos = Utility.BestPosition(enemyHeroes, radius)

	if not best_pos and default_pos then Ability.CastPosition(ultimate, default_pos) end
	if best_pos then Ability.CastPosition(ultimate, best_pos) end
end

function Puck.KillSteal()
	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local orb = NPC.GetAbility(myHero, "puck_illusory_orb")
	local orb_damage = 0
	if orb then orb_damage = 70 * Ability.GetLevel(orb) end

	local silence = NPC.GetAbility(myHero, "puck_waning_rift")
	local silence_damage = 0
	if silence and Ability.GetLevel(silence) > 0 then 
		silence_damage = 100 + 60 * (Ability.GetLevel(silence) - 1)
	end

	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and Utility.CanCastSpellOn(enemy) then
			
			local true_silence_damage = silence_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
			if true_silence_damage >= Entity.GetHealth(enemy) and Puck.CastSilence(enemy) then return end

			local true_orb_damage = orb_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
			if true_orb_damage >= Entity.GetHealth(enemy) then
				local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
				local delay = dis / 651
				local pos = Utility.GetPredictedPosition(enemy, delay)
				if Puck.CastOrb(pos) then return end
			end
		end
	end
end

-- define Puck's defind behavior
-- input: target entity, can be nil
function Puck.Defend(target)
	local myHero = Heroes.GetLocal()
	if not myHero then return end

	-- 1. use phrase shift to dodge
	if Puck.CastShift() then return end

	-- 2. use silence against enemy in range
	if Puck.CastSilence(target) then return end

	-- 3. use jaunt to dodge; it can be dangerous in some conditions
	-- if Puck.CastJaunt() then return end
end

function Puck.CastOrb(pos)
	local myHero = Heroes.GetLocal()
	if not myHero then return false end

	local orb = NPC.GetAbility(myHero, "puck_illusory_orb")
	if not orb or not Ability.IsCastable(orb, NPC.GetMana(myHero)) then return false end

	local range = 1950
	local dis = (Entity.GetAbsOrigin(myHero) - pos):Length()
	if dis > range then return false end

	Ability.CastPosition(orb, pos)
	return true
end

function Puck.CastJaunt()
	local myHero = Heroes.GetLocal()
	if not myHero then return false end

	local jaunt = NPC.GetAbility(myHero, "puck_ethereal_jaunt")
	if not jaunt or not Ability.IsCastable(jaunt, NPC.GetMana(myHero)) then return false end

	Ability.CastNoTarget(jaunt)
	return true
end

-- input: target entity, can be nil
function Puck.CastSilence(target)
	local myHero = Heroes.GetLocal()
	if not myHero then return false end

	local silence = NPC.GetAbility(myHero, "puck_waning_rift")
	if not silence or not Ability.IsCastable(silence, NPC.GetMana(myHero)) then return false end

	local radius = 400
	if target and (not NPC.IsEntityInRange(myHero, target, radius) or not Utility.CanCastSpellOn(target)) then return false end

	Ability.CastNoTarget(silence)
	return true
end

function Puck.CastShift()
	local myHero = Heroes.GetLocal()
	if not myHero then return false end

	local shift = NPC.GetAbility(myHero, "puck_phase_shift")
	if not shift or not Ability.IsCastable(shift, NPC.GetMana(myHero)) then return false end

	Ability.CastNoTarget(shift)
	return true
end

return Puck