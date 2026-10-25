-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- PLAYER
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

--------------------------------------------------
-- CONFIG (FOR VIDEO CUSTOMIZATION)
--------------------------------------------------

local WALK_SPEED = 16
local SPRINT_SPEED = 24

-- Sprint key options
local SPRINT_KEYS = {
	[Enum.KeyCode.LeftShift] = true,
	[Enum.KeyCode.LeftControl] = true
}

--------------------------------------------------
-- ANIMATIONS
--------------------------------------------------

local Animations = {}

Animations.Idle = Instance.new("Animation")
Animations.Idle.AnimationId = "rbxassetid://000000000000"

Animations.Walk = Instance.new("Animation")
Animations.Walk.AnimationId = "rbxassetid://000000000000"

Animations.Sprint = Instance.new("Animation")
Animations.Sprint.AnimationId = "rbxassetid://000000000000"

Animations.Jump = Instance.new("Animation")
Animations.Jump.AnimationId = "rbxassetid://000000000000"

--------------------------------------------------
-- LOAD TRACKS
--------------------------------------------------

local Tracks = {}
for name, anim in pairs(Animations) do
	local track = humanoid:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Movement
	Tracks[name] = track
end

local current = nil

local function playAnim(name)
	if current == name then return end

	for trackName, track in pairs(Tracks) do
		if trackName ~= name then
			track:Stop(0.15)
		end
	end

	Tracks[name]:Play(0.15)
	current = name
end

--------------------------------------------------
-- SPRINT LOGIC
--------------------------------------------------

local sprinting = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if SPRINT_KEYS[input.KeyCode] then
		sprinting = true
		humanoid.WalkSpeed = SPRINT_SPEED
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if SPRINT_KEYS[input.KeyCode] then
		sprinting = false
		humanoid.WalkSpeed = WALK_SPEED
	end
end)

--------------------------------------------------
-- MAIN ANIMATION LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	local state = humanoid:GetState()
	local moving = humanoid.MoveDirection.Magnitude > 0.1

	if state == Enum.HumanoidStateType.Jumping
	or state == Enum.HumanoidStateType.Freefall then
		playAnim("Jump")

	elseif moving and sprinting then
		playAnim("Sprint")

	elseif moving then
		playAnim("Walk")

	else
		playAnim("Idle")
	end
end)
