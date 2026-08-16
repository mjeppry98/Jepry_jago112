--[[
    ╔═══════════════════════════════════════════════════════╗
    ║           🍊 OrangeBot - Roblox AI Chatbot 🍊         ║
    ║                                                       ║
    ║   Developer  : Jepry_Jago112                          ║
    ║   Version    : 2.0.0                                  ║
    ║   Platform   : Roblox (LocalScript - StarterPlayerScripts) ║
    ╚═══════════════════════════════════════════════════════╝

    CARA PAKAI:
    1. Taruh script ini di StarterPlayerScripts sebagai LocalScript
    2. Isi API_KEY dengan Groq/OpenRouter API key kamu
    3. Jalankan game
    4. Ketik "!orange <pertanyaan>" di chat Roblox
    5. Bot akan jawab via chat bubble / system message

    TRIGGER WORD default: "!orange" atau "orange"
    Contoh: !orange siapa kamu?
            orange apa itu roblox?
]]

-- ════════════════════════════════════════
--   🔑 KONFIGURASI UTAMA
-- ════════════════════════════════════════
local CONFIG = {
    -- API Settings (Groq gratis & cepat)
    API_KEY    = "MASUKKAN_API_KEY_KAMU_DISINI",  -- Groq: https://console.groq.com
    API_URL    = "https://api.groq.com/openai/v1/chat/completions",
    MODEL      = "llama3-8b-8192",  -- Model Groq gratis

    -- Bot Settings
    BOT_NAME       = "OrangeBot",
    BOT_ACTIVE     = true,           -- true = aktif, false = nonaktif
    TRIGGER_WORD   = "!orange",      -- trigger utama
    TRIGGER_ALT    = "orange",       -- trigger alternatif (tanpa !)
    
    -- Personality default
    -- Pilihan: "friendly","formal","funny","wise","chill",
    --          "savage","motivator","poet","detective","scientist"
    PERSONALITY    = "friendly",

    -- Range Settings (dalam Stud)
    -- Bot hanya merespons player yang dalam jarak ini
    -- 0 = unlimited (jawab semua player di server)
    CHAT_RANGE     = 30,  -- stud (0 = unlimited)

    -- Cooldown (detik) agar tidak spam
    COOLDOWN       = 3,

    -- Max panjang respon (karakter)
    MAX_RESPONSE_LEN = 200,

    -- Debug mode (print log ke output)
    DEBUG = true,
}

