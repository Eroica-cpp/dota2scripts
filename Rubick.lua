local Utility = require("Utility")

local Rubick = {}

local optionAutoTelekinesis = Menu.AddOption({"Hero Specific", "Rubick"}, "Auto Telekinesis", "Auto cast Telekinesis on any enemy in range once rubick has level 6")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Kill Steal", "Cast spell on enemy to KS")
local optionAutoSpellSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Auto Spell Steal", "Auto steal important spells")
local optionQuickCast = Menu.AddOption({"Hero Specific", "Rubick"}, "Quick Cast Spells", "If have certain spells, then cast them quickly.")


local StealTable = {}
StealTable["abaddon_aphotic_shield"] = true
StealTable["abyssal_underlord_firestorm"] = true
StealTable["abyssal_underlord_pit_of_malice"] = true
StealTable["abyssal_underlord_dark_rift"] = true
StealTable["alchemist_unstable_concoction"] = true
StealTable["alchemist_chemical_rage"] = true
StealTable["ancient_apparition_cold_feet"] = true
StealTable["ancient_apparition_ice_blast"] = true
StealTable["antimage_blink"] = true
StealTable["antimage_mana_void"] = true
StealTable["axe_berserkers_call"] = true
StealTable["bane_nightmare"] = true
StealTable["bane_fiends_grip"] = true
StealTable["batrider_firefly"] = true
StealTable["batrider_flaming_lasso"] = true
StealTable["beastmaster_primal_roar"] = true
StealTable["bloodseeker_blood_bath"] = true
StealTable["bloodseeker_rupture"] = true
StealTable["bounty_hunter_wind_walk"] = true
StealTable["bounty_hunter_track"] = true
StealTable["brewmaster_primal_split"] = true
StealTable["centaur_hoof_stomp"] = true
StealTable["centaur_stampede"] = true
StealTable["chaos_knight_chaos_bolt"] = true
-- StealTable["chaos_knight_reality_rift"] = true
StealTable["chaos_knight_phantasm"] = true
StealTable["chen_hand_of_god"] = true
StealTable["chen_holy_persuasion"] = true
StealTable["clinkz_wind_walk"] = true
StealTable["crystal_maiden_frostbite"] = true
StealTable["crystal_maiden_freezing_field"] = true
StealTable["dark_seer_ion_shell"] = true
StealTable["dark_seer_surge"] = true
StealTable["dark_seer_wall_of_replica"] = true
StealTable["dazzle_shallow_grave"] = true
StealTable["dazzle_weave"] = true
StealTable["death_prophet_silence"] = true
StealTable["death_prophet_exorcism"] = true
StealTable["disruptor_glimpse"] = true
StealTable["disruptor_kinetic_field"] = true
StealTable["disruptor_static_storm"] = true
StealTable["doom_bringer_doom"] = true
StealTable["dragon_knight_dragon_tail"] = true
StealTable["dragon_knight_elder_dragon_form"] = true
StealTable["drow_ranger_wave_of_silence"] = true
StealTable["earth_spirit_magnetize"] = true
StealTable["earthshaker_fissure"] = true
StealTable["earthshaker_echo_slam"] = true
StealTable["elder_titan_earth_splitter"] = true
StealTable["ember_spirit_searing_chains"] = true
StealTable["ember_spirit_flame_guard"] = true
StealTable["ember_spirit_activate_fire_remnant"] = true
StealTable["enchantress_enchant"] = true
StealTable["enchantress_natures_attendants"] = true
StealTable["enigma_malefice"] = true
StealTable["enigma_midnight_pulse"] = true
StealTable["enigma_black_hole"] = true
StealTable["faceless_void_time_walk"] = true
StealTable["faceless_void_chronosphere"] = true
StealTable["furion_sprout"] = true
StealTable["furion_teleportation"] = true
StealTable["furion_force_of_nature"] = true
StealTable["furion_wrath_of_nature"] = true
StealTable["gyrocopter_homing_missile"] = true
StealTable["gyrocopter_call_down"] = true
StealTable["huskar_inner_vitality"] = true
StealTable["invoker_cold_snap"] = true
StealTable["invoker_ghost_walk"] = true
StealTable["invoker_tornado"] = true
StealTable["invoker_emp"] = true
StealTable["invoker_chaos_meteor"] = true
StealTable["invoker_sun_strike"] = true
StealTable["invoker_forge_spirit"] = true
StealTable["invoker_ice_wall"] = true
StealTable["invoker_deafening_blast"] = true
StealTable["jakiro_ice_path"] = true
StealTable["jakiro_macropyre"] = true
StealTable["juggernaut_blade_fury"] = true
StealTable["juggernaut_healing_ward"] = true
StealTable["juggernaut_omni_slash"] = true
StealTable["keeper_of_the_light_mana_leak"] = true
StealTable["keeper_of_the_light_chakra_magic"] = true
StealTable["keeper_of_the_light_blinding_light"] = true
StealTable["kunkka_torrent"] = true
StealTable["kunkka_x_marks_the_spot"] = true
StealTable["kunkka_ghostship"] = true
StealTable["legion_commander_press_the_attack"] = true
StealTable["legion_commander_duel"] = true
StealTable["leshrac_split_earth"] = true
StealTable["leshrac_diabolic_edict"] = true
StealTable["lich_chain_frost"] = true
StealTable["life_stealer_rage"] = true
StealTable["life_stealer_open_wounds"] = true
StealTable["life_stealer_infest"] = true
StealTable["lina_light_strike_array"] = true
StealTable["lina_laguna_blade"] = true
StealTable["lion_impale"] = true
StealTable["lion_voodoo"] = true
StealTable["lion_finger_of_death"] = true
StealTable["lone_druid_spirit_bear"] = true
StealTable["luna_eclipse"] = true
StealTable["lycan_summon_wolves"] = true
StealTable["lycan_shapeshift"] = true
StealTable["magnataur_skewer"] = true
StealTable["magnataur_reverse_polarity"] = true
StealTable["medusa_stone_gaze"] = true
StealTable["meepo_earthbind"] = true
StealTable["mirana_arrow"] = true
StealTable["mirana_leap"] = true
StealTable["mirana_invis"] = true
StealTable["monkey_king_boundless_strike"] = true
StealTable["monkey_king_tree_dance"] = true
StealTable["monkey_king_primal_spring"] = true
StealTable["monkey_king_wukongs_command"] = true
StealTable["morphling_waveform"] = true
StealTable["morphling_adaptive_strike"] = true
StealTable["morphling_morph_agi"] = true
StealTable["morphling_morph_str"] = true
StealTable["morphling_morph"] = true
StealTable["naga_siren_ensnare"] = true
StealTable["naga_siren_song_of_the_siren"] = true
StealTable["necrolyte_sadist"] = true
StealTable["necrolyte_reapers_scythe"] = true
StealTable["nevermore_requiem"] = true
StealTable["night_stalker_void"] = true
StealTable["night_stalker_crippling_fear"] = true
StealTable["night_stalker_hunter_in_the_night"] = true
StealTable["nyx_assassin_impale"] = true
StealTable["nyx_assassin_spiked_carapace"] = true
StealTable["nyx_assassin_vendetta"] = true
StealTable["obsidian_destroyer_astral_imprisonment"] = true
StealTable["obsidian_destroyer_sanity_eclipse"] = true
StealTable["ogre_magi_fireblast"] = true
StealTable["ogre_magi_multicast"] = true
StealTable["omniknight_repel"] = true
StealTable["omniknight_guardian_angel"] = true
StealTable["oracle_fortunes_end"] = true
StealTable["oracle_false_promise"] = true
StealTable["phantom_assassin_stifling_dagger"] = true
StealTable["phantom_lancer_doppelwalk"] = true
StealTable["phoenix_icarus_dive"] = true
StealTable["phoenix_supernova"] = true
StealTable["puck_waning_rift"] = true
StealTable["puck_phase_shift"] = true
StealTable["puck_dream_coil"] = true
StealTable["pudge_meat_hook"] = true
StealTable["pudge_dismember"] = true
StealTable["pugna_nether_blast"] = true
StealTable["pugna_nether_ward"] = true
StealTable["pugna_life_drain"] = true
StealTable["queenofpain_blink"] = true
StealTable["queenofpain_sonic_wave"] = true
StealTable["rattletrap_battery_assault"] = true
StealTable["rattletrap_hookshot"] = true
StealTable["razor_static_link"] = true
StealTable["razor_eye_of_the_storm"] = true
StealTable["riki_smoke_screen"] = true
StealTable["riki_blink_strike"] = true
StealTable["riki_tricks_of_the_trade"] = true
StealTable["sandking_burrowstrike"] = true
StealTable["sandking_sand_storm"] = true
StealTable["sandking_epicenter"] = true
StealTable["shadow_demon_disruption"] = true
StealTable["shadow_demon_demonic_purge"] = true
StealTable["shadow_shaman_voodoo"] = true
StealTable["shadow_shaman_shackles"] = true
StealTable["shadow_shaman_mass_serpent_ward"] = true
StealTable["shredder_timber_chain"] = true
StealTable["silencer_last_word"] = true
StealTable["silencer_global_silence"] = true
StealTable["skeleton_king_hellfire_blast"] = true
StealTable["skywrath_mage_ancient_seal"] = true
StealTable["skywrath_mage_mystic_flare"] = true
StealTable["slardar_sprint"] = true
StealTable["slardar_slithereen_crush"] = true
StealTable["slardar_amplify_damage"] = true
StealTable["slark_pounce"] = true
StealTable["slark_shadow_dance"] = true
StealTable["sniper_shrapnel"] = true
StealTable["sniper_assassinate"] = true
StealTable["spectre_spectral_dagger"] = true
StealTable["spectre_haunt"] = true
StealTable["spirit_breaker_charge_of_darkness"] = true
StealTable["spirit_breaker_nether_strike"] = true
StealTable["storm_spirit_electric_vortex"] = true
StealTable["storm_spirit_ball_lightning"] = true
StealTable["sven_gods_strength"] = true
StealTable["sven_warcry"] = true
StealTable["techies_land_mines"] = true
StealTable["techies_stasis_trap"] = true
StealTable["techies_suicide"] = true
StealTable["techies_remote_mines"] = true
StealTable["templar_assassin_refraction"] = true
StealTable["templar_assassin_meld"] = true
StealTable["templar_assassin_trap"] = true
StealTable["terrorblade_sunder"] = true
StealTable["tidehunter_ravage"] = true
StealTable["tinker_rearm"] = true
StealTable["tiny_avalanche"] = true
StealTable["tiny_toss"] = true
StealTable["treant_living_armor"] = true
StealTable["treant_overgrowth"] = true
StealTable["troll_warlord_battle_trance"] = true
StealTable["tusk_ice_shards"] = true
StealTable["tusk_snowball"] = true
StealTable["tusk_walrus_kick"] = true
StealTable["tusk_walrus_punch"] = true
StealTable["undying_tombstone"] = true
StealTable["undying_flesh_golem"] = true
StealTable["ursa_enrage"] = true
StealTable["vengefulspirit_magic_missile"] = true
StealTable["vengefulspirit_nether_swap"] = true
StealTable["venomancer_plague_ward"] = true
StealTable["venomancer_poison_nova"] = true
StealTable["viper_viper_strike"] = true
StealTable["visage_summon_familiars"] = true
StealTable["warlock_fatal_bonds"] = true
StealTable["warlock_rain_of_chaos"] = true
StealTable["weaver_shukuchi"] = true
StealTable["weaver_time_lapse"] = true
StealTable["windrunner_shackleshot"] = true
StealTable["windrunner_windrun"] = true
StealTable["winter_wyvern_cold_embrace"] = true
StealTable["winter_wyvern_winters_curse"] = true
StealTable["witch_doctor_paralyzing_cask"] = true
StealTable["witch_doctor_voodoo_restoration"] = true
StealTable["witch_doctor_death_ward"] = true
StealTable["zuus_lightning_bolt"] = true
StealTable["zuus_cloud"] = true
StealTable["zuus_thundergods_wrath"] = true

