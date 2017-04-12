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