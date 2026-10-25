--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--------------------------------------------------
-- PLAYER
--------------------------------------------------

local player = Players.LocalPlayer
local character = script.Parent

local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local animator = humanoid:FindFirstChildOfClass("Animator")

if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Settings = {

	-- Movement
	WalkSpeed = 16,
	SprintSpeed = 26,

	-- Sprint system
	EnableSprint = false,
	SprintKey = Enum.KeyCode.LeftShift,
	ToggleSprint = false,

	-- Stamina system
	EnableStamina = false,
	MaxStamina = 100,
	StaminaDrainPerSecond = 20,
	StaminaRegenPerSecond = 14,
	StaminaRegenDelay = 1.25,
	MinimumStaminaToSprint = 5,

	-- Interface
	ShowStaminaBar = true,
	ShowMobileSprintButton = true,

	-- Animation IDs
	IdleAnimationId = "rbxassetid://000000000000",
	WalkAnimationId = "rbxassetid://000000000000",
	SprintAnimationId = "rbxassetid://000000000000",
	JumpAnimationId = "rbxassetid://000000000000",

	-- Animation playback speeds
	IdleAnimationSpeed = 1,
	WalkAnimationSpeed = 1,
	SprintAnimationSpeed = 1,
	JumpAnimationSpeed = 1,
}

--------------------------------------------------
-- DISABLE DEFAULT ROBLOX ANIMATIONS
--------------------------------------------------

local defaultAnimateScript = character:FindFirstChild("Animate")

if defaultAnimateScript then
	defaultAnimateScript.Disabled = true
end

--------------------------------------------------
-- CREATE ANIMATIONS
--------------------------------------------------

local function createAnimation(
	animationId: string,
	priority: Enum.AnimationPriority,
	looped: boolean
): AnimationTrack?

	if animationId == "" or animationId == "rbxassetid://000000000000" then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	local success, animationTrack = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	animation:Destroy()

	if not success or not animationTrack then
		warn("Failed to load animation:", animationId)
		return nil
	end

	animationTrack.Priority = priority
	animationTrack.Looped = looped

	return animationTrack
end

local idleTrack = createAnimation(
	Settings.IdleAnimationId,
	Enum.AnimationPriority.Idle,
	true
)

local walkTrack = createAnimation(
	Settings.WalkAnimationId,
	Enum.AnimationPriority.Movement,
	true
)

local sprintTrack = createAnimation(
	Settings.SprintAnimationId,
	Enum.AnimationPriority.Movement,
	true
)

local jumpTrack = createAnimation(
	Settings.JumpAnimationId,
	Enum.AnimationPriority.Action,
	false
)

--------------------------------------------------
-- VARIABLES
--------------------------------------------------

local stamina = Settings.MaxStamina

local sprintInputHeld = false
local sprintToggled = false
local isSprinting = false
local isMoving = false
local isGrounded = true
local isDead = false

local lastSprintTime = 0
local currentMovementAnimation: AnimationTrack? = nil

--------------------------------------------------
-- INTERFACE
--------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMovementGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- STAMINA BAR
--------------------------------------------------

local staminaContainer: Frame? = nil
local staminaFill: Frame? = nil
local staminaText: TextLabel? = nil

if Settings.EnableStamina and Settings.ShowStaminaBar then

	staminaContainer = Instance.new("Frame")
	staminaContainer.Name = "StaminaContainer"
	staminaContainer.AnchorPoint = Vector2.new(0.5, 1)
	staminaContainer.Position = UDim2.new(0.5, 0, 0.94, 0)
	staminaContainer.Size = UDim2.new(0, 260, 0, 28)
	staminaContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	staminaContainer.BackgroundTransparency = 0.15
	staminaContainer.BorderSizePixel = 0
	staminaContainer.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 8)
	containerCorner.Parent = staminaContainer

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(255, 255, 255)
	containerStroke.Transparency = 0.65
	containerStroke.Thickness = 1
	containerStroke.Parent = staminaContainer

	staminaFill = Instance.new("Frame")
	staminaFill.Name = "Fill"
	staminaFill.Position = UDim2.new(0, 4, 0, 4)
	staminaFill.Size = UDim2.new(1, -8, 1, -8)
	staminaFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	staminaFill.BorderSizePixel = 0
	staminaFill.Parent = staminaContainer

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 5)
	fillCorner.Parent = staminaFill

	staminaText = Instance.new("TextLabel")
	staminaText.Name = "StaminaText"
	staminaText.Size = UDim2.fromScale(1, 1)
	staminaText.BackgroundTransparency = 1
	staminaText.Text = "STAMINA"
	staminaText.TextColor3 = Color3.fromRGB(255, 255, 255)
	staminaText.TextStrokeTransparency = 0.35
	staminaText.Font = Enum.Font.GothamBold
	staminaText.TextSize = 13
	staminaText.ZIndex = 2
	staminaText.Parent = staminaContainer
