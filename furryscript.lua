local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Закрываем предыдущую версию при повторном запуске.
local env = getgenv and getgenv() or _G

if env.VDMenuCleanup then
    pcall(env.VDMenuCleanup)
end

local connections = {}
local highlights = {}
local espEnabled = false
local menuKey = Enum.KeyCode.Insert
local waitingForKey = false

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
    create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, object)
end

local function clearHighlights()
    for _, highlight in ipairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
    end

    table.clear(highlights)
end

local function addHighlight(character)
    if not espEnabled or not character then
        return
    end

    if character:FindFirstChild("VDTestHighlight") then
        return
    end

    local highlight = create("Highlight", {
        Name = "VDTestHighlight",
        Adornee = character,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillColor = Color3.fromRGB(255, 70, 70),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0
    }, character)

    table.insert(highlights, highlight)
end

local function setupPlayer(player)
    if player == localPlayer then
        return
    end

    if player.Character then
        addHighlight(player.Character)
    end

    connect(player.CharacterAdded, function(character)
        addHighlight(character)
    end)
end

local gui = create("ScreenGui", {
    Name = "VDTestMenu",
    ResetOnSpawn = false
}, playerGui)

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(640, 400),
    Position = UDim2.new(0.5, -320, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(27, 28, 33),
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)
round(main, 12)

local sidebar = create("Frame", {
    Size = UDim2.new(0, 190, 1, 0),
    BackgroundColor3 = Color3.fromRGB(35, 36, 43),
    BorderSizePixel = 0
}, main)

create("TextLabel", {
    Size = UDim2.new(1, -24, 0, 54),
    Position = UDim2.fromOffset(14, 4),
    BackgroundTransparency = 1,
    Text = "VD • TEST MENU",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 60),
    BackgroundTransparency = 1,
    Text = "КАТЕГОРИИ",
    TextColor3 = Color3.fromRGB(150, 153, 165),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local espTab = create("TextButton", {
    Size = UDim2.new(1, -20, 0, 42),
    Position = UDim2.fromOffset(10, 90),
    BackgroundColor3 = Color3.fromRGB(62, 65, 78),
    Text = "ESP",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = true
}, sidebar)
round(espTab, 8)

-- Профиль в нижнем левом углу.
local profileButton = create("TextButton", {
    Size = UDim2.new(1, -20, 0, 64),
    Position = UDim2.new(0, 10, 1, -74),
    BackgroundColor3 = Color3.fromRGB(48, 49, 58),
    Text = "",
    AutoButtonColor = true
}, sidebar)
round(profileButton, 8)

local avatar = create("ImageLabel", {
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(10, 11),
    BackgroundColor3 = Color3.fromRGB(70, 72, 82),
    BorderSizePixel = 0,
    Image = ""
}, profileButton)
round(avatar, 21)

create("TextLabel", {
    Size = UDim2.new(1, -62, 0, 22),
    Position = UDim2.fromOffset(60, 9),
    BackgroundTransparency = 1,
    Text = localPlayer.DisplayName,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd
}, profileButton)

create("TextLabel", {
    Size = UDim2.new(1, -62, 0, 18),
    Position = UDim2.fromOffset(60, 32),
    BackgroundTransparency = 1,
    Text = "Настройки →",
    TextColor3 = Color3.fromRGB(170, 173, 185),
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, profileButton)

task.spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            localPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)

    if success and gui.Parent then
        avatar.Image = image
    end
end)

local content = create("Frame", {
    Size = UDim2.new(1, -190, 1, 0),
    Position = UDim2.fromOffset(190, 0),
    BackgroundTransparency = 1
}, main)

local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    Active = true
}, content)

local heading = create("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.fromOffset(24, 0),
    BackgroundTransparency = 1,
    Text = "ESP",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

local closeButton = create("TextButton", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.new(1, -48, 0, 10),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextSize = 26,
    Font = Enum.Font.Gotham
}, header)

local espPage = create("Frame", {
    Size = UDim2.new(1, 0, 1, -60),
    Position = UDim2.fromOffset(0, 60),
    BackgroundTransparency = 1
}, content)

