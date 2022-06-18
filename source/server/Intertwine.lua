-- Services
local ms = game:GetService('MessagingService')
local http = game:GetService('HttpService')

-- Tables
local server_stats = {}
server_stats.ServerLimit = 210
server_stats.TotalUsage = 0
server_stats.MaxTopics = 7
server_stats.AmountOfTopics = 0
server_stats.ActiveTopics = {}
server_stats.Connections = {}

-- Main Module
local intertwine = {}
intertwine.__index = intertwine

function intertwine:Subscribe(key, callback)
	local success, response = pcall(function()
		return ms:SubscribeAsync(self.Topic, callback)
	end)

	if (not success and self.isDebug) then
		warn('Failed to subscribe to', self.Topic)
		print(response)
	else
		self.isSubscribed = true
		if (key) then
			if (not server_stats.Connections[key]) then
				server_stats.Connections[key] = {}
			end
			table.insert(server_stats.Connections[key], response) --> The response is inserted because it is an RBXScriptConnection
		end
	end
end

function intertwine:Post(data)
	if (self.Current + 1 > self.Limit) then
		if (self.isDebug) then
			warn('Request limit has been hit.')
		end

		return
	elseif (self.Current == 0) then
		task.spawn(function()
			task.delay(60, function()
				self.Current = 0
				server_stats.TotalUsage = 0
			end)
		end)
	end

	server_stats.TotalUsage += 1
	self.Current += 1

	local success, response = pcall(function()
		local encoded = http:JSONEncode(data)

		ms:PublishAsync(self.Topic, encoded)
	end)

	if (not success and self.isDebug) then
		warn('Failed to post to', self.Topic)
		print(response)
	end
end

function intertwine.TotalUsage()
	local self = server_stats
	local percentage = ('%.1f'):format((self.TotalUsage / self.ServerLimit) * 100)

	return tostring(percentage) .. '%'
end

function intertwine.Disconnect(key)
	assert(server_stats.Connections[key], 'Invalid key.')

	for i, v in ipairs(server_stats.Connections[key]) do
		v:Disconnect()
		table.remove(server_stats.Connections[key], i)
	end
end

return {
	New = function(topic, isDebug)
		assert(
			typeof(topic) == 'string' and not table.find(server_stats.ActiveTopics, topic:lower()) and server_stats.AmountOfTopics < 7,
			'Failed to create object.'
		)

		local self = {}
		self.Topic = topic
		self.Limit = 30
		self.Current = 0
		self.isDebug = isDebug or nil
		self.isSubscribed = false

		server_stats.AmountOfTopics += 1
		table.insert(server_stats.ActiveTopics, topic:lower())

		return setmetatable(self, intertwine)
	end
}