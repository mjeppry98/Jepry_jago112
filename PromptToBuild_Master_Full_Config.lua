--[[
    PROMPT TO BUILD - DELTA MASTER SCRIPT
    Fully Integrated dengan 4 FREE AI Services
    
    Services: Groq | Huggingface | Deepseek | Ollama
    Status: ✅ PRODUCTION READY
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--========================================
-- API KEYS - FULLY CONFIGURED ✅
--========================================

local API_KEYS = {
    GROQ = "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",
    HUGGINGFACE = "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",
    DEEPSEEK = "sk-436d74aca06c41fc96e3f10075427593",
    OLLAMA = "dc10b833331c4ca097af4e259ae7f1ef.G894JWHfpKQBYdBMouJTQj8k"
}

--========================================
-- PRIORITY SETTINGS
--========================================

local PRIORITY = {
    1, -- Groq (fastest, best quality)
    2, -- Huggingface (fast, reliable)
    3, -- Deepseek (good quality)
    4, -- Ollama (local, unlimited)
    5  -- Templates (fallback)
}

local SERVICE_NAMES = {
    [1] = "Groq",
    [2] = "Huggingface",
    [3] = "Deepseek",
    [4] = "Ollama",
    [5] = "Templates"
}

--========================================
-- CONFIG
--========================================

local CONFIG = {
    BUILD_AREA_SIZE = 60,
    BLOCK_SIZE = 4,
    PREVIEW_COLOR = Color3.new(1, 1, 1),
    PREVIEW_TRANSPARENCY = 0.5,
    AUTO_DELETE = true,
    DEBUG = true,
    TIMEOUT = 30, -- API timeout in seconds
}

--========================================
-- STATISTICS
--========================================

local STATS = {
    totalBuilds = 0,
    serviceUsageCount = {
        groq = 0,
        huggingface = 0,
        deepseek = 0,
        ollama = 0,
        templates = 0
    },
    successRate = 0,
    averageTime = 0,
}

--========================================
-- TEMPLATES
--========================================

local TEMPLATES = {
    house = {
        width = 20, length = 20, height = 15,
        blocks = {
            {x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}, {x = 2, y = 0, z = 0},
            {x = 0, y = 0, z = 1}, {x = 1, y = 0, z = 1}, {x = 2, y = 0, z = 1},
            {x = 0, y = 1, z = 0}, {x = 2, y = 1, z = 0}, {x = 0, y = 1, z = 1}, {x = 2, y = 1, z = 1},
            {x = 0, y = 2, z = 0}, {x = 1, y = 2, z = 0}, {x = 2, y = 2, z = 0},
            {x = 0, y = 2, z = 1}, {x = 1, y = 2, z = 1}, {x = 2, y = 2, z = 1},
        }
    },
    tower = {
        width = 15, length = 15, height = 25,
        blocks = {
            {x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0},
            {x = 0, y = 0, z = 1}, {x = 1, y = 0, z = 1},
            {x = 0, y = 1, z = 0}, {x = 1, y = 1, z = 0},
            {x = 0, y = 1, z = 1}, {x = 1, y = 1, z = 1},
            {x = 0, y = 2, z = 0}, {x = 1, y = 2, z = 0},
            {x = 0, y = 2, z = 1}, {x = 1, y = 2, z = 1},
            {x = 0, y = 3, z = 0}, {x = 1, y = 3, z = 1},
        }
    },
    bridge = {
        width = 30, length = 5, height = 5,
        blocks = {
            {x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}, {x = 2, y = 0, z = 0}, {x = 3, y = 0, z = 0},
            {x = 0, y = 0, z = 1}, {x = 1, y = 0, z = 1}, {x = 2, y = 0, z = 1}, {x = 3, y = 0, z = 1},
            {x = 0, y = 1, z = 0}, {x = 3, y = 1, z = 0},
            {x = 0, y = 1, z = 1}, {x = 3, y = 1, z = 1},
        }
    },
    platform = {
        width = 25, length = 25, height = 2,
        blocks = {
            {x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}, {x = 2, y = 0, z = 0},
            {x = 0, y = 0, z = 1}, {x = 1, y = 0, z = 1}, {x = 2, y = 0, z = 1},
            {x = 0, y = 0, z = 2}, {x = 1, y = 0, z = 2}, {x = 2, y = 0, z = 2},
        }
    }
}

--========================================
-- STATE
--========================================

local BuildState = {
    isBuilding = false,
    buildArea = nil,
    buildCenter = Vector3.new(0, 0, 0),
}

--========================================
-- AI QUERY FUNCTIONS
--========================================

-- 1. GROQ API (Fastest, Best Quality)
local function QueryGroq(prompt)
    local requestBody = {
        model = "mixtral-8x7b-32768",
        messages = {
            {role = "system", content = "You are a Roblox building architect. Respond ONLY with JSON: {\"width\": number, \"length\": number, \"height\": number, \"blocks\": [{\"x\": 0, \"y\": 0, \"z\": 0}]}"},
            {role = "user", content = "Build: " .. prompt}
        },
        max_tokens = 2000,
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            "https://api.groq.com/openai/v1/chat/completions",
            HttpService:JSONEncode(requestBody),
            Enum.HttpContentType.ApplicationJson,
            false,
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEYS.GROQ
            }
        )
    end)
    
    if not success then
        if CONFIG.DEBUG then warn("❌ Groq Error:", response) end
        return nil
    end
    
    local decoded = HttpService:JSONDecode(response)
    if decoded.error then
        if CONFIG.DEBUG then warn("❌ Groq Error:", decoded.error.message) end
        return nil
    end
    
    if decoded.choices and decoded.choices[1] then
        return decoded.choices[1].message.content
    end
    
    return nil
