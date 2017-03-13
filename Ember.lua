local Ember = {}

Ember.fistChainCombo = Menu.AddOption({"Hero Specific", "Ember Spirit"}, "fist & chain combo", "On/Off")
Ember.dashCombo = Menu.AddOption({"Hero Specific", "Ember Spirit"}, "remnant dash combo", "On/Off")
Ember.dashKey = Menu.AddKeyOption({"Hero Specific", "Ember Spirit" }, "Dash Key", Enum.ButtonCode.KEY_F)

local clock = os.clock
local last_time = clock()

function Ember.OnUpdate()

	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_ember_spirit" then return end
	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

	-- fist and chain combo
	if Menu.IsEnabled(Ember.fistChainCombo) then
		Ember.FistChain(myHero)
	end

	-- remnants dash combo
	if Menu.IsEnabled(Ember.dashCombo) and Menu.IsKeyDown(Ember.dashKey) then
		Ember.Dash(myHero)
	end

end

function Ember.FistChain(myHero)
	if not NPC.HasModifier(myHero, "modifier_ember_spirit_sleight_of_fist_caster") then return end

	local chain = NPC.GetAbilityByIndex(myHero, 0)
	local fist = NPC.GetAbilityByIndex(myHero, 1)
	local myMana = NPC.GetMana(myHero)

	if not Ability.IsCastable(chain, myMana) then return end

	local chain_radius = 400
	local enemyAround = NPC.GetHeroesInRadius(myHero, chain_radius, Enum.TeamType.TEAM_ENEMY)
	if #enemyAround > 0 then
		Ability.CastNoTarget(chain)
	end
end

function Ember.Dash(myHero)

	local activate_remnant = NPC.GetAbilityByIndex(myHero, 3)
	local place_remnant = NPC.GetAbilityByIndex(myHero, 4)
	local myMana = NPC.GetMana(myHero)

	if not Ability.IsCastable(activate_remnant, myMana) or not Ability.IsCastable(place_remnant, 0) then return end

	local mod_remnant = NPC.GetModifier(myHero, "modifier_ember_spirit_fire_remnant_charge_counter")
	if not mod_remnant then return end

	local counter = Modifier.GetStackCount(mod_remnant)
	if counter <= 1 then return end

	local pos1 = Input.GetWorldCursorPos()
	local origin = NPC.GetAbsOrigin(myHero)
	local diff = pos1 - origin
	local pos2 = origin - diff -- fail back position
	local distance = diff:Length2D()

	local remnant_speed = 2.5 * NPC.GetMoveSpeed(myHero) + 1
	local elapse_time = distance / remnant_speed
	
	while counter > 1 do
		Ability.CastPosition(place_remnant, pos1)
		counter = counter - 1
		last_time = clock()
	end
	Ability.CastPosition(place_remnant, pos2)

	while clock() - last_time < elapse_time do end
	Ability.CastPosition(activate_remnant, pos2)

end

return Ember