local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- SETTINGS
local WALK_SPEED = 16
local SPRINT_SPEED = 25

local MAX_STAMINA = 10 -- seconds
local stamina = MAX_STAMINA

local sprinting = false

-- UI
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.3, 0, 0.03, 0)
barBg.Position = UDim2.new(0.35, 0, 0.9, 0)
barBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
barBg.Parent = screenGui

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
bar.Parent = barBg

-- INPUT
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = false
	end
end)

-- LOOP
RunService.RenderStepped:Connect(function(dt)
	if sprinting and stamina > 0 then
		humanoid.WalkSpeed = SPRINT_SPEED
		stamina -= dt
	else
		humanoid.WalkSpeed = WALK_SPEED
		stamina += dt * 0.5 -- regen slower
	end

	-- clamp
	stamina = math.clamp(stamina, 0, MAX_STAMINA)

	-- update bar
	bar.Size = UDim2.new(stamina / MAX_STAMINA, 0, 1, 0)

	-- optional: change color when low
	if stamina < 3 then
		bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
	else
		bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
	end
end)