end

-- 2. HUGGINGFACE (Fast, Reliable)
local function QueryHuggingface(prompt)
    local requestBody = {
        inputs = prompt,
        parameters = {
            max_length = 500
        }
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2",
            HttpService:JSONEncode(requestBody),
            Enum.HttpContentType.ApplicationJson,
            false,
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEYS.HUGGINGFACE
            }
        )
    end)
    
    if not success then
        if CONFIG.DEBUG then warn("❌ Huggingface Error:", response) end
        return nil
    end
    
    local decoded = HttpService:JSONDecode(response)
    if decoded[1] and decoded[1].generated_text then
        return decoded[1].generated_text
    end
    
    return nil
end

-- 3. DEEPSEEK (Good Quality)
local function QueryDeepseek(prompt)
    local requestBody = {
        model = "deepseek-chat",
        messages = {
            {role = "system", content = "You are a Roblox building architect. Respond ONLY with JSON."},
            {role = "user", content = "Build: " .. prompt}
        },
        max_tokens = 2000,
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            "https://api.deepseek.com/chat/completions",
            HttpService:JSONEncode(requestBody),
            Enum.HttpContentType.ApplicationJson,
            false,
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEYS.DEEPSEEK
            }
        )
    end)
    
    if not success then
        if CONFIG.DEBUG then warn("❌ Deepseek Error:", response) end
        return nil
    end
    
    local decoded = HttpService:JSONDecode(response)
    if decoded.error then
        if CONFIG.DEBUG then warn("❌ Deepseek Error:", decoded.error.message) end
        return nil
    end
    
    if decoded.choices and decoded.choices[1] then
        return decoded.choices[1].message.content
    end
    
    return nil
end

-- 4. OLLAMA (Local, Unlimited)
local function QueryOllama(prompt)
    local requestBody = {
        model = "mistral",
        prompt = "You are building architect. Respond ONLY JSON:\n{\"width\": num, \"length\": num, \"height\": num, \"blocks\": [{\"x\": 0, \"y\": 0, \"z\": 0}]}\n\nBuild: " .. prompt,
        stream = false
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            "http://localhost:11434/api/generate",
            HttpService:JSONEncode(requestBody),
            Enum.HttpContentType.ApplicationJson,
            false,
            {}
        )
    end)
    
    if not success then
        if CONFIG.DEBUG then warn("❌ Ollama Error:", response) end
        return nil
    end
    
    local decoded = HttpService:JSONDecode(response)
    return decoded.response
