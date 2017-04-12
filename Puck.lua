local Utility = require("Utility")

local Puck = {}

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