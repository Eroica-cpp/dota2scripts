-- Utility.lua (Version 1.0)
-- Author: Eroica
-- Release Date: 2017/5/8

local Utility = {}

Utility.AncientCreepNameList = {
    "npc_dota_neutral_black_drake",
    "npc_dota_neutral_black_dragon",
    "npc_dota_neutral_blue_dragonspawn_sorcerer",
    "npc_dota_neutral_blue_dragonspawn_overseer",
    "npc_dota_neutral_granite_golem",
    "npc_dota_neutral_elder_jungle_stalker",
    "npc_dota_neutral_prowler_acolyte",
    "npc_dota_neutral_prowler_shaman",
    "npc_dota_neutral_rock_golem",
    "npc_dota_neutral_small_thunder_lizard",
    "npc_dota_neutral_jungle_stalker",
    "npc_dota_neutral_big_thunder_lizard",
    "npc_dota_roshan"
}

-- return best position to cast certain spells
-- eg. axe's call, void's chrono, enigma's black hole
-- input  : unitsAround, radius
-- return : positon (a vector)
function Utility.BestPosition(unitsAround, radius)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return Entity.GetAbsOrigin(unitsAround[1]) end

	-- find all mid points of every two enemy heroes,
	-- then find out the best position among these.
	-- O(n^3) complexity
	local maxNum = 1
	local bestPos = Entity.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = Entity.GetAbsOrigin(unitsAround[i])
				local pos2 = Entity.GetAbsOrigin(unitsAround[j])
				local mid = pos1:__add(pos2):Scaled(0.5)

				local heroesNum = 0
				for k = 1, enemyNum do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesNum = heroesNum + 1
					end
				end

				if heroesNum > maxNum then
					maxNum = heroesNum
					bestPos = mid
				end

			end
		end
	end

	return bestPos
end

-- return predicted position
function Utility.GetPredictedPosition(npc, delay)
    local pos = Entity.GetAbsOrigin(npc)
    if Utility.CantMove(npc) then return pos end
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = Utility.GetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

function Utility.GetMoveSpeed(npc)
    local base_speed = NPC.GetBaseSpeed(npc)
    local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    -- when affected by ice wall, assume move speed as 100 for convenience
    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end

    -- when get hexed,  move speed = 140/100 + bonus_speed
    if Utility.GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end

-- return true if is protected by lotus orb or AM's aghs
function Utility.IsLotusProtected(npc)
	if NPC.HasModifier(npc, "modifier_item_lotus_orb_active") then return true end

	local shield = NPC.GetAbility(npc, "antimage_spell_shield")
	if shield and Ability.IsReady(shield) and NPC.HasItem(npc, "item_ultimate_scepter", true) then
		return true
	end

	return false
end

-- return true if this npc is disabled, return false otherwise
function Utility.IsDisabled(npc)
	if not Entity.IsAlive(npc) then return true end
	if NPC.IsStunned(npc) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end

    return false
end

-- return true if can cast spell on this npc, return false otherwise
function Utility.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end

-- check if it is safe to cast spell or item on enemy
-- in case enemy has blademail or lotus.
-- Caster will take double damage if target has both lotus and blademail
function Utility.IsSafeToCast(myHero, enemy, magic_damage)
    if not myHero or not enemy or not magic_damage then return true end
    if magic_damage <= 0 then return true end

    local counter = 0
    if NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") then counter = counter + 1 end
    if NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") then counter = counter + 1 end

    local reflect_damage = counter * magic_damage * NPC.GetMagicalArmorDamageMultiplier(myHero)
    return Entity.GetHealth(myHero) > reflect_damage
end

-- situations that ally need to be saved
function Utility.NeedToBeSaved(npc)
	if not npc or NPC.IsIllusion(npc) or not Entity.IsAlive(npc) then return false end

	if NPC.IsStunned(npc) or NPC.IsSilenced(npc) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_DISARMED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_PASSIVES_DISABLED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_BLIND) then return true end

	if Entity.GetHealth(npc) <= 0.2 * Entity.GetMaxHealth(npc) then return true end

	return false
end

