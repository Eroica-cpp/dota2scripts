local Morphling = {}

Morphling.killableAwareness = Menu.AddOption({"Hero Specific","Morphling"},"Killable Awareness", "show if can kill an enemy by hits or double edge")
Morphling.autoLifeSteal = Menu.AddOption({"Hero Specific","Morphling"},"Auto Life Steal", "auto KS")
Morphling.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

local magicDamageFactor = 0.75

function Morphling.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_morphling" then return end

	if Menu.IsEnabled(Morphling.killableAwareness) then
		Morphling.Awareness(myHero)
	end
end

function Morphling.Awareness(myHero)
	local strikeDmg = getStrikeDamamge(myHero)
	Log.Write("strikeDmg: " .. strikeDmg*magicDamageFactor)
	
	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
			local physicalDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)

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

	Log.Write("multiplier: " .. multiplier)
	return basicDamage + myAgility * multiplier
end

return Morphling