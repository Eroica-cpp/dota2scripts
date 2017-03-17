local Responder = require("Responder")

local Manager = {}

Manager.optionDodge = Menu.AddOption({"Utility", "Dodge Spells and Items"}, "Dodge", "On/Off")

-- use message queue to manage tasks
local msg_queue = {}
local DELTA = 0.05

function Manager.OnUpdate()
	if not next(msg_queue) then return end
	local info = table.remove(msg_queue, 1)
end

-- add animation information
function Manager.Update(info)
	Log.Write("updating info ..")
end

return Manager