local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- SETTINGS
local FULL_DAY_LENGTH = 300 -- 300 seconds = 5 minutes
local START_TIME = 8        -- Starts at 8:00 AM

Lighting.ClockTime = START_TIME

RunService.Heartbeat:Connect(function(deltaTime)
	local hoursPerSecond = 24 / FULL_DAY_LENGTH

	Lighting.ClockTime = (
		Lighting.ClockTime + hoursPerSecond * deltaTime
	) % 24
end)
