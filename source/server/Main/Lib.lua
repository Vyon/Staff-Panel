-- Services:
local players = game:GetService("Players")
local tween_service = game:GetService("TweenService")
local starter_gui = game:GetService("StarterGui")
local user_input_service = game:GetService("UserInputService")

-- Player:
local player = players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

-- Private Variables:
local palette = {
	Text = Color3.new(1, 1 , 1),
	Content = Color3.fromRGB(178, 0, 0),
}

-- Private Functions:
local function DarkenColor(color, opacity_percentage)
	local red = color.R * (opacity_percentage / 100)
	local green = color.G * (opacity_percentage / 100)
	local blue = color.B * (opacity_percentage / 100)

	return Color3.new(red, green, blue)
end

local function CreateInstance(class, properties, children)
	local instance = Instance.new(class)

	for property, value in pairs(properties) do
		instance[property] = value
	end

	for _, child in pairs(children or {}) do
		child.Parent = instance
	end

	return instance
end

local function TableLength(table)
	local count = 0

	for _ in pairs(table) do
		count += 1
	end

	return count
end

-- Main Module:
local lib = {}
lib.FLAGS = {}
lib.MainGui = CreateInstance("ScreenGui", {
	Name = "EclipseLib",
	ResetOnSpawn = false,
	DisplayOrder = 69420,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Main Gui setup:
lib.MainGui.Parent = player_gui
lib.MainGui:SetAttribute("Eclipse", true)

-- Methods:
function lib:Window(title)
	local window = CreateInstance("Frame", {
		Name = "Window",
		Parent = self.MainGui,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		Position = UDim2.new(0.35, 0, 0.3, 0),
		Size = UDim2.new(0, 584, 0, 321)
	}, {
		-- Title:
		CreateInstance("TextLabel", {
			Name = "Title",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 505, 0, 35),
			ZIndex = 2,
			Font = Enum.Font.SourceSansSemibold,
			Text = title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			CreateInstance("UIPadding", {
				PaddingLeft = UDim.new(0, 10)
			})
		}),

		-- Frames:
		-- Menu Buttons:
		CreateInstance("Frame", {
			Name = "MenuButtons",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 511, 0, 4),
			Size = UDim2.new(0, 73, 0, 30),
			ZIndex = 2
		}, {
			-- Buttons:
			CreateInstance("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				ZIndex = 2,
				Image = "rbxassetid://3926305904",
				ImageRectOffset = Vector2.new(284, 4),
				ImageRectSize = Vector2.new(24, 24)
			}),
			CreateInstance("ImageButton", {
				Name = "Minmize",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 2,
				Image = "rbxassetid://3926307971",
				ImageRectOffset = Vector2.new(884, 284),
				ImageRectSize = Vector2.new(36, 36)
			}),

			-- Components:
			CreateInstance("UIGridLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				CellSize = UDim2.new(0, 28, 0, 28),
			})
		}),

		-- Tab Frame:
		CreateInstance("Frame", {
			Name = "TabFrame",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 6, 0, 46),
			Size = UDim2.new(0, 571, 0, 23)
		}, {
			-- Components:
			CreateInstance("UIGridLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				CellSize = UDim2.new(0, 110, 1, 0),
			})
		}),

		-- Drag Frame:
		CreateInstance("Frame", {
			Name = "DragFrame",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 3,
			Size = UDim2.new(0, 584, 0, 39),
		}),

		-- Container:
		CreateInstance("Frame", {
			Name = "Container",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 6, 0, 75),
			Size = UDim2.new(0, 571, 0, 238),
		}, {
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 4)
			})
		}),

		-- Bars:
		CreateInstance("Frame", {
			Name = "ThemeBar",
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 34),
			Size = UDim2.new(0, 584, 0, 5),
			ZIndex = 2
		}, {
			CreateInstance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(193, 193, 193)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(102, 102, 102))
				})
			})
		}),

		-- Components:
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 4)
		})
	})

	-- Private Variables:
	local minimized = false
	local minimize_tween = nil
	local button1_down = false
	local in_frame = false
	local origin, position

	-- Setup Window Connections:
	window.DragFrame.MouseEnter:Connect(function()
		in_frame = true
	end)

	window.DragFrame.MouseLeave:connect(function()
		in_frame = false
	end)

	user_input_service.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 and in_frame) then
			button1_down = true
			origin = user_input_service:GetMouseLocation()
			position = Vector2.new(window.Position.X.Scale, window.Position.Y.Scale)
		end
	end)

	user_input_service.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement and button1_down) then
			local mouse_position = user_input_service:GetMouseLocation()
			local final = position + ((mouse_position - origin) / workspace.CurrentCamera.ViewportSize)

			window.Position = UDim2.new(final.X, 0, final.Y, 0)
		end
	end)

	user_input_service.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			button1_down = false
		end
	end)

	window.MenuButtons.Close.MouseButton1Click:Connect(function()
		self.MainGui:Destroy()
	end)

	window.MenuButtons.Minmize.MouseButton1Click:Connect(function()
		if (minimize_tween) then return end

		if (minimized) then
			minimize_tween = tween_service:Create(window, TweenInfo.new(.3), {
				Size = UDim2.new(0, 584, 0, 321)
			})

			minimize_tween:Play()
			minimize_tween.Completed:Wait()
			minimize_tween:Destroy()
			minimize_tween = nil
		else
			minimize_tween = tween_service:Create(window, TweenInfo.new(.3), {
				Size = UDim2.new(0, 584, 0, 39)
			})

			minimize_tween:Play()
			minimize_tween.Completed:Wait()
			minimize_tween:Destroy()
			minimize_tween = nil
		end

		minimized = not minimized
	end)

	local pages = { Created = {} }

	function pages:Page(page_name)
		-- Check if the page already exists
		if (self.Created[page_name]) then
			return self.Created[page_name]
		end

		local page = CreateInstance("ScrollingFrame", {
			Name = page_name,
			Parent = window.Container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = TableLength(pages.Created) + 1,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageTransparency = 1,
			Position = UDim2.new(0, 0, 0.0252100844, 0),
			Size = UDim2.new(1, 0, 0.945378125, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = TableLength(pages.Created) == 0 and true or false
		}, {
			CreateInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 5),
			})
		})

		local tab = CreateInstance("TextButton", {
			Name = page_name .. "Tab",
			Parent = window.TabFrame,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.SourceSansSemibold,
			Text = page_name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 16
		})

		self.Created[page_name] = page

		tab.MouseButton1Down:Connect(function()
			for _, v in pairs(self.Created) do
				if (v == page) then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end)

		local content = {}

		function content.Slider(slider_name, start, min, max, callback)
			local active = false

			-- Had to do this for proper sizing
			local slider_title = CreateInstance("TextLabel", {
				Name = "SliderTitle",
				BackgroundColor3 = Color3.fromRGB(38, 38, 38),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.0671834648, 0, 0.148648649, 0),
				Size = UDim2.new(0, 61, 0, 26),
				Font = Enum.Font.SourceSansSemibold,
				Text = slider_name or "Slider",
				TextColor3 = palette.Text,
				TextSize = 23,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.X
			}, {
				CreateInstance("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10)
				})
			})

			local slider = CreateInstance("Frame", {
				Name = "SliderBackground",
				Parent = page,
				BackgroundColor3 = Color3.new(0.105882, 0.105882, 0.109803),
				Size = UDim2.new(0, 447, 0, 73)
			}, {
				slider_title,
				CreateInstance("Frame", {
					Name = "InputContainer",
					BackgroundColor3 = Color3.fromRGB(38, 38, 38),
					Position = UDim2.new(0, (slider_title.AbsoluteSize.X + 103), 0.162162155, 0),
					Size = UDim2.new(0, 53, 0, 25),
				}, {
					CreateInstance("TextBox", {
						Name = "InputField",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						ClearTextOnFocus = false,
						Font = Enum.Font.SourceSansSemibold,
						PlaceholderText = "Value",
						Text = start or min,
						TextColor3 = palette.Content,
						PlaceholderColor3 = DarkenColor(palette.Content, 75),
						TextSize = 18
					}),

					-- Components
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})
				}),
				CreateInstance("Frame", {
					Name = "SliderBar",
					BackgroundColor3 = Color3.fromRGB(38, 38, 38),
					Position = UDim2.new(0.0465116277, 0, 0.689189196, 0),
					Size = UDim2.new(0.904392779, 0, 0.135135129, 0)
				}, {
					CreateInstance("ImageButton", {
						Name = "Update",
						Active = false,
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 2,
						AutoButtonColor = false,
						ImageTransparency = 1
					}),
					CreateInstance("Frame", {
						Name = "ProgressBar",
						BackgroundColor3 = palette.Content,
						Size = UDim2.new(0, 0, 1, 0)
					}, {
						-- Components
						CreateInstance("UICorner", {
							CornerRadius = UDim.new(0, 4)
						})
					}),

					-- Components
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})
				}),

				-- Components
				CreateInstance("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})

			local bar = slider.SliderBar
			local click_update = bar.Update
			local progress_bar = bar.ProgressBar
			local input = slider.InputContainer.InputField

			-- Slider Functions
			local function Update(position)
				local current_position = math.clamp(
					(position - bar.AbsolutePosition.X),
					0,
					bar.AbsoluteSize.X
				)

				progress_bar.Size = UDim2.new(0, current_position, 1, 0)

				local value = math.floor((max - min) * (current_position / bar.AbsoluteSize.X) + min)
				input.Text = value

				task.spawn(pcall, callback, value)
			end

			local function Set(value)
				local bar_position = bar.AbsolutePosition.X
				local bar_size = bar.AbsoluteSize.X

				local result = ((value + 0.2) - min) / (max - min)
				local position = (result * bar_size) + bar_position

				Update(position)
			end

			if (start) then
				Set(start)
			end

			user_input_service.InputChanged:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseMovement and active) then
					Update(input.Position.X)
				end
			end)

			user_input_service.InputEnded:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 and active) then
					active = false
				end
			end)

			click_update.MouseButton1Down:Connect(function()
				active = true
				Update(user_input_service:GetMouseLocation().X)
			end)

			input.FocusLost:Connect(function(...)
				local value = tonumber(input.Text)

				if (value) then
					Set(value)
				end
			end)
		end

		function content.Toggle(toggle_name, callback, start)
			local toggle = CreateInstance("Frame", {
				Name = "ToggleBackground",
				Parent = page,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				BorderSizePixel = 0,
				Position = UDim2.new(0.112084068, 0, 0.324444443, 0),
				Size = UDim2.new(0, 447, 0, 41)
			}, {
				CreateInstance("TextLabel", {
					Name = "ToggleTitle",
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.0671834648, 0, 0.169651359, 0),
					Size = UDim2.new(0, 61, 0, 26),
					Font = Enum.Font.SourceSansSemibold,
					Text = toggle_name,
					TextColor3 = palette.Text,
					TextSize = 23,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X
				}, {
					-- Components
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),

					CreateInstance("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					})
				}),

				CreateInstance("ImageButton", {
					Name = "Toggle",
					BackgroundColor3 = Color3.fromRGB(38, 38, 38),
					BorderSizePixel = 0,
					Position = UDim2.new(0.927999973, 0, 0.194999993, 0),
					Size = UDim2.new(0, 25, 0, 25),
					Image = "",
					ImageTransparency = 1
				}, {
					-- Components
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})
				}),

				-- Components
				CreateInstance("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})

			local value = start or false

			local toggle_button = toggle.Toggle
			toggle_button.MouseButton1Down:Connect(function()
				value = not value
				pcall(callback, value)

				if (value) then
					toggle_button.BackgroundColor3 = palette.Content
				else
					toggle_button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
				end
			end)
		end

		function content.Button(button_name, callback)
			local button = CreateInstance("ImageButton", {
				Name = "ButtonBackground",
				Parent = page,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				BorderSizePixel = 0,
				Position = UDim2.new(0.112084068, 0, 0.324444443, 0),
				Size = UDim2.new(0, 447, 0, 41),
				ImageTransparency = 1
			}, {
				CreateInstance("TextLabel", {
					Name = "ButtonTitle",
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.0671834648, 0, 0.169651359, 0),
					Size = UDim2.new(0, 61, 0, 26),
					Font = Enum.Font.SourceSansSemibold,
					Text = button_name,
					TextColor3 = palette.Text,
					TextSize = 23,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X
				}, {
					-- Components
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),

					CreateInstance("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					})
				}),

				-- Components
				CreateInstance("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})

			button.MouseButton1Down:Connect(function()
				pcall(callback)
			end)
		end

		function content.Dropdown(dropdown_name, options, callback)
			local dropdown = CreateInstance("Frame", {
				Name = "DropdownBackground",
				Parent = page,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Size = UDim2.new(0, 447, 0, 38)
			}, {
				CreateInstance("TextLabel", {
					Name = "DropdownTitle",
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 30, 0, 6),
					Size = UDim2.new(0, 61, 0, 26),
					Font = Enum.Font.SourceSansSemibold,
					Text = dropdown_name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 23,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X
				}, {
					-- Components
					CreateInstance("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					}),
				}),
				CreateInstance("ImageButton", {
					Name = "Toggle",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 9,
					Position = UDim2.new(0, 414, 0, 7),
					Size = UDim2.new(0, 25, 0, 25),
					ZIndex = 2,
					Image = "rbxassetid://3926305904",
					ImageRectOffset = Vector2.new(564, 284),
					ImageRectSize = Vector2.new(36, 36)
				}),
				CreateInstance("ScrollingFrame", {
					Name = "List",
					Active = true,
					BackgroundColor3 = Color3.fromRGB(34, 34, 34),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 0, 127),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarThickness = 0,
					AutomaticCanvasSize = Enum.AutomaticSize.Y
				}, {
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),
					CreateInstance("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder
					})
				})
			})

			-- Locals
			local toggle = dropdown:FindFirstChild("Toggle")
			local list = dropdown:FindFirstChild("List")
			local name = dropdown:FindFirstChild("DropdownTitle")

			local toggled = false
			local tweening = false
			local current = nil

			-- Connections
			toggle.MouseButton1Down:Connect(function()
				if (tweening) then return end

				if (toggled) then
					local tween = tween_service:Create(dropdown, TweenInfo.new(.3), {
						Size = UDim2.new(0, 447, 0, 38)
					})

					tweening = true
					tween:Play()
					tween.Completed:Wait()
					tweening = false
				else
					local tween = tween_service:Create(dropdown, TweenInfo.new(.3), {
						Size = UDim2.new(0, 447, 0, list.AbsoluteCanvasSize.Y + 38)
					})

					tweening = true
					tween:Play()
					tween.Completed:Wait()
					tweening = false
				end

				toggled = not toggled
			end)

			local function Update(choices)
				for _, v in ipairs(list:GetChildren()) do
					if (v:IsA("TextButton")) then
						v:Destroy()
					end
				end

				for _, v in ipairs(choices) do
					v = tostring(v)

					local button = CreateInstance("TextButton", {
						Name = v,
						Parent = list,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 25),
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.fromRGB(127, 127, 127),
						TextSize = 18,
						Text = v .. " (Not Selected)"
					})

					list.Size = UDim2.fromOffset(dropdown.Size.X.Offset, #choices * 25)

					button.MouseButton1Down:Connect(function()
						if (current) then
							current.TextColor3 = Color3.fromRGB(127, 127, 127)
							current.Text = current.Name .. " (Not Selected)"
						end

						current = button
						button.TextColor3 = Color3.fromRGB(255, 255, 255)
						button.Text = button.Name .. " (Selected)"

						name.Text = string.format("%s (%s)", dropdown_name, button.Name)
						pcall(callback, button.Name)
					end)
				end

				if (toggled) then
					local tween = tween_service:Create(dropdown, TweenInfo.new(.3), {
						Size = UDim2.new(0, 447, 0, list.AbsoluteCanvasSize.Y + 38)
					})

					tweening = true
					tween:Play()
					tween.Completed:Wait()
					tweening = false
				end
			end

			Update(options)

			return {
				Refresh = Update
			}
		end

		function content.Input(input_name, callback, placeholder_text)
			local input = CreateInstance("Frame", {
				Name = "InputBackground",
				Parent = page,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				BorderSizePixel = 0,
				Selectable = true,
				Size = UDim2.new(0, 447, 0, 41)
			}, {
				CreateInstance("TextLabel", {
					Name = "InputTitle",
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.0671834648, 0, 0.169651359, 0),
					Size = UDim2.new(0, 61, 0, 26),
					Font = Enum.Font.SourceSansSemibold,
					Text = input_name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 23,
					TextXAlignment = Enum.TextXAlignment.Left
				}, {
					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),

					CreateInstance("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					})
				}),

				CreateInstance("Frame", {
					Name = "InputContainer",
					BackgroundColor3 = Color3.fromRGB(38, 38, 38),
					Position = UDim2.new(0.768000007, 0, 0.162, 0),
					Size = UDim2.new(0.217002243, 0, 0.609756112, 0)
				}, {
					CreateInstance("TextBox", {
						Name = "InputField",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ClearTextOnFocus = false,
						Font = Enum.Font.SourceSansSemibold,
						PlaceholderColor3 = DarkenColor(palette.Content, 75),
						PlaceholderText = placeholder_text or "Value",
						Text = "",
						TextWrapped = true,
						TextColor3 = palette.Content,
						TextSize = 18
					}),

					CreateInstance("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})
				}),

				CreateInstance("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})

			local input_container = input:FindFirstChild("InputContainer")
			local input_field = input_container:FindFirstChild("InputField")

			input_field.FocusLost:Connect(function()
				if (input_field.Text == "") then
					return
				end

				pcall(callback, input_field.Text)
			end)
		end

		return content
	end

	return pages
end

function lib.Notification(info)
	starter_gui:SetCore("SendNotification", {
		Title = info.Title or "No title was set",
		Text = info.Content or "",
		Duration = info.Duration or 5,
		Callback = info.Callback,
		Button1 = info.Button1,
		Button2 = info.Button2
	})
end

return lib