create("TextLabel", {
    Size = UDim2.new(1, -48, 0, 30),
    Position = UDim2.fromOffset(24, 12),
    BackgroundTransparency = 1,
    Text = "Подсветка игроков",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 16,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, espPage)

create("TextLabel", {
    Size = UDim2.new(1, -48, 0, 24),
    Position = UDim2.fromOffset(24, 44),
    BackgroundTransparency = 1,
    Text = "Показывать других игроков сквозь стены",
    TextColor3 = Color3.fromRGB(165, 168, 180),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, espPage)

local espButton = create("TextButton", {
    Size = UDim2.fromOffset(180, 42),
    Position = UDim2.fromOffset(24, 85),
    BackgroundColor3 = Color3.fromRGB(65, 65, 75),
    Text = "ESP: ВЫКЛ",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold
}, espPage)
round(espButton, 8)

local profilePage = create("Frame", {
    Size = UDim2.new(1, 0, 1, -60),
    Position = UDim2.fromOffset(0, 60),
    BackgroundTransparency = 1,
    Visible = false
}, content)

create("TextLabel", {
    Size = UDim2.new(1, -48, 0, 28),
    Position = UDim2.fromOffset(24, 12),
    BackgroundTransparency = 1,
    Text = "Аккаунт: @" .. localPlayer.Name,
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd
}, profilePage)

create("TextLabel", {
    Size = UDim2.new(1, -48, 0, 28),
    Position = UDim2.fromOffset(24, 55),
    BackgroundTransparency = 1,
    Text = "Клавиша открытия меню",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, profilePage)

local bindButton = create("TextButton", {
    Size = UDim2.fromOffset(220, 42),
    Position = UDim2.fromOffset(24, 92),
    BackgroundColor3 = Color3.fromRGB(65, 65, 75),
    Text = "Клавиша: Insert",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamMedium
}, profilePage)
round(bindButton, 8)

create("TextLabel", {
    Size = UDim2.new(1, -48, 0, 45),
    Position = UDim2.fromOffset(24, 145),
    BackgroundTransparency = 1,
    Text = "Нажми кнопку и затем нужную клавишу.\nEsc — отменить выбор.",
    TextColor3 = Color3.fromRGB(165, 168, 180),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, profilePage)

local function showPage(name)
    local isEsp = name == "ESP"
    espPage.Visible = isEsp
    profilePage.Visible = not isEsp
    heading.Text = isEsp and "ESP" or "Профиль"

    waitingForKey = false
    bindButton.Text = "Клавиша: " .. menuKey.Name
end

connect(espTab.MouseButton1Click, function()
    showPage("ESP")
end)

connect(profileButton.MouseButton1Click, function()
    showPage("Profile")
end)

connect(closeButton.MouseButton1Click, function()
    waitingForKey = false
    bindButton.Text = "Клавиша: " .. menuKey.Name
    main.Visible = false
end)

connect(bindButton.MouseButton1Click, function()
    waitingForKey = true
    bindButton.Text = "Нажми клавишу..."
end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    if waitingForKey then
        waitingForKey = false

        if input.KeyCode ~= Enum.KeyCode.Escape
            and input.KeyCode ~= Enum.KeyCode.Unknown then
            menuKey = input.KeyCode
        end

        bindButton.Text = "Клавиша: " .. menuKey.Name
        return
    end

    if not gameProcessed and input.KeyCode == menuKey then
        main.Visible = not main.Visible
    end
end)

connect(espButton.MouseButton1Click, function()
    espEnabled = not espEnabled

    espButton.Text = espEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
    espButton.BackgroundColor3 = espEnabled
        and Color3.fromRGB(55, 135, 85)
        or Color3.fromRGB(65, 65, 75)

    clearHighlights()

    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                addHighlight(player.Character)
            end
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

connect(Players.PlayerAdded, setupPlayer)

-- Перетаскивание за верхнюю часть меню.
local dragging = false
local dragStart
local startPosition

connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

local function cleanup()
    espEnabled = false
    clearHighlights()

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    gui:Destroy()
    env.VDMenuCleanup = nil
end

env.VDMenuCleanup = cleanup

print("Меню загружено. Клавиша открытия: Insert")
