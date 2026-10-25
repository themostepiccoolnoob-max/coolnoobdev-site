local button = script.Parent
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local GAMEPASS_ID = 1234567890 -- Replace with your gamepass ID

button.MouseButton1Click:Connect(function()
	MarketplaceService:PromptGamePassPurchase(player, GAMEPASS_ID)
end)
