local Utility = require("Utility")
local Manager = require("Manager")

local Monitor = {}

-- Dodge.option = Menu.AddOption({"Utility", "Dodge Spells and Items"}, "Dodge Projectile", "On/Off")

-- use message queue to manage tasks
-- Dodge.msg_queue = {}
-- Dodge.delta = 0.05

function Monitor.OnProjectile(projectile)
	-- if not Menu.IsEnabled(Dodge.option) then return end
	if not projectile.source or not projectile.target then return end
	if not projectile.dodgeable then return end
	if not Entity.IsHero(projectile.source) then return end
	if projectile.isAttack then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	if projectile.target ~= myHero then return end
	if Entity.IsSameTeam(projectile.source, projectile.target) then return end

	-- Dodge.Defend(myHero)
end

function Monitor.OnLinearProjectileCreate(projectile)
	-- if not Menu.IsEnabled(Dodge.option) then return end
	-- Log.Write(projectile.name)
end

function Monitor.OnUnitAnimation(animation)
	-- if not Menu.IsEnabled(Dodge.option) then return end
	if not animation or not animation.unit then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if Entity.IsSameTeam(myHero, animation.unit) then return end

	-- Log.Write(animation.sequenceName .. " " .. NPC.GetUnitName(animation.unit))

	-- 1. anti-mage's mana void
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_antimage" then
		local radius = 600 + 500/2
		if animation.sequenceName == "basher_cast4_mana_void_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 2. axe's culling blade (cant catch call's animation)
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_axe" then
		local radius = 300
		if animation.sequenceName == "culling_blade_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 3. bane's nightmare and fiend's grip
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_bane" then
		local radius1 = 825
		if animation.sequenceName == "nightmare" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			Dodge.Defend(myHero)
		end

		local radius2 = 800
		if animation.sequenceName == "fiends_grip_cast" and NPC.IsEntityInRange(myHero, animation.unit, radius2) then
			Dodge.Defend(myHero)
		end		
	end	

	-- 4. batrider's lasso
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_batrider" then
		local radius = 200
		if animation.sequenceName == "lasso_start_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 5. beastmaster's roar
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_beastmaster" then
		local radius = 950
		if animation.sequenceName == "cast4_primal_roar_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 5. bloodseeker's rupture
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_bloodseeker" then
		local radius = 1000
		if animation.sequenceName == "cast4_rupture_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end	

	-- 6. centaur's stomp
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_centaur" then
		local radius = 315
		if animation.sequenceName == "cast_hoofstomp_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 7. chaos knight's bolt and rift (cant catch rift animation)
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_chaos_knight" then
		local radius1 = 500
		if animation.sequenceName == "chaosbolt_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			Dodge.Defend(myHero)
		end

		-- local radius2 = 700
		-- if animation.sequenceName == "chaosbolt_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
		-- 	Dodge.Defend(myHero)
		-- end		
	end

	-- 8. clock's hook
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_rattletrap" then
		-- cant catch animation of hook
	end

	-- 9. crystal maiden's frostbite
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_crystal_maiden" then
		local radius = 650
		if animation.sequenceName == "frostbite_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 10. death prophet's silence
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_death_prophet" then
		local radius = 1000 + 425/2
		if animation.sequenceName == "cast2_silence_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 11. disruptor's glimpse (cant catch disruptor's ultimate)
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_disruptor" then
		-- cant catch disruptor's ultimate
	end

	-- 12. doom
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_doom_bringer" then
		local radius = 550
		if animation.sequenceName == "cast_doom" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 13. dragon knight's stun
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_dragon_knight" then
		-- dk's stun has no animation, and thus cant dodge
	end

	-- 14. drow's silence
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_drow_ranger" then
		local radius = 1000
		if animation.sequenceName == "cast2_silence_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 15. earth spirit
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_earth_spirit" then
	end

	-- 16. earthshaker
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_earthshaker" then
		local radius1 = 1400
		if animation.sequenceName == "fissure_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			Dodge.Defend(myHero)
		end

		local radius2 = 350
		if animation.sequenceName == "enchant_totem_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius2) then
			Dodge.Defend(myHero)
		end
	end

	-- 17. engima's black hole
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_enigma" then
		local radius = 275 + 420/2
		if animation.sequenceName == "cast4_black_hole_chasm" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 18. void's chrono
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_faceless_void" then
		local radius = 600 + 425/2
		if animation.sequenceName == "chronosphere_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 19. jakiro
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_jakiro" then
		-- can be implemented by OnLinearProjectile()
	end

	-- 20. juggernaut's omnislash
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_juggernaut" then
		local radius = 350 + 425/2
		if animation.sequenceName == "attack_omni_cast" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 21. KoL's mana leak
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_keeper_of_the_light" then
		-- no need to implement this
	end

	-- 21.5 Kunkka's X mark
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_kunkka" 
		and NPC.HasModifier(myHero, "modifier_kunkka_x_marks_the_spot") 
		and animation.sequenceName == "x_mark_anim" then
			Dodge.Defend(myHero)
	end

	-- 22. legion's duel
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_legion_commander" then
		local radius = 300
		if animation.sequenceName == "dualwield_legion_commander_duel_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 23. lich's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lich" then
		local radius = 1000
		if animation.sequenceName == "chain_frost" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 24. lina's laguna blade
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lina" then
		local radius = 725
		if animation.sequenceName == "laguna_blade_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 25. lion's finger and spike
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lion" then
		local radius1 = 850
		if animation.sequenceName == "impale_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			-- Dodge.Defend(myHero)
			Dodge.DefendWithDelay(0.3-0.1)
		end

		local radius2 = 900
		if animation.sequenceName == "finger_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius2) then
			-- Dodge.Defend(myHero)
			Dodge.DefendWithDelay(0.3)
		end
	end

	-- 26. lone druid's roar
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_lone_druid" then
		local radius = 350
		if animation.sequenceName == "cast_savage_roar" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 27. luna's lucent
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_luna" then
		local radius = 800
		if animation.sequenceName == "moonfall_cast1_lucent_beam_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 28. magnus's rp
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_magnataur" then
		local radius = 410 + 50
		if animation.sequenceName == "polarity_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			-- Dodge.Defend(myHero)
			Dodge.DefendWithDelay(0.1)
		end
	end

	-- 29. monkey king's strike
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_monkey_king" then
		-- no animation detection for monkey king yet
	end

	-- 30. naga siren's song
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_naga_siren" then
		local radius = 1250
		if animation.sequenceName == "cast4_sirenSong_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 31. necro's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_necrolyte" then
		local radius = 650
		if animation.sequenceName == "cast_ult_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 32. night stalker's silence
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_night_stalker" then
		local radius = 650
		if animation.sequenceName == "cast_cripplingfear_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 32. nyx_assassin's impale
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_nyx_assassin" then
		local radius = 700
		if animation.sequenceName == "impale_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 33. ogre_magi's stun
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_ogre_magi" then
		local radius = 600
		if animation.sequenceName == "cast1_fireblast_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 33.5 OD's imprison and ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_obsidian_destroyer" then
		local radius1 = 450
		if animation.sequenceName == "castb_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius1) then
			Dodge.Defend(myHero)
		end

		local radius2 = 700 + 575/2
		if animation.sequenceName == "cast_ulti_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius2) then
			-- Dodge.Defend(myHero)
			Dodge.DefendWithDelay(0.1)
		end
	end
	-- 34. puck's silence
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_puck" then
		local radius = 450
		if animation.sequenceName == "cast2_rift_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 35. pudge's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_pudge" then
		local radius = 250
		if animation.sequenceName == "pudge_dismember_start" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 36. qop's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_queenofpain" then
		local radius = 900
		if animation.sequenceName == "queen_sonicwave_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 37. riki's smoke
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_riki" then
		local radius = 550 + 325/2
		if animation.sequenceName == "cast1_smoke_screen_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 38. rubick's lift
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_rubick" then
		local radius = 700
		if animation.sequenceName == "rubick_cast_telekinesis_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 39. Sand King's burrow
	-- burrow doesn't have animation, it can be dodge in OnLinearProjectile()

	-- 40. shadow demon's disruption
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_shadow_demon" then
		local radius = 700
		if animation.sequenceName == "ability1_cast" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 41. shadow fiend's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_nevermore" then
		local radius = 1000
		if animation.sequenceName == "cast6_requiem_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			-- Dodge.Defend(myHero)
			Dodge.DefendWithDelay(1.67-0.2)
		end
	end

	-- 42. shadow shaman's shackles
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_shadow_shaman" then
		local radius = 500
		if animation.sequenceName == "cast_channel_shackles_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 43. silencer's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_silencer" then
		if animation.sequenceName == "cast_GS_anim" then
			Dodge.Defend(myHero)
		end
	end

	-- 44. skywrath mage's silence
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_skywrath_mage" then
		local radius = 750
		if animation.sequenceName == "skywrath_mage_seal_cast_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 45. slardar's crush
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_slardar" then
		local radius = 350
		if animation.sequenceName == "crush_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 46. spirit breaker's ultimate (no animation for charge)
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_spirit_breaker" then
		local radius = 850
		if animation.sequenceName == "ultimate_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 47. storm's pull
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_storm_spirit" then
		local radius = 350
		if animation.sequenceName == "vortex_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 48. sven's hammer
	-- implemented in OnProjectile()

	-- 49. techies's suicide
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_techies" then
		local radius = 1200
		if animation.sequenceName == "cast_blast_off" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 50. tb's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_terrorblade" then
		local radius = 600
		if animation.sequenceName == "sunder" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 51. tide's ravage
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_tidehunter" then
		local radius = 1100
		if animation.sequenceName == "ravage_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 52. tinker's laser
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_tinker" then
		local radius = 725 + 220
		if animation.sequenceName == "laser_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 53. tiny
	-- tiny's VT combo don't have animation time

	-- 54. treant's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_treant" then
		local radius = 850
		if animation.sequenceName == "cast5_Overgrowth_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 55. Tusk
	-- no animation for tusk's punch

	-- 56. underlord's trap
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_abyssal_underlord" then
		local radius = 875 + 375/2
		if animation.sequenceName == "au_cast02_pit_of_malice" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 57. venge's swap
	-- no animation for venge's swap

	-- 58. visage's birds' stun
	if NPC.GetUnitName(animation.unit) == "npc_dota_visage_familiar3" then
		local radius = 350
		if animation.sequenceName == "cast" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 59. warlock's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_warlock" then
		local radius = 1200 + 600/2
		if animation.sequenceName == "warlock_cast4_rain_chaos_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 60. windrunner's shackle
	-- can be dodged by OnProjectile()

	-- 61. winter wyvern's ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_winter_wyvern" then
		local radius = 800 + 500/2
		if animation.sequenceName == "cast04_winters_curse_flying_low_anim" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end
	end

	-- 62. zues's lightning bolt and ultimate
	if NPC.GetUnitName(animation.unit) == "npc_dota_hero_zuus" then
		local radius = 900 + 375/2
		if animation.sequenceName == "zeus_cast2_lightning_bolt" and NPC.IsEntityInRange(myHero, animation.unit, radius) then
			Dodge.Defend(myHero)
		end

		if animation.sequenceName == "zeus_cast4_thundergods_wrath" then
			Dodge.Defend(myHero)
		end
	end