local QuickCastAbilities = {
    "abyssal_underlord_pit_of_malice",
    "ancient_apparition_cold_feet",
    "batrider_flaming_lasso",
    "bane_nightmare_end",
    "bloodseeker_rupture",
    "bounty_hunter_track",
    "chaos_knight_chaos_bolt",
    "crystal_maiden_frostbite",
    "death_prophet_silence",
    "doom_bringer_doom",
    "dragon_knight_dragon_tail",
    "drow_ranger_wave_of_silence",
    "earthshaker_fissure",
    "elder_titan_earth_splitter",
    "enigma_malefice",
    "enigma_midnight_pulse",
    "enigma_black_hole",
    "gyrocopter_homing_missile",
    "gyrocopter_call_down",
    "invoker_cold_snap",
    "invoker_tornado",
    "invoker_emp",
    "invoker_chaos_meteor",
    "invoker_sun_strike",
    "invoker_deafening_blast",
    "jakiro_ice_path",
    "jakiro_macropyre",
    "juggernaut_omni_slash",
    "keeper_of_the_light_mana_leak",
    "kunkka_torrent",
    "kunkka_x_marks_the_spot",
    "kunkka_ghostship",
    "leshrac_split_earth",
    "lich_chain_frost",
    "life_stealer_open_wounds",
    "lina_light_strike_array",
    "lina_laguna_blade",
    "lion_impale",
    "lion_voodoo",
    "lion_finger_of_death",
    "mirana_arrow",
    "monkey_king_boundless_strike",
    "morphling_adaptive_strike",
    "naga_siren_ensnare",
    "night_stalker_void",
    "night_stalker_crippling_fear",
    "nyx_assassin_impale",
    "nyx_assassin_mana_burn",
    "ogre_magi_fireblast",
    "ogre_magi_ignite",
    "ogre_magi_multicast",
    "phantom_assassin_stifling_dagger",
    "phantom_lancer_spirit_lance",
    "pudge_dismember",
    "pugna_nether_blast",
    "pugna_life_drain",
    "queenofpain_sonic_wave",
    "razor_static_link",
    "riki_smoke_screen",
    "shadow_demon_demonic_purge",
    "shadow_shaman_ether_shock",
    "shadow_shaman_voodoo",
    "silencer_last_word",
    "skeleton_king_hellfire_blast",
    "skywrath_mage_ancient_seal",
    "skywrath_mage_mystic_flare",
    "slardar_amplify_damage",
    "spectre_spectral_dagger",
    "storm_spirit_electric_vortex",
    "sven_storm_bolt",
    "techies_land_mines",
    "techies_stasis_trap",
    "templar_assassin_trap",
    "tidehunter_gush",
    "tinker_laser",
    "tinker_heat_seeking_missile",
    "tinker_march_of_the_machines",
    "tiny_avalanche",
    "tusk_walrus_punch",
    "vengefulspirit_magic_missile",
    "viper_viper_strike",
    "warlock_fatal_bonds",
    "warlock_shadow_word",
    "windrunner_shackleshot",
    "witch_doctor_paralyzing_cask",
    "witch_doctor_maledict",
    "zuus_lightning_bolt"
}

