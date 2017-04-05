local Morphling = {}

Morphling.autoLifeSteal = Menu.AddOption({"Hero Specific","Morphling"},"Auto Life Steal", "auto KS using strike or ethereal blade, \n also show if can kill an enemy")
Morphling.autoShiftOption = Menu.AddOption({"Hero Specific","Morphling"},"Auto Shift", "auto shift strength is got stunned")
Morphling.maxWaveRange = Menu.AddOption({"Hero Specific","Morphling"}, "Max Wave", "wave to a direction if instructed position out of range")
Morphling.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

Morphling.HpThreshold = 0.25

-- max wave
function Morphling.OnPrepareUnitOrders(orders)
	if not orders then return true end
	if not Menu.IsEnabled(Morphling.maxWaveRange) then return true end
	
	if not orders.order or orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION then return true end
	if not orders.npc or NPC.GetUnitName(orders.npc) ~= "npc_dota_hero_morphling" then return true end
	if not orders.ability or Ability.GetName(orders.ability) ~= "morphling_waveform" then return true end

	local castRange = Ability.GetCastRange(orders.ability)
	if NPC.IsPositionInRange(orders.npc, orders.position, castRange, 0) then return true end
	
    local origin = Entity.GetAbsOrigin(orders.npc)
    local dir = orders.position - origin

    dir:SetZ(0)
    dir:Normalize()
    dir:Scale(castRange - 1)

    local pos = origin + dir

    Player.PrepareUnitOrders(orders.player, orders.order, orders.target, pos, orders.ability, orders.orderIssuer, orders.npc, orders.queue, orders.showEffects)

    return false
end

function Morphling.OnDraw()
	local myHero = Heroes.GetLocal()
	if not myHero or not Entity.IsAlive(myHero) then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_morphling" then return end

	if Menu.IsEnabled(Morphling.autoLifeSteal) then
		Morphling.AutoKill(myHero)
	end

	if Menu.IsEnabled(Morphling.autoShiftOption) then
		Morphling.AutoShift(myHero)
	end

end

function Morphling.AutoShift(myHero)
	if NPC.IsSilenced(myHero) then return end

	local myMana = NPC.GetMana(myHero)
	local morph2 =  NPC.GetAbilityByIndex(myHero, 3)

	if NPC.IsStunned(myHero) 
		or NPC.HasModifier(myHero, "modifier_legion_commander_duel") 
		or NPC.HasModifier(myHero, "modifier_axe_berserkers_call")
		or NPC.HasModifier(myHero, "modifier_faceless_void_chronosphere")
		or NPC.HasModifier(myHero, "modifier_enigma_black_hole_pull") 
		or Entity.GetHealth(myHero) <= Entity.GetMaxHealth(myHero) * Morphling.HpThreshold
		then

		if morph2 and Ability.IsCastable(morph2, myMana) and not Ability.GetToggleState(morph2) then
			Ability.Toggle(morph2, true)
		end

	end
end

function Morphling.AutoKill(myHero)
	local myMana = NPC.GetMana(myHero)

	local wave = NPC.GetAbilityByIndex(myHero, 0)
	local waveLevel = Ability.GetLevel(wave)
	local waveDamage = (waveLevel > 0) and 100+75*(waveLevel-1) or 0

	local strike = NPC.GetAbilityByIndex(myHero, 1)
	local strikeCastRange = Ability.GetCastRange(strike)
	local strikeDamage = getStrikeDamamge(myHero)
	
	local ethereal = NPC.GetItem(myHero, "item_ethereal_blade", true)
	local etherealCastRange = ethereal and Ability.GetCastRange(ethereal) or 0
	local etherealDamge = getEtherealDamage(myHero, ethereal)

	if not wave or not Ability.IsCastable(wave, myMana) then waveDamage = 0 end
	if not strike or not Ability.IsCastable(strike, myMana) then strikeDamage = 0 end
	if not ethereal or not Ability.IsCastable(ethereal, myMana) then etherealDamge = 0 end

	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
			local physicalDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
			local trueWaveDamage = waveDamage * NPC.GetMagicalArmorDamageMultiplier(enemy)
			local trueStrikeDamage = strikeDamage * NPC.GetMagicalArmorDamageMultiplier(enemy)
			local trueEtherealDamage = etherealDamge * NPC.GetMagicalArmorDamageMultiplier(enemy)

			local enemyHp = Entity.GetHealth(enemy)
			local enemyHpLeft = enemyHp - trueStrikeDamage - trueEtherealDamage - trueWaveDamage
			local hitsLeft = math.ceil(enemyHpLeft / physicalDamage)

			local pos = Entity.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

			-- red : can kill; green : cant kill
			if enemyHp - trueStrikeDamage - trueEtherealDamage <= 0 then
				if ethereal and Ability.IsCastable(ethereal, myMana) and NPC.IsEntityInRange(enemy, myHero, etherealCastRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
					Ability.CastTarget(ethereal, enemy)
					sleep(0.02)
				end
				if strike and Ability.IsCastable(strike, myMana) and NPC.IsEntityInRange(enemy, myHero, strikeCastRange) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
					Ability.CastTarget(strike, enemy)
					sleep(0.02)
				end
				Renderer.SetDrawColor(255, 0, 0, 255)
				Renderer.DrawTextCentered(Morphling.font, x, y, "Kill", 1)
			elseif enemyHpLeft <= 0 then
				Renderer.SetDrawColor(255, 0, 0, 255)
				Renderer.DrawTextCentered(Morphling.font, x, y, "Kill", 1)
			else
				Renderer.SetDrawColor(0, 255, 0, 255)
				Renderer.DrawTextCentered(Morphling.font, x, y, hitsLeft, 1)
			end

		end -- end of if statement
	end -- enf of for loop

end

function getStrikeDamamge(myHero)
	local strike = NPC.GetAbilityByIndex(myHero, 1)
	local strikeLevel = Ability.GetLevel(strike)
	if strikeLevel <= 0 then return 0 end

	local basicDamage = 100

	local myAgility = Hero.GetAgilityTotal(myHero)
	local myStrength = Hero.GetStrengthTotal(myHero)

	local minMultiplier = 0.25
	local maxMultiplier = 0.5 + 0.5 * (strikeLevel - 1)

	local ratio = myAgility / myStrength
	local minRatio = 2/3
	local maxRatio = 3/2
	local multiplier = minMultiplier+(maxMultiplier-minMultiplier)*(ratio-minRatio)/(maxRatio-minRatio)
	multiplier = multiplier > maxMultiplier and maxMultiplier or multiplier
	multiplier = multiplier < minMultiplier and minMultiplier or multiplier

	return basicDamage + myAgility * multiplier
end

function getEtherealDamage(myHero, ethereal)
	if not ethereal then return 0 end
	local myAgility = Hero.GetAgilityTotal(myHero)
	return 1.4 * (2 * myAgility + 75)
end

-- 0.02s delay works good for me
local clock = os.clock
function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

return Morphling
