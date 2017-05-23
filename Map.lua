local Map = {}

Map.BuildingLocation = {
	radiant_fountain = Vector(-7600, -7300, 640),
	dire_fountain = Vector(7800, 7250, 640)
}

Map.CampLocation = {
	radiant_ancient_camp_1 = Vector(-2700, -250, 384),
	radiant_ancient_camp_2 = Vector(150, -2000, 384),
	dire_ancient_camp_1 = Vector(-700, 2300, 384),
	dire_ancient_camp_2 = Vector(3600, -700, 256),
	radiant_small_camp = Vector(3250, -4500, 256),
	dire_small_camp = Vector(-3050, 4800, 384),
	radiant_mid_camp_1 = Vector(-3900, 600, 256),
	radiant_mid_camp_2 = Vector(-1800, 4150, 128),
	radiant_mid_camp_3 = Vector(650, -4600, 384),
	dire_mid_camp_1 = Vector(-1650, 4000, 256),
	dire_mid_camp_2 = Vector(1100, 3500, 384),
	dire_mid_camp_3 = Vector(2800, 100, 384),
	radiant_large_camp_1 = Vector(-4700, -350, 256),
	radiant_large_camp_2 = Vector(-600, -3300, 256),
	radiant_large_camp_3 = Vector(4500, -4300, 256),
	dire_large_camp_1 = Vector(-4350, 3700, 256),
	dire_large_camp_2 = Vector(-300, 3400, 256),
	dire_large_camp_3 = Vector(4350, 750, 384)
}

Map.RoshanLocation = Vector(-2350, 1800, 160)

-- function Map.OnDraw()
-- 	local pos = Input.GetWorldCursorPos()
-- 	Log.Write(tostring(pos) .." ".. tostring(Map.InRoshan(pos)))
-- end

-- valid position can't be like Vector(1.0, 1.0, 1.0) or Vector(350.0, 350.0, 1.0)
function Map.IsValidPos(pos)
	if not pos then return false end
	if pos:GetX() == math.floor(pos:GetX()) or pos:GetY() == math.floor(pos:GetY()) then return false end
	return true
end

function Map.InFountain(pos)
	local range = 2000
	if (Map.BuildingLocation["radiant_fountain"] - pos):Length() <= range then return true end
	if (Map.BuildingLocation["dire_fountain"] - pos):Length() <= range then return true end
	return false
end

-- tell whether given position is ally
function Map.IsAlly(myHero, pos)
    local range = 50
    local allies = NPCs.InRadius(pos, range, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    if allies and #allies > 0 then return true end
    return false
end

function Map.InNeutralCamp(pos)
	local range = 600
	for name, location in pairs(Map.CampLocation) do
		local dis = (location - pos):Length()
		if dis <= range then return true end
	end
	return false
end

function Map.InRoshan(pos)
	local range = 500
	return (Map.RoshanLocation - pos):Length() <= range
end

return Map