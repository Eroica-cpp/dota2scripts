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

Utility.IsAxeOrLegion = {}
Utility.IsAxeOrLegion["npc_dota_hero_legion_commander"] = true
Utility.IsAxeOrLegion["npc_dota_hero_axe"] = true

Utility.PhysicalCoreHeroes = {}
Utility.PhysicalCoreHeroes["npc_dota_hero_abaddon"]            = true
Utility.PhysicalCoreHeroes["npc_dota_hero_alchemist"]          = true
Utility.PhysicalCoreHeroes["npc_dota_hero_antimage"]           = true
Utility.PhysicalCoreHeroes["npc_dota_hero_arc_warden"]         = true
Utility.PhysicalCoreHeroes["npc_dota_hero_bloodseeker"]        = true
Utility.PhysicalCoreHeroes["npc_dota_hero_broodmother"]        = true
Utility.PhysicalCoreHeroes["npc_dota_hero_chaos_knight"]       = true
Utility.PhysicalCoreHeroes["npc_dota_hero_clinkz"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_dragon_knight"]      = true
Utility.PhysicalCoreHeroes["npc_dota_hero_drow_ranger"]        = true
Utility.PhysicalCoreHeroes["npc_dota_hero_faceless_void"]      = true
Utility.PhysicalCoreHeroes["npc_dota_hero_furion"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_gyrocopter"]         = true
Utility.PhysicalCoreHeroes["npc_dota_hero_huskar"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_invoker"]            = true
Utility.PhysicalCoreHeroes["npc_dota_hero_juggernaut"]         = true
Utility.PhysicalCoreHeroes["npc_dota_hero_kunkka"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_legion_commander"]   = true
Utility.PhysicalCoreHeroes["npc_dota_hero_life_stealer"]       = true
Utility.PhysicalCoreHeroes["npc_dota_hero_lina"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_lone_druid"]         = true
Utility.PhysicalCoreHeroes["npc_dota_hero_luna"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_lycan"]              = true
Utility.PhysicalCoreHeroes["npc_dota_hero_medusa"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_mirana"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_morphling"]          = true
Utility.PhysicalCoreHeroes["npc_dota_hero_nevermore"]          = true
Utility.PhysicalCoreHeroes["npc_dota_hero_night_stalker"]      = true
Utility.PhysicalCoreHeroes["npc_dota_hero_obsidian_destroyer"] = true
Utility.PhysicalCoreHeroes["npc_dota_hero_phantom_assassin"]   = true
Utility.PhysicalCoreHeroes["npc_dota_hero_phantom_lancer"]     = true
Utility.PhysicalCoreHeroes["npc_dota_hero_queenofpain"]        = true
Utility.PhysicalCoreHeroes["npc_dota_hero_razor"]              = true
Utility.PhysicalCoreHeroes["npc_dota_hero_riki"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_silencer"]           = true
Utility.PhysicalCoreHeroes["npc_dota_hero_slardar"]            = true
Utility.PhysicalCoreHeroes["npc_dota_hero_slark"]              = true
Utility.PhysicalCoreHeroes["npc_dota_hero_sniper"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_spectre"]            = true
Utility.PhysicalCoreHeroes["npc_dota_hero_storm_spirit"]       = true
Utility.PhysicalCoreHeroes["npc_dota_hero_sven"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_templar_assassin"]   = true
Utility.PhysicalCoreHeroes["npc_dota_hero_terrorblade"]        = true
Utility.PhysicalCoreHeroes["npc_dota_hero_tiny"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_troll_warlord"]      = true
Utility.PhysicalCoreHeroes["npc_dota_hero_ursa"]               = true
Utility.PhysicalCoreHeroes["npc_dota_hero_viper"]              = true
Utility.PhysicalCoreHeroes["npc_dota_hero_weaver"]             = true
Utility.PhysicalCoreHeroes["npc_dota_hero_windrunner"]         = true

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

    if NPC.HasModifier(npc, "modifier_item_diffusal_blade_slow") then return 100 end

    -- when get hexed,  move speed = 140/100 + bonus_speed
    if Utility.GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end

-- return true if is protected by lotus orb or AM's aghs
function Utility.IsLotusProtected(npc)
	if NPC.HasModifier(npc, "modifier_item_lotus_orb_active") then return true end
    if NPC.HasModifier(npc, "modifier_antimage_counterspell") then return true end
    if NPC.HasModifier(npc, "modifier_item_mirror_shield") then return true end

	return false
end

-- return true if protected by Aeon Disk
function Utility.IsDiskProtected(npc)
    local disk = NPC.GetItem(npc, "item_aeon_disk", true)
    if disk and (Ability.GetCooldown(disk) <= 0.5 or Ability.SecondsSinceLastUse(disk) <= 0.5) then
        return true
    end

    if NPC.HasModifier(npc, "modifier_item_aeon_disk_buff") then
        return true
    end

    return false
end

function Utility.IsLinkensProtected(npc)
    if NPC.HasModifier(npc, "modifier_antimage_counterspell") then
        return true
    end

    return NPC.IsLinkensProtected(npc)
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
	if NPC.IsStructure(npc) then return false end
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
    if NPC.HasModifier(enemy, "modifier_antimage_counterspell")
        or NPC.HasModifier(enemy, "modifier_antimage_counterspell_passive") then counter = counter + 1 end

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

-- Reference: https://dota2.gamepedia.com/Stun
-- black items on the list seems are not included in "modifier_stunned"
Utility.StunModifiers = {
    "modifier_stunned",
    "modifier_bashed",
    "modifier_bane_fiends_grip",
    "modifier_rattletrap_hookshot",
    "modifier_winter_wyvern_winters_curse_aura",
    "modifier_necrolyte_reapers_scythe"
}

-- Reference: https://dota2.gamepedia.com/Sleep
Utility.SleepModifiers = {
    "modifier_bane_nightmare",
    "modifier_elder_titan_echo_stomp",
    "modifier_naga_siren_song_of_the_siren"
}

-- Reference: https://dota2.gamepedia.com/Root
Utility.RootModifiers = {
    "modifier_crystal_maiden_frostbite",
    "modifier_dark_troll_warlord_ensnare",
    "modifier_ember_spirit_searing_chains",
    "modifier_meepo_earthbind",
    "modifier_naga_siren_ensnare",
    "modifier_oracle_fortunes_end_purge",
    "modifier_rod_of_atos_debuff",
    "modifier_lone_druid_spirit_bear_entangle_effect",
    "modifier_techies_stasis_trap_stunned",
    "modifier_treant_natures_guise_root",
    "modifier_treant_overgrowth",
    "modifier_abyssal_underlord_pit_of_malice_ensare"
}

-- Reference: https://dota2.gamepedia.com/Taunt
Utility.TauntModifiers = {
    "modifier_axe_berserkers_call",
    "modifier_legion_commander_duel",
    "modifier_winter_wyvern_winters_curse"
}

-- only able to get stun modifier. no specific modifier for root or hex.
function Utility.GetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

-- time left to be fixed in a position (stunned, sleeped, rooted, or taunted)
function Utility.GetFixTimeLeft(npc)
    for i, val in ipairs(Utility.StunModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utility.SleepModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utility.RootModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utility.TauntModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    return 0
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
function Utility.IsChannellingAbility(npc)
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

-- standard APIs have fixed this issue
function Utility.GetCastRange(myHero, ability)
    return Ability.GetCastRange(ability)
    -- if not myHero or not ability then return 0 end
    --
    -- local range = Ability.GetCastRange(ability)
    --
    -- if NPC.HasItem(myHero, "item_aether_lens", true) then
    --     range = range + 250
    -- end
    --
    -- for i = 0, 24 do
    --     local ability = NPC.GetAbilityByIndex(myHero, i)
    --     if ability and Ability.GetLevel(ability) > 0 then
    --         local bonus_name = Ability.GetName(ability)
    --         if string.find(bonus_name, "special_bonus_cast_range") then
    --             local diff = tonumber(string.match(bonus_name, "[0-9]+"))
    --             range = range + diff
    --         end
    --     end
    -- end
    --
    -- return range
end

function Utility.GetRealDamage(myHero, enemy, damage)
    local spell_amplifier = 1

    if NPC.HasModifier(enemy, "modifier_item_veil_of_discord_debuff") then
        spell_amplifier = spell_amplifier + 0.18
    end

    if NPC.HasItem(myHero, "item_kaya", true) then
        spell_amplifier = spell_amplifier + 0.08
    end

    if NPC.HasItem(myHero, "item_bloodstone", true) then
        spell_amplifier = spell_amplifier + 0.08
    end

    if NPC.HasItem(myHero, "item_nether_shawl", false) then
        spell_amplifier = spell_amplifier + 0.08
    end

    if NPC.HasItem(myHero, "item_timeless_relic", false) then
        spell_amplifier = spell_amplifier + 0.15
    end

    if NPC.HasItem(myHero, "item_yasha_and_kaya", true) then
        spell_amplifier = spell_amplifier + 0.16
    end

    if NPC.HasItem(myHero, "item_kaya_and_sange", true) then
        spell_amplifier = spell_amplifier + 0.16
    end

    if NPC.HasItem(myHero, "item_trident", false) then
        spell_amplifier = spell_amplifier + 0.30
    end

    local rubick_arcane_supremacy = NPC.GetAbility(myHero, "rubick_arcane_supremacy")
    if rubick_arcane_supremacy then
        spell_amplifier = spell_amplifier + 0.1 + 0.04 * Ability.GetLevel(rubick_arcane_supremacy)
    end

    real_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy) * spell_amplifier
    return real_damage
end

function Utility.GetSafeDirection(myHero)
    local mid = Vector()
    local pos = Entity.GetAbsOrigin(myHero)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not Entity.IsSameTeam(myHero, enemy) then
            mid = mid + Entity.GetAbsOrigin(enemy)
        end
	end

    mid:Set(mid:GetX()/Heroes.Count(), mid:GetY()/Heroes.Count(), mid:GetZ()/Heroes.Count())
    return (pos + pos - mid):Normalized()
end

function Utility.IsKillable(npc)

    -- Abaddon's ultimate
    if NPC.HasModifier(npc, "modifier_abaddon_borrowed_time") then return false end

    -- Dazzle's save
    if NPC.HasModifier(npc, "modifier_dazzle_shallow_grave") then return false end

    -- Oracle's save
    if NPC.HasModifier(npc, "modifier_oracle_false_promise") then return false end

    -- WW's ultimate
    if NPC.HasModifier(npc, "modifier_winter_wyvern_winters_curse") then return false end
    if NPC.HasModifier(npc, "modifier_winter_wyvern_winters_curse_aura") then return false end

    return true
end

-- Get true physical damage
function Utility.GetTrueDamage(myHero)

    local damage = NPC.GetTrueDamage(myHero)

    if NPC.HasItem(myHero, "item_diffusal_blade", true) then
        damage = damage + 40 * 0.8
    end

    return damage
end

function Utility.GetHeroIndicesOrderedByLevel()

    local levels = {}
    for i = 1, Heroes.Count() do
        local npc = Heroes.Get(i)
        table.insert(levels, {i, NPC.GetCurrentLevel(npc)})
    end

    table.sort(levels, function (a, b) return a[2] > b[2] end)

    local indices = {}
    for k,v in ipairs(levels) do
       indices[k] = v[1]
    end

    return indices
end

function Utility.GetHeroIndicesOrderedByDistance()

    local myHero = Heroes.GetLocal()
    local pos1 = Entity.GetAbsOrigin(myHero)

    local distances = {}
    for i = 1, Heroes.Count() do
        local npc = Heroes.Get(i)
        local pos2 = Entity.GetAbsOrigin(npc)
        table.insert(distances, {i, (pos1 - pos2):Length()})
    end

    table.sort(distances, function (a, b) return a[2] < b[2] end)

    local indices = {}
    for k,v in ipairs(distances) do
       indices[k] = v[1]
    end

    return indices
end

-- return true if npc1 is facing towards npc2
function Utility.IsFacingTowards(npc1, npc2)

    if Entity.IsTurning(npc1) then
        return false
    end

    return NPC.GetTimeToFacePosition(npc1, Entity.GetAbsOrigin(npc2)) < 0.05
end

return Utility