end

function Monitor.OnUpdate()
	-- if not Menu.IsEnabled(Dodge.option) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end

	-- Dodge.TaskManagement(myHero)

	-- task management
	-- if msg_queue and #msg_queue > 0 then
	-- 	local timeStamp = table.remove(msg_queue, 1)
	-- 	local current = GameRules.GetGameTime()
	-- 	if math.abs(current - timeStamp) <= delta then
	-- 		Dodge.Defend(myHero)
	-- 	elseif timeStamp > current then
	-- 		table.insert(msg_queue, timeStamp)
	-- 	end
	-- end

	-- when kunkka's X mark expire
	if NPC.HasModifier(myHero, "modifier_kunkka_x_marks_the_spot") then
		local mod = NPC.GetModifier(myHero, "modifier_kunkka_x_marks_the_spot")
		local timeLeft = Modifier.GetDieTime(mod) - GameRules.GetGameTime()
		-- make sure not be X_marked by teammate; 0.3s delay works
		if Modifier.GetDuration(mod) <= 5 and timeLeft <= 0.3 then
			Dodge.Defend(myHero)
		end
	end

	-- for few cases that fail in OnUnitAnimation()
	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if enemy and not NPC.IsIllusion(enemy) 
			and not Entity.IsSameTeam(myHero, enemy) 
			and not Entity.IsDormant(enemy) 
			and Entity.IsAlive(enemy) then

			-- axe's call
			local axe_call = NPC.GetAbility(enemy, "axe_berserkers_call")
			local call_range = 300
			if axe_call and Ability.IsInAbilityPhase(axe_call)
				and NPC.IsEntityInRange(myHero, enemy, call_range) then
				Dodge.DefendWithDelay(Ability.GetCastPoint(axe_call)/2)
			end

			-- shadow fiend's raze
			local raze_1 = NPC.GetAbility(enemy, "nevermore_shadowraze1")
			local raze_2 = NPC.GetAbility(enemy, "nevermore_shadowraze2")
			local raze_3 = NPC.GetAbility(enemy, "nevermore_shadowraze3")
			local range_1, range_2, range_3 = 200, 450, 700
			local direction = Entity.GetAbsRotation(enemy):GetForward():Normalized()
			local pos_1 = Entity.GetAbsOrigin(enemy) + direction:Scaled(range_1)
			local pos_2 = Entity.GetAbsOrigin(enemy) + direction:Scaled(range_2)
			local pos_3 = Entity.GetAbsOrigin(enemy) + direction:Scaled(range_3)
			local radius = 250
			if (raze_1 and Ability.IsInAbilityPhase(raze_1) and NPC.IsPositionInRange(myHero, pos_1, radius, 0)) 
				or (raze_2 and Ability.IsInAbilityPhase(raze_2) and NPC.IsPositionInRange(myHero, pos_2, radius, 0))
				or (raze_3 and Ability.IsInAbilityPhase(raze_3) and NPC.IsPositionInRange(myHero, pos_3, radius, 0))
				then
				Dodge.DefendWithDelay(Ability.GetCastPoint(raze_1)/2)
			end

		end
	end
