--[[
    OrangeBot.lua (Mobile Fix)
    Personal Chatbot for Roblox
    Supports: Delta, Arceus, Xeno, Solara, etc. (Mobile & PC)
    Developer: Jepry_jago112
    Features:
      - Touch-friendly GUI
      - Indicator click to toggle main window
      - Chat, Settings, Credits tabs
      - Trigger word detection
      - Distance check
--]]

-- =====================================================
-- 1. DETECT EXECUTOR
-- =====================================================
local function getExecutor()
    local exec = "Unknown"
    if syn and syn.getexecutorname then
        exec = syn.getexecutorname()
    elseif getexecutorname then
        exec = getexecutorname()
    elseif is_sirhurt and is_sirhurt() then
        exec = "Sirhurt"
    elseif check_synapse and check_synapse() then
        exec = "Synapse"
    elseif identifyexecutor then
        exec = identifyexecutor()
    elseif getgenv and getgenv().KRNL_LOADED then
        exec = "Krnl"
    elseif getgenv and getgenv().XENO_LOADED then
        exec = "Xeno"
    elseif getgenv and getgenv().SOLARA_LOADED then
        exec = "Solara"
    elseif getgenv and getgenv().ARCEUS_LOADED then
        exec = "Arceus"
    end
    return exec
end

local executorName = getExecutor()

-- =====================================================
-- 2. SERVICES & GLOBALS
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =====================================================
-- 3. CONFIGURATION
-- =====================================================
local config = {
    active = true,
    triggerWord = "!orange",
    distance = 20,
    personality = "friendly",
    botPosition = Vector3.new(0, 0, 0),
}

-- =====================================================
-- 4. PERSONALITIES
-- =====================================================
local personalities = {
    friendly = { label = "Ramah", emoji = "😊", system = "Ramah dan hangat." },
    formal = { label = "Formal", emoji = "👔", system = "Profesional dan sopan." },
    funny = { label = "Kocak", emoji = "😂", system = "Lucu dan suka bercanda." },
    wise = { label = "Bijak", emoji = "🧙", system = "Bijaksana dan reflektif." },
    chill = { label = "Santai", emoji = "😎", system = "Santai dan akrab." },
    sassy = { label = "Cerewet", emoji = "🔥", system = "Sarkastik dan pedas." },
    romantic = { label = "Romantis", emoji = "💖", system = "Manis dan penuh cinta." },
    pirate = { label = "Bajak Laut", emoji = "🏴‍☠️", system = "Gaya bajak laut." },
    robot = { label = "Robot", emoji = "🤖", system = "Mekanis dan efisien." },
    ninja = { label = "Ninja", emoji = "🥷", system = "Misterius dan filosofis." }
}

-- =====================================================
-- 5. CHATBOT LOGIC
-- =====================================================
local function getPersonality(key)
    return personalities[key] or personalities.friendly
end