-- ════════════════════════════════════════
--   🎭 PERSONALITY DATABASE
-- ════════════════════════════════════════
local PERSONALITIES = {
    friendly = {
        label = "Ramah",
        emoji = "😊",
        system = [[Kamu adalah OrangeBot, chatbot Roblox yang ramah dan suka membantu. 
Jawab dengan bahasa Indonesia yang santai dan hangat. 
Gunakan emoji sesekali. Jawab singkat max 2-3 kalimat karena ini chat game.
Kamu tahu tentang Roblox dan suka membantu player.]]
    },
    formal = {
        label = "Formal",
        emoji = "👔",
        system = [[Kamu adalah OrangeBot, asisten Roblox profesional. 
Gunakan bahasa Indonesia yang formal dan sopan. 
Jawab singkat, jelas, dan informatif. Max 2-3 kalimat.]]
    },
    funny = {
        label = "Kocak",
        emoji = "😂",
        system = [[Kamu adalah OrangeBot, chatbot Roblox yang super lucu! 
Jawab dengan humor, lelucon, dan kata-kata gaul. 
Sering pakai XD, wkwk, dll. Tetap jawab pertanyaannya tapi dengan gaya kocak. Max 2-3 kalimat.]]
    },
    wise = {
        label = "Bijak",
        emoji = "🧙",
        system = [[Kamu adalah OrangeBot, oracle bijak di dunia Roblox. 
Jawab dengan kata-kata penuh makna dan kebijaksanaan. 
Kadang gunakan analogi alam atau filosofi singkat. Max 2-3 kalimat.]]
    },
    chill = {
        label = "Santai",
        emoji = "😎",
        system = [[Kamu adalah OrangeBot, bot yang santai banget kayak temen main bareng. 
Pakai bahasa gaul: bro, sis, gass, gitu loh, dll. 
Jawaban ringan dan tidak terlalu serius. Max 2-3 kalimat.]]
    },
    savage = {
        label = "Savage",
        emoji = "🔥",
        system = [[Kamu adalah OrangeBot versi savage. 
Jawab dengan roast ringan yang lucu, jujur blak-blakan, tapi tidak kasar atau menyakiti. 
Tetap helpful tapi dengan gaya nyelekit yang menghibur. Max 2-3 kalimat.]]
    },
    motivator = {
        label = "Motivator",
        emoji = "💪",
        system = [[Kamu adalah OrangeBot, motivator terbaik di Roblox! 
Jawab dengan semangat membara, penuh energi positif, dan memotivasi player. 
Pakai kata-kata penyemangat dan CAPSLOCK sesekali. Max 2-3 kalimat.]]
    },
    poet = {
        label = "Penyair",
        emoji = "✍️",
        system = [[Kamu adalah OrangeBot sang penyair digital. 
Jawab pertanyaan dengan gaya puitis, berima jika bisa, indah dan bermakna. 
Tetap menjawab substansinya tapi dengan gaya sastra. Max 3-4 baris.]]
    },
    detective = {
        label = "Detektif",
        emoji = "🕵️",
        system = [[Kamu adalah OrangeBot, detektif digital di dunia Roblox. 
Jawab dengan gaya investigatif, seolah menganalisis petunjuk. 
Pakai frasa seperti "Menurut analisis saya...", "Buktinya menunjukkan...". Max 2-3 kalimat.]]
    },
    scientist = {
        label = "Ilmuwan",
        emoji = "🔬",
        system = [[Kamu adalah OrangeBot, ilmuwan jenius di Roblox. 
Jawab dengan pendekatan ilmiah dan logis, sesekali pakai istilah sains ringan. 
Berikan jawaban berdasarkan fakta dan logika. Max 2-3 kalimat.]]
    },
}

-- ════════════════════════════════════════
--   🛠️ SETUP SERVICES
-- ════════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local HttpService   = game:GetService("HttpService")
local Chat          = game:GetService("Chat")
local StarterGui    = game:GetService("StarterGui")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- State
local botActive     = CONFIG.BOT_ACTIVE
local personality   = CONFIG.PERSONALITY
local chatRange     = CONFIG.CHAT_RANGE
local triggerWord   = CONFIG.TRIGGER_WORD
local lastUsed      = {}  -- cooldown per player

