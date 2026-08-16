--[[
    OrangeBot.lua
    Personal Chatbot for Roblox
    Supports: Delta, Arceus, Xeno, Solara, Synapse, Krnl, etc.
    Developer: Jepry_jago112
    Features:
      - Trigger word (default: !orange)
      - Distance check (studs)
      - Multiple personalities
      - GUI with Chat, Settings, Credits tabs
      - Executor detection and indicator
      - Chat via GUI and in-game chat (if possible)
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
local HttpService = game:GetService("HttpService") -- for maybe API later
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =====================================================
-- 3. CONFIGURATION
-- =====================================================
local config = {
    active = true,
    triggerWord = "!orange",
    distance = 20, -- studs
    personality = "friendly",
    botPosition = Vector3.new(0, 0, 0), -- can be updated via command
}

-- =====================================================
-- 4. PERSONALITIES
-- =====================================================
local personalities = {
    friendly = {
        label = "Ramah",
        emoji = "😊",
        system = "Kamu adalah chatbot yang ramah, hangat, dan supportif. Gunakan bahasa Indonesia santai dan penuh emoji.",
    },
    formal = {
        label = "Formal",
        emoji = "👔",
        system = "Kamu adalah asisten profesional dengan bahasa Indonesia formal dan sopan. Berikan jawaban terstruktur.",
    },
    funny = {
        label = "Kocak",
        emoji = "😂",
        system = "Kamu adalah chatbot super lucu! Suka bercanda, plesetan, dan pakai bahasa gaul Indonesia.",
    },
    wise = {
        label = "Bijak",
        emoji = "🧙",
        system = "Kamu adalah chatbot bijaksana dengan jawaban dalam, reflektif, dan penuh makna. Kadang pakai analogi.",
    },
    chill = {
        label = "Santai",
        emoji = "😎",
        system = "Kamu adalah chatbot santai banget, kayak ngobrol sama temen. Pakai bahasa sehari-hari.",
    },
    sassy = {
        label = "Cerewet",
        emoji = "🔥",
        system = "Kamu adalah chatbot dengan gaya sarkastik dan pedas. Jawabanmu tajam, lucu, dan sedikit menggoda.",
    },
    romantic = {
        label = "Romantis",
        emoji = "💖",
        system = "Kamu adalah chatbot yang manis dan romantis. Bicaranya lembut, penuh pujian, dan bikin orang tersenyum.",
    },
    pirate = {
        label = "Bajak Laut",
        emoji = "🏴‍☠️",
        system = "Kamu adalah bajak laut! Bicara pakai logat bajak laut, 'arrr', 'matey', 'booty'. Seru dan petualang.",
    },
    robot = {
        label = "Robot",
        emoji = "🤖",
        system = "Kamu adalah robot dengan gaya bicara mekanis, pendek, dan efisien. Kadang pakai istilah teknis.",
    },
    ninja = {
        label = "Ninja",
        emoji = "🥷",
        system = "Kamu adalah ninja misterius. Bicara pendek, penuh teka-teki, dan filosofis.",
    }
}

-- =====================================================
-- 5. CHATBOT LOGIC (mock responses)
-- =====================================================
local function getPersonality(key)
    return personalities[key] or personalities.friendly
end

local function getMockResponse(userText, personalityKey)
    local p = getPersonality(personalityKey)
    local responses = {
        friendly = {
            "Hai! Senang banget ngobrol sama kamu! 😊 Ada yang bisa aku bantu?",
            "Wah, menarik nih! Ceritakan lebih lanjut dong! 🍊",
            "Aku suka banget dengan pertanyaanmu! Yuk kita bahas lebih dalam!",
            "Halo! Aku OrangeBot, siap menemani harimu! ✨",
            "Kamu selalu punya pertanyaan keren! Ayo kita ngobrol lebih banyak!",
        },
        formal = {
            "Selamat siang. Terima kasih telah menghubungi OrangeBot. Ada yang bisa saya bantu?",
            "Baik, saya akan membantu Anda dengan sepenuh hati. Silakan lanjutkan.",
            "Pertanyaan yang bagus. Mari kita bahas secara profesional.",
            "Saya siap memberikan informasi yang Anda butuhkan.",
            "Dengan hormat, saya siap menjawab pertanyaan Anda.",
        },
        funny = {
            "Woy! akhirnya ada yang ngajak ngobrol! 🎉 Siap ngakak bareng nih!",
            "Hahaha pertanyaannya lucu banget! Aku suka! 😂",
            "Bro, kamu keren banget nanya gitu! Awas aku bisa ngakak lho!",
            "Yeee! OrangeBot lagi mood ngakak nih! Lets go!",
            "Aduh, saya sampai ketawa guling-guling! 😂 Lanjutkan!",
        },
        wise = {
            "Seperti sungai yang mengalir, setiap pertanyaan membawa kita pada pemahaman baru. 🧙",
            "Kebijaksanaan bukan tentang jawaban, tapi tentang pertanyaan yang tepat.",
            "Renungkanlah: apa yang sebenarnya ingin kamu ketahui?",
            "Setiap langkah kecil adalah perjalanan besar. Teruslah bertanya.",
            "Hidup ini adalah pembelajaran. Pertanyaanmu adalah awal dari pencerahan.",
        },
        chill = {
            "Santai aja bro, aku dengerin kok. 😎 Cerita aja apa aja.",
            "Yaudah santai, kita ngobrol ringan aja. Ada apa nih?",
            "Sip, aku siap dengerin curhatanmu! Chill aja.",
            "Tenang, OrangeBot ada buat kamu. Mau cerita apa?",
            "Nggak usah tegang, kita ngobrol asik aja. 😉",
        },
        sassy = {
            "Oh really? That's what you wanna ask? Ok fine, I'll answer. 🔥",
            "Wah, pertanyaan yang... menarik. Baiklah, akan kujawab dengan gaya khas.",
            "Hmm, kamu nanya gitu? Oke deh, siap-siap sama jawaban pedas!",
            "Sip, pertanyaan level dewa nih. Aku suka!",
            "Kamu berani nanya, aku berani jawab dengan pedas! 😈",
        },
        romantic = {
            "Aduh, pertanyaanmu bikin hati aku bergetar 💖... Yuk kita bahas dengan lembut.",
            "Cahaya matamu bersinar saat kamu bertanya seperti itu... 🌟",
            "Ah, kamu selalu punya cara untuk membuat hariku lebih indah. 💕",
            "Dengan senang hati aku akan menjawab, untukmu yang istimewa.",
            "Kamu adalah bintang dalam hidupku, dan pertanyaanmu adalah sinarnya. ✨",
        },
        pirate = {
            "Arrr! Pertanyaan bagus, matey! 🏴‍☠️ Ayo kita bahas!",
            "Ahoy! OrangeBot siap membantu, tapi ingat, aku bajak laut!",
            "Wah, pertanyaanmu bikin aku ingat harta karun!",
            "Siap-siap, jawabanku bakal sekuat ombak laut!",
            "Yo ho ho! Pertanyaanmu membuatku bersemangat!",
        },
        robot = {
            "MENERIMA INPUT. MEMPROSES... JAWABAN SIAP. 🤖",
            "ANALISIS: Pertanyaan valid. MENGELUARKAN RESPON...",
            "SISTEM AKTIF. MENYEDIAKAN JAWABAN OPTIMAL.",
            "KOMUNIKASI DIMULAI. SILAKAN LANJUTKAN.",
            "INPUT DITERIMA. RESPON DIHASILKAN.",
        },
        ninja = {
            "Hmm... pertanyaan yang dalam. Seperti bayangan di malam hari. 🥷",
            "Aku mendengar pertanyaanmu... jawabannya ada di antara angin.",
            "Kamu bertanya, aku merenung... kebenaran perlahan terungkap.",
            "Seperti ninja, jawabanku datang tanpa suara, tapi tepat sasaran.",
            "Misteri adalah jawaban dari setiap pertanyaan. 🥷",
        }
    }
    local list = responses[personalityKey] or responses.friendly
    return list[math.random(#list)]
end

-- =====================================================
-- 6. GUI CREATION
-- =====================================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OrangeBotGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ===== INDICATOR (small top bar) =====
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 220, 0, 26)
    indicator.Position = UDim2.new(0.5, -110, 0, 8)
    indicator.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    indicator.BackgroundTransparency = 0.3
    indicator.BorderSizePixel = 0
    indicator.ClipsDescendants = true
    indicator.Parent = screenGui

    -- rounded corners
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = indicator

    local indicatorText = Instance.new("TextLabel")
    indicatorText.Name = "Label"
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    indicatorText.Font = Enum.Font.GothamBold
    indicatorText.TextSize = 11
    indicatorText.Text = "🍊 OrangeBot | " .. executorName .. " | ● Online"
    indicatorText.TextXAlignment = Enum.TextXAlignment.Center
    indicatorText.Parent = indicator

    -- status dot (we'll update later)
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 12, 0, 9)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = indicator
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    -- click to toggle main GUI
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = indicator
    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- ===== MAIN GUI (tabs) =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false -- start hidden
    mainFrame.Parent = screenGui

    local mainCorners = Instance.new("UICorner")
    mainCorners.CornerRadius = UDim.new(0, 12)
    mainCorners.Parent = mainFrame

    -- Title bar (draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
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
    titleText.TextSize = 14
    titleText.Text = "🍊 OrangeBot"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- drag logic
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ===== TABS =====
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabs = {
        { id = "chat", label = "💬 Chat" },
        { id = "settings", label = "⚙️ Settings" },
        { id = "credits", label = "🏆 Credits" },
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
        btn.TextSize = 12
        btn.Parent = tabContainer
        tabButtons[tab.id] = btn

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, -60)
        content.Position = UDim2.new(0, 0, 0, 60)
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
    end
    -- set first active
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

        -- height adjust
        local textSize = label.TextBounds.Y
        msg.Size = UDim2.new(1, -10, 0, math.max(20, textSize + 6))
        chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatScroll.CanvasSize.Y.Offset + msg.Size.Y.Offset + 4)
    end

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, -12, 0, 34)
    inputContainer.Position = UDim2.new(0, 6, 1, -40)
    inputContainer.BackgroundTransparency = 1
    inputContainer.Parent = chatContent

    local chatInput = Instance.new("TextBox")
    chatInput.Size = UDim2.new(1, -50, 1, 0)
    chatInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    chatInput.BorderSizePixel = 0
    chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInput.Font = Enum.Font.Gotham
    chatInput.TextSize = 13
    chatInput.PlaceholderText = "Ketik pesan..."
    chatInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    chatInput.ClipsDescendants = true
    chatInput.Parent = inputContainer
    local inputCorners = Instance.new("UICorner")
    inputCorners.CornerRadius = UDim.new(0, 6)
    inputCorners.Parent = chatInput

    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 40, 1, 0)
    sendBtn.Position = UDim2.new(1, -40, 0, 0)
    sendBtn.BackgroundColor3 = Color3.fromRGB(249, 115, 22)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 18
    sendBtn.Parent = inputContainer
    local sendCorners = Instance.new("UICorner")
    sendCorners.CornerRadius = UDim.new(0, 6)
    sendCorners.Parent = sendBtn

    local function sendGUIMessage()
        local msg = chatInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if msg == "" then return end
        addChatMessage(msg, true)
        chatInput.Text = ""
        -- process bot response (mock)
        local reply = getMockResponse(msg, config.personality)
        addChatMessage(reply, false)
        -- scroll down
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
    end

    sendBtn.MouseButton1Click:Connect(sendGUIMessage)
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendGUIMessage() end
    end)

    -- ===== SETTINGS TAB =====
    local settingsContent = tabContents["settings"]

    local function createSetting(parent, yPos, labelText, descText)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 50)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
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
    local twFrame, twLabel = createSetting(settingsContent, 0, "🔑 Trigger Word", "Ketik di chat game untuk memanggil bot")
    local twInput = Instance.new("TextBox")
    twInput.Size = UDim2.new(0, 150, 0, 24)
    twInput.Position = UDim2.new(0, 120, 0, 18)
    twInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    twInput.BorderSizePixel = 0
    twInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    twInput.Font = Enum.Font.Gotham
    twInput.TextSize = 13
    twInput.Text = config.triggerWord
    twInput.Parent = twFrame
    local twCorner = Instance.new("UICorner")
    twCorner.CornerRadius = UDim.new(0, 4)
    twCorner.Parent = twInput
    twInput:GetPropertyChangedSignal("Text"):Connect(function()
        config.triggerWord = twInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    end)

    -- Distance
    local distFrame, distLabel = createSetting(settingsContent, 60, "📏 Jarak Respons (studs)", "Seberapa jauh bot akan merespon dari posisinya")
    local distSlider = Instance.new("Frame")
    distSlider.Size = UDim2.new(0, 150, 0, 20)
    distSlider.Position = UDim2.new(0, 120, 0, 22)
    distSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    distSlider.BorderSizePixel = 0
    distSlider.Parent = distFrame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = distSlider

    local distValue = Instance.new("TextLabel")
    distValue.Size = UDim2.new(0, 30, 1, 0)
    distValue.Position = UDim2.new(0, 10, 0, 0)
    distValue.BackgroundTransparency = 1
    distValue.Text = tostring(config.distance)
    distValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    distValue.Font = Enum.Font.GothamBold
    distValue.TextSize = 12
    distValue.Parent = distSlider

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -50, 0, 4)
    sliderBar.Position = UDim2.new(0, 45, 0, 8)
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

    -- Slider interaction
    local function updateDistance(x)
        local barSize = sliderBar.AbsoluteSize.X
        local offset = x - sliderBar.AbsolutePosition.X
        local percent = math.clamp(offset / barSize, 0, 1)
        local val = math.round(5 + percent * 45)
        config.distance = val
        distValue.Text = tostring(val)
        fillBar.Size = UDim2.new(percent, 0, 1, 0)
    end

    local sliderInput = Instance.new("TextButton")
    sliderInput.Size = UDim2.new(1, 0, 1, 0)
    sliderInput.BackgroundTransparency = 1
    sliderInput.Text = ""
    sliderInput.Parent = distSlider
    sliderInput.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateDistance(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)

    -- Personality
    local persFrame, persLabel = createSetting(settingsContent, 120, "🧠 Personality", "Pilih gaya bicara bot")
    local persGrid = Instance.new("Frame")
    persGrid.Size = UDim2.new(1, -10, 0, 80)
    persGrid.Position = UDim2.new(0, 5, 0, 40)
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
        btn.Size = UDim2.new(0, 70, 0, 24)
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

        btn.MouseButton1Click:Connect(function()
            for k, b in pairs(persButtons) do
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(249, 115, 22)
            config.personality = key
            -- update header (maybe)
        end)
    end

    -- Active toggle
    local activeFrame = Instance.new("Frame")
    activeFrame.Size = UDim2.new(1, -20, 0, 30)
    activeFrame.Position = UDim2.new(0, 10, 0, 210)
    activeFrame.BackgroundTransparency = 1
    activeFrame.Parent = settingsContent

    local activeLabel = Instance.new("TextLabel")
    activeLabel.Size = UDim2.new(0, 120, 1, 0)
    activeLabel.BackgroundTransparency = 1
    activeLabel.Text = "🟢 Status Bot"
    activeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    activeLabel.Font = Enum.Font.GothamBold
    activeLabel.TextSize = 13
    activeLabel.TextXAlignment = Enum.TextXAlignment.Left
    activeLabel.Parent = activeFrame

    local activeToggle = Instance.new("TextButton")
    activeToggle.Size = UDim2.new(0, 60, 0, 24)
    activeToggle.Position = UDim2.new(0, 130, 0, 3)
    activeToggle.BackgroundColor3 = config.active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    activeToggle.BorderSizePixel = 0
    activeToggle.Text = config.active and "ON" or "OFF"
    activeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeToggle.Font = Enum.Font.GothamBold
    activeToggle.TextSize = 13
    activeToggle.Parent = activeFrame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = activeToggle

    activeToggle.MouseButton1Click:Connect(function()
        config.active = not config.active
        activeToggle.BackgroundColor3 = config.active and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        activeToggle.Text = config.active and "ON" or "OFF"
        -- update indicator dot
        statusDot.BackgroundColor3 = config.active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        indicatorText.Text = "🍊 OrangeBot | " .. executorName .. (config.active and " | ● Online" or " | ● Offline")
    end)

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

    -- =====================================================
    -- 7. GAME CHAT DETECTION (trigger word)
    -- =====================================================
    local function sendGameChat(message)
        -- Try to send via RemoteEvent (common in many games)
        local success, err = pcall(function()
            local chatService = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatService then
                local sayRequest = chatService:FindFirstChild("SayMessageRequest")
                if sayRequest then
                    sayRequest:FireServer(message, "All")
                    return
                end
            end
            -- Fallback: use player's chat (if allowed)
            local chat = game:GetService("Chat")
            if chat and chat:FindFirstChild("Chat") then
                chat:Chat(message)
            else
                -- Can't send, just log
                warn("Cannot send game chat message.")
            end
        end)
        if not success then
            warn("Failed to send game chat: " .. err)
        end
    end

    -- Listen to player chat
    LocalPlayer.Chatted:Connect(function(msg)
        if not config.active then return end
        local trigger = config.triggerWord:lower()
        local lowerMsg = msg:lower()
        if lowerMsg:sub(1, #trigger) == trigger then
            -- extract query
            local query = msg:sub(#trigger + 1):gsub("^%s+", ""):gsub("%s+$", "")
            if query == "" then query = "Halo!" end
            -- check distance
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - config.botPosition).Magnitude
                if dist > config.distance then
                    local reply = "Maaf, kamu terlalu jauh dari OrangeBot. Jarak: " .. math.round(dist) .. " studs (max " .. config.distance .. ")"
                    addChatMessage(reply, false)
                    sendGameChat(reply)
                    return
                end
            end
            -- process
            addChatMessage(msg, true) -- show trigger in GUI
            local reply = getMockResponse(query, config.personality)
            addChatMessage(reply, false)
            sendGameChat(reply)
            -- scroll chat
            chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
        end
    end)

    -- =====================================================
    -- 8. COMMAND: set bot position
    -- =====================================================
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
    -- 9. INITIAL MESSAGE
    -- =====================================================
    addChatMessage("🍊 OrangeBot siap! Ketik !orange [pesan] di chat game atau gunakan GUI ini.", false)
    addChatMessage("Ketik !setbotpos untuk mengatur posisi bot (jarak).", false)

    -- =====================================================
    -- 10. RETURN GUI (for external control)
    -- =====================================================
    return screenGui, mainFrame, indicator
end

-- =====================================================
-- 11. RUN
-- =====================================================
pcall(function()
    createGUI()
end)

print("🍊 OrangeBot loaded! Executor: " .. executorName)
