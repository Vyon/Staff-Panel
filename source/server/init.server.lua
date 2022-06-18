-- Services:
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local data_store_service = game:GetService("DataStoreService")

-- Data Stores:
local ban_data_store = data_store_service:GetDataStore("Bans")

-- Folders:
local remotes = replicated_storage.Remotes

-- Remotes:
local communicator = remotes.Communicator

-- Modules:
local events = require(script.Events)
local whitelist = require(script.Whitelist)

-- Variables:
local loaded = {}

-- Private Functions:
local function IsWhitelisted(player: Player)
	if (table.find(whitelist, player.Name) or table.find(whitelist, player.UserId)) then
		return true
	end
end

local function PlayerAdded(player: Player)
	if (loaded[player]) then return end

	loaded[player] = true

	-- Check if user is banned
	local is_banned = ban_data_store:GetAsync(tostring(player.UserId))

	if (is_banned) then
		player:Kick("You are permanently banned.")
	end

	-- Check if a user is not whitelisted
	if (not IsWhitelisted(player)) then
		return
	end

	local container = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	container.Name = "Staff Panel"
	container.ResetOnSpawn = false

	script.Main:Clone().Parent = container
end

-- Init:
for _, player in ipairs(players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

-- Connections:
players.PlayerAdded:Connect(PlayerAdded)
players.PlayerRemoving:Connect(function(player: Player)
	loaded[player] = nil
end)

communicator.OnServerEvent:Connect(function(player: Player, event: string, ...: any)
	if (not IsWhitelisted(player)) then
		return
	end

	if (not events[event]) then
		return
	end

	events[event](player, ...)
end)