local Centaur = {}

Centaur.killableAwareness = Menu.AddOption({"Hero Specific","Centaur Warrunner"},"Killable Awareness", "show if can kill an enemy by hits or double edge")
Centaur.autoLifeSteal = Menu.AddOption({"Hero Specific","Centaur Warrunner"},"Auto Life Steal", "auto double edge to KS")
Centaur.autoSaveAlly = Menu.AddOption({"Hero Specific","Centaur Warrunner"},"Auto Save Ally", "auto use ultimate if teammate's health lower then threshold")
Centaur.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

local magicDamageFactor = 0.75
local HpThreshold = 0.2

function Centaur.OnUpdate()
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_centaur" then return end

	if Menu.IsEnabled(Centaur.autoSaveAlly) then
		AutoSave(myHero)
	end
end

function AutoSave(myHero)
	if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return end

	local myMana = NPC.GetMana(myHero)
	local ultimate = NPC.GetAbilityByIndex(myHero, 3)

	if not ultimate or not Ability.IsCastable(ultimate, myMana) then return end

	for i = 1, Heroes.Count() do
		local ally = Heroes.Get(i)
		if Entity.IsSameTeam(myHero, ally) and Entity.GetHealth(ally) <= HpThreshold*Entity.GetMaxHealth(ally) then
			Ability.CastNoTarget(ultimate, true)
			return
		end
	end

end

return Centaur