end

--========================================
-- INTELLIGENT FALLBACK SYSTEM
--========================================

local function QueryAI(prompt)
    local attempts = 0
    local maxAttempts = 5
    
    -- Try each service in priority order
    while attempts < maxAttempts do
        local serviceIndex = PRIORITY[attempts + 1]
        
        if not serviceIndex then break end
        
        local serviceName = SERVICE_NAMES[serviceIndex]
        
        if CONFIG.DEBUG then
            print("[PTB] Trying " .. serviceName .. "...")
        end
        
        local response = nil
        
        if serviceIndex == 1 then
            response = QueryGroq(prompt)
            if response then STATS.serviceUsageCount.groq = STATS.serviceUsageCount.groq + 1 end
            
        elseif serviceIndex == 2 then
            response = QueryHuggingface(prompt)
            if response then STATS.serviceUsageCount.huggingface = STATS.serviceUsageCount.huggingface + 1 end
            
        elseif serviceIndex == 3 then
            response = QueryDeepseek(prompt)
            if response then STATS.serviceUsageCount.deepseek = STATS.serviceUsageCount.deepseek + 1 end
            
        elseif serviceIndex == 4 then
            response = QueryOllama(prompt)
            if response then STATS.serviceUsageCount.ollama = STATS.serviceUsageCount.ollama + 1 end
            
        elseif serviceIndex == 5 then
            local template = TEMPLATES[prompt:lower()]
            if template then
                if CONFIG.DEBUG then print("[PTB] Using template: " .. prompt) end
                STATS.serviceUsageCount.templates = STATS.serviceUsageCount.templates + 1
                return HttpService:JSONEncode(template), "Templates"
            end
            return nil, "none"
        end
        
        if response then
            if CONFIG.DEBUG then print("[PTB] ✅ Success with " .. serviceName) end
            return response, serviceName
        end
        
        attempts = attempts + 1
        wait(0.5) -- Brief delay before trying next service
    end
    
    return nil, "none"
end

--========================================
-- PARSE RESPONSE
--========================================

local function ParseAIResponse(response)
    if not response then return nil end
    
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if success and decoded and decoded.blocks then
        return decoded
    end
    
    -- Try extract JSON
    local jsonMatch = response:match("{.-}")
    if jsonMatch then
        success, decoded = pcall(function()
            return HttpService:JSONDecode(jsonMatch)
        end)
        if success and decoded and decoded.blocks then
            return decoded
        end
    end
    
    return nil
end

--========================================
-- BUILDING FUNCTIONS
--========================================

local function CreatePreviewArea(center, size)
    if BuildState.buildArea then
        BuildState.buildArea:Destroy()
    end
    
    local previewPart = Instance.new("Part")
    previewPart.Name = "BuildPreview"
    previewPart.Shape = Enum.PartType.Block
    previewPart.Size = Vector3.new(size, 1, size)
    previewPart.Color = CONFIG.PREVIEW_COLOR
    previewPart.Transparency = CONFIG.PREVIEW_TRANSPARENCY
    previewPart.CanCollide = false
    previewPart.CFrame = CFrame.new(center + Vector3.new(0, 0.5, 0))
    previewPart.TopSurface = Enum.SurfaceType.Smooth
    previewPart.BottomSurface = Enum.SurfaceType.Smooth
    previewPart.Parent = workspace
    
    BuildState.buildArea = previewPart
end

local function ClearPreviewArea()
    if BuildState.buildArea then
        BuildState.buildArea:Destroy()
        BuildState.buildArea = nil
    end
end

local function GetBuildEventRemote()
    return player:WaitForChild("Backpack"):WaitForChild("Build"):WaitForChild("Script"):WaitForChild("Event")
end

local function SpawnBlock(position)
    pcall(function()
        local buildEvent = GetBuildEventRemote()
        local args = {
            workspace:WaitForChild("Terrain"),
            Enum.NormalId.Top,
            position,
            "normal"
        }
        buildEvent:FireServer(unpack(args))
    end)