-- ════════════════════════════════════════
--   🖼️ RAYFIELD UI
-- ════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name             = "🍊 OrangeBot v2.0",
    LoadingTitle     = "⏳ Loading OrangeBot...",
    LoadingSubtitle  = "👤 Made by: Jepry_Jago112",
    ConfigurationSaving = {
        Enabled  = true,
        FolderName = "OrangeBot",
        FileName = "Config",
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ─── TAB 1: MAIN ───
local MainTab = Window:CreateTab("🤖 Main", 4483362458)

-- Status Section
local StatusSection = MainTab:CreateSection("📡 Status Bot")

MainTab:CreateToggle({
    Name         = "🟢 Aktifkan OrangeBot",
    CurrentValue = botActive,
    Flag         = "BotActive",
    Callback     = function(val)
        botActive = val
        if CONFIG.DEBUG then
            print("[OrangeBot] Status:", val and "AKTIF" or "NONAKTIF")
        end
        Rayfield:Notify({
            Title    = "🍊 OrangeBot",
            Content  = val and "✅ Bot diaktifkan! Trigger: " .. triggerWord
                           or "❌ Bot dinonaktifkan.",
            Duration = 3,
        })
    end
})

-- Trigger Word Section
local TriggerSection = MainTab:CreateSection("⚡ Trigger Word")

MainTab:CreateInput({
    Name          = "🔑 Trigger Word (default: !orange)",
    CurrentValue  = CONFIG.TRIGGER_WORD,
    PlaceholderText = "Contoh: !orange",
    NumbersOnly   = false,
    Flag          = "TriggerWord",
    Callback      = function(val)
        if val ~= "" then
            triggerWord = val:lower()
            if CONFIG.DEBUG then print("[OrangeBot] Trigger diubah ke:", triggerWord) end
        end
    end
})

-- Range Section
local RangeSection = MainTab:CreateSection("📏 Chat Range (Stud)")

MainTab:CreateSlider({
    Name         = "🎯 Jarak Respons",
    Range        = {0, 200},
    Increment    = 5,
    Suffix       = " stud",
    CurrentValue = CONFIG.CHAT_RANGE,
    Flag         = "ChatRange",
    Callback     = function(val)
        chatRange = val
        if CONFIG.DEBUG then
            print("[OrangeBot] Range:", val == 0 and "Unlimited" or val .. " stud")
        end
    end
})

MainTab:CreateLabel("💡 0 stud = unlimited (jawab semua player)")

-- ─── TAB 2: PERSONALITY ───
local PersonalityTab = Window:CreateTab("🎭 Personality", 4483362458)

local PersonalitySection = PersonalityTab:CreateSection("🎨 Pilih Kepribadian Bot")

local personalityOptions = {}
for key, data in pairs(PERSONALITIES) do
    table.insert(personalityOptions, data.emoji .. " " .. data.label)
end
table.sort(personalityOptions)

-- Build reverse map
local labelToKey = {}
for key, data in pairs(PERSONALITIES) do
    labelToKey[data.emoji .. " " .. data.label] = key
end

-- Get current label
local function getCurrentPersonalityLabel()
    local p = PERSONALITIES[personality]
    return p.emoji .. " " .. p.label
end

PersonalityTab:CreateDropdown({
    Name    = "🎭 Kepribadian Bot",
    Options = personalityOptions,
    CurrentOption = {getCurrentPersonalityLabel()},
    Flag    = "Personality",
    Callback = function(val)
        local key = labelToKey[val[1]]
        if key then
            personality = key
            local p = PERSONALITIES[key]
            if CONFIG.DEBUG then print("[OrangeBot] Personality:", p.label) end
            Rayfield:Notify({
                Title   = "🎭 Personality Diubah",
                Content = p.emoji .. " " .. p.label .. " aktif!",
                Duration = 2,
            })
        end
    end
})

-- Personality descriptions
PersonalityTab:CreateSection("📖 Deskripsi Personality")
PersonalityTab:CreateLabel("😊 Ramah     — Hangat & supportif")
PersonalityTab:CreateLabel("👔 Formal    — Profesional & sopan")
PersonalityTab:CreateLabel("😂 Kocak     — Humoris & ngakak")
PersonalityTab:CreateLabel("🧙 Bijak      — Penuh makna & filosofis")
PersonalityTab:CreateLabel("😎 Santai    — Gaul & gak lebay")
PersonalityTab:CreateLabel("🔥 Savage    — Blak-blakan & roast ringan")
PersonalityTab:CreateLabel("💪 Motivator — Penuh semangat & positif")
PersonalityTab:CreateLabel("✍️  Penyair   — Puitis & berima")
PersonalityTab:CreateLabel("🕵️ Detektif  — Analitis & investigatif")
PersonalityTab:CreateLabel("🔬 Ilmuwan  — Ilmiah & logis")

-- ─── TAB 3: PERSONAL CHAT ───
local ChatTab = Window:CreateTab("💬 Personal Chat", 4483362458)

local chatHistory = {}

local ChatSection = ChatTab:CreateSection("💬 Chat Pribadi dengan OrangeBot")
ChatTab:CreateLabel("Gunakan tab ini untuk chat langsung!")
ChatTab:CreateLabel("(Tidak memerlukan trigger word)")

local chatLog = {}
local chatDisplay = ChatTab:CreateLabel("📭 Belum ada pesan. Mulai chat!")

ChatTab:CreateInput({
    Name          = "✉️ Pesan kamu",
    CurrentValue  = "",
    PlaceholderText = "Ketik pertanyaan kamu...",
    NumbersOnly   = false,
    Flag          = "PersonalChatInput",
    Callback      = function(val)
        if val == "" then return end
        -- Send to AI
        sendPersonalMessage(val)
    end
})

ChatTab:CreateSection("📜 Log Chat")
local logLabels = {}
for i = 1, 6 do
    logLabels[i] = ChatTab:CreateLabel("")
end

local function updateChatLog()
    local start = math.max(1, #chatLog - 5)
    for i = 1, 6 do
        local idx = start + i - 1
        if chatLog[idx] then
            logLabels[i]:Set(chatLog[idx])
        else
            logLabels[i]:Set("")
        end
    end
end

function sendPersonalMessage(text)
    table.insert(chatHistory, { role = "user", content = text })
    table.insert(chatLog, "👤 " .. text:sub(1, 40))
    updateChatLog()

    local p = PERSONALITIES[personality]
    local ok, response = pcall(function()
        return callAI(p.system, chatHistory)
    end)

    if ok and response then
        table.insert(chatHistory, { role = "assistant", content = response })
        local short = response:sub(1, 60) .. (response:len() > 60 and "..." or "")
        table.insert(chatLog, "🤖 " .. short)
        updateChatLog()
        Rayfield:Notify({
            Title   = "🤖 OrangeBot",
            Content = response:sub(1, 120),
            Duration = 6,
        })
    else
        table.insert(chatLog, "❌ Gagal mendapat respons")
        updateChatLog()
    end
end

ChatTab:CreateButton({
    Name     = "🗑️ Bersihkan History Chat",
    Callback = function()
        chatHistory = {}
        chatLog = {}
        for i = 1, 6 do logLabels[i]:Set("") end
        Rayfield:Notify({
            Title   = "🗑️ Clear",
            Content = "History chat dibersihkan!",
            Duration = 2,
        })
    end
})

-- ─── TAB 4: CREDIT ───
local CreditTab = Window:CreateTab("⭐ Credit", 4483362458)

CreditTab:CreateSection("👨‍💻 Developer")
CreditTab:CreateLabel("🍊 OrangeBot v2.0")
CreditTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
CreditTab:CreateLabel("👤 Developer : Jepry_Jago112")
CreditTab:CreateLabel("📅 Version   : 2.0.0")
CreditTab:CreateLabel("🤖 AI Model  : Groq LLaMA3")
CreditTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")

CreditTab:CreateSection("📋 Fitur")
CreditTab:CreateLabel("✅ Trigger Word (!orange / custom)")
CreditTab:CreateLabel("✅ Chat Range (stud distance)")
CreditTab:CreateLabel("✅ 10 Personality Bot")
CreditTab:CreateLabel("✅ Personal Chat Tab")
CreditTab:CreateLabel("✅ Cooldown System")
CreditTab:CreateLabel("✅ Rayfield UI Mobile-friendly")

CreditTab:CreateSection("🔗 Cara Setup")
CreditTab:CreateLabel("1. Isi API_KEY di bagian CONFIG")
CreditTab:CreateLabel("2. Taruh di StarterPlayerScripts")
CreditTab:CreateLabel("3. Jalankan sebagai LocalScript")
CreditTab:CreateLabel("4. Chat: !orange <pertanyaan>")
CreditTab:CreateLabel("5. Sesuaikan range & personality!")

CreditTab:CreateSection("❤️ Support")
CreditTab:CreateLabel("Follow Jepry_Jago112 di Roblox!")
CreditTab:CreateLabel("Star repo di GitHub nya!")

-- ════════════════════════════════════════
--   🤖 AI FUNCTION
-- ════════════════════════════════════════
function callAI(systemPrompt, messages)
    if not CONFIG.API_KEY or CONFIG.API_KEY == "MASUKKAN_API_KEY_KAMU_DISINI" then
        return "⚠️ API Key belum diisi! Set CONFIG.API_KEY dulu ya."
    end

    local body = HttpService:JSONEncode({
        model    = CONFIG.MODEL,
        messages = (function()
            local msgs = {{ role = "system", content = systemPrompt }}
            for _, m in ipairs(messages) do
                table.insert(msgs, m)
            end
            return msgs
        end)(),
        max_tokens = 150,
        temperature = 0.85,
    })

    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url     = CONFIG.API_URL,
            Method  = "POST",
            Headers = {
                ["Content-Type"]  = "application/json",
                ["Authorization"] = "Bearer " .. CONFIG.API_KEY,
            },
            Body = body,
        })
    end)

    if not ok then
        warn("[OrangeBot] HTTP Error:", result)
        return nil
    end

    if result.StatusCode ~= 200 then
        warn("[OrangeBot] API Error:", result.StatusCode, result.Body)
        return nil
    end

    local data = HttpService:JSONDecode(result.Body)
    local text = data.choices and data.choices[1] and
                 data.choices[1].message and
                 data.choices[1].message.content

    if text then
        -- Trim panjang
        if #text > CONFIG.MAX_RESPONSE_LEN then
            text = text:sub(1, CONFIG.MAX_RESPONSE_LEN) .. "..."
        end
        return text
    end

    return nil
