local AntiMageExtended = {}

AntiMageExtended.optionEnabled = Menu.AddOption({"Hero Specific","Anti-Mage"},"Awareness", "Show hits left to kill with ultimate")
AntiMageExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function AntiMageExtended.OnDraw()
	if not Menu.IsEnabled(AntiMageExtended.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_antimage" then return end
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return end

	local myMana = NPC.GetMana(myHero)

	local manaBreak = NPC.GetAbilityByIndex(myHero, 0)
	local manaBreakLevel = Ability.GetLevel(manaBreak)
	local manaBurn = (manaBreakLevel > 0) and 28+12*(manaBreakLevel-1) or 0
	local manaBreakDamage = 0.6 * manaBurn

	local ultimate = NPC.GetAbilityByIndex(myHero, 3)
	local ultimateCastRange = 600
	local ultimateLevel = Ability.GetLevel(ultimate)
	local damagePerMana = (ultimateLevel > 0) and 0.6+0.25*(ultimateLevel-1) or 0
	local magicDamageFactor = 0.75

	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if not NPC.IsIllusion(enemy) 
			and not Entity.IsSameTeam(myHero, enemy) 
			and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE)
			and not Entity.IsDormant(enemy) 
			and Entity.IsAlive(enemy) then

			-- in case of whether enemy has mana to be burned or not.
			local orbDamage = (NPC.GetMana(enemy) >= manaBurn) and manaBreakDamage or 0
			local oneHitDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) + orbDamage) * NPC.GetArmorDamageMultiplier(enemy) 

			local enemyHp = Entity.GetHealth(enemy)
			local enemyMana = NPC.GetMana(enemy)
			local manaLost = NPC.GetMaxMana(enemy) - enemyMana

			-- solve an equation of n (hits needed),
			-- currentHp - oneHitDamage * n = (currentManaLost + manaBurn * n) * damagePerMana * magicDamageFactor
			-- thus,
			-- n = (currentHp - currentManaLost * damagePerMana) / (oneHitDamage + manaBurn * damagePerMana)
			local hitsLeft = 99999
			if Ability.IsCastable(ultimate, myMana) then
				hitsLeft = math.ceil((enemyHp - manaLost * damagePerMana * magicDamageFactor) / (oneHitDamage + manaBurn * damagePerMana * magicDamageFactor))
			else
				hitsLeft = math.ceil(enemyHp / oneHitDamage)
			end

			-- draw
			local pos = Entity.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

			-- red : can kill; green : cant kill
			if hitsLeft <= 0 then
				Renderer.SetDrawColor(255, 0, 0, 255)
				Renderer.DrawTextCentered(AntiMageExtended.font, x, y, "Kill", 1)
			else
				Renderer.SetDrawColor(0, 255, 0, 255)
				Renderer.DrawTextCentered(AntiMageExtended.font, x, y, hitsLeft, 1)
			end

		end
	end

end

-- 	local skillManaVoid = NPC.GetAbilityByIndex(myHero, 3)
-- 	local rangeManaVoid = Ability.GetLevelSpecialValueFor(skillManaVoid, "mana_void_aoe_radius")
-- 	local damageManaVoid = Ability.GetLevelSpecialValueFor(skillManaVoid, "mana_void_damage_per_mana")

-- 	unitsAround = NPC.GetHeroesInRadius(myHero, rangeManaVoid, Enum.TeamType.TEAM_ENEMY)

-- 	local maxManaDiff = 0
-- 	local maxManaDiffEnemy = nil
-- 	local leastHealth = 100000
-- 	local damage = 0
	
-- 	for i,enemy in ipairs(unitsAround) do
-- 		local manaDiff = NPC.GetMaxMana(enemy) - NPC.GetMana(enemy)
-- 		if manaDiff >= maxManaDiff then
-- 			maxManaDiff = manaDiff
-- 			maxManaDiffEnemy = enemy
-- 		end

-- 		local enemyHealth = Entity.GetHealth(enemy)
-- 		if leastHealth >= enemyHealth then
-- 			leastHealth = enemyHealth
-- 		end

-- 		local magicBlockFactor = 0.75 -- (1 - NPC.GetMagicalArmorValue(maxManaDiffEnemy))
-- 		damage = damageManaVoid * maxManaDiff * magicBlockFactor
-- 		local hitDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))
-- 		local hitsLeft = math.ceil((enemyHealth - damage) / hitDamage)
-- 		local pos = Entity.GetAbsOrigin(enemy)
-- 		local x, y, visible = Renderer.WorldToScreen(pos)
-- 		Renderer.SetDrawColor(255, 255, 0, 255)
-- 		Renderer.DrawTextCentered(AntiMageExtended.font, x, y, hitsLeft, 1)	

-- 	end

-- 	if damage >= leastHealth and Ability.IsCastable(skillManaVoid, myMana) then
-- 		Ability.CastTarget(skillManaVoid, maxManaDiffEnemy, true)
-- 	end

-- end

return AntiMageExtended