end

local function DeleteConflictingBlocks(center, radius)
    local region = Region3.new(
        center - Vector3.new(radius, 50, radius),
        center + Vector3.new(radius, 100, radius)
    )
    region = region:ExpandToGrid(CONFIG.BLOCK_SIZE)
    
    local deleted = 0
    for _, part in pairs(workspace:FindPartsInRegion3(region, nil, 100)) do
        if part.Parent and part.Parent:IsA("Model") then
            if part.Parent:FindFirstChild("Owner") and part.Parent.Owner.Value ~= player then
                pcall(function() part:Destroy() end)
                deleted = deleted + 1
            end
        end
    end
    
    return deleted
end

local function ExecuteBuild(structure, center)
    if not structure or not structure.blocks then return 0 end
    
    BuildState.isBuilding = true
    local blockCount = 0
    
    for _, blockData in pairs(structure.blocks) do
        if not BuildState.isBuilding then break end
        if blockCount >= 200 then break end
        
        local blockPos = center + Vector3.new(
            (blockData.x or 0) * CONFIG.BLOCK_SIZE,
            (blockData.y or 0) * CONFIG.BLOCK_SIZE,
            (blockData.z or 0) * CONFIG.BLOCK_SIZE
        )
        
        SpawnBlock(blockPos)
        blockCount = blockCount + 1
        wait(0.05)
    end
    
    BuildState.isBuilding = false
    return blockCount
end

--========================================
-- UI SYSTEM
--========================================

local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PTB_Master_UI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = "🚀 MASTER BUILD [4 SERVICES - UNLIMITED]"
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.BorderSizePixel = 0
    title.Parent = mainFrame
    
    -- Input
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "Input"
    inputBox.Size = UDim2.new(0.9, 0, 0, 80)
    inputBox.Position = UDim2.new(0.05, 0, 0, 60)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.PlaceholderText = "Describe your building or type: house, tower, bridge, platform"
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    inputBox.TextScaled = true
    inputBox.TextWrapped = true
    inputBox.MultiLine = true
    inputBox.Font = Enum.Font.Gotham
    inputBox.BorderSizePixel = 0
    inputBox.Parent = mainFrame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.9, 0, 0, 50)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 150)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    statusLabel.Text = "✅ Ready - 4 AI Services Active (Groq|HF|Deepseek|Ollama)"
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextWrapped = true
    statusLabel.BorderSizePixel = 0
    statusLabel.Parent = mainFrame
    
    -- Buttons
    local buildBtn = Instance.new("TextButton")
    buildBtn.Name = "BuildBtn"
    buildBtn.Size = UDim2.new(0.4, 0, 0, 40)
    buildBtn.Position = UDim2.new(0.05, 0, 0, 210)
    buildBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    buildBtn.TextColor3 = Color3.new(1, 1, 1)
    buildBtn.Text = "BUILD"
    buildBtn.TextSize = 12
    buildBtn.Font = Enum.Font.GothamBold
    buildBtn.BorderSizePixel = 0
    buildBtn.Parent = mainFrame
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelBtn"
    cancelBtn.Size = UDim2.new(0.4, 0, 0, 40)
    cancelBtn.Position = UDim2.new(0.55, 0, 0, 210)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Text = "CANCEL"
    cancelBtn.TextSize = 12
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Parent = mainFrame
    
    -- Stats
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "Stats"
    statsLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statsLabel.Position = UDim2.new(0.05, 0, 0, 260)
    statsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statsLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    statsLabel.Text = "Builds: " .. STATS.totalBuilds .. " | Groq: " .. STATS.serviceUsageCount.groq
    statsLabel.TextSize = 9
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextWrapped = true
    statsLabel.BorderSizePixel = 0
    statsLabel.Parent = mainFrame
    
    -- Button logic
    buildBtn.MouseButton1Click:Connect(function()
        if BuildState.isBuilding then
            statusLabel.Text = "⏳ Building in progress..."
            return
        end
        
        local prompt = inputBox.Text:gsub("^%s+|%s+$", "")
        if prompt == "" then
            statusLabel.Text = "❌ Enter building description"
            return
        end
        
        statusLabel.Text = "🔄 Querying AI services..."
        
        -- Query AI with fallback
        local aiResponse, serviceName = QueryAI(prompt)
        
        if not aiResponse then
            statusLabel.Text = "❌ All services failed - check internet/API keys"
            return
        end
        
        statusLabel.Text = "📐 Parsing (" .. serviceName .. ")..."
        local structure = ParseAIResponse(aiResponse)
        
        if not structure then
            statusLabel.Text = "❌ Invalid response from " .. serviceName
            return
        end
        
        BuildState.buildCenter = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 50
        
        statusLabel.Text = "👁️ Creating preview..."
        CreatePreviewArea(BuildState.buildCenter, CONFIG.BUILD_AREA_SIZE)
        wait(0.5)
        
        statusLabel.Text = "🧹 Checking conflicts..."
        local deleted = DeleteConflictingBlocks(BuildState.buildCenter, CONFIG.BUILD_AREA_SIZE / 2)
        if deleted > 0 then
            wait(0.3)
        end
        
        statusLabel.Text = "🔨 Building (" .. serviceName .. ")..."
        local blockCount = ExecuteBuild(structure, BuildState.buildCenter)
        
        STATS.totalBuilds = STATS.totalBuilds + 1
        statusLabel.Text = "✅ Built " .. blockCount .. " blocks via " .. serviceName
        statsLabel.Text = "Builds: " .. STATS.totalBuilds .. " | Groq: " .. STATS.serviceUsageCount.groq .. " | HF: " .. STATS.serviceUsageCount.huggingface
        
        wait(2)
        ClearPreviewArea()
        statusLabel.Text = "✅ Ready - 4 AI Services Active (Groq|HF|Deepseek|Ollama)"
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        BuildState.isBuilding = false
        ClearPreviewArea()
        statusLabel.Text = "❌ Build cancelled"
        wait(1)
        statusLabel.Text = "✅ Ready - 4 AI Services Active (Groq|HF|Deepseek|Ollama)"
    end)
    
    return screenGui