function Rubick.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        Rubick.KillSteal()
    end

    if Menu.IsEnabled(optionAutoTelekinesis) then
        Rubick.AutoTelekinesis()
    end

    if Menu.IsEnabled(optionAutoSpellSteal) then
        Rubick.AutoSpellSteal()
    end

    if Menu.IsEnabled(optionQuickCast) then
        Rubick.QuickCast()
    end
end

-- Kill stealer or linkens breaker
function Rubick.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "rubick_fade_bolt")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    local range = Utility.GetCastRange(myHero, spell)
    local damage = 80 * Ability.GetLevel(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            if true_damage >= Entity.GetHealth(enemy) or Utility.IsLinkensProtected(enemy) then
                Ability.CastTarget(spell, enemy)
                return
            end
        end
    end
end

function Rubick.AutoTelekinesis()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end
    if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "rubick_telekinesis")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Utility.GetCastRange(myHero, spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) and not Utility.IsLinkensProtected(enemy) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function Rubick.AutoSpellSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local steal = NPC.GetAbility(myHero, "rubick_spell_steal")
    if not steal or not Ability.IsCastable(steal, NPC.GetMana(myHero)) then return end
    local range = Utility.GetCastRange(myHero, steal)

    -- don't steal if currently has stolen spells available
    local slot1 = NPC.GetAbilityByIndex(myHero, 3)
    local slot2 = NPC.GetAbilityByIndex(myHero, 4)
    if (slot1 and Ability.IsCastable(slot1, NPC.GetMana(myHero))) or (slot2 and Ability.IsCastable(slot2, NPC.GetMana(myHero))) then return end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsLinkensProtected(enemy) then

            local spell = Rubick.GetLastSpell(enemy)
            if spell and StealTable[Ability.GetName(spell)]
            and (not slot1 or Ability.GetName(slot1) ~= Ability.GetName(spell))
            and (not slot2 or Ability.GetName(slot2) ~= Ability.GetName(spell)) then
                Ability.CastTarget(steal, enemy)
                return
            end
        end
    end
end

function Rubick.QuickCast()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_rubick" then return end

    local spell
    for i = 1, #QuickCastAbilities do
        if NPC.GetAbility(myHero, QuickCastAbilities[i]) then
            spell = NPC.GetAbility(myHero, QuickCastAbilities[i])
        end
    end

    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Utility.GetCastRange(myHero, spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) then

            Ability.CastTarget(spell, enemy)
            Ability.CastPosition(spell, Utility.GetPredictedPosition(enemy, Ability.GetCastPoint(spell)))
            return
        end
    end
end

function Rubick.GetLastSpell(enemy)
    if not enemy then return end

    local min = 999999
    local res
    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(enemy, i)
        if ability and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            -- Ability.SecondsSinceLastUse returns -1 if it isn't on cooldown.
            local lastUsed = Ability.SecondsSinceLastUse(ability)
            if lastUsed >= 0 and lastUsed < min then
                res = ability
                min = lastUsed
            end
        end
    end

    return res
end

return Rubick
