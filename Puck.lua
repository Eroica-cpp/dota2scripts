local Utility = require("Utility")

local Puck = {}

local optionUltimateHelper = Menu.AddOption({"Hero Specific", "Puck"}, "Ultimate Helper", "Cast ultimate on best position once the order key is pressed")

function Puck.OnPrepareUnitOrders(orders)
    if not orders then return true end

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

function Puck.CastOrb(default_pos)
	local myHero = Heroes.GetLocal()
	if not myHero then return false end
	local pos = Entity.GetAbsOrigin(myHero)

	local orb = NPC.GetAbility(myHero, "puck_illusory_orb")
	if not orb or not Ability.IsCastable(orb, NPC.GetMana(myHero)) then return false end

	local range = 3000
	Ability.CastPosition(orb, pos + (default_pos - pos):Normalized():Scaled(range))
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