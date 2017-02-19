-- ===========================================
-- Economic Panel (Version 1.0)
-- Author : Eroica (eroicacmcs@gmail.com)
-- Date : 2017.2.18
-- ===========================================
-- 
-- Usage:
-- 1. Place this script to ./scripts/ folder
-- 2. Navigate in menu : "Awareness" -> "Economic Panel" (On/Off)
-- 
-- Features:
-- 1. Show economic status of every player in game (like spetator mode). It is based on the total value of items that players have in inventory.
-- 2. Show economic difference between two teams.
-- 
-- Thanks @paroxysm for his item panel script. It is a great reference.
-- Please feel free to report bugs or provide suggestions.
-- ===========================================

local EconPanel = {}

EconPanel.optionEnable = Menu.AddOption({ "Awareness" }, "Econ Panel", "show hero ranking of total item price")
EconPanel.font = Renderer.LoadFont("Tahoma", 16, Enum.FontWeight.EXTRABOLD)

EconPanel.heroes = {}
EconPanel.heroes["npc_dota_hero_abaddon"] = "Abaddon"
EconPanel.heroes["npc_dota_hero_alchemist"] = "Alchemist"
EconPanel.heroes["npc_dota_hero_antimage"] = "Anti-Mage"
EconPanel.heroes["npc_dota_hero_ancient_apparition"] = "Ancient Apparition"
EconPanel.heroes["npc_dota_hero_arcwarden"] = "Arc Warden"
EconPanel.heroes["npc_dota_hero_axe"] = "Axe"
EconPanel.heroes["npc_dota_hero_bane"] = "Bane"
EconPanel.heroes["npc_dota_hero_batrider"] = "Batrider"
EconPanel.heroes["npc_dota_hero_beastmaster"] = "Beastmaster"
EconPanel.heroes["npc_dota_hero_bloodseeker"] = "Bloodseeker"
EconPanel.heroes["npc_dota_hero_bounty_hunter"] = "Bounty Hunter"
EconPanel.heroes["npc_dota_hero_brewmaster"] = "Brewmaster"
EconPanel.heroes["npc_dota_hero_bristleback"] = "Bristleback"
EconPanel.heroes["npc_dota_hero_broodmother"] = "Broodmother"
EconPanel.heroes["npc_dota_hero_centaur"] = "Centaur Warrunner"
EconPanel.heroes["npc_dota_hero_chaos_knight"] = "Chaos Knight"
EconPanel.heroes["npc_dota_hero_chen"] = "Chen"
EconPanel.heroes["npc_dota_hero_clinkz"] = "Clinkz"
EconPanel.heroes["npc_dota_hero_rattletrap"] = "Clockwerk"
EconPanel.heroes["npc_dota_hero_crystal_maiden"] = "Crystal Maiden"
EconPanel.heroes["npc_dota_hero_dark_seer"] = "Dark Seer"
EconPanel.heroes["npc_dota_hero_dazzle"] = "Dazzle"
EconPanel.heroes["npc_dota_hero_death_prophet"] = "Death Prophet"
EconPanel.heroes["npc_dota_hero_disruptor"] = "Disruptor"
EconPanel.heroes["npc_dota_hero_doom_bringer"] = "Doom"
EconPanel.heroes["npc_dota_hero_dragon_knight"] = "Dragon Knight"
EconPanel.heroes["npc_dota_hero_drow_ranger"] = "Drow Ranger"
EconPanel.heroes["npc_dota_hero_earth_spirit"] = "Earth Spirit"
EconPanel.heroes["npc_dota_hero_earthshaker"] = "Earthshaker"
EconPanel.heroes["npc_dota_hero_elder_titan"] = "Elder Titan"
EconPanel.heroes["npc_dota_hero_ember_spirit"] = "Ember Spirit"
EconPanel.heroes["npc_dota_hero_enchantress"] = "Enchantress"
EconPanel.heroes["npc_dota_hero_enigma"] = "Enigma"
EconPanel.heroes["npc_dota_hero_faceless_void"] = "Faceless Void"
EconPanel.heroes["npc_dota_hero_gyrocopter"] = "Gyrocopter"
EconPanel.heroes["npc_dota_hero_huskar"] = "Huskar"
EconPanel.heroes["npc_dota_hero_invoker"] = "Invoker"
EconPanel.heroes["npc_dota_hero_wisp"] = "Io"
EconPanel.heroes["npc_dota_hero_jakiro"] = "Jakiro"
EconPanel.heroes["npc_dota_hero_juggernaut"] = "Juggernaut"
EconPanel.heroes["npc_dota_hero_keeper_of_the_light"] = "Keeper of the Light"
EconPanel.heroes["npc_dota_hero_kunkka"] = "Kunkka"
EconPanel.heroes["npc_dota_hero_legion_commander"] = "Legion Commander"
EconPanel.heroes["npc_dota_hero_leshrac"] = "Leshrac"
EconPanel.heroes["npc_dota_hero_lich"] = "Lich"
EconPanel.heroes["npc_dota_hero_life_stealer"] = "Lifestealer"
EconPanel.heroes["npc_dota_hero_lina"] = "Lina"
EconPanel.heroes["npc_dota_hero_lion"] = "Lion"
EconPanel.heroes["npc_dota_hero_lone_druid"] = "Lone Druid"
EconPanel.heroes["npc_dota_hero_luna"] = "Luna"
EconPanel.heroes["npc_dota_hero_lycan"] = "Lycan"
EconPanel.heroes["npc_dota_hero_magnataur"] = "Magnus"
EconPanel.heroes["npc_dota_hero_medusa"] = "Medusa"
EconPanel.heroes["npc_dota_hero_meepo"] = "Meepo"
EconPanel.heroes["npc_dota_hero_mirana"] = "Mirana"
EconPanel.heroes["npc_dota_hero_morphling"] = "Morphling"
EconPanel.heroes["npc_dota_hero_monkey_king"] = "Monkey King"
EconPanel.heroes["npc_dota_hero_naga_siren"] = "Naga Siren"
EconPanel.heroes["npc_dota_hero_furion"] = "Nature's Prophet"
EconPanel.heroes["npc_dota_hero_necrolyte"] = "Necrophos"
EconPanel.heroes["npc_dota_hero_night_stalker"] = "Night Stalker"
EconPanel.heroes["npc_dota_hero_nyx_assassin"] = "Nyx Assassin"
EconPanel.heroes["npc_dota_hero_ogre_magi"] = "Ogre Magi"
EconPanel.heroes["npc_dota_hero_omniknight"] = "Omniknight"
EconPanel.heroes["npc_dota_hero_oracle"] = "Oracle"
EconPanel.heroes["npc_dota_hero_obsidian_destroyer"] = "Outworld Devourer"
EconPanel.heroes["npc_dota_hero_phantom_assassin"] = "Phantom Assassin"
EconPanel.heroes["npc_dota_hero_phantom_lancer"] = "Phantom Lancer"
EconPanel.heroes["npc_dota_hero_phoenix"] = "Phoenix"
EconPanel.heroes["npc_dota_hero_puck"] = "Puck"
EconPanel.heroes["npc_dota_hero_pudge"] = "Pudge"
EconPanel.heroes["npc_dota_hero_pugna"] = "Pugna"
EconPanel.heroes["npc_dota_hero_queenofpain"] = "Queen of Pain"
EconPanel.heroes["npc_dota_hero_razor"] = "Razor"
EconPanel.heroes["npc_dota_hero_riki"] = "Riki"
EconPanel.heroes["npc_dota_hero_rubick"] = "Rubick"
EconPanel.heroes["npc_dota_hero_sand_king"] = "Sand King"
EconPanel.heroes["npc_dota_hero_shadow_demon"] = "Shadow Demon"
EconPanel.heroes["npc_dota_hero_nevermore"] = "Shadow Fiend"
EconPanel.heroes["npc_dota_hero_shadow_shaman"] = "Shadow Shaman"
EconPanel.heroes["npc_dota_hero_silencer"] = "Silencer"
EconPanel.heroes["npc_dota_hero_skywrath_mage"] = "Skywrath Mage"
EconPanel.heroes["npc_dota_hero_slardar"] = "Slardar"
EconPanel.heroes["npc_dota_hero_slark"] = "Slark"
EconPanel.heroes["npc_dota_hero_sniper"] = "Sniper"
EconPanel.heroes["npc_dota_hero_spectre"] = "Spectre"
EconPanel.heroes["npc_dota_hero_spirit_breaker"] = "Spirit Breaker"
EconPanel.heroes["npc_dota_hero_storm_spirit"] = "Storm Spirit"
EconPanel.heroes["npc_dota_hero_sven"] = "Sven"
EconPanel.heroes["npc_dota_hero_techies"] = "Techies"
EconPanel.heroes["npc_dota_hero_templar_assassin"] = "Templar Assassin"
EconPanel.heroes["npc_dota_hero_terrorblade"] = "Terrorblade"
EconPanel.heroes["npc_dota_hero_tidehunter"] = "Tidehunter"
EconPanel.heroes["npc_dota_hero_shredder"] = "Timbersaw"
EconPanel.heroes["npc_dota_hero_tinker"] = "Tinker"
EconPanel.heroes["npc_dota_hero_tiny"] = "Tiny"
EconPanel.heroes["npc_dota_hero_treant"] = "Treant Protector"
EconPanel.heroes["npc_dota_hero_troll_warlord"] = "Troll Warlord"
EconPanel.heroes["npc_dota_hero_tusk"] = "Tusk"
EconPanel.heroes["npc_dota_hero_abyssal_underlord"] = "Underlord"
EconPanel.heroes["npc_dota_hero_undying"] = "Undying"
EconPanel.heroes["npc_dota_hero_ursa"] = "Ursa"
EconPanel.heroes["npc_dota_hero_vengefulspirit"] = "Vengeful Spirit"
EconPanel.heroes["npc_dota_hero_venomancer"] = "Venomancer"
EconPanel.heroes["npc_dota_hero_viper"] = "Viper"
EconPanel.heroes["npc_dota_hero_visage"] = "Visage"
EconPanel.heroes["npc_dota_hero_warlock"] = "Warlock"
EconPanel.heroes["npc_dota_hero_weaver"] = "Weaver"
EconPanel.heroes["npc_dota_hero_windrunner"] = "Windranger"
EconPanel.heroes["npc_dota_hero_winter_wyvern"] = "Winter Wyvern"
EconPanel.heroes["npc_dota_hero_witch_doctor"] = "Witch Doctor"
EconPanel.heroes["npc_dota_hero_skeleton_king"] = "Wraith King"
EconPanel.heroes["npc_dota_hero_zuus"] = "Zeus"

