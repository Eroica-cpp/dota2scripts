-- ==================================
-- File Name : Phoenix.lua
-- Author    : Eroica
-- Version   : 1.2
-- Date      : 2017.2.18
-- ==================================

local Phoenix = {}

Phoenix.optionEnabled = Menu.AddOption({"Hero Specific","Phoenix"},"Auto Fire Spirit", "auto cast fire spirit while diving if enabled")

function Phoenix.OnUpdate()

	if not Menu.IsEnabled(Phoenix.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_phoenix" then return end
	local myMana = NPC.GetMana(myHero)

	local dive = NPC.GetAbilityByIndex(myHero, 0)
	local fireSpirit = NPC.GetAbilityByIndex(myHero, 1)
	local fireSpiritLevel = Ability.GetLevel(fireSpirit)

	if fireSpiritLevel <= 0 or (not Ability.IsInAbilityPhase(dive)) then return end

	for i = 1, Heroes.Count() do
		
		local npc = Heroes.Get(i)
		
		if (not NPC.IsIllusion(npc)) and (not Entity.IsSameTeam(npc, myHero)) then
			
			local enemyPos = NPC.GetAbsOrigin(npc)
			
			if Ability.IsCastable(fireSpirit, myMana) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and NPC.IsEntityInRange(npc, myHero, Ability.GetCastRange(fireSpirit)) then
				Ability.CastPosition(fireSpirit, enemyPos)
			end

		end

	end

end

return Phoenix