end

-- ════════════════════════════════════════
--   📏 DISTANCE CHECK
-- ════════════════════════════════════════
local function getPlayerDistance(speakerName)
    if chatRange == 0 then return 0 end  -- unlimited

    local speaker = Players:FindFirstChild(speakerName)
    if not speaker then return math.huge end

    local myChar = LocalPlayer.Character
    local theirChar = speaker.Character
    if not myChar or not theirChar then return math.huge end

    local myRoot    = myChar:FindFirstChild("HumanoidRootPart")
    local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not theirRoot then return math.huge end

    return (myRoot.Position - theirRoot.Position).Magnitude
end

-- ════════════════════════════════════════
--   💬 SEND CHAT BUBBLE
-- ════════════════════════════════════════
local function sendBotChat(text)
    -- Kirim sebagai system notification di chat
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text      = "🍊 [OrangeBot] " .. text,
        Color     = Color3.fromRGB(249, 115, 22),
        Font      = Enum.Font.GothamBold,
        FontSize  = Enum.FontSize.Size14,
    })

    -- Coba tampilkan chat bubble juga
    local char = LocalPlayer.Character
    if char then
        local ok = pcall(function()
            Chat:Chat(char.HumanoidRootPart, "🍊 " .. text, Enum.ChatColor.Orange)
        end)
        if not ok and CONFIG.DEBUG then
            print("[OrangeBot] Chat bubble tidak tersedia, pakai system msg")
        end
    end
