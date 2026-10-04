local GoGhostButtonEvent = game.ReplicatedStorage.GoGhostButtonEvent

local player = game.Players.LocalPlayer
local TextButton = player.PlayerGui:WaitForChild("GoGhostGUI"):WaitForChild("Frame"):WaitForChild("TextButton") 

TextButton.MouseButton1Click:Connect(function()
	GoGhostButtonEvent:FireServer()
end)