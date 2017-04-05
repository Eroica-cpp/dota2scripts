local ForceStaff = {}

ForceStaff.option = Menu.AddOption({"Item Specific", "Force Staff / Hurricane Pike"}, "Force Staff / Hurricane Pike", "use force staff (hurricane pike) as blink, no need to double tap")
ForceStaff.key = Menu.AddKeyOption({"Item Specific", "Force Staff / Hurricane Pike"}, "Key", Enum.ButtonCode.KEY_Z)

function ForceStaff.OnUpdate()
	if not Menu.IsEnabled(ForceStaff.option) or not Menu.IsKeyDown(ForceStaff.key) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    local item
    
    local staff = NPC.GetItem(myHero, "item_force_staff", true)
    if staff and Ability.IsCastable(staff, NPC.GetMana(myHero)) then item = staff end
    
    local pike = NPC.GetItem(myHero, "item_hurricane_pike", true)
    if pike and Ability.IsCastable(pike, NPC.GetMana(myHero)) then item = pike end

    if not item then return end

    local range = 100
    local npc = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
    local cursorPos = Input.GetWorldCursorPos()

    if not npc or (Entity.GetAbsOrigin(npc) - cursorPos):Length() > range then
    	Ability.CastTarget(item, myHero)
    	return
    end

    Ability.CastTarget(item, npc)
end

return ForceStaff