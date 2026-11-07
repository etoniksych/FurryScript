local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local env = getgenv and getgenv() or _G

if env.VDMenuCleanup then
pcall(env.VDMenuCleanup)
end

local connections = {}
local highlights = {}
local espEnabled = false
local menuKey = Enum.KeyCode.Insert
local waitingForKey = false
local speedMultiplier = 1
local speedHumanoid = nil
local baseSpeed = nil
local lastAppliedSpeed = nil
local speedConnection = nil
local sliderDragging = false
local alive = true
local menuDragging = false
local menuDragStart, menuStartPosition

local function connect(signal, callback)
local connection = signal:Connect(callback)
table.insert(connections, connection)
return connection
end

local function create(className, properties, parent)
local object = Instance.new(className)
for property, value in pairs(properties) do
object[property] = value
end
object.Parent = parent
return object
end

local function round(object, radius)
create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

local function clearHighlights()
for _, highlight in ipairs(highlights) do
highlight:Destroy()
end
table.clear(highlights)
end

local function addHighlight(character)
if not espEnabled or not character then return end
local player = Players:GetPlayerFromCharacter(character)
if not player or player == localPlayer then return end
local teamName = player.Team and player.Team.Name
local color
if teamName == "Killer" then
color = Color3.fromRGB(255, 70, 70)
elseif teamName == "Survivors" then
color = Color3.fromRGB(70, 160, 255)
end
local existing = character:FindFirstChild("VDTestHighlight")
if not color then
if existing then existing:Destroy() end
return
end
if existing then
existing.FillColor = color
return
end
local highlight = create("Highlight", {
Name = "VDTestHighlight",
Adornee = character,
DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
FillColor = color,
OutlineColor = Color3.fromRGB(255, 255, 255),
FillTransparency = 0.5,
OutlineTransparency = 0
}, character)
table.insert(highlights, highlight)
end

local function setupPlayer(player)
if player == localPlayer then return end
if player.Character then addHighlight(player.Character) end
connect(player.CharacterAdded, addHighlight)
connect(player:GetPropertyChangedSignal("Team"), function()
if player.Character then addHighlight(player.Character) end
end)
end

-- Скорость берётся из текущего Humanoid, а не из фиксированного значения.
local function applySpeed()
if speedHumanoid and speedHumanoid.Parent and baseSpeed then
local target = baseSpeed * speedMultiplier
lastAppliedSpeed = target
speedHumanoid.WalkSpeed = target
end
end

local function attachCharacter(character)
if speedConnection then
speedConnection:Disconnect()
speedConnection = nil
end
speedHumanoid = nil
baseSpeed = nil
lastAppliedSpeed = nil
local humanoid = character:FindFirstChildOfClass("Humanoid")
or character:WaitForChild("Humanoid", 10)
if not alive or not humanoid or localPlayer.Character ~= character then return end
speedHumanoid = humanoid
baseSpeed = humanoid.WalkSpeed
speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
if humanoid ~= speedHumanoid then return end
local current = humanoid.WalkSpeed
if lastAppliedSpeed and math.abs(current - lastAppliedSpeed) < 0.001 then return end
baseSpeed = current
applySpeed()
end)
applySpeed()
end

local gui = create("ScreenGui", {
Name = "VDTestMenu", ResetOnSpawn = false
}, playerGui)
local main = create("Frame", {
Name = "Main", Size = UDim2.fromOffset(640, 400),
Position = UDim2.new(0.5, -320, 0.5, -200),
BackgroundColor3 = Color3.fromRGB(27, 28, 33),
BorderSizePixel = 0, ClipsDescendants = true
}, gui)
round(main, 12)

-- Меню располагается поверх других ScreenGui в PlayerGui.
-- Системное меню Roblox остаётся выше интерфейса игры.
gui.DisplayOrder = 10000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local cursorStepName = "VDTestMenuCursor"
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil
local cursorCaptured = false

local function captureCursor()
if cursorCaptured then return end
cursorCaptured = true
savedMouseBehavior = UserInputService.MouseBehavior
savedMouseIconEnabled = UserInputService.MouseIconEnabled
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
UserInputService.MouseIconEnabled = true
end

