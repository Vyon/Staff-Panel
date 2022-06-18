-- Services:
local players = game:GetService("Players")
local http_service = game:GetService("HttpService")
local data_store_service = game:GetService("DataStoreService")

-- Data Stores:
local ban_data_store = data_store_service:GetDataStore("Bans")

-- Modules:
local intertwine = require(script.Parent.Intertwine)

-- Topics:
local ban_topic = intertwine.New("Ban")

-- Variables:
local references = {
	Visibility = {}
}

-- Main Module:
local events = {
	Bring = function(player: Player, target_name: string)
		local target = players:FindFirstChild(target_name)

		if (not target or target == player) then return end

		local target_character = target.Character or target.CharacterAdded:Wait()
		local player_character = player.Character or player.CharacterAdded:Wait()

		target_character.HumanoidRootPart.CFrame = player_character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
	end,
	Invisible = function(player: Player, value: boolean)
		local character = player.Character or player.CharacterAdded:Wait()
		local entry = references.Visibility[player]

		if (not entry) then
			references.Visibility[player] = {}
			entry = references.Visibility[player]
		end

		if (value) then
			-- Update part transparency and hold reference to decals
			for _, v in ipairs(character:GetDescendants()) do
				if (v:IsA("BasePart")) then
					v.Transparency = 1
				elseif (v:IsA("Decal")) then
					table.insert(entry, {
						Ref = v,
						Parent = v.Parent
					})

					v.Parent = nil
				end
			end
		else
			-- Update part transparency
			for _, v in ipairs(character:GetDescendants()) do
				if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") then
					v.Transparency = 0
				end
			end

			-- Restore decals
			for _, v in ipairs(entry) do
				v.Ref.Parent = v.Parent
			end
		end
	end,
	Kick = function(player: Player, target_name: string, message: string?)
		if (typeof(target_name) == "string" and typeof(message) ~= "string") then return end

		message = message ~= "" and message or "No reason specified."

		local target = players:FindFirstChild(target_name)

		if (not target) then return end

		target:Kick("You have been kicked for: " ..  message)
	end,
	Ban = function(player: Player, target_name: string, message: string)
		if (typeof(target_name) == "string" and typeof(message) ~= "string") then return end

		message = message ~= "" and message or "No reason specified."

		local target = players:FindFirstChild(target_name)

		if (not target) then return end

		ban_data_store:SetAsync(tostring(target.UserId), true)

		target:Kick("You have been banned for: " ..  message)
	end,
	GlobalBan = function(player: Player, target_name: string, message: string)
		if (typeof(target_name) == "string" and typeof(message) ~= "string") then return end

		message = message ~= "" and message or "No reason specified."

		local target = players:GetUserIdFromNameAsync(target_name)

		if (not target) then return end

		ban_data_store:SetAsync(tostring(target), true)

		ban_topic:Post({
			Player = target,
			Message = message
		})
	end,
	Unban = function(player: Player, target_name: string)
		if (typeof(target_name) == "string") then return end

		local target = players:GetUserIdFromNameAsync(target_name)

		ban_data_store:SetAsync(tostring(target), false)
	end
}

-- Connections:
ban_topic:Subscribe(nil, function(payload: Dictionary<any>)
	local data = http_service:JSONDecode(payload.Data)

	if (not data or not data.Player) then return end

	local username = players:GetNameFromUserIdAsync(data.Player)

	if (not username) then return end

	local target = players:FindFirstChild(username)

	if (target) then
		target:Kick("You have been banned for: " .. data.Message)
	end
end)

return table.freeze(events)