local Utility = {}

-- return best position to cast certain spells 
-- eg. axe's call, void's chrono, enigma's black hole
-- input  : unitsAround, radius 
-- return : positon (a vector)
function Utility.BestPosition(unitsAround, radius)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return NPC.GetAbsOrigin(unitsAround[1]) end

	-- find all mid points of every two enemy heroes, 
	-- then find out the best position among these.
	-- O(n^3) complexity
	local maxNum = 1
	local bestPos = NPC.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = NPC.GetAbsOrigin(unitsAround[i])
				local pos2 = NPC.GetAbsOrigin(unitsAround[j])
				local mid = pos1:__add(pos2):Scaled(0.5)
				
				local heroesNum = 0
				for k = 1, enemyNum do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesNum = heroesNum + 1
					end
				end

				if heroesNum > maxNum then
					maxNum = heroesNum
					bestPos = mid
				end

			end
		end
	end

	return bestPos
end

return Utility