end

function Dodge.DefendWithDelay(delay)
	delay = math.max(delay, 0)
	table.insert(Dodge.msg_queue, GameRules.GetGameTime() + delay)
end

-- task table contains: {startTime; delay; type}
function Dodge.AddTask(task)
	table.insert(Dodge.msg_queue, task)
end

-- task table contains: {startTime; delay; type}
function Dodge.TaskManagement(myHero)
	if not Dodge.msg_queue or #Dodge.msg_queue <= 0 then return end

	local task = table.remove(Dodge.msg_queue, 1)
	if not task.startTime or not task.delay or not task.type then return end

	local currentTime = GameRules.GetGameTime()

	-- manage message queue
	if task.startTime + Dodge.delta < currentTime then return end
	if task.startTime > currentTime + Dodge.delta then Dodge.AddTask(task); return end

	-- for: 

	-- if queue and #queue > 0 then
	-- 	local timeStamp = table.remove(queue, 1)
	-- 	if math.abs(current - timeStamp) <= delta then
	-- 		Dodge.Defend(myHero)
	-- 	elseif timeStamp > current then
	-- 		table.insert(queue, timeStamp)
	-- 	end
	-- end
end

-- function Dodge.Defend(myHero)
-- 	if not myHero then return end
-- 	if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

-- 	local myMana = NPC.GetMana(myHero)