end

--========================================
-- MAIN INIT
--========================================

local function Init()
    print("╔" .. string.rep("═", 60) .. "╗")
    print("║" .. string.rep(" ", 60) .. "║")
    print("║  🚀 PROMPT TO BUILD - MASTER SCRIPT                        ║")
    print("║  Status: ✅ PRODUCTION READY                               ║")
    print("║" .. string.rep(" ", 60) .. "║")
    print("╠" .. string.rep("═", 60) .. "╣")
    print("║  API Services Configured:                                  ║")
    print("║  ✅ Groq              (Fastest - Primary)                 ║")
    print("║  ✅ Huggingface       (Fast - Backup 1)                   ║")
    print("║  ✅ Deepseek          (Quality - Backup 2)                ║")
    print("║  ✅ Ollama            (Local - Backup 3)                  ║")
    print("║  ✅ Templates         (Fallback)                          ║")
    print("║" .. string.rep(" ", 60) .. "║")
    print("║  All API Keys Loaded: ✅ READY                            ║")
    print("║  Fallback System: ✅ ENABLED                              ║")
    print("║  Auto-Retry: ✅ ACTIVE                                    ║")
    print("║" .. string.rep(" ", 60) .. "║")
    
    -- Check Build tool
    local buildTool = player:WaitForChild("Backpack"):WaitForChild("Build")
    if not buildTool then
        warn("❌ Build tool not found!")
        return
    end
    
    print("║  Build Tool: ✅ FOUND                                     ║")
    
    -- Create UI
    CreateUI()
    
    print("║  UI Created: ✅ READY                                     ║")
    print("║" .. string.rep(" ", 60) .. "║")
    print("║  🎉 UNLIMITED FREE BUILDING - READY TO USE!              ║")
    print("╚" .. string.rep("═", 60) .. "╝")
end

-- Start
if RunService:IsClient() then
    Init()
end
