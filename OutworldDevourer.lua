-- ==================================
-- File Name : OutworldDevourer.lua
-- Author    : Eroica
-- Version   : 1.1
-- Date      : 2017.2.17
-- ==================================

local OutworldDevourer = {}

OutworldDevourer.optionEnabled = Menu.AddOption({"Hero Specific","Outworld Devourer"},"Killable awareness", "show if can kill an enemy by hits or ultimate")
-- OutworldDevourer.optionEnabled = Menu.AddOption({"Hero Specific","Outworld Devourer"},"Auto Life Steal", "show ")
OutworldDevourer.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function OutworldDevourer.OnDraw()

	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_obsidian_destroyer" then return end
	
	if Menu.IsEnabled(OutworldDevourer.optionEnabled) then 
		OutworldDevourer.Awareness(myHero)
	end
	
end

function OutworldDevourer.Awareness(myHero)

	local myTeam = Entity.GetTeamNum(myHero)
	
	local myIntell = Hero.GetIntellectTotal(myHero)
	local myMana = NPC.GetMana(myHero)
	local orb = NPC.GetAbilityByIndex(myHero, 0)
	local orbLevel = Ability.GetLevel(orb)
	-- 6% 7% 8% 9% of mana pool into orb damaga
	local manaToOrbDamagePara = (orbLevel > 0) and (0.05 + 0.01 * orbLevel) or 0
	local orbDamage = myMana * manaToOrbDamagePara
	local intellToManaPara = 12 -- every 1 point intelligence == 12 points mana
	local intellSteal = orbLevel
	local orbHitDamageAccumulator = intellSteal * intellToManaPara * manaToOrbDamagePara

	local ultimate = NPC.GetAbilityByIndex(myHero, 3)
	local ultimateLevel = Ability.GetLevel(ultimate)
	-- int diff damaga multiplier are : 8 / 9 / 10
	local intDiffDamageMultiplier = 7 + ultimateLevel

	local magicDamageFactor = 0.75

	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if (not NPC.IsIllusion(enemy)) and not (Entity.GetTeamNum(enemy) == myTeam) then

			local enemyHp = Entity.GetHealth(enemy)
			local physicalDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy) 
			local oneHitDamage = physicalDamage + orbDamage

			local enemyIntell = Hero.GetIntellectTotal(enemy)
			local intellDiff = (myIntell >= enemyIntell) and (myIntell - enemyIntell) or 0

			local ultimateDamage = 0
			if ultimateLevel > 0 and Ability.IsCastable(ultimate, myMana) then
				ultimateDamage = intellDiff * intDiffDamageMultiplier * magicDamageFactor
				-- this calculation is tricky, each hit creates 2*intDiffDamageMultiplier*orbLevel extra damage into ultimate
				oneHitDamage = oneHitDamage + 2 * orbLevel * intDiffDamageMultiplier
			end
			
			local enemyHpLeft = math.floor(enemyHp - ultimateDamage)

			local hitsLeft = 999999
			if orbLevel > 0 then
				-- solve a quadratic equation
				local a = 0.5*orbHitDamageAccumulator
				local b = oneHitDamage - 0.5*orbHitDamageAccumulator
				local c = -enemyHpLeft
				hitsLeft = math.ceil( (-b + math.sqrt(b*b - 4*a*c)) / (2*a) )
			else
				hitsLeft = math.ceil(enemyHpLeft / physicalDamage)
			end

			-- draw
			local pos = NPC.GetAbsOrigin(enemy)
			local x, y, visible = Renderer.WorldToScreen(pos)

			-- red : can kill; green : cant kill
			if enemyHpLeft <= 0 and ultimateLevel > 0 then
				Renderer.SetDrawColor(255, 0, 0, 255)
				Renderer.DrawTextCentered(OutworldDevourer.font, x, y, "Kill", 1)
			else
				Renderer.SetDrawColor(0, 255, 0, 255)
				Renderer.DrawTextCentered(OutworldDevourer.font, x, y, hitsLeft, 1)
			end

		end -- end big if statement (Lua doesnt have 'continue' for God sake !!)

	end -- end for loop

end

return OutworldDevourer