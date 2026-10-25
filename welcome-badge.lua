local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local BADGE_ID = 0 -- Replace with your badge ID

Players.PlayerAdded:Connect(function(player)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, BADGE_ID)
	end)

	if success and not hasBadge then
		pcall(function()
			BadgeService:AwardBadgeAsync(player.UserId, BADGE_ID)
		end)
	end
end)