local function getMockResponse(userText, personalityKey)
    local p = getPersonality(personalityKey)
    local responses = {
        friendly = {
            "Hai! Senang banget ngobrol sama kamu! 😊",
            "Wah, menarik nih! Ceritakan lebih lanjut! 🍊",
            "Aku suka banget dengan pertanyaanmu! Yuk bahas!",
            "Halo! Aku OrangeBot, siap menemani harimu! ✨",
        },
        formal = {
            "Selamat siang. Ada yang bisa saya bantu?",
            "Baik, saya akan membantu Anda dengan sepenuh hati.",
            "Pertanyaan yang bagus. Mari kita bahas secara profesional.",
            "Saya siap memberikan informasi yang Anda butuhkan.",
        },
        funny = {
            "Woy! akhirnya ada yang ngajak ngobrol! 🎉",
            "Hahaha pertanyaannya lucu banget! 😂",
            "Bro, kamu keren banget nanya gitu!",
            "Yeee! OrangeBot lagi mood ngakak nih!",
        },
        wise = {
            "Setiap pertanyaan adalah awal dari pencerahan. 🧙",
            "Kebijaksanaan bukan tentang jawaban, tapi tentang pertanyaan yang tepat.",
            "Renungkanlah: apa yang sebenarnya ingin kamu ketahui?",
            "Setiap langkah kecil adalah perjalanan besar.",
        },
        chill = {
            "Santai aja bro, aku dengerin kok. 😎",
            "Yaudah santai, kita ngobrol ringan aja.",
            "Sip, aku siap dengerin curhatanmu!",
            "Tenang, OrangeBot ada buat kamu.",
        },
        sassy = {
            "Oh really? That's what you wanna ask? Ok fine. 🔥",
            "Wah, pertanyaan yang... menarik. Aku jawab dengan gaya khas.",
            "Hmm, oke deh, siap-siap sama jawaban pedas!",
            "Sip, pertanyaan level dewa nih. Aku suka!",
        },
        romantic = {
            "Aduh, pertanyaanmu bikin hati aku bergetar 💖",
            "Cahaya matamu bersinar saat kamu bertanya... 🌟",
            "Ah, kamu selalu punya cara untuk membuat hariku indah. 💕",
            "Dengan senang hati aku akan menjawab, untukmu yang istimewa.",
        },
        pirate = {
            "Arrr! Pertanyaan bagus, matey! 🏴‍☠️",
            "Ahoy! OrangeBot siap membantu, aku bajak laut!",
            "Wah, pertanyaanmu bikin aku ingat harta karun!",
            "Yo ho ho! Pertanyaanmu membuatku bersemangat!",
        },
        robot = {
            "MENERIMA INPUT. MEMPROSES... JAWABAN SIAP. 🤖",
            "ANALISIS: Pertanyaan valid. MENGELUARKAN RESPON...",
            "SISTEM AKTIF. MENYEDIAKAN JAWABAN OPTIMAL.",
            "INPUT DITERIMA. RESPON DIHASILKAN.",
        },
        ninja = {
            "Hmm... pertanyaan yang dalam. Seperti bayangan di malam hari. 🥷",
            "Aku mendengar pertanyaanmu... jawabannya ada di antara angin.",
            "Kamu bertanya, aku merenung... kebenaran perlahan terungkap.",
            "Misteri adalah jawaban dari setiap pertanyaan. 🥷",
        }
    }
    local list = responses[personalityKey] or responses.friendly
    return list[math.random(#list)]
end

-- =====================================================
-- 6. CREATE MOBILE-FRIENDLY GUI
-- =====================================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OrangeBotGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- ===== INDICATOR (top center, clickable) =====
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 240, 0, 32)
    indicator.Position = UDim2.new(0.5, -120, 0, 10)
    indicator.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    indicator.BackgroundTransparency = 0.2
    indicator.BorderSizePixel = 0
    indicator.ClipsDescendants = true
    indicator.Parent = screenGui
    
    local indCorners = Instance.new("UICorner")
    indCorners.CornerRadius = UDim.new(0, 12)
    indCorners.Parent = indicator
    
    local indText = Instance.new("TextLabel")
    indText.Name = "Label"
    indText.Size = UDim2.new(1, 0, 1, 0)
    indText.BackgroundTransparency = 1
    indText.TextColor3 = Color3.fromRGB(255, 255, 255)
    indText.Font = Enum.Font.GothamBold
    indText.TextSize = 13
    indText.Text = "🍊 OrangeBot | " .. executorName .. " | ● Online"
    indText.TextXAlignment = Enum.TextXAlignment.Center
    indText.Parent = indicator
    
    -- Status dot (small green/red)
    local dot = Instance.new("Frame")
    dot.Name = "StatusDot"
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 12, 0, 11)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    dot.Parent = indicator
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- Toggle button (full indicator click)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = indicator
    
    -- ===== MAIN FRAME =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 360, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorners = Instance.new("UICorner")
    mainCorners.CornerRadius = UDim.new(0, 12)
    mainCorners.Parent = mainFrame
    
    -- Title bar (draggable with touch)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 34)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Text = "🍊 OrangeBot"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    -- touch support for close
    closeBtn.TouchEnded:Connect(function()
        mainFrame.Visible = false
    end)
    
    -- Drag logic for touch & mouse
    local dragging = false
    local dragStart, startPos
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    titleBar.InputBegan:Connect(onInputBegan)
    titleBar.InputEnded:Connect(onInputEnded)
    UserInputService.InputChanged:Connect(onInputChanged)
    
    -- ===== TABS =====
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 34)
    tabContainer.Position = UDim2.new(0, 0, 0, 34)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabs = {
        { id = "chat", label = "💬 Chat" },
        { id = "settings", label = "⚙️" },
        { id = "credits", label = "🏆" },
    }
    
    local tabButtons = {}
    local tabContents = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #tabs, 0, 1, 0)
        btn.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)
        btn.BackgroundTransparency = 0.8
        btn.Text = tab.label
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Parent = tabContainer
        tabButtons[tab.id] = btn
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, -68)
        content.Position = UDim2.new(0, 0, 0, 68)
        content.BackgroundTransparency = 1
        content.Visible = (i == 1)
        content.Parent = mainFrame
        tabContents[tab.id] = content
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabButtons) do
                b.BackgroundTransparency = 0.8
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            btn.BackgroundTransparency = 0.4
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            for id, cont in pairs(tabContents) do
                cont.Visible = (id == tab.id)
            end
        end)
        -- touch support
        btn.TouchEnded:Connect(function()
            for _, b in pairs(tabButtons) do
                b.BackgroundTransparency = 0.8
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            btn.BackgroundTransparency = 0.4
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            for id, cont in pairs(tabContents) do
                cont.Visible = (id == tab.id)
            end
        end)
    end
    tabButtons["chat"].BackgroundTransparency = 0.4
    tabButtons["chat"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===== CHAT TAB =====
    local chatContent = tabContents["chat"]
    
    local chatScroll = Instance.new("ScrollingFrame")
    chatScroll.Size = UDim2.new(1, -12, 1, -50)
    chatScroll.Position = UDim2.new(0, 6, 0, 6)
    chatScroll.BackgroundTransparency = 1
    chatScroll.BorderSizePixel = 0
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatScroll.ScrollBarThickness = 4
    chatScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    chatScroll.Parent = chatContent
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.FillDirection = Enum.FillDirection.Vertical
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 4)
    chatLayout.Parent = chatScroll
    
    local function addChatMessage(text, isUser)
        local msg = Instance.new("Frame")
        msg.Size = UDim2.new(1, -10, 0, 20)
        msg.BackgroundTransparency = 1
        msg.Parent = chatScroll
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = isUser and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(200, 220, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        label.Text = (isUser and "🧑 " or "🍊 ") .. text
        label.TextWrapped = true
        label.Parent = msg
        
        local textSize = label.TextBounds.Y
        msg.Size = UDim2.new(1, -10, 0, math.max(20, textSize + 6))
        chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatScroll.CanvasSize.Y.Offset + msg.Size.Y.Offset + 4)
    end
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, -12, 0, 38)
    inputContainer.Position = UDim2.new(0, 6, 1, -44)
    inputContainer.BackgroundTransparency = 1
    inputContainer.Parent = chatContent
    
    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -54, 1, 0)
    chatInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    chatInput.BorderSizePixel = 0
    chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInput.Font = Enum.Font.Gotham
    chatInput.TextSize = 14
    chatInput.PlaceholderText = "Ketik..."
    chatInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    chatInput.ClipsDescendants = true
    chatInput.Parent = inputContainer
    local inpCorners = Instance.new("UICorner")
    inpCorners.CornerRadius = UDim.new(0, 6)
    inpCorners.Parent = chatInput
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 44, 1, 0)
    sendBtn.Position = UDim2.new(1, -44, 0, 0)
    sendBtn.BackgroundColor3 = Color3.fromRGB(249, 115, 22)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 20
    sendBtn.Parent = inputContainer
    local sendCorners = Instance.new("UICorner")
    sendCorners.CornerRadius = UDim.new(0, 6)
    sendCorners.Parent = sendBtn
    
    local function sendGUIMessage()
        local msg = chatInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if msg == "" then return end
        addChatMessage(msg, true)
        chatInput.Text = ""
        local reply = getMockResponse(msg, config.personality)
        addChatMessage(reply, false)
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
    end
    
    sendBtn.MouseButton1Click:Connect(sendGUIMessage)
    sendBtn.TouchEnded:Connect(sendGUIMessage)
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendGUIMessage() end
    end)
    
    -- ===== SETTINGS TAB =====
    local settingsContent = tabContents["settings"]
    
    local function createSetting(parent, yPos, labelText, descText)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 54)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 22)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 24)
        desc.BackgroundTransparency = 1
        desc.Text = descText or ""
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 11
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
        
        return frame, label, desc
    end
    
    -- Trigger Word
    local twFrame, twLabel = createSetting(settingsContent, 0, "🔑 Trigger Word", "Ketik di chat game untuk panggil bot")
    local twInput = Instance.new("TextBox")
    twInput.Size = UDim2.new(0, 160, 0, 26)
    twInput.Position = UDim2.new(0, 130, 0, 20)
    twInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    twInput.BorderSizePixel = 0
    twInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    twInput.Font = Enum.Font.Gotham
    twInput.TextSize = 14
    twInput.Text = config.triggerWord
    twInput.Parent = twFrame
    local twCorner = Instance.new("UICorner")
    twCorner.CornerRadius = UDim.new(0, 4)
    twCorner.Parent = twInput
    twInput:GetPropertyChangedSignal("Text"):Connect(function()
        config.triggerWord = twInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    end)
    
    -- Distance
    local distFrame, distLabel = createSetting(settingsContent, 64, "📏 Jarak (studs)", "Max jarak respon dari posisi bot")
    local distSlider = Instance.new("Frame")
    distSlider.Size = UDim2.new(0, 160, 0, 22)
    distSlider.Position = UDim2.new(0, 130, 0, 24)
    distSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    distSlider.BorderSizePixel = 0
    distSlider.Parent = distFrame
    local slideCorner = Instance.new("UICorner")
    slideCorner.CornerRadius = UDim.new(0, 10)
    slideCorner.Parent = distSlider
    
    local distVal = Instance.new("TextLabel")
    distVal.Size = UDim2.new(0, 32, 1, 0)
    distVal.Position = UDim2.new(0, 8, 0, 0)
    distVal.BackgroundTransparency = 1
    distVal.Text = tostring(config.distance)
    distVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    distVal.Font = Enum.Font.GothamBold
    distVal.TextSize = 13
    distVal.Parent = distSlider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -52, 0, 4)
    sliderBar.Position = UDim2.new(0, 44, 0, 9)
    sliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = distSlider
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = sliderBar
    
    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((config.distance - 5) / 45, 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(249, 115, 22)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fillBar
    
    local function updateDistance(x)
        local barSize = sliderBar.AbsoluteSize.X
        local offset = x - sliderBar.AbsolutePosition.X
        local percent = math.clamp(offset / barSize, 0, 1)
        local val = math.round(5 + percent * 45)
        config.distance = val
        distVal.Text = tostring(val)
        fillBar.Size = UDim2.new(percent, 0, 1, 0)
    end
    
    local sliderHit = Instance.new("TextButton")
    sliderHit.Size = UDim2.new(1, 0, 1, 0)
    sliderHit.BackgroundTransparency = 1
    sliderHit.Text = ""
    sliderHit.Parent = distSlider
    
    local dragConnection
    sliderHit.MouseButton1Down:Connect(function()
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateDistance(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragConnection then dragConnection:Disconnect() end
            end
        end)
    end)
    sliderHit.TouchBegan:Connect(function()
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                updateDistance(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                if dragConnection then dragConnection:Disconnect() end
            end
        end)
    end)
    
    -- Personality
    local persFrame, persLabel = createSetting(settingsContent, 128, "🧠 Personality", "Pilih gaya bicara bot")
    local persGrid = Instance.new("Frame")
    persGrid.Size = UDim2.new(1, -10, 0, 80)
    persGrid.Position = UDim2.new(0, 5, 0, 44)
    persGrid.BackgroundTransparency = 1
    persGrid.Parent = persFrame
    
    local persLayout = Instance.new("UIListLayout")
    persLayout.FillDirection = Enum.FillDirection.Horizontal
    persLayout.SortOrder = Enum.SortOrder.LayoutOrder
    persLayout.Padding = UDim.new(0, 6)
    persLayout.Wrap = true
    persLayout.Parent = persGrid
    
    local persButtons = {}
    for key, p in pairs(personalities) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 72, 0, 26)
        btn.BackgroundColor3 = (key == config.personality) and Color3.fromRGB(249, 115, 22) or Color3.fromRGB(50, 50, 50)
        btn.BorderSizePixel = 0
        btn.Text = p.emoji .. " " .. p.label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.Parent = persGrid
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        persButtons[key] = btn
        
        local function select()
            for k, b in pairs(persButtons) do
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(249, 115, 22)
            config.personality = key
        end
        btn.MouseButton1Click:Connect(select)
        btn.TouchEnded:Connect(select)
    end
    
    -- Active toggle
    local activeFrame = Instance.new("Frame")
    activeFrame.Size = UDim2.new(1, -20, 0, 34)
    activeFrame.Position = UDim2.new(0, 10, 0, 218)
    activeFrame.BackgroundTransparency = 1
    activeFrame.Parent = settingsContent
    
    local activeLabel = Instance.new("TextLabel")
    activeLabel.Size = UDim2.new(0, 130, 1, 0)
    activeLabel.BackgroundTransparency = 1
    activeLabel.Text = "🟢 Status Bot"
    activeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    activeLabel.Font = Enum.Font.GothamBold
    activeLabel.TextSize = 14
    activeLabel.TextXAlignment = Enum.TextXAlignment.Left
    activeLabel.Parent = activeFrame
    
    local activeToggle = Instance.new("TextButton")
    activeToggle.Size = UDim2.new(0, 70, 0, 28)
    activeToggle.Position = UDim2.new(0, 140, 0, 3)
    activeToggle.BackgroundColor3 = config.active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    activeToggle.BorderSizePixel = 0
    activeToggle.Text = config.active and "ON" or "OFF"
    activeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeToggle.Font = Enum.Font.GothamBold
    activeToggle.TextSize = 14
    activeToggle.Parent = activeFrame
    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 6)
    togCorner.Parent = activeToggle
    
    local function toggleActive()
        config.active = not config.active
        activeToggle.BackgroundColor3 = config.active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        activeToggle.Text = config.active and "ON" or "OFF"
        dot.BackgroundColor3 = config.active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        indText.Text = "🍊 OrangeBot | " .. executorName .. (config.active and " | ● Online" or " | ● Offline")
    end
    activeToggle.MouseButton1Click:Connect(toggleActive)
    activeToggle.TouchEnded:Connect(toggleActive)
    
    -- ===== CREDITS TAB =====
    local creditsContent = tabContents["credits"]
    local creditFrame = Instance.new("Frame")
    creditFrame.Size = UDim2.new(1, -20, 1, -20)
    creditFrame.Position = UDim2.new(0, 10, 0, 10)
    creditFrame.BackgroundTransparency = 1
    creditFrame.Parent = creditsContent
    
    local creditTitle = Instance.new("TextLabel")
    creditTitle.Size = UDim2.new(1, 0, 0, 40)
    creditTitle.BackgroundTransparency = 1
    creditTitle.Text = "🍊 OrangeBot"
    creditTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    creditTitle.Font = Enum.Font.GothamBold
    creditTitle.TextSize = 24
    creditTitle.Parent = creditFrame
    
    local devLabel = Instance.new("TextLabel")
    devLabel.Size = UDim2.new(1, 0, 0, 30)
    devLabel.Position = UDim2.new(0, 0, 0, 50)
    devLabel.BackgroundTransparency = 1
    devLabel.Text = "Developer: Jepry_jago112"
    devLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    devLabel.Font = Enum.Font.GothamSemibold
    devLabel.TextSize = 18
    devLabel.Parent = creditFrame
    
    local thanksLabel = Instance.new("TextLabel")
    thanksLabel.Size = UDim2.new(1, 0, 0, 50)
    thanksLabel.Position = UDim2.new(0, 0, 0, 90)
    thanksLabel.BackgroundTransparency = 1
    thanksLabel.Text = "Terima kasih telah menggunakan OrangeBot!\nDibangun dengan ❤️ untuk komunitas Roblox."
    thanksLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    thanksLabel.Font = Enum.Font.Gotham
    thanksLabel.TextSize = 14
    thanksLabel.TextWrapped = true
    thanksLabel.Parent = creditFrame
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 20)
    versionLabel.Position = UDim2.new(0, 0, 0, 150)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v2.0 · Personal Chatbot"
    versionLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 12
    versionLabel.Parent = creditFrame
    
    -- ===== TOGGLE MAIN FRAME =====
    local function toggleMain()
        mainFrame.Visible = not mainFrame.Visible
    end
    toggleBtn.MouseButton1Click:Connect(toggleMain)
    toggleBtn.TouchEnded:Connect(toggleMain)
    
    -- =====================================================
    -- 7. GAME CHAT DETECTION (trigger word)
    -- =====================================================
    local function sendGameChat(message)
        local success, err = pcall(function()
            local chatService = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatService then
                local sayRequest = chatService:FindFirstChild("SayMessageRequest")
                if sayRequest then
                    sayRequest:FireServer(message, "All")
                    return
                end
            end
            local chat = game:GetService("Chat")
            if chat and chat:FindFirstChild("Chat") then
                chat:Chat(message)
            else
                warn("Cannot send game chat message.")
            end
        end)
        if not success then
            warn("Failed to send game chat: " .. err)
        end
    end
    
    LocalPlayer.Chatted:Connect(function(msg)
        if not config.active then return end
        local trigger = config.triggerWord:lower()
        local lowerMsg = msg:lower()
        if lowerMsg:sub(1, #trigger) == trigger then
            local query = msg:sub(#trigger + 1):gsub("^%s+", ""):gsub("%s+$", "")
            if query == "" then query = "Halo!" end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - config.botPosition).Magnitude
                if dist > config.distance then
                    local reply = "Maaf, kamu terlalu jauh. Jarak: " .. math.round(dist) .. " (max " .. config.distance .. ")"
                    addChatMessage(reply, false)
                    sendGameChat(reply)
                    return
                end
            end
            addChatMessage(msg, true)
            local reply = getMockResponse(query, config.personality)
            addChatMessage(reply, false)
            sendGameChat(reply)
            chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
        end
    end)
    
    LocalPlayer.Chatted:Connect(function(msg)
        if msg:lower() == "!setbotpos" then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                config.botPosition = char.HumanoidRootPart.Position
                addChatMessage("📍 Posisi bot diatur ke: " .. tostring(config.botPosition), false)
                sendGameChat("Posisi OrangeBot diperbarui!")
            end
        end
    end)
    
    -- =====================================================
    -- 8. INITIAL MESSAGE
    -- =====================================================
    addChatMessage("🍊 OrangeBot siap! Ketik !orange [pesan] di chat game atau gunakan GUI ini.", false)
    addChatMessage("Ketik !setbotpos untuk mengatur posisi bot.", false)
    
    return screenGui, mainFrame, indicator
end

-- =====================================================
-- 9. RUN
-- =====================================================
pcall(function()
    createGUI()
end)

print("🍊 OrangeBot loaded! Executor: " .. executorName)
print("📱 Mobile-friendly GUI aktif. Klik indikator di atas untuk membuka menu.")