EconPanel.item2price = {}
EconPanel.item2price["item_aegis"] = 0 --"Aegis of the Immortal"
EconPanel.item2price["item_courier"] = 100 -- "Animal Courier"
EconPanel.item2price["item_boots_of_elves"] = 450 -- "Band of Elvenskin"
EconPanel.item2price["item_belt_of_strength"] = 450 -- "Belt of Strength"
EconPanel.item2price["item_blade_of_alacrity"] = 1000 -- "Blade of Alacrity"
EconPanel.item2price["item_blades_of_attack"] = 420 -- "Blades of Attack"
EconPanel.item2price["item_blight_stone"] = 300 -- "Blight Stone"
EconPanel.item2price["item_blink"] = 2250 -- "Blink Dagger"
EconPanel.item2price["item_boots"] = 400 -- "Boots of Speed"
EconPanel.item2price["item_bottle"] = 660 -- "Bottle"
EconPanel.item2price["item_broadsword"] = 1200 -- "Broadsword"
EconPanel.item2price["item_chainmail"] = 550 -- "Chainmail"
EconPanel.item2price["item_cheese"] = 0 -- "Cheese"
EconPanel.item2price["item_circlet"] = 165 -- "Circlet"
EconPanel.item2price["item_clarity"] = 50 -- "Clarity"
EconPanel.item2price["item_claymore"] = 1400 -- "Claymore"
EconPanel.item2price["item_cloak"] = 550 -- "Cloak"
EconPanel.item2price["item_demon_edge"] = 2400 -- "Demon Edge"
EconPanel.item2price["item_dust"] = 180 -- "Dust of Appearance"
EconPanel.item2price["item_eagle"] = 3200 -- "Eaglesong"
EconPanel.item2price["item_enchanted_mango"] = 110 -- "Enchanted Mango"
EconPanel.item2price["item_energy_booster"] = 900 -- "Energy Booster"
EconPanel.item2price["item_faerie_fire"] = 75 -- "Faerie Fire"
EconPanel.item2price["item_flying_courier"] = 250 -- "Flying Courier"
EconPanel.item2price["item_gauntlets"] = 150 -- "Gauntlets of Strength"
EconPanel.item2price["item_gem"] = 900 -- "Gem of True Sight"
EconPanel.item2price["item_ghost"] = 1500 -- "Ghost Scepter"
EconPanel.item2price["item_gloves"] = 500 -- "Gloves of Haste"
EconPanel.item2price["item_flask"] = 110 -- "Healing Salve"
EconPanel.item2price["item_helm_of_iron_will"] = 900 -- "Helm of Iron Will"
EconPanel.item2price["item_hyperstone"] = 2000 -- "Hyperstone"
EconPanel.item2price["item_infused_raindrop"] = 225 -- "Infused Raindrop"
EconPanel.item2price["item_branches"] = 50 -- "Iron Branch"
EconPanel.item2price["item_javelin"] = 1500 -- "Javelin"
EconPanel.item2price["item_magic_stick"] = 200 -- "Magic Stick"
EconPanel.item2price["item_mantle"] = 150 -- "Mantle of Intelligence"
EconPanel.item2price["item_mithril_hammer"] = 1600 -- "Mithril Hammer"
EconPanel.item2price["item_lifesteal"] = 1200 -- "Morbid Mask"
EconPanel.item2price["item_mystic_staff"] = 2700 -- "Mystic Staff"
EconPanel.item2price["item_ward_observer"] = 65 -- "Observer Ward"
EconPanel.item2price["item_ogre_axe"] = 1000 -- "Ogre Club"
EconPanel.item2price["item_orb_of_venom"] = 275 -- "Orb of Venom"
EconPanel.item2price["item_platemail"] = 1400 -- "Platemail"
EconPanel.item2price["item_point_booster"] = 1200 -- "Point Booster"
EconPanel.item2price["item_quarterstaff"] = 875 -- "Quarterstaff"
EconPanel.item2price["item_quelling_blade"] = 200 -- "Quelling Blade"
EconPanel.item2price["item_reaver"] = 3000 -- "Reaver"
EconPanel.item2price["item_ring_of_health"] = 850 -- "Ring of Health"
EconPanel.item2price["item_ring_of_protection"] = 175 -- "Ring of Protection"
EconPanel.item2price["item_ring_of_regen"] = 325 -- "Ring of Regen"
EconPanel.item2price["item_robe"] = 450 -- "Robe of the Magi"
EconPanel.item2price["item_relic"] = 3800 -- "Sacred Relic"
EconPanel.item2price["item_sobi_mask"] = 325 -- "Sage's Mask"
EconPanel.item2price["item_ward_sentry"] = 100 -- "Sentry Ward"
EconPanel.item2price["item_shadow_amulet"] = 1300 -- "Shadow Amulet"
EconPanel.item2price["item_slippers"] = 150 -- "Slippers of Agility"
EconPanel.item2price["item_smoke_of_deceit"] = 50 -- "Smoke of Deceit"
EconPanel.item2price["item_staff_of_wizardry"] = 1000 -- "Staff of Wizardry"
EconPanel.item2price["item_stout_shield"] = 200 -- "Stout Shield"
EconPanel.item2price["item_talisman_of_evasion"] = 1450 -- "Talisman of Evasion"
EconPanel.item2price["item_tango"] = 125 -- "Tango"
EconPanel.item2price["item_tango_single"] = 0 -- "Tango (Shared)"
EconPanel.item2price["item_tome_of_knowledge"] = 150 -- "Tome of Knowledge"
EconPanel.item2price["item_tpscroll"] = 50 -- "Town Portal Scroll"
EconPanel.item2price["item_ultimate_orb"] = 2100 -- "Ultimate Orb"
EconPanel.item2price["item_vitality_booster"] = 1100 -- "Vitality Booster"
EconPanel.item2price["item_void_stone"] = 850 -- "Void Stone"
EconPanel.item2price["item_wind_lace"] = 250 -- "Wind Lace"
EconPanel.item2price["item_abyssal_blade"] = 6400 -- "Abyssal Blade"
EconPanel.item2price["item_aether_lens"] = 2350 -- "Aether Lens"
EconPanel.item2price["item_ultimate_scepter"] = 4200 -- "Aghanim's Scepter"
EconPanel.item2price["item_arcane_boots"] = 1300 -- "Arcane Boots"
EconPanel.item2price["item_armlet"] = 2370 -- "Armlet of Mordiggian"
EconPanel.item2price["item_assault"] = 5250 -- "Assault Cuirass"
EconPanel.item2price["item_bfury"] = 4500 -- "Battle Fury"
EconPanel.item2price["item_black_king_bar"] = 3975 -- "Black King Bar"
EconPanel.item2price["item_blade_mail"] = 2200 -- "Blade Mail"
EconPanel.item2price["item_bloodstone"] = 4900 -- "Bloodstone"
EconPanel.item2price["item_bloodthorn"] = 7195 -- "Bloodthorn"
EconPanel.item2price["item_travel_boots"] = 2400 -- "Boots of Trave 1"
EconPanel.item2price["item_travel_boots_2"] = 4400 -- "Boots of Trave 2"
EconPanel.item2price["item_bracer"] = 505 -- "Bracer"
EconPanel.item2price["item_buckler"] = 800 -- "Buckler"
EconPanel.item2price["item_butterfly"] = 5525 -- "Butterfly"
EconPanel.item2price["item_crimson_guard"] = 3550 -- "Crimson Guard"
EconPanel.item2price["item_lesser_crit"] = 2120 -- "Crystalys"
EconPanel.item2price["item_greater_crit"] = 5520 -- "Daedalus"
EconPanel.item2price["item_dagon"] = 2720 -- "Dagon 1"
EconPanel.item2price["item_dagon_2"] = 3972 -- "Dagon 2"
EconPanel.item2price["item_dagon_3"] = 5220 -- "Dagon 3"
EconPanel.item2price["item_dagon_4"] = 6470 -- "Dagon 4"
EconPanel.item2price["item_dagon_5"] = 7720 -- "Dagon 5"
EconPanel.item2price["item_desolator"] = 3500 -- "Desolator"
EconPanel.item2price["item_diffusal_blade"] = 3150 -- "Diffusal Blade 1"
EconPanel.item2price["item_diffusal_blade_2"] = 3850 -- "Diffusal Blade 2"
EconPanel.item2price["item_dragon_lance"] = 1900 -- "Dragon Lance"
EconPanel.item2price["item_ancient_janggo"] = 1780 -- "Drum of Endurance"
EconPanel.item2price["item_echo_sabre"] = 2650 -- "Echo Sabre"
EconPanel.item2price["item_ethereal_blade"] = 4700 -- "Ethereal Blade"
EconPanel.item2price["item_cyclone"] = 2750 -- "Eul's Scepter of Divinity"
EconPanel.item2price["item_skadi"] = 5675 -- "Eye of Skadi"
EconPanel.item2price["item_force_staff"] = 2225 -- "Force Staff"
EconPanel.item2price["item_glimmer_cape"] = 1850 -- "Glimmer Cape"
EconPanel.item2price["item_guardian_greaves"] = 5275 -- "Guardian Greaves"
EconPanel.item2price["item_hand_of_midas"] = 2050 -- "Hand of Midas"
EconPanel.item2price["item_headdress"] = 575 -- "Headdress"
EconPanel.item2price["item_heart"] = 5500 -- "Heart of Tarrasque"
EconPanel.item2price["item_heavens_halberd"] = 3500 -- "Heaven's Halberd"
EconPanel.item2price["item_helm_of_the_dominator"] = 1800 -- "Helm of the Dominator"
EconPanel.item2price["item_hood_of_defiance"] = 1725 -- "Hood of Defiance"
EconPanel.item2price["item_hurricane_pike"] = 4375 -- "Hurricane Pike"
EconPanel.item2price["item_iron_talon"] = 500 -- "Iron Talon"
EconPanel.item2price["item_sphere"] = 4800 -- "Linken's Sphere"
EconPanel.item2price["item_lotus_orb"] = 4000 -- "Lotus Orb"
EconPanel.item2price["item_maelstrom"] = 2800 -- "Maelstrom"
EconPanel.item2price["item_magic_wand"] = 465 -- "Magic Wand"
EconPanel.item2price["item_manta"] = 4950 -- "Manta Style"
EconPanel.item2price["item_mask_of_madness"] = 1900 -- "Mask of Madness"
EconPanel.item2price["item_medallion_of_courage"] = 1175 -- "Medallion of Courage"
EconPanel.item2price["item_mekansm"] = 2275 -- "Mekansm"
EconPanel.item2price["item_mjollnir"] = 5700 -- "Mjollnir"
EconPanel.item2price["item_monkey_king_bar"] = 5400 -- "Monkey King Bar"
EconPanel.item2price["item_moon_shard"] = 4000 -- "Moon Shard"
EconPanel.item2price["item_necronomicon"] = 2650 -- "Necronomicon 1"
EconPanel.item2price["item_necronomicon_2"] = 3850 -- "Necronomicon 2"
EconPanel.item2price["item_necronomicon_3"] = 5050 -- "Necronomicon 3"
EconPanel.item2price["item_null_talisman"] = 470 -- "Null Talisman"
EconPanel.item2price["item_oblivion_staff"] = 1650 -- "Oblivion Staff"
EconPanel.item2price["item_ward_dispenser"] = 165 -- "Observer and Sentry Wards"
EconPanel.item2price["item_octarine_core"] = 5900 -- "Octarine Core"
EconPanel.item2price["item_orchid"] = 4075 -- "Orchid Malevolence"
EconPanel.item2price["item_pers"] = 1700 -- "Perseverance"
EconPanel.item2price["item_phase_boots"] = 1240 -- "Phase Boots"
EconPanel.item2price["item_pipe"] = 3100 -- "Pipe of Insight"
EconPanel.item2price["item_poor_mans_shield"] = 500 -- "Poor Man's Shield"
EconPanel.item2price["item_power_treads"] = 1350 -- "Power Treads"
EconPanel.item2price["item_radiance"] = 5150 -- "Radiance"
EconPanel.item2price["item_rapier"] = 6200 -- "Divine Rapier"
EconPanel.item2price["item_refresher"] = 5200 -- "Refresher Orb"
EconPanel.item2price["item_ring_of_aquila"] = 985 -- "Ring of Aquila"
EconPanel.item2price["item_ring_of_basilius"] = 500 -- "Ring of Basilius"
EconPanel.item2price["item_rod_of_atos"] = 3100 -- "Rod of Atos"
EconPanel.item2price["item_sange"] = 2050 -- "Sange"
EconPanel.item2price["item_sange_and_yasha"] = 4100 -- "Sange and Yasha"
EconPanel.item2price["item_satanic"] = 5800 -- "Satanic"
EconPanel.item2price["item_sheepstick"] = 5650 -- "Scythe of Vyse"
EconPanel.item2price["item_invis_sword"] = 2700 -- "Shadow Blade"
EconPanel.item2price["item_shivas_guard"] = 4700 -- "Shiva's Guard"
EconPanel.item2price["item_silver_edge"] = 5100 -- "Silver Edge"
EconPanel.item2price["item_basher"] = 2700 -- "Skull Basher"
EconPanel.item2price["item_solar_crest"] = 2625 -- "Solar Crest"
EconPanel.item2price["item_soul_booster"] = 3200 -- "Soul Booster"
EconPanel.item2price["item_soul_ring"] = 800 -- "Soul Ring"
EconPanel.item2price["item_tranquil_boots"] = 900 -- "Tranquil Boots"
EconPanel.item2price["item_urn_of_shadows"] = 875 -- "Urn of Shadows"
EconPanel.item2price["item_vanguard"] = 2150 -- "Vanguard"
EconPanel.item2price["item_veil_of_discord"] = 2240 -- "Veil of Discord"
EconPanel.item2price["item_vladmir"] = 2275 -- "Vladmir's Offering"
EconPanel.item2price["item_wraith_band"] = 485 -- "Wraith Band"
EconPanel.item2price["item_yasha"] = 2050 -- "Yasha"