end

--------------------------------------------------
-- MOBILE SPRINT BUTTON
--------------------------------------------------

local mobileSprintButton: TextButton? = nil

if UserInputService.TouchEnabled
	and Settings.EnableSprint
	and Settings.ShowMobileSprintButton then

	mobileSprintButton = Instance.new("TextButton")
	mobileSprintButton.Name = "SprintButton"
	mobileSprintButton.AnchorPoint = Vector2.new(1, 1)
	mobileSprintButton.Position = UDim2.new(1, -30, 1, -170)
	mobileSprintButton.Size = UDim2.fromOffset(90, 90)
	mobileSprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mobileSprintButton.BackgroundTransparency = 0.25
	mobileSprintButton.BorderSizePixel = 0
	mobileSprintButton.Text = "SPRINT"
	mobileSprintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	mobileSprintButton.TextStrokeTransparency = 0.4
	mobileSprintButton.Font = Enum.Font.GothamBold
	mobileSprintButton.TextScaled = true
	mobileSprintButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(1, 0)
	buttonCorner.Parent = mobileSprintButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 255)
	buttonStroke.Transparency = 0.5
	buttonStroke.Thickness = 2
	buttonStroke.Parent = mobileSprintButton

	local buttonPadding = Instance.new("UIPadding")
	buttonPadding.PaddingLeft = UDim.new(0, 12)
	buttonPadding.PaddingRight = UDim.new(0, 12)
	buttonPadding.PaddingTop = UDim.new(0, 12)
	buttonPadding.PaddingBottom = UDim.new(0, 12)
	buttonPadding.Parent = mobileSprintButton
end

--------------------------------------------------
-- ANIMATION FUNCTIONS
--------------------------------------------------

local function stopTrack(track: AnimationTrack?, fadeTime: number?)
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.15)
	end
end

local function playTrack(
	track: AnimationTrack?,
	speed: number,
	fadeTime: number?
)
	if not track then
		return
	end

	if not track.IsPlaying then
		track:Play(fadeTime or 0.15)
	end

	track:AdjustSpeed(speed)
end

local function stopMovementAnimations()
	stopTrack(idleTrack)
	stopTrack(walkTrack)
	stopTrack(sprintTrack)

	currentMovementAnimation = nil
end

local function playMovementAnimation(
	track: AnimationTrack?,
	speed: number
)
	if currentMovementAnimation == track then
		if track and track.IsPlaying then
			track:AdjustSpeed(speed)
		end

		return
	end

	stopTrack(idleTrack)
	stopTrack(walkTrack)
	stopTrack(sprintTrack)

	currentMovementAnimation = track

	playTrack(track, speed)
end

--------------------------------------------------
-- STAMINA UI
--------------------------------------------------

local function updateStaminaInterface()
	if not staminaFill or not staminaText then
		return
	end

	local percentage = math.clamp(
		stamina / Settings.MaxStamina,
		0,
		1
	)

	staminaFill.Size = UDim2.new(
		percentage,
		-8 * percentage,
		1,
		-8
	)

	staminaText.Text = string.format(
		"STAMINA %d/%d",
		math.floor(stamina + 0.5),
		Settings.MaxStamina
	)

	if percentage <= 0.2 then
		staminaFill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	elseif percentage <= 0.5 then
		staminaFill.BackgroundColor3 = Color3.fromRGB(235, 180, 55)
	else
		staminaFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
end

--------------------------------------------------
-- SPRINT FUNCTIONS
--------------------------------------------------

local function sprintRequested(): boolean
	if not Settings.EnableSprint then
		return false
	end

	if Settings.ToggleSprint then
		return sprintToggled
	end

	return sprintInputHeld
end

local function canSprint(): boolean
	if not Settings.EnableSprint then
		return false
	end

	if isDead then
		return false
	end

	if not isMoving then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	if Settings.EnableStamina
		and stamina < Settings.MinimumStaminaToSprint then
		return false
	end

	return true
end

local function startSprinting()
	if isSprinting then
		return
	end

	if not canSprint() then
		return
	end

	isSprinting = true
	humanoid.WalkSpeed = Settings.SprintSpeed
end

local function stopSprinting()
	if not isSprinting then
		return
	end

	isSprinting = false
	humanoid.WalkSpeed = Settings.WalkSpeed
	lastSprintTime = time()
end

