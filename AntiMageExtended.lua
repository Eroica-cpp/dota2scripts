local AntiMageExtended = {}

AntiMageExtended.optionEnabled = Menu.AddOption({"Hero Specific","Anti-Mage"},"Auto Mana Void 2", "Extended Auto Mana Void")
AntiMageExtended.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function AntiMageExtended.OnDraw()
	if not Menu.IsEnabled(AntiMageExtended.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if (not myHero) or NPC.GetUnitName(myHero) ~= "npc_dota_hero_antimage" then return end
	local myMana = NPC.GetMana(myHero)

	local skillManaVoid = NPC.GetAbilityByIndex(myHero, 3)
	local rangeManaVoid = Ability.GetLevelSpecialValueFor(skillManaVoid, "mana_void_aoe_radius")
	local damageManaVoid = Ability.GetLevelSpecialValueFor(skillManaVoid, "mana_void_damage_per_mana")

	unitsAround = NPC.GetHeroesInRadius(myHero, rangeManaVoid, Enum.TeamType.TEAM_ENEMY)

	local maxManaDiff = 0
	local maxManaDiffEnemy = nil
	local leastHealth = 100000
	local damage = 0
	
	for i,enemy in ipairs(unitsAround) do
		local manaDiff = NPC.GetMaxMana(enemy) - NPC.GetMana(enemy)
		if manaDiff >= maxManaDiff then
			maxManaDiff = manaDiff
			maxManaDiffEnemy = enemy
		end

		local enemyHealth = Entity.GetHealth(enemy)
		if leastHealth >= enemyHealth then
			leastHealth = enemyHealth
		end

		damage = damageManaVoid * maxManaDiff * (1 - NPC.GetMagicalArmorValue(maxManaDiffEnemy))
		local hitDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))
		local hitsLeft = math.ceil((enemyHealth - damage) / hitDamage)
		local pos = NPC.GetAbsOrigin(enemy)
		local x, y, visible = Renderer.WorldToScreen(pos)
		Renderer.SetDrawColor(255, 255, 0, 255)
		Renderer.DrawTextCentered(AntiMageExtended.font, x, y, hitsLeft, 1)	

	end

	if damage >= leastHealth and Ability.IsCastable(skillManaVoid, myMana) then
		Ability.CastTarget(skillManaVoid, maxManaDiffEnemy, true)
	end

end

return AntiMageExtended