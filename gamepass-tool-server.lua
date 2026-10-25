local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local GAMEPASS_ID = 1234567890 -- Use the same gamepass ID as the LocalScript
local TOOL_NAME = "SuperSword" -- Set this to your tool's name

-- Give the player a copy of the tool
local function giveTool(player)
	local tool = ServerStorage:FindFirstChild(TOOL_NAME)
	if tool then
		local clone = tool:Clone()
		clone.Parent = player.Backpack
	end
end

-- Check whether the player already owns the gamepass
Players.PlayerAdded:Connect(function(player)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_ID)
	end)

	if success and result then
		giveTool(player)
	end
end)

-- Give the tool after a successful purchase
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if passId == GAMEPASS_ID and purchased then
		giveTool(player)
	end
end)
