-- Services:
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

-- Player Info:
local player = players.LocalPlayer

-- Folder:
local remotes = replicated_storage.Remotes

-- Remotes:
local communicator = remotes.Communicator

-- Modules:
local library = require(script.Lib)

-- Variables:
local target = nil
local mod_target = nil
local reason = ""
local external_target = ""

-- Init:
local window = library:Window("Staff Panel by @Vyon")
local main = window:Page("Main")

local dropdown = main.Dropdown("Target", players:GetPlayers(), function(value: string)
	target = players:FindFirstChild(value)
end)

main.Slider("WalkSpeed", 16, 16, 100, function(value: number)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")

	if (humanoid) then
		humanoid.WalkSpeed = value
	end
end)

main.Slider("JumpPower", 50, 50, 300, function(value: number)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")

	if (humanoid) then
		humanoid.JumpPower = value
	end
end)

main.Toggle("Invisible", function(value: boolean)
	communicator:FireServer("Invisible", value)
end)

main.Button("TeleportTo", function()
	if (not target) then return end

	local target_character = target.Character or target.CharacterAdded:Wait()
	local player_character = player.Character or player.CharacterAdded:Wait()

	if (target_character == player_character) then return end

	player_character.HumanoidRootPart.CFrame = target_character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
end)

main.Button("Bring", function()
	if (not target) then return end

	communicator:FireServer("Bring", target.Name)
end)

main.Button("Spectate", function()
	if (not target) then return end

	local target_character = target.Character or target.CharacterAdded:Wait()

	workspace.CurrentCamera.CameraSubject = target_character:FindFirstChildOfClass("Humanoid")
end)

local moderation = window:Page("Moderation")
local moderation_dropdown = moderation.Dropdown("Target", players:GetPlayers(), function(value: string)
	mod_target = players:FindFirstChild(value)
end)

moderation.Input("External Target", function(value: string)
	external_target = value
end)

moderation.Input("Reason", function(value: string)
	reason = value
end)

moderation.Button("Kick", function()
	if (not mod_target) then return end

	communicator:FireServer("Kick", mod_target.Name, reason)
end)

moderation.Button("Ban", function()
	if (not mod_target) then return end

	communicator:FireServer("Ban", mod_target.Name, reason)
end)

moderation.Button("Global Ban", function()
	if (not external_target) then return end

	communicator:FireServer("GlobalBan", external_target, reason)
end)

-- Connections:
players.PlayerAdded:Connect(function()
	local all_players = players:GetPlayers()

	dropdown.Refresh(all_players)
	moderation_dropdown.Refresh(all_players)
end)

players.PlayerRemoving:Connect(function()
	local all_players = players:GetPlayers()

	dropdown.Refresh(all_players)
	moderation_dropdown.Refresh(all_players)
end)