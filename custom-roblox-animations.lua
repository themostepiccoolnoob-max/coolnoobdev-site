local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- Animation Objects
local Animations = {}

Animations.Idle = Instance.new("Animation")
Animations.Idle.AnimationId = "rbxassetid://000000000000"

Animations.Walk = Instance.new("Animation")
Animations.Walk.AnimationId = "rbxassetid://000000000000"

Animations.Jump = Instance.new("Animation")
Animations.Jump.AnimationId = "rbxassetid://000000000000"

-- Load Tracks
local Tracks = {}
for name, anim in pairs(Animations) do
    Tracks[name] = humanoid:LoadAnimation(anim)
    Tracks[name].Priority = Enum.AnimationPriority.Movement
end

local current = nil

local function playAnim(name)
    if current == name then return end

    -- stop all other tracks
    for trackName, track in pairs(Tracks) do
        if trackName ~= name then
            track:Stop(0.15)
        end
    end

    -- play the new one
    Tracks[name]:Play(0.15)
    current = name
end

-- Main Animation Logic
game:GetService("RunService").RenderStepped:Connect(function()
    local state = humanoid:GetState()
    local moving = humanoid.MoveDirection.Magnitude > 0.1

    if state == Enum.HumanoidStateType.Jumping then
        playAnim("Jump")

    elseif state == Enum.HumanoidStateType.Freefall then
        playAnim("Jump")

    elseif moving then
        playAnim("Walk")

    else
        playAnim("Idle")
    end
end)