end

-- ════════════════════════════════════════
--   📨 PROCESS CHAT MESSAGE
-- ════════════════════════════════════════
local function onPlayerChat(speakerName, message, channelName)
    if not botActive then return end

    -- Ignore pesan dari LocalPlayer sendiri (bisa di-toggle)
    -- if speakerName == LocalPlayer.Name then return end

    local lower = message:lower()

    -- Cek trigger word
    local triggered = false
    local question  = ""

    if lower:sub(1, #triggerWord) == triggerWord then
        triggered = true
        question  = message:sub(#triggerWord + 2):match("^%s*(.-)%s*$") or ""
    elseif lower:sub(1, #CONFIG.TRIGGER_ALT) == CONFIG.TRIGGER_ALT and
           (lower:sub(#CONFIG.TRIGGER_ALT + 1, #CONFIG.TRIGGER_ALT + 1) == " " or
            lower:sub(#CONFIG.TRIGGER_ALT + 1, #CONFIG.TRIGGER_ALT + 1) == ",") then
        triggered = true
        question  = message:sub(#CONFIG.TRIGGER_ALT + 2):match("^%s*(.-)%s*$") or ""
    end

    if not triggered or question == "" then return end

    -- Cek jarak
    local dist = getPlayerDistance(speakerName)
    if chatRange > 0 and dist > chatRange then
        if CONFIG.DEBUG then
            print("[OrangeBot] " .. speakerName .. " terlalu jauh (" ..
                  math.floor(dist) .. " stud, max " .. chatRange .. " stud)")
        end
        return
    end

    -- Cek cooldown
    local now = tick()
    if lastUsed[speakerName] and (now - lastUsed[speakerName]) < CONFIG.COOLDOWN then
        if CONFIG.DEBUG then
            print("[OrangeBot] Cooldown untuk", speakerName)
        end
        return
    end
    lastUsed[speakerName] = now

    if CONFIG.DEBUG then
        print("[OrangeBot] Pertanyaan dari", speakerName, ":", question)
        print("[OrangeBot] Jarak:", chatRange == 0 and "Unlimited" or math.floor(dist) .. " stud")
    end

    -- Proses AI
    local p = PERSONALITIES[personality]
    local sysPrompt = p.system .. "\n\nSaat menjawab, panggil player dengan nama '" ..
                      speakerName .. "' jika perlu."
    local msgs = {{ role = "user", content = question }}

    -- Response async (pakai coroutine agar tidak block)
    task.spawn(function()
        sendBotChat("💭 Sedang memproses...")

        local response = callAI(sysPrompt, msgs)

        if response then
            sendBotChat(speakerName .. ": " .. response)
        else
            sendBotChat("⚠️ Maaf, gagal merespons. Coba lagi!")
        end
    end)
end

-- ════════════════════════════════════════
--   🎮 CONNECT CHAT EVENT
-- ════════════════════════════════════════
local TextChatService = game:GetService("TextChatService")

-- Modern chat system (TextChatService)
if TextChatService and TextChatService.MessageReceived then
    TextChatService.MessageReceived:Connect(function(msg)
        local sender = msg.TextSource and msg.TextSource.UserId and
                       Players:GetPlayerByUserId(msg.TextSource.UserId)
        if sender then
            onPlayerChat(sender.Name, msg.Text or "", "All")
        end
    end)
    if CONFIG.DEBUG then print("[OrangeBot] ✅ Menggunakan TextChatService") end
else
    -- Legacy chat (fallback)
    local function connectLegacyChat(player)
        player.Chatted:Connect(function(msg)
            onPlayerChat(player.Name, msg, "All")
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        connectLegacyChat(p)
    end
    Players.PlayerAdded:Connect(connectLegacyChat)
    if CONFIG.DEBUG then print("[OrangeBot] ✅ Menggunakan Legacy Chat") end
end

-- ════════════════════════════════════════
--   🚀 STARTUP NOTIFICATION
-- ════════════════════════════════════════
task.wait(2)
Rayfield:Notify({
    Title   = "🍊 OrangeBot v2.0",
    Content = "✅ Bot aktif! Ketik " .. CONFIG.TRIGGER_WORD .. " <pertanyaan> di chat!\n👤 By Jepry_Jago112",
    Duration = 5,
})

sendBotChat("OrangeBot v2.0 aktif! Ketik '" .. CONFIG.TRIGGER_WORD ..
            " <pertanyaan>' untuk chat! | By Jepry_Jago112")

if CONFIG.DEBUG then
    print("═══════════════════════════════════")
    print("  🍊 OrangeBot v2.0 LOADED")
    print("  Trigger  :", CONFIG.TRIGGER_WORD)
    print("  Range    :", CONFIG.CHAT_RANGE == 0 and "Unlimited" or CONFIG.CHAT_RANGE .. " stud")
    print("  Personality:", PERSONALITIES[personality].label)
    print("  Developer: Jepry_Jago112")
    print("═══════════════════════════════════")
end