-- pop all defensive items
function Utility.PopDefensiveItems(myHero)
	if not myHero then return end

    -- blade mail
    if NPC.HasItem(myHero, "item_blade_mail", true) then
    	local item = NPC.GetItem(myHero, "item_blade_mail", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- buckler
    if NPC.HasItem(myHero, "item_buckler", true) then
    	local item = NPC.GetItem(myHero, "item_buckler", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- hood of defiance
    if NPC.HasItem(myHero, "item_hood_of_defiance", true) then
    	local item = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- pipe of insight
    if NPC.HasItem(myHero, "item_pipe", true) then
    	local item = NPC.GetItem(myHero, "item_pipe", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- crimson guard
    if NPC.HasItem(myHero, "item_crimson_guard", true) then
    	local item = NPC.GetItem(myHero, "item_crimson_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- shiva's guard
    if NPC.HasItem(myHero, "item_shivas_guard", true) then
    	local item = NPC.GetItem(myHero, "item_shivas_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- lotus orb
    if NPC.HasItem(myHero, "item_lotus_orb", true) then
    	local item = NPC.GetItem(myHero, "item_lotus_orb", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

    -- mjollnir
    if NPC.HasItem(myHero, "item_mjollnir", true) then
    	local item = NPC.GetItem(myHero, "item_mjollnir", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

end

function Utility.IsAncientCreep(npc)
    if not npc then return false end

    for i, name in ipairs(Utility.AncientCreepNameList) do
        if name and NPC.GetUnitName(npc) == name then return true end
    end

    return false
end

function Utility.CantMove(npc)
    if not npc then return false end

    if NPC.IsRooted(npc) or Utility.GetStunTimeLeft(npc) >= 1 then return true end
    if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
    if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

    return false
end

-- only able to get stun modifier. no specific modifier for root or hex.
function Utility.GetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

-- hex only has three types: sheepstick, lion's hex, shadow shaman's hex
function Utility.GetHexTimeLeft(npc)
    local mod
    local mod1 = NPC.GetModifier(npc, "modifier_sheepstick_debuff")
    local mod2 = NPC.GetModifier(npc, "modifier_lion_voodoo")
    local mod3 = NPC.GetModifier(npc, "modifier_shadow_shaman_voodoo")

    if mod1 then mod = mod1 end
    if mod2 then mod = mod2 end
    if mod3 then mod = mod3 end

    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

-- return false for conditions that are not suitable to cast spell (like TPing, being invisible)
-- return true otherwise
function Utility.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

function Utility.IsSuitableToUseItem(myHero)
    if NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

-- return true if: (1) channeling ability; (2) TPing
function Utility.IsChannellingAbility(npc, target)
    if NPC.HasModifier(npc, "modifier_teleporting") then return true end
    if NPC.IsChannellingAbility(npc) then return true end
    
    return false
end

function Utility.IsAffectedByDoT(npc)
    if not npc then return false end

    if NPC.HasModifier(npc, "modifier_item_radiance_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_item_urn_damage") then return true end
    if NPC.HasModifier(npc, "modifier_alchemist_acid_spray") then return true end
    if NPC.HasModifier(npc, "modifier_cold_feet") then return true end
    if NPC.HasModifier(npc, "modifier_ice_blast") then return true end
    if NPC.HasModifier(npc, "modifier_axe_battle_hunger") then return true end
    if NPC.HasModifier(npc, "modifier_bane_fiends_grip") then return true end
    if NPC.HasModifier(npc, "modifier_batrider_firefly") then return true end
    if NPC.HasModifier(npc, "modifier_rattletrap_battery_assault") then return true end
    if NPC.HasModifier(npc, "modifier_crystal_maiden_frostbite") then return true end
    if NPC.HasModifier(npc, "modifier_crystal_maiden_freezing_field") then return true end
    if NPC.HasModifier(npc, "modifier_dazzle_poison_touch") then return true end
    if NPC.HasModifier(npc, "modifier_disruptor_static_storm") then return true end
    if NPC.HasModifier(npc, "modifier_disruptor_thunder_strike") then return true end
    if NPC.HasModifier(npc, "modifier_doom_bringer_doom") then return true end
    if NPC.HasModifier(npc, "modifier_doom_bringer_scorched_earth_effect") then return true end
    if NPC.HasModifier(npc, "modifier_dragon_knight_corrosive_breath_dot") then return true end
    if NPC.HasModifier(npc, "modifier_earth_spirit_magnetize") then return true end
    if NPC.HasModifier(npc, "modifier_ember_spirit_flame_guard") then return true end
    if NPC.HasModifier(npc, "modifier_enigma_malefice") then return true end
    if NPC.HasModifier(npc, "modifier_brewmaster_fire_permanent_immolation") then return true end
    if NPC.HasModifier(npc, "modifier_gyrocopter_rocket_barrage") then return true end
    if NPC.HasModifier(npc, "modifier_huskar_burning_spear_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_invoker_chaos_meteor_burn") then return true end
    if NPC.HasModifier(npc, "modifier_jakiro_dual_breath_burn") then return true end
    if NPC.HasModifier(npc, "modifier_jakiro_macropyre") then return true end
    if NPC.HasModifier(npc, "modifier_juggernaut_blade_fury") then return true end
    if NPC.HasModifier(npc, "modifier_leshrac_diabolic_edict") then return true end
    if NPC.HasModifier(npc, "modifier_leshrac_pulse_nova") then return true end
    if NPC.HasModifier(npc, "modifier_ogre_magi_ignite") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_fire_spirit_burn") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_icarus_dive_burn") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_sun_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_pudge_rot") then return true end
    if NPC.HasModifier(npc, "modifier_pugna_life_drain") then return true end
    if NPC.HasModifier(npc, "modifier_queenofpain_shadow_strike") then return true end
    if NPC.HasModifier(npc, "modifier_razor_eye_of_the_storm") then return true end
    if NPC.HasModifier(npc, "modifier_sandking_sand_storm") then return true end
    if NPC.HasModifier(npc, "modifier_silencer_curse_of_the_silent") then return true end
    if NPC.HasModifier(npc, "modifier_sniper_shrapnel_slow") then return true end
    if NPC.HasModifier(npc, "modifier_shredder_chakram_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_treant_leech_seed") then return true end
    if NPC.HasModifier(npc, "modifier_abyssal_underlord_firestorm_burn") then return true end
    if NPC.HasModifier(npc, "modifier_venomancer_venomous_gale") then return true end
    if NPC.HasModifier(npc, "modifier_venomancer_poison_nova") then return true end
    if NPC.HasModifier(npc, "modifier_viper_viper_strike") then return true end
    if NPC.HasModifier(npc, "modifier_warlock_shadow_word") then return true end
    if NPC.HasModifier(npc, "modifier_warlock_golem_permanent_immolation_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_maledict") then return true end

    return false
end

return Utility