function EconPanel.OnDraw()
	if not Menu.IsEnabled(EconPanel.optionEnable) then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local econTable = {} -- econTable = { {heroName_1, econValue_1}, {heroName_2, econValue_2}, ...}
	local isSameTeamTable = {} -- isSameTeamTable[heroName] = True/False

	for i = 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		if not NPC.IsIllusion(hero) then
			local heroName = EconPanel.heroes[NPC.GetUnitName(hero)]
			isSameTeamTable[heroName] = Entity.IsSameTeam(myHero, hero)
			econTable[#econTable + 1] = {heroName, EconPanel.GetEcon(hero)}
		end
	end

	-- sort econTable by econValue in descending order
	table.sort(econTable, function(a, b) return a[2] > b[2] end)
	
	-- draw parameters
	local drawX = 10
	local drawY = 100
	local lineGap = 20
	local wordGap = 10
	local maxWidth = 200
	local maxGold = 35000
	local rectHeight = 10

	local myTeamEcon = 0
	local enemyTeamEcon = 0

	for i, v in ipairs(econTable) do
		local heroName = v[1]
		local econValue = v[2]

		if isSameTeamTable[heroName] then
			Renderer.SetDrawColor(0, 255, 0, 150)
			myTeamEcon = myTeamEcon + econValue
		else
			Renderer.SetDrawColor(255, 0, 0, 150)
			enemyTeamEcon = enemyTeamEcon + econValue
		end

		drawY = drawY + lineGap
		local rectWidth = math.floor(maxWidth * econValue / maxGold)
		Renderer.DrawFilledRect(drawX, math.floor(drawY+0.5*rectHeight), rectWidth, rectHeight)
		local drawText = heroName.." ("..econValue..")"
		Renderer.DrawText(EconPanel.font, drawX+wordGap+rectWidth, drawY, drawText, 1)
	end

	local econDiff = myTeamEcon - enemyTeamEcon
	if econDiff > 0 then
		Renderer.SetDrawColor(0, 255, 0, 255)
	else
		Renderer.SetDrawColor(255, 0, 0, 255)
	end
	drawY = drawY + 2 * lineGap
	Renderer.DrawText(EconPanel.font, drawX, drawY, "Economic Difference: "..econDiff, 1)

end

-- Cant count repeated items. For example. if have two moon shards, it only counts once.
function EconPanel.GetEcon(hero)
	local totalEcon = 0
	for key, value in pairs(EconPanel.item2price) do
		if NPC.HasItem(hero, key, true) then
			totalEcon = totalEcon + EconPanel.item2price[key]
		end
	end
	return totalEcon
end

return EconPanel