local function restoreCursor()
if not cursorCaptured then return end
UserInputService.MouseBehavior = savedMouseBehavior
UserInputService.MouseIconEnabled = savedMouseIconEnabled
cursorCaptured = false
end

connect(main:GetPropertyChangedSignal("Visible"), function()
if main.Visible then
captureCursor()
else
restoreCursor()
end
end)

captureCursor()
RunService:BindToRenderStep(cursorStepName, Enum.RenderPriority.Last.Value, function()
if main.Visible then
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
UserInputService.MouseIconEnabled = true
end
end)

local sidebar = create("Frame", {
Size = UDim2.new(0, 190, 1, 0),
BackgroundColor3 = Color3.fromRGB(35, 36, 43), BorderSizePixel = 0
}, main)
create("TextLabel", {
Size = UDim2.new(1, -24, 0, 54), Position = UDim2.fromOffset(14, 4),
BackgroundTransparency = 1, Text = "VD • TEST MENU",
TextColor3 = Color3.fromRGB(245, 245, 250), TextSize = 16,
Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)
create("TextLabel", {
Size = UDim2.new(1, -28, 0, 24), Position = UDim2.fromOffset(14, 60),
BackgroundTransparency = 1, Text = "КАТЕГОРИИ",
TextColor3 = Color3.fromRGB(150, 153, 165), TextSize = 11,
Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)
local function tab(text, y)
local button = create("TextButton", {
Size = UDim2.new(1, -20, 0, 42), Position = UDim2.fromOffset(10, y),
BackgroundColor3 = Color3.fromRGB(48, 49, 58), Text = text,
TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15,
Font = Enum.Font.GothamMedium, AutoButtonColor = true
}, sidebar)
round(button, 8)
return button
end
local espTab = tab("ESP", 90)
local tweaksTab = tab("Твики", 140)
local profileButton = create("TextButton", {
Size = UDim2.new(1, -20, 0, 64), Position = UDim2.new(0, 10, 1, -74),
BackgroundColor3 = Color3.fromRGB(48, 49, 58), Text = "", AutoButtonColor = true
}, sidebar)
round(profileButton, 8)
local avatar = create("ImageLabel", {
Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(10, 11),
BackgroundColor3 = Color3.fromRGB(70, 72, 82), BorderSizePixel = 0, Image = ""
}, profileButton)
round(avatar, 21)
create("TextLabel", {
Size = UDim2.new(1, -62, 0, 22), Position = UDim2.fromOffset(60, 9),
BackgroundTransparency = 1, Text = localPlayer.DisplayName,
TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13,
Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd
}, profileButton)
create("TextLabel", {
Size = UDim2.new(1, -62, 0, 18), Position = UDim2.fromOffset(60, 32),
BackgroundTransparency = 1, Text = "Настройки →",
TextColor3 = Color3.fromRGB(170, 173, 185), TextSize = 11,
Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left
}, profileButton)
task.spawn(function()
local ok, image = pcall(function()
return Players:GetUserThumbnailAsync(localPlayer.UserId,
Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok and gui.Parent then avatar.Image = image end
end)

local content = create("Frame", {
Size = UDim2.new(1, -190, 1, 0), Position = UDim2.fromOffset(190, 0),
BackgroundTransparency = 1
}, main)
local header = create("Frame", {
Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Active = true
}, content)
local heading = create("TextLabel", {
Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(24, 0),
BackgroundTransparency = 1, Text = "ESP",
TextColor3 = Color3.fromRGB(245, 245, 250), TextSize = 20,
Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
}, header)
local closeButton = create("TextButton", {
Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -48, 0, 10),
BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(200, 200, 210),
TextSize = 26, Font = Enum.Font.Gotham
}, header)
local function page()
return create("Frame", {
Size = UDim2.new(1, 0, 1, -60), Position = UDim2.fromOffset(0, 60),
BackgroundTransparency = 1, Visible = false
}, content)
end
local espPage, tweaksPage, profilePage = page(), page(), page()
local function label(parent, text, x, y, width, height, size, color)
return create("TextLabel", {
Size = UDim2.fromOffset(width, height), Position = UDim2.fromOffset(x, y),
BackgroundTransparency = 1, Text = text,
TextColor3 = color or Color3.fromRGB(245, 245, 250),
TextSize = size or 14, Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
}, parent)
end
local function button(parent, text, x, y, width, height)
local b = create("TextButton", {
Size = UDim2.fromOffset(width, height), Position = UDim2.fromOffset(x, y),
BackgroundColor3 = Color3.fromRGB(65, 65, 75), Text = text,
TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14,
Font = Enum.Font.GothamMedium, AutoButtonColor = true
}, parent)
round(b, 8)
return b
end
label(espPage, "Подсветка игроков", 24, 12, 380, 30, 16)
label(espPage, "Маньяк — красный, выжившие — синие", 24, 44, 390, 36, 12, Color3.fromRGB(165, 168, 180))
local espButton = button(espPage, "ESP: ВЫКЛ", 24, 95, 180, 42)

-- Разворачиваемый раздел управления скоростью.
local speedHeader = button(tweaksPage, "Скорость игрока ▾", 24, 15, 390, 42)
local speedPanel = create("Frame", {
Size = UDim2.fromOffset(390, 150), Position = UDim2.fromOffset(24, 66),
BackgroundColor3 = Color3.fromRGB(36, 37, 44), BorderSizePixel = 0, Visible = false
}, tweaksPage)
round(speedPanel, 8)
label(speedPanel, "Множитель скорости", 14, 12, 210, 28, 14)
local speedBox = create("TextBox", {
Size = UDim2.fromOffset(76, 32), Position = UDim2.new(1, -90, 0, 10),
BackgroundColor3 = Color3.fromRGB(65, 65, 75), Text = "1.00",
PlaceholderText = "1.00–1.50", ClearTextOnFocus = false,
TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14,
Font = Enum.Font.GothamMedium
}, speedPanel)
round(speedBox, 6)
local slider = create("Frame", {
Size = UDim2.new(1, -40, 0, 8), Position = UDim2.fromOffset(20, 76),
BackgroundColor3 = Color3.fromRGB(83, 85, 96), BorderSizePixel = 0, Active = true
}, speedPanel)
round(slider, 4)
local sliderFill = create("Frame", {
Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(80, 160, 240),
BorderSizePixel = 0
}, slider)
round(sliderFill, 4)
local knob = create("TextButton", {
Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(240, 245, 255),
Text = "", AutoButtonColor = false
}, slider)
round(knob, 11)
label(speedPanel, "1.00×", 14, 98, 80, 25, 12, Color3.fromRGB(165, 168, 180))
local maxLabel = label(speedPanel, "1.50×", 296, 98, 80, 25, 12, Color3.fromRGB(165, 168, 180))
maxLabel.TextXAlignment = Enum.TextXAlignment.Right

label(profilePage, "Аккаунт: @" .. localPlayer.Name, 24, 12, 390, 28, 15)
label(profilePage, "Клавиша открытия меню", 24, 55, 390, 28, 15)
local bindButton = button(profilePage, "Клавиша: Insert", 24, 92, 220, 42)
label(profilePage, "Нажми кнопку и затем нужную клавишу.\nEsc — отменить выбор.", 24, 145, 390, 45, 12, Color3.fromRGB(165, 168, 180))

local function showPage(name)
espPage.Visible = name == "ESP"
tweaksPage.Visible = name == "Твики"
profilePage.Visible = name == "Профиль"
heading.Text = name
espTab.BackgroundColor3 = name == "ESP" and Color3.fromRGB(62, 65, 78) or Color3.fromRGB(48, 49, 58)
tweaksTab.BackgroundColor3 = name == "Твики" and Color3.fromRGB(62, 65, 78) or Color3.fromRGB(48, 49, 58)
waitingForKey = false
bindButton.Text = "Клавиша: " .. menuKey.Name
end
showPage("ESP")
connect(espTab.MouseButton1Click, function() showPage("ESP") end)
connect(tweaksTab.MouseButton1Click, function() showPage("Твики") end)
connect(profileButton.MouseButton1Click, function() showPage("Профиль") end)
connect(closeButton.MouseButton1Click, function()
waitingForKey = false
bindButton.Text = "Клавиша: " .. menuKey.Name
main.Visible = false
end)
connect(bindButton.MouseButton1Click, function()
waitingForKey = true
bindButton.Text = "Нажми клавишу..."
end)
connect(espButton.MouseButton1Click, function()
espEnabled = not espEnabled
espButton.Text = espEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(55, 135, 85) or Color3.fromRGB(65, 65, 75)
clearHighlights()
if espEnabled then
for _, player in ipairs(Players:GetPlayers()) do
if player ~= localPlayer and player.Character then addHighlight(player.Character) end
end
end
end)
connect(speedHeader.MouseButton1Click, function()
speedPanel.Visible = not speedPanel.Visible
speedHeader.Text = speedPanel.Visible and "Скорость игрока ▴" or "Скорость игрока ▾"
end)
local function setMultiplier(value)
if not value or value ~= value then value = speedMultiplier end
value = math.clamp(value, 1, 1.5)
speedMultiplier = math.floor(value * 100 + 0.5) / 100
local fraction = (speedMultiplier - 1) / 0.5
sliderFill.Size = UDim2.fromScale(fraction, 1)
knob.Position = UDim2.new(fraction, 0, 0.5, 0)
speedBox.Text = string.format("%.2f", speedMultiplier)
applySpeed()
end
local function updateFromPointer(x)
local width = slider.AbsoluteSize.X
if width <= 0 then return end
local fraction = math.clamp((x - slider.AbsolutePosition.X) / width, 0, 1)
setMultiplier(1 + fraction * 0.5)
end
connect(speedBox.FocusLost, function()
local input = string.gsub(speedBox.Text, ",", ".")
setMultiplier(tonumber(input))
end)
local function beginSlider(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
sliderDragging = true
updateFromPointer(input.Position.X)
end
end
connect(slider.InputBegan, beginSlider)
connect(knob.InputBegan, beginSlider)
connect(UserInputService.InputBegan, function(input, gameProcessed)
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
if UserInputService:GetFocusedTextBox() then return end
if waitingForKey then
waitingForKey = false
if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
menuKey = input.KeyCode
end
bindButton.Text = "Клавиша: " .. menuKey.Name
return
end
if not gameProcessed and input.KeyCode == menuKey then main.Visible = not main.Visible end
end)
connect(header.InputBegan, function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
menuDragging = true
menuDragStart = input.Position
menuStartPosition = main.Position
end
end)
connect(UserInputService.InputEnded, function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
sliderDragging = false
menuDragging = false
end
end)
connect(UserInputService.InputChanged, function(input)
if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
if sliderDragging then updateFromPointer(input.Position.X) end
if menuDragging then
local delta = input.Position - menuDragStart
main.Position = UDim2.new(menuStartPosition.X.Scale, menuStartPosition.X.Offset + delta.X,
menuStartPosition.Y.Scale, menuStartPosition.Y.Offset + delta.Y)
end
end)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
connect(Players.PlayerAdded, setupPlayer)
connect(localPlayer.CharacterAdded, function(character) task.spawn(attachCharacter, character) end)
if localPlayer.Character then task.spawn(attachCharacter, localPlayer.Character) end

local function cleanup()
RunService:UnbindFromRenderStep(cursorStepName)
restoreCursor()
alive = false
espEnabled = false
clearHighlights()
if speedConnection then speedConnection:Disconnect() end
if speedHumanoid and speedHumanoid.Parent and baseSpeed and lastAppliedSpeed
and math.abs(speedHumanoid.WalkSpeed - lastAppliedSpeed) < 0.001 then
speedHumanoid.WalkSpeed = baseSpeed
end
for _, connection in ipairs(connections) do connection:Disconnect() end
gui:Destroy()
env.VDMenuCleanup = nil
end
env.VDMenuCleanup = cleanup
print("Меню загружено. Клавиша открытия: Insert")
