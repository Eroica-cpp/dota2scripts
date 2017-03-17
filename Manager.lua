local Responder = require("Responder")

local Manager = {}

Manager.optionDodge = Menu.AddOption({"Utility", "Dodge Spells and Items"}, "Dodge", "On/Off")

-- use message queue to manage tasks
local msg_queue = {}
local DELTA = 0.05

function Manager.OnUpdate()
end

function Manager.AddTask(task)
	Log.Write("adding task ..")
end

return Manager