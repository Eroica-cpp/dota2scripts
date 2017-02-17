local OutworldDevourer = {}

OutworldDevourer.optionEnabled = Menu.AddOption({"Hero Specific","Outworld Devourer"},"Killable awareness", "show if can kill an enemy by hits or ultimate")
OutworldDevourer.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function OutworldDevourer.OnDraw()

	if not Menu.IsEnabled(OutworldDevourer.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_obsidian_destroyer" then return end
	
	local myIntell = Hero.GetIntellectTotal(myHero)
	local myMana = NPC.GetMana(myHero)
	local orb = NPC.GetAbilityByIndex(myHero, 0)
	local orbLevel = Ability.GetLevel(orb)
	-- 6% 7% 8% 9% mana to orb damaga
	local oneHitDamage = NPC.GetTrueDamage(myHero) + myMana * (0.05 + 0.01 * orbLevel)

	local ultimate = NPC.GetAbilityByIndex(myHero, 2)
	-- int diff damaga multiplier are : 8 / 9 / 10
	local intDiffDamageMultiplier = 7 + Ability.GetLevel(ultimate)

	local magicDamageFactor = 0.75
	local radius = 2000
	local unitsAround = NPC.GetHeroesInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)

	for i, enemy in ipairs(unitsAround) do

		local enemyHp = Entity.GetHealth(enemy)
		local hitsLeft = math.ceil( enemyHp / oneHitDamage )

		local enemyIntell = Hero.GetIntellectTotal(enemy)
		local intellDiff = (myIntell >= enemyIntell) and (myIntell - enemyIntell) or 0
		local ultimateDamage = intellDiff * intDiffDamageMultiplier * magicDamageFactor
		local enemyHpLeft = math.floor(enemyHp - ultimateDamage)

		-- draw
		local pos = NPC.GetAbsOrigin(enemy)
		local x, y, visible = Renderer.WorldToScreen(pos)
		Renderer.SetDrawColor(255, 255, 0, 255)

		if ultimate then
			Renderer.DrawTextCentered(OutworldDevourer.font, x, y, hitsLeft..", "..enemyHpLeft, 1)
		else
			Renderer.DrawTextCentered(OutworldDevourer.font, x, y, hitsLeft, 1)
		end

	end

end

return OutworldDevourer