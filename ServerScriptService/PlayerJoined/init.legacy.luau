local Players = game:GetService("Players")

local PlayerDataHandlingOOP = require(game.ServerScriptService.PlayerJoined.PlayerDataHandlingOOP)

local PlayerData = {}

Players.PlayerAdded:Connect(function(player)
	PlayerData[player.UserId] = PlayerDataHandlingOOP.new(player.UserId)
	
	while true do
		task.wait(1)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local object = PlayerData[player.UserId]

	if object then
		object:Destroy()
		PlayerData[player.UserId] = nil
	end
end)