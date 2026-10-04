local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GoGhostButtonEvent = ReplicatedStorage.GoGhostButtonEvent

GoGhostButtonEvent.OnServerEvent:Connect(function(player)
	local userID = player.UserId
	
	local userData = ServerStorage.UserData:FindFirstChild(tostring(userID)) -- Get this player's server-side data.
	if not userData then warn("No user data found!") return end

	local GhostCoolDownValue = userData.GhostCoolDownValue
	local State = userData.State
	local Ghostduration = userData.Ghostduration

	if GhostCoolDownValue.Value > 0 then print("oh no") return end -- reloading

	if State.Value ~= "Human" then warn("Player is not in human state", State.Value) return end

	State.Value = "Ghost"
	print("succ")
end)