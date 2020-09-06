local Utility = require("Utility")

local BountyHunter = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "Kill Steal", "Use toss to KS (or cancel TP or channelling spell)")
local optionAutoTrack = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "Auto Track", "Auto cast track on enemies in range or use track to break linken")

function BountyHunter.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        BountyHunter.KillSteal()
    end

    if Menu.IsEnabled(optionAutoTrack) then
        BountyHunter.AutoTrack()
    end
end

function BountyHunter.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not BountyHunter.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "bounty_hunter_shuriken_toss")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    local level = Ability.GetLevel(spell)
    local damage = 75 * (level + 1)
    if NPC.GetCurrentLevel(myHero) >= 15 then damage = damage + 50 end

    local range = Ability.GetCastRange(spell)
    if NPC.HasItem(myHero, "item_ultimate_scepter", true) then
    	range = range + 250

    	local jinada = NPC.GetAbility(myHero, "bounty_hunter_jinada")
    	if jinada then
    		jinada_damage = 80 + 30 * Ability.GetLevel(jinada)
    		damage = damage + jinada_damage
    	end
    end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        local real_damage = Utility.GetRealDamage(myHero, enemy, damage)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy)
        and (real_damage >= Entity.GetHealth(enemy) or NPC.HasModifier(enemy, "modifier_teleporting") or NPC.IsChannellingAbility(enemy)) then

        	-- if the enemy is within cast range, hit directly.
        	if NPC.IsEntityInRange(myHero, enemy, range) then
        		 Ability.CastTarget(spell, enemy)
        		 return
        	end

        	-- if the enemy is out of the cast range but being tracked, then hit a third unit to bound to the enemy.
        	if NPC.HasModifier(enemy, "modifier_bounty_hunter_track") then
		        for i, npc in ipairs(Entity.GetUnitsInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY, true)) do
		        	if NPC.IsEntityInRange(npc, enemy, 1200) and Utility.CanCastSpellOn(npc) then
		        		Ability.CastTarget(spell, npc)
		        		return
		        	end
		        end
		    end
        end
    end
end

-- -- use DFS to find a path
-- function BountyHunter.TossTarget(myHero, target, toss, r1, r2, counter)
--     -- set maximum depth as 3 to avoid infinite loops
--     if counter >= 3 then return end
--     if Utility.CanCastSpellOn(target) and NPC.IsEntityInRange(myHero, target, r1) then Ability.CastTarget(toss, target) return end

--     if NPC.HasModifier(target, "modifier_bounty_hunter_track") then
--         for i, npc in ipairs(NPC.GetUnitsInRadius(target, r2, Enum.TeamType.TEAM_FRIEND)) do
--             BountyHunter.TossTarget(myHero, npc, toss, r1, r2, counter+1)
--         end
--     else
--         for i, npc in ipairs(NPC.GetUnitsInRadius(target, r1, Enum.TeamType.TEAM_FRIEND)) do
--             BountyHunter.TossTarget(myHero, npc, toss, r1, r2, counter+1)
--         end
--     end
-- end

function BountyHunter.AutoTrack()
    local myHero = Heroes.GetLocal()
    if not myHero or not BountyHunter.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "bounty_hunter_track")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and BountyHunter.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and (BountyHunter.GetTrackTimeLeft(enemy) <= Ability.GetCooldownLength(spell)
        or Utility.IsLinkensProtected(enemy)) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function BountyHunter.GetTrackTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_bounty_hunter_track")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

function BountyHunter.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    -- disable following checks for kill stealing:
    -- if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end
    return true
end

function BountyHunter.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
    -- track pierces spell immunity
    -- if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end

return BountyHunter