local function updateMobileButton()
	if not mobileSprintButton then
		return
	end

	local active = sprintRequested()

	if active then
		mobileSprintButton.BackgroundTransparency = 0.05
		mobileSprintButton.Text = "SPRINTING"
	else
		mobileSprintButton.BackgroundTransparency = 0.25
		mobileSprintButton.Text = "SPRINT"
	end
end

--------------------------------------------------
-- KEYBOARD INPUT
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or isDead then
		return
	end

	if input.KeyCode ~= Settings.SprintKey then
		return
	end

	if not Settings.EnableSprint then
		return
	end

	if Settings.ToggleSprint then
		sprintToggled = not sprintToggled
	else
		sprintInputHeld = true
	end

	updateMobileButton()
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode ~= Settings.SprintKey then
		return
	end

	if Settings.ToggleSprint then
		return
	end

	sprintInputHeld = false
	updateMobileButton()
end)

--------------------------------------------------
-- MOBILE INPUT
--------------------------------------------------

if mobileSprintButton then

	if Settings.ToggleSprint then

		mobileSprintButton.Activated:Connect(function()
			if isDead then
				return
			end

			sprintToggled = not sprintToggled
			updateMobileButton()
		end)

	else

		mobileSprintButton.MouseButton1Down:Connect(function()
			if isDead then
				return
			end

			sprintInputHeld = true
			updateMobileButton()
		end)

		mobileSprintButton.MouseButton1Up:Connect(function()
			sprintInputHeld = false
			updateMobileButton()
		end)

		mobileSprintButton.MouseLeave:Connect(function()
			sprintInputHeld = false
			updateMobileButton()
		end)
	end
end

--------------------------------------------------
-- HUMANOID STATES
--------------------------------------------------

humanoid.StateChanged:Connect(function(_, newState)

	if newState == Enum.HumanoidStateType.Jumping then
		isGrounded = false

		stopMovementAnimations()

		if jumpTrack then
			stopTrack(jumpTrack, 0)
			playTrack(
				jumpTrack,
				Settings.JumpAnimationSpeed,
				0.05
			)
		end

	elseif newState == Enum.HumanoidStateType.Freefall then
		isGrounded = false

	elseif newState == Enum.HumanoidStateType.Landed
		or newState == Enum.HumanoidStateType.Running
		or newState == Enum.HumanoidStateType.RunningNoPhysics then

		isGrounded = true
	end
end)

--------------------------------------------------
-- DEATH
--------------------------------------------------

humanoid.Died:Connect(function()
	isDead = true

	stopSprinting()
	stopMovementAnimations()
	stopTrack(jumpTrack)

	if screenGui then
		screenGui:Destroy()
	end
end)

--------------------------------------------------
-- MAIN UPDATE LOOP
--------------------------------------------------

humanoid.WalkSpeed = Settings.WalkSpeed
updateStaminaInterface()
updateMobileButton()

RunService.RenderStepped:Connect(function(deltaTime)
	if isDead then
		return
	end

	isMoving = humanoid.MoveDirection.Magnitude > 0.05

	----------------------------------------------
	-- SPRINTING
	----------------------------------------------

	if sprintRequested() and canSprint() then
		startSprinting()
	else
		stopSprinting()
	end

	----------------------------------------------
	-- STAMINA
	----------------------------------------------

	if Settings.EnableStamina then

		if isSprinting and isMoving then

			stamina -= Settings.StaminaDrainPerSecond * deltaTime
			stamina = math.max(stamina, 0)

			lastSprintTime = time()

			if stamina <= 0 then
				stopSprinting()

				if Settings.ToggleSprint then
					sprintToggled = false
				else
					sprintInputHeld = false
				end

				updateMobileButton()
			end

		elseif time() - lastSprintTime >= Settings.StaminaRegenDelay then

			stamina += Settings.StaminaRegenPerSecond * deltaTime
			stamina = math.min(stamina, Settings.MaxStamina)
		end

		updateStaminaInterface()
	end

	----------------------------------------------
	-- MOVEMENT ANIMATIONS
	----------------------------------------------

	if not isGrounded then
		return
	end

	if not isMoving then

		playMovementAnimation(
			idleTrack,
			Settings.IdleAnimationSpeed
		)

	elseif isSprinting then

		local speedMultiplier =
			humanoid.WalkSpeed / Settings.SprintSpeed

		playMovementAnimation(
			sprintTrack,
			Settings.SprintAnimationSpeed * speedMultiplier
		)

	else

		local speedMultiplier =
			humanoid.WalkSpeed / Settings.WalkSpeed

		playMovementAnimation(
			walkTrack,
			Settings.WalkAnimationSpeed * speedMultiplier
		)
	end
end)
