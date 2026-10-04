local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local PlayerData = {} -- Create the table that will become our class.

PlayerData.__index = PlayerData -- Make missing methods look inside PlayerData.

local PlayerDataModule = require(game.ServerScriptService.PlayerData)
local PlayerStateHandling = require(game.ServerScriptService.PlayerStateHandling)

function PlayerData.new(playerUserID:number) -- innitialize the player's data
	print("interlizing")
	local self = setmetatable({}, PlayerData)

	self.PlayerUserID = playerUserID
	self.Player = Players:GetPlayerByUserId(playerUserID)
	self.State = "Human"
	self.DefaultGhostCooldown = PlayerDataModule.ghost.cooldown -- defualt value
	self.DefaultGhostDuration = PlayerDataModule.ghost.duration

	self.StateConnection = nil -- val changed connections
	self.GhostCooldownConnection = nil
	self.GhostDurationConnection = nil

	self.GhostCooldownDebounce = false -- val changed connections debounces
	self.GhostDurationDebounce = false
	
	self.Destroyed = false

	self:CreateItems(playerUserID) -- Create the player's data folder/items.
	
	self:GhostDurationHandling() -- Start the ghost-duration handling connection.
	self:GhostCoolDownHandling() -- Start the human-cooldown handling connection.
	self:StateHandling() -- Start the state handling connection.
	
	self.GhostCoolDownValue.Value = self.DefaultGhostCooldown 
	self.GhostDurationValue.Value = 0
	
	return self -- Return the finished OOP object.
end


function PlayerData:CreateItems(playerUserID) -- Create the player's items/data folder.

	local folder = Instance.new("Folder") -- create folder
	folder.Name = tostring(playerUserID)
	folder.Parent = ServerStorage.UserData
	self.Folder = folder
	
	self.StateValue = Instance.new("StringValue") -- create state value
	self.StateValue.Name = "State"
	self.StateValue.Value = self.State 
	self.StateValue.Parent = folder
	
	self.GhostCoolDownValue = Instance.new("IntValue") -- create state value
	self.GhostCoolDownValue.Name = "GhostCoolDownValue"
	self.GhostCoolDownValue.Parent = folder
	
	self.GhostDurationValue = Instance.new("IntValue") -- create state value
	self.GhostDurationValue.Name = "Ghostduration"
	self.GhostDurationValue.Parent = folder
	
end


local function Countdown(self, intval, defualtval)
	local prev = nil

	while intval.Value > 0 and not self.Destroyed do
		task.wait(1)

		local cur = intval.Value
		if cur ~= defualtval and prev ~= cur + 1 then
			warn("Countdown interrupted or irregular sequence detected!")
		end
		
		prev = cur
		cur -= 1
			
		intval.Value = cur
	end
	
	return true
end

function PlayerData:GhostCoolDownHandling()
	self.GhostCooldownConnection = self.GhostCoolDownValue.Changed:Connect(function()
		if self.GhostCooldownDebounce then return end
		
		self.GhostCooldownDebounce = true
		Countdown(self, self.GhostCoolDownValue, self.DefaultGhostCooldown)
		self.GhostCooldownDebounce = false
	end)
end

function PlayerData:GhostDurationHandling()
	self.GhostDurationConnection = self.GhostDurationValue.Changed:Connect(function()
		if self.GhostDurationDebounce then return end

		self.GhostDurationDebounce = true
		local succ = Countdown(self, self.GhostDurationValue, self.DefaultGhostDuration)
		
		warn("count")
		if succ then self:__StateSetter("Human") end
		self.GhostDurationDebounce = false
	end)
end

function PlayerData:StateHandling()
	self.StateConnection = self.StateValue.Changed:Connect(function(NewState)
		if NewState == "Human" then
			self.GhostCoolDownValue.Value = self.DefaultGhostCooldown
			--PlayerStateHandling:HumanState(self.Player)
		elseif NewState == "Ghost" then
			self.GhostDurationValue.Value = self.DefaultGhostDuration
			--PlayerStateHandling:GhostState(self.Player)
		else
			warn("Invalid state provided: " .. tostring(NewState))
		end
		
		self.State = NewState
	end)
end

function PlayerData:__StateSetter(NewState)
	if (NewState ~= "Human" and NewState ~= "Ghost") or NewState == self.State then
		warn("Invalid state transition or no state change.", NewState, self.State)
		return
	end
	
	self.State = NewState
	self.StateValue.Value = self.State
end

function PlayerData:Destroy()
	self.Destroyed = true
	-- Disconnect all event connections.
	if self.StateConnection then
		self.StateConnection:Disconnect()
		self.StateConnection = nil
	end

	if self.GhostCooldownConnection then
		self.GhostCooldownConnection:Disconnect()
		self.GhostCooldownConnection = nil
	end

	if self.GhostDurationConnection then
		self.GhostDurationConnection:Disconnect()
		self.GhostDurationConnection = nil
	end

	-- Destroy the player's data folder and all of its children.
	if self.Folder then
		self.Folder:Destroy()
		self.Folder = nil
	end

	-- Clear references to Roblox instances.
	self.StateValue = nil
	self.GhostCoolDownValue = nil
	self.GhostDurationValue = nil
	self.Player = nil

	-- Clear remaining data.
	self.PlayerUserID = nil
	self.State = nil
	self.DefaultGhostCooldown = nil
	self.DefaultGhostDuration = nil

	-- Reset debounce states.
	self.GhostCooldownDebounce = nil
	self.GhostDurationDebounce = nil
	task.wait(3)
	self.Destroyed = nil

	return nil
end


return PlayerData -- Return the class so the Driver script can use it.