-- 	-- life stealer's rage
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_life_stealer" then
-- 		local rage = NPC.GetAbilityByIndex(myHero, 0)
-- 		if rage and Ability.IsCastable(rage, myMana) then
-- 			Ability.CastNoTarget(rage)
-- 		end
-- 	end

-- 	-- juggernaut's spin
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_juggernaut" then
-- 		local spin = NPC.GetAbilityByIndex(myHero, 0)
-- 		if spin and Ability.IsCastable(spin, myMana) then
-- 			Ability.CastNoTarget(spin)
-- 		end
-- 	end

-- 	-- weaver's shukuchi
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_weaver" then
-- 		local shukuchi = NPC.GetAbilityByIndex(myHero, 1)
-- 		if shukuchi and Ability.IsCastable(shukuchi, myMana) then
-- 			Ability.CastNoTarget(shukuchi)
-- 		end
-- 	end

-- 	-- omni's repel
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_omniknight" then
-- 		local repel = NPC.GetAbilityByIndex(myHero, 1)
-- 		if repel and Ability.IsCastable(repel, myMana) then
-- 			Ability.CastTarget(repel, myHero)
-- 		end
-- 	end

-- 	-- slark's dark pact
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_slark" then
-- 		local pact = NPC.GetAbilityByIndex(myHero, 0)
-- 		if pact and Ability.IsCastable(pact, myMana) then
-- 			Ability.CastNoTarget(pact)
-- 		end
-- 	end

-- 	-- ember's fist (T)
-- 	if NPC.GetUnitName(myHero) == "npc_dota_hero_ember_spirit" then
-- 		local fist = NPC.GetAbilityByIndex(myHero, 1)
-- 		local level = Ability.GetLevel(fist)
-- 		local cast_range = 700 
-- 		local radius = level > 0 and 250+100*(level-1) or 0
-- 		local enemyUnits = NPC.GetUnitsInRadius(myHero, cast_range, Enum.TeamType.TEAM_ENEMY)
-- 		if fist and Ability.IsCastable(fist, myMana) and #enemyUnits > 0 then
-- 			local pos = Utility.BestPosition(enemyUnits, radius)
			
-- 			if pos and NPC.IsPositionInRange(myHero, pos, cast_range, 0) then 
-- 				Ability.CastPosition(fist, pos) 
-- 			end
-- 		end
-- 	end

-- end

return Dodge