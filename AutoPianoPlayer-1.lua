--[[
╔══════════════════════════════════════════════════════════════════╗
║            🎹 AUTO PIANO PLAYER v2.0                            ║
║        Sky Music · Roblox Piano · Mobile & PC                   ║
║                  by Jepry_Jago112                               ║
╠══════════════════════════════════════════════════════════════════╣
║  SUPPORTED SHEET FORMATS:                                       ║
║  • Single key   : u f p t e r                                   ║
║  • Chord        : [eup] [rua] [tus]                             ║
║  • Chord+prefix : [6eup] [7rua] [8tus]                         ║
║  • Multi-prefix : [48qepj] [59wak] [60esl]                      ║
║  • Solo number  : 4 8 0 e t u p s                               ║
║  • Bar line     : | (ignored)                                   ║
╚══════════════════════════════════════════════════════════════════╝
--]]

-- ╔══════════════════════════════════════╗
-- ║         SERVICES & SETUP            ║
-- ╚══════════════════════════════════════╝
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local VirtualInputManager

-- Check if VirtualInputManager is available (executor support)
local ok, vim = pcall(function()
    return game:GetService("VirtualInputManager")
end)
if ok then VirtualInputManager = vim end

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ╔══════════════════════════════════════╗
-- ║         COLORS (dark theme)         ║
-- ╚══════════════════════════════════════╝
local C = {
    BG        = Color3.fromRGB(10,  10,  10),
    SURFACE   = Color3.fromRGB(17,  17,  17),
    SURFACE2  = Color3.fromRGB(26,  26,  26),
    SURFACE3  = Color3.fromRGB(34,  34,  34),
    BORDER    = Color3.fromRGB(42,  42,  42),
    IVORY     = Color3.fromRGB(245, 230, 200),
    GOLD      = Color3.fromRGB(201, 168, 76),
    GOLD_DIM  = Color3.fromRGB(122, 98,  48),
    RED       = Color3.fromRGB(224, 85,  85),
    GREEN     = Color3.fromRGB(78,  201, 122),
    BLUE      = Color3.fromRGB(90,  158, 224),
    TEXT      = Color3.fromRGB(232, 232, 232),
    TEXT_DIM  = Color3.fromRGB(136, 136, 136),
    TEXT_MUT  = Color3.fromRGB(68,  68,  68),
    BLACK     = Color3.fromRGB(0,   0,   0),
    WHITE     = Color3.fromRGB(255, 255, 255),
}

-- ╔══════════════════════════════════════╗
-- ║         KEYCODE MAP                 ║
-- ╚══════════════════════════════════════╝
-- Map character → Roblox Enum.KeyCode
local KEY_MAP = {
    q = Enum.KeyCode.Q, w = Enum.KeyCode.W, e = Enum.KeyCode.E,
    r = Enum.KeyCode.R, t = Enum.KeyCode.T, y = Enum.KeyCode.Y,
    u = Enum.KeyCode.U, i = Enum.KeyCode.I, o = Enum.KeyCode.O,
    p = Enum.KeyCode.P,
    a = Enum.KeyCode.A, s = Enum.KeyCode.S, d = Enum.KeyCode.D,
    f = Enum.KeyCode.F, g = Enum.KeyCode.G, h = Enum.KeyCode.H,
    j = Enum.KeyCode.J, k = Enum.KeyCode.K, l = Enum.KeyCode.L,
    z = Enum.KeyCode.Z, x = Enum.KeyCode.X, c = Enum.KeyCode.C,
    v = Enum.KeyCode.V, b = Enum.KeyCode.B, n = Enum.KeyCode.N,
    m = Enum.KeyCode.M,
    ["0"] = Enum.KeyCode.Zero,  ["1"] = Enum.KeyCode.One,
    ["2"] = Enum.KeyCode.Two,   ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four,  ["5"] = Enum.KeyCode.Five,
    ["6"] = Enum.KeyCode.Six,   ["7"] = Enum.KeyCode.Seven,
    ["8"] = Enum.KeyCode.Eight, ["9"] = Enum.KeyCode.Nine,
}

-- ╔══════════════════════════════════════╗
-- ║         SKY MUSIC PARSER            ║
-- ╚══════════════════════════════════════╝
-- Tokens/symbols to ignore during parsing
local IGNORE = { ["|"] = true, ["-"] = true, ["_"] = true, ["."] = true }

--[[
  Parses a raw sheet string into a list of token objects.
  Each token has:
    { kind = "note",  keys = { "u" } }          -- single key press
    { kind = "chord", keys = { "e","u","p" } }  -- simultaneous key press

  Supported formats:
    u f p           → single notes (space-separated)
    [eup]           → chord (press all together)
    [6eup]          → prefixed chord (6 = shift key + chord keys eup)
    [48qepj]        → multi-prefix chord (all chars pressed simultaneously)
    [0fx]           → chord with digit key
    8 0 e t u p s   → individual note sequence (digits & letters)
    |               → bar line (ignored)
]]
local function parseSheet(raw)
    local tokens = {}
    -- Split the raw text by whitespace into chunks
    for chunk in raw:gmatch("%S+") do
        if not IGNORE[chunk] then
            local i = 1
            while i <= #chunk do
                local ch = chunk:sub(i, i)
                if ch == "[" then
                    -- Find the matching closing bracket
                    local closePos = chunk:find("]", i, true)
                    if closePos then
                        local inner = chunk:sub(i + 1, closePos - 1)
                        i = closePos + 1
                        if #inner > 0 then
                            local keys = {}
                            -- Extract every alphanumeric char as a key to press
                            for c in inner:gmatch("[a-zA-Z0-9]") do
                                table.insert(keys, c:lower())
                            end
                            if #keys == 1 then
                                table.insert(tokens, { kind = "note",  keys = keys })
                            elseif #keys > 1 then
                                table.insert(tokens, { kind = "chord", keys = keys })
                            end
                        end
                    else
                        i = i + 1 -- No closing bracket found, skip '['
                    end
                elseif ch:match("[a-zA-Z0-9]") then
                    -- Standalone single note
                    table.insert(tokens, { kind = "note", keys = { ch:lower() } })
                    i = i + 1
                else
                    i = i + 1 -- Skip unknown character
                end
            end
        end
    end
    return tokens
end

-- ╔══════════════════════════════════════╗
-- ║         KEY PRESS ENGINE            ║
-- ╚══════════════════════════════════════╝
local function pressKey(k)
    local kc = KEY_MAP[k]
    if not kc then return end

    -- Method 1: VirtualInputManager (executor-level access)
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true,  kc, false, game)
            task.delay(0.07, function()
                VirtualInputManager:SendKeyEvent(false, kc, false, game)
            end)
        end)
        return
    end

    -- Method 2: keypress() — available in many Roblox exploit executors
    if keypress then
        pcall(function()
            keypress(kc.Value)
            task.delay(0.07, function() keyrelease(kc.Value) end)
        end)
        return
    end

    -- Method 3: No fallback available in standard environment
end

local function pressKeys(keys)
    for _, k in ipairs(keys) do
        pressKey(k)
    end
end

-- ╔══════════════════════════════════════╗
-- ║         GUI BUILDER HELPERS         ║
-- ╚══════════════════════════════════════╝
local function newInst(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function newFrame(parent, props)
    props.Parent = parent
    return newInst("Frame", props)
end

local function newLabel(parent, props)
    props.Parent = parent
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    return newInst("TextLabel", props)
end

local function newBtn(parent, props)
    props.Parent = parent
    props.AutoButtonColor = false
    return newInst("TextButton", props)
end

local function newBox(parent, props)
    props.Parent = parent
    return newInst("TextBox", props)
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BORDER
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

local function listLayout(parent, pad, dir)
    local ul = Instance.new("UIListLayout")
    ul.Padding       = UDim.new(0, pad or 6)
    ul.FillDirection = dir or Enum.FillDirection.Vertical
    ul.SortOrder     = Enum.SortOrder.LayoutOrder
    ul.Parent        = parent
    return ul
end

local function padding(parent, px)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, px)
    p.PaddingRight  = UDim.new(0, px)
    p.PaddingTop    = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.Parent        = parent
    return p
end

local function tween(obj, goal, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad), goal):Play()
end

-- ╔══════════════════════════════════════╗
-- ║         BUILD GUI                   ║
-- ╚══════════════════════════════════════╝

-- Remove any existing GUI instance to avoid duplicates
if PlayerGui:FindFirstChild("AutoPianoPlayer") then
    PlayerGui.AutoPianoPlayer:Destroy()
end

local ScreenGui = newInst("ScreenGui", {
    Name             = "AutoPianoPlayer",
    ResetOnSpawn     = false,
    IgnoreGuiInset   = true,
    ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
    Parent           = PlayerGui,
})

-- ── BACKDROP ──────────────────────────────────────────────────────────────────
-- Semi-transparent dark overlay behind the window
local Backdrop = newFrame(ScreenGui, {
    Name                   = "Backdrop",
    Size                   = UDim2.new(1, 0, 1, 0),
    Position               = UDim2.new(0, 0, 0, 0),
    BackgroundColor3       = C.BG,
    BackgroundTransparency = 0.45,
    ZIndex                 = 1,
})

-- ── MAIN WINDOW (draggable) ───────────────────────────────────────────────────
local WIN_W = 420
local WIN_H = 620

local Window = newFrame(ScreenGui, {
    Name             = "Window",
    Size             = UDim2.new(0, WIN_W, 0, WIN_H),
    Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
    BackgroundColor3 = C.SURFACE,
    ZIndex           = 10,
    ClipsDescendants = true,
})
corner(Window, 14)
stroke(Window, C.BORDER, 1)

-- Drop shadow effect
local Shadow = newFrame(ScreenGui, {
    Name                   = "Shadow",
    Size                   = UDim2.new(0, WIN_W + 20, 0, WIN_H + 20),
    Position               = UDim2.new(0.5, -(WIN_W+20)/2, 0.5, -(WIN_H+20)/2 + 6),
    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.55,
    ZIndex                 = 9,
})
corner(Shadow, 18)

-- ── TITLE BAR ─────────────────────────────────────────────────────────────────
local TitleBar = newFrame(Window, {
    Name             = "TitleBar",
    Size             = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = C.SURFACE2,
    ZIndex           = 11,
})
-- Gold accent line below the title bar
local TitleLine = newFrame(TitleBar, {
    Size             = UDim2.new(1, 0, 0, 2),
    Position         = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = C.GOLD_DIM,
    ZIndex           = 12,
})

newLabel(TitleBar, {
    Text           = "🎹 Auto Piano Player",
    Size           = UDim2.new(1, -100, 1, 0),
    Position       = UDim2.new(0, 14, 0, 0),
    Font           = Enum.Font.GothamBold,
    TextSize       = 15,
    TextColor3     = C.IVORY,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex         = 12,
})

newLabel(TitleBar, {
    Text           = "Sky Music · v2.0",
    Size           = UDim2.new(0, 120, 1, 0),
    Position       = UDim2.new(1, -130, 0, 0),
    Font           = Enum.Font.Gotham,
    TextSize       = 10,
    TextColor3     = C.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex         = 12,
})

-- Close button
local CloseBtn = newBtn(TitleBar, {
    Text             = "✕",
    Size             = UDim2.new(0, 34, 0, 34),
    Position         = UDim2.new(1, -42, 0.5, -17),
    BackgroundColor3 = C.SURFACE3,
    Font             = Enum.Font.GothamBold,
    TextSize         = 13,
    TextColor3       = C.TEXT_DIM,
    ZIndex           = 12,
})
corner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize button
local MinBtn = newBtn(TitleBar, {
    Text             = "─",
    Size             = UDim2.new(0, 34, 0, 34),
    Position         = UDim2.new(1, -82, 0.5, -17),
    BackgroundColor3 = C.SURFACE3,
    Font             = Enum.Font.GothamBold,
    TextSize         = 14,
    TextColor3       = C.TEXT_DIM,
    ZIndex           = 12,
})
corner(MinBtn, 6)

-- ── DRAG LOGIC ────────────────────────────────────────────────────────────────
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = Window.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (
        inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = inp.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- Keep shadow synchronized with window movement
        Shadow.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X - 10,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y - 4
        )
    end
end)

-- ── MINIMIZE TOGGLE ───────────────────────────────────────────────────────────
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(Window, { Size = UDim2.new(0, WIN_W, 0, 48) }, 0.2)
        Shadow.Visible = false
    else
        tween(Window, { Size = UDim2.new(0, WIN_W, 0, WIN_H) }, 0.2)
        Shadow.Visible = true
    end
end)

-- ── CONTENT SCROLL ────────────────────────────────────────────────────────────
local ScrollFrame = newInst("ScrollingFrame", {
    Name                 = "Content",
    Parent               = Window,
    Size                 = UDim2.new(1, 0, 1, -48),
    Position             = UDim2.new(0, 0, 0, 48),
    BackgroundTransparency = 1,
    ScrollBarThickness   = 3,
    ScrollBarImageColor3 = C.BORDER,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize  = Enum.AutomaticSize.Y,
    ZIndex               = 11,
})

local ContentPad = newFrame(ScrollFrame, {
    Name                   = "ContentPad",
    Size                   = UDim2.new(1, 0, 0, 0),
    AutomaticSize          = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    ZIndex                 = 11,
})
listLayout(ContentPad, 10)
padding(ContentPad, 14)

-- ── HELPER: SECTION HEADER ────────────────────────────────────────────────────
local function sectionLabel(parent, text, order)
    local row = newFrame(parent, {
        Name                   = "SLabel_"..text,
        Size                   = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder            = order,
        ZIndex                 = 12,
    })
    newLabel(row, {
        Text           = text,
        Size           = UDim2.new(0, 0, 1, 0),
        AutomaticSize  = Enum.AutomaticSize.X,
        Font           = Enum.Font.GothamBold,
        TextSize       = 9,
        TextColor3     = C.GOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 12,
    })
    newFrame(row, {
        Size             = UDim2.new(1, -80, 0, 1),
        Position         = UDim2.new(0, 75, 0.5, 0),
        BackgroundColor3 = C.BORDER,
        ZIndex           = 12,
    })
    return row
end

-- ╔══════════════════════════════════════╗
-- ║         PIANO VISUALIZER           ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "🎹  PIANO VISUALIZER", 1)

local VisFrame = newFrame(ContentPad, {
    Name             = "Visualizer",
    Size             = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 2,
    ZIndex           = 12,
})
corner(VisFrame, 8)
stroke(VisFrame, C.BORDER)

-- 24-key visual keyboard layout (w = white, b = black)
local KEY_LAYOUT_VIS = {
    "w","b","w","b","w","w","b","w","b","w","b","w",
    "w","b","w","b","w","w","b","w","b","w","b","w",
}
-- Sky Music key → approximate visual column index
local SKY_TO_VIS_COL = {
    q=1,  a=1,  z=1,  ["1"]=1,
    w=3,  s=3,  x=3,  ["2"]=3,
    e=5,  d=5,  c=5,  ["3"]=5,
    r=6,  f=6,  v=6,  ["4"]=6,
    t=8,  g=8,  b=8,  ["5"]=8,
    y=10, h=10, n=10, ["6"]=10,
    u=12, j=12, m=12, ["7"]=12,
    i=13, k=13,       ["8"]=13,
    o=15, l=15,       ["9"]=15,
    p=17,             ["0"]=17,
}

local visKeyFrames = {}
local xOffset = 2

for idx = 1, 24 do
    local isBlack = KEY_LAYOUT_VIS[idx] == "b"
    local kf = newFrame(VisFrame, {
        Size             = UDim2.new(0, isBlack and 10 or 14, 0, isBlack and 24 or 36),
        Position         = UDim2.new(0, xOffset, 1, isBlack and -26 or -38),
        BackgroundColor3 = isBlack and Color3.fromRGB(22,22,22) or Color3.fromRGB(42,42,42),
        ZIndex           = isBlack and 14 or 13,
    })
    corner(kf, 2)
    visKeyFrames[idx] = { frame = kf, isBlack = isBlack }
    xOffset = xOffset + (isBlack and 8 or 16)
end

local function lightVisKeys(skyKeys)
    -- Reset all visualizer keys to their default color
    for _, vk in ipairs(visKeyFrames) do
        vk.frame.BackgroundColor3 = vk.isBlack
            and Color3.fromRGB(22,22,22)
            or  Color3.fromRGB(42,42,42)
    end
    if not skyKeys or #skyKeys == 0 then return end
    -- Highlight the active keys in gold
    local cols = {}
    for _, k in ipairs(skyKeys) do
        local col = SKY_TO_VIS_COL[k]
        if col then cols[col] = true end
    end
    for col in pairs(cols) do
        local vk = visKeyFrames[col]
        if vk then
            tween(vk.frame, { BackgroundColor3 = C.GOLD }, 0.05)
            task.delay(0.15, function()
                if vk.frame and vk.frame.Parent then
                    tween(vk.frame, {
                        BackgroundColor3 = vk.isBlack
                            and Color3.fromRGB(22,22,22)
                            or  Color3.fromRGB(42,42,42)
                    }, 0.1)
                end
            end)
        end
    end
end

-- ╔══════════════════════════════════════╗
-- ║         SHEET INPUT                 ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "🎼  SHEET MUSIC", 3)

local SheetFrame = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 110),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 4,
    ZIndex           = 12,
})
corner(SheetFrame, 8)
stroke(SheetFrame, C.BORDER)

local SheetBox = newBox(SheetFrame, {
    Name                   = "SheetInput",
    Size                   = UDim2.new(1, -16, 1, -16),
    Position               = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1,
    Text                   = "",
    PlaceholderText        = "Paste sheet here...\n\nExample: u u u [eup] [6eup] [7rua]\n[48qepj] 8 0 e t u p s [fjlx]\nf [uf] f u f [up] f [5wua]",
    PlaceholderColor3      = C.TEXT_MUT,
    TextColor3             = C.IVORY,
    Font                   = Enum.Font.Code,
    TextSize               = 11,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Top,
    TextWrapped            = true,
    MultiLine              = true,
    ClearTextOnFocus       = false,
    ZIndex                 = 13,
})

newLabel(ContentPad, {
    Text        = "Supports: single [u] · chord [eup] · prefix [6eup] [48qepj] · numbers [0-9] · | ignored",
    Size        = UDim2.new(1, 0, 0, 24),
    Font        = Enum.Font.Gotham,
    TextSize    = 9,
    TextColor3  = C.TEXT_MUT,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
    LayoutOrder = 5,
    ZIndex      = 12,
})

-- ╔══════════════════════════════════════╗
-- ║         SHEET STATISTICS            ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "📊  SHEET STATISTICS", 6)

local StatsRow = newFrame(ContentPad, {
    Size                   = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    LayoutOrder            = 7,
    ZIndex                 = 12,
})
local statsLL = Instance.new("UIListLayout")
statsLL.FillDirection = Enum.FillDirection.Horizontal
statsLL.Padding       = UDim.new(0, 6)
statsLL.SortOrder     = Enum.SortOrder.LayoutOrder
statsLL.Parent        = StatsRow

local statLabels = {}
local statDefs = {
    { id = "total",  label = "Total"  },
    { id = "chords", label = "Chord"  },
    { id = "single", label = "Single" },
    { id = "rest",   label = "Rest"   },
}

for i, def in ipairs(statDefs) do
    local chip = newFrame(StatsRow, {
        Size             = UDim2.new(0.25, -5, 1, 0),
        BackgroundColor3 = C.SURFACE2,
        LayoutOrder      = i,
        ZIndex           = 12,
    })
    corner(chip, 7)
    stroke(chip, C.BORDER)
    local val = newLabel(chip, {
        Text       = "0",
        Size       = UDim2.new(1, 0, 0, 26),
        Position   = UDim2.new(0, 0, 0, 6),
        Font       = Enum.Font.GothamBold,
        TextSize   = 16,
        TextColor3 = C.IVORY,
        ZIndex     = 13,
    })
    newLabel(chip, {
        Text       = def.label:upper(),
        Size       = UDim2.new(1, 0, 0, 14),
        Position   = UDim2.new(0, 0, 1, -16),
        Font       = Enum.Font.Gotham,
        TextSize   = 8,
        TextColor3 = C.TEXT_MUT,
        ZIndex     = 13,
    })
    statLabels[def.id] = val
end

local function updateStats(toks)
    local chords, singles, rests = 0, 0, 0
    for _, t in ipairs(toks) do
        if     t.kind == "chord" then chords  = chords  + 1
        elseif t.kind == "note"  then singles = singles + 1
        else                          rests   = rests   + 1
        end
    end
    statLabels.total.Text  = tostring(#toks)
    statLabels.chords.Text = tostring(chords)
    statLabels.single.Text = tostring(singles)
    statLabels.rest.Text   = tostring(rests)
end

-- ╔══════════════════════════════════════╗
-- ║         PLAYBACK SPEED SLIDER       ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "⚡  PLAYBACK SPEED", 8)

local SpeedRow = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 9,
    ZIndex           = 12,
})
corner(SpeedRow, 8)
stroke(SpeedRow, C.BORDER)
padding(SpeedRow, 10)

newLabel(SpeedRow, {
    Text     = "🐢",
    Size     = UDim2.new(0, 20, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Font     = Enum.Font.Gotham,
    TextSize = 16,
    ZIndex   = 13,
})

local SpeedValLabel = newLabel(SpeedRow, {
    Text       = "1.0×",
    Size       = UDim2.new(0, 36, 1, 0),
    Position   = UDim2.new(1, -36, 0, 0),
    Font       = Enum.Font.GothamBold,
    TextSize   = 12,
    TextColor3 = C.IVORY,
    ZIndex     = 13,
})

newLabel(SpeedRow, {
    Text     = "🐇",
    Size     = UDim2.new(0, 20, 1, 0),
    Position = UDim2.new(1, -60, 0, 0),
    Font     = Enum.Font.Gotham,
    TextSize = 16,
    ZIndex   = 13,
})

-- Slider track
local SliderBG = newFrame(SpeedRow, {
    Size             = UDim2.new(1, -90, 0, 4),
    Position         = UDim2.new(0, 24, 0.5, -2),
    BackgroundColor3 = C.BORDER,
    ZIndex           = 13,
})
corner(SliderBG, 2)

local SliderFill = newFrame(SliderBG, {
    Size             = UDim2.new(0.25, 0, 1, 0),
    BackgroundColor3 = C.GOLD,
    ZIndex           = 14,
})
corner(SliderFill, 2)

local SliderThumb = newFrame(SliderBG, {
    Size             = UDim2.new(0, 16, 0, 16),
    Position         = UDim2.new(0.25, -8, 0.5, -8),
    BackgroundColor3 = C.GOLD,
    ZIndex           = 15,
})
corner(SliderThumb, 8)

local speedValue    = 1.0
local MIN_SPEED     = 0.25
local MAX_SPEED     = 4.0

-- BUG FIX: removed the redundant 'origSetSpeed' wrapper that was
-- reassigning setSpeed to a no-op closure below. One clean function suffices.
local function setSpeed(val)
    val        = math.clamp(val, MIN_SPEED, MAX_SPEED)
    speedValue = val
    local pct  = (val - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    SliderFill.Size        = UDim2.new(pct, 0, 1, 0)
    SliderThumb.Position   = UDim2.new(pct, -8, 0.5, -8)
    SpeedValLabel.Text     = string.format("%.2g×", val)
end

setSpeed(1.0)

-- Slider drag handling
local sliderDragging = false
local function updateSliderFromInput(inp)
    local sliderAbs = SliderBG.AbsolutePosition
    local sliderW   = SliderBG.AbsoluteSize.X
    local pct       = math.clamp((inp.Position.X - sliderAbs.X) / sliderW, 0, 1)
    -- Snap to 0.25× increments
    local raw       = MIN_SPEED + pct * (MAX_SPEED - MIN_SPEED)
    local snapped   = math.floor(raw / 0.25 + 0.5) * 0.25
    setSpeed(snapped)
end

SliderBG.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSliderFromInput(inp)
    end
end)
SliderThumb.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if sliderDragging and (
        inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSliderFromInput(inp)
    end
end)

-- ╔══════════════════════════════════════╗
-- ║         NOTE DELAY INPUT            ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "⏱  NOTE DELAY (MS)", 10)

local DelayRow = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 11,
    ZIndex           = 12,
})
corner(DelayRow, 8)
stroke(DelayRow, C.BORDER)

newLabel(DelayRow, {
    Text           = "🎵  Delay between notes:",
    Size           = UDim2.new(1, -100, 1, 0),
    Position       = UDim2.new(0, 12, 0, 0),
    Font           = Enum.Font.Gotham,
    TextSize       = 11,
    TextColor3     = C.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex         = 13,
})

local DelayBox = newBox(DelayRow, {
    Text             = "150",
    Size             = UDim2.new(0, 60, 0, 26),
    Position         = UDim2.new(1, -80, 0.5, -13),
    BackgroundColor3 = C.SURFACE3,
    TextColor3       = C.IVORY,
    Font             = Enum.Font.Code,
    TextSize         = 12,
    ZIndex           = 13,
    ClearTextOnFocus = false,
})
corner(DelayBox, 6)
stroke(DelayBox, C.BORDER)

newLabel(DelayRow, {
    Text       = "ms",
    Size       = UDim2.new(0, 20, 1, 0),
    Position   = UDim2.new(1, -18, 0, 0),
    Font       = Enum.Font.Gotham,
    TextSize   = 10,
    TextColor3 = C.TEXT_MUT,
    ZIndex     = 13,
})

-- Returns effective delay in milliseconds, divided by current speed multiplier
local function getDelay()
    local v = tonumber(DelayBox.Text) or 150
    return math.max(30, math.floor(v / speedValue))
end

-- ╔══════════════════════════════════════╗
-- ║         CONTROL BUTTONS             ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "🎮  CONTROLS", 12)

local BtnRow = newFrame(ContentPad, {
    Size                   = UDim2.new(1, 0, 0, 44),
    BackgroundTransparency = 1,
    LayoutOrder            = 13,
    ZIndex                 = 12,
})
local btnLL = Instance.new("UIListLayout")
btnLL.FillDirection = Enum.FillDirection.Horizontal
btnLL.Padding       = UDim.new(0, 8)
btnLL.SortOrder     = Enum.SortOrder.LayoutOrder
btnLL.Parent        = BtnRow

local function makeBtn(parent, text, icon, bgColor, txtColor, order)
    local btn = newBtn(parent, {
        Size             = UDim2.new(0.333, -6, 1, 0),
        BackgroundColor3 = bgColor,
        LayoutOrder      = order,
        ZIndex           = 13,
    })
    corner(btn, 8)
    if bgColor ~= C.GOLD then stroke(btn, C.BORDER) end

    local iconL = newLabel(btn, {
        Text     = icon,
        Size     = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 4),
        Font     = Enum.Font.Gotham,
        TextSize = 16,
        ZIndex   = 14,
    })
    local txtL = newLabel(btn, {
        Name       = "Label",
        Text       = text,
        Size       = UDim2.new(1, 0, 0, 14),
        Position   = UDim2.new(0, 0, 1, -17),
        Font       = Enum.Font.GothamBold,
        TextSize   = 10,
        TextColor3 = txtColor,
        ZIndex     = 14,
    })
    btn.MouseButton1Down:Connect(function()
        tween(btn, { BackgroundColor3 = bgColor:Lerp(C.WHITE, 0.12) }, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, { BackgroundColor3 = bgColor }, 0.1)
    end)
    return btn, txtL, iconL
end

local PlayBtn,  PlayLbl,  PlayIcon  = makeBtn(BtnRow, "PLAY",  "▶",  C.GOLD,     C.BLACK, 1)
local PauseBtn, PauseLbl, PauseIcon = makeBtn(BtnRow, "PAUSE", "⏸", C.SURFACE3, C.TEXT,  2)
local ClearBtn, ClearLbl, ClearIcon = makeBtn(BtnRow, "CLEAR", "🗑", C.SURFACE3, C.TEXT,  3)

-- ╔══════════════════════════════════════╗
-- ║         PROGRESS BAR                ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "📈  PROGRESS", 14)

local ProgressFrame = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 15,
    ZIndex           = 12,
})
corner(ProgressFrame, 8)
stroke(ProgressFrame, C.BORDER)

-- Animated status indicator dot
local StatusDot = newFrame(ProgressFrame, {
    Size             = UDim2.new(0, 7, 0, 7),
    Position         = UDim2.new(0, 12, 0, 12),
    BackgroundColor3 = C.TEXT_MUT,
    ZIndex           = 13,
})
corner(StatusDot, 4)

local StatusLbl = newLabel(ProgressFrame, {
    Text           = "Idle",
    Size           = UDim2.new(0.5, -30, 0, 18),
    Position       = UDim2.new(0, 24, 0, 6),
    Font           = Enum.Font.GothamBold,
    TextSize       = 10,
    TextColor3     = C.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex         = 13,
})

local ProgressCountLbl = newLabel(ProgressFrame, {
    Text           = "0 / 0",
    Size           = UDim2.new(0.4, 0, 0, 18),
    Position       = UDim2.new(0.6, 0, 0, 6),
    Font           = Enum.Font.Code,
    TextSize       = 10,
    TextColor3     = C.TEXT_DIM,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex         = 13,
})

local ProgBG = newFrame(ProgressFrame, {
    Size             = UDim2.new(1, -24, 0, 5),
    Position         = UDim2.new(0, 12, 1, -14),
    BackgroundColor3 = C.BORDER,
    ZIndex           = 13,
})
corner(ProgBG, 3)

local ProgFill = newFrame(ProgBG, {
    Size             = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.GOLD_DIM,
    ZIndex           = 14,
})
corner(ProgFill, 3)

local function setStatus(state)
    if state == "playing" then
        StatusDot.BackgroundColor3 = C.GREEN
        StatusLbl.Text             = "Playing"
        StatusLbl.TextColor3       = C.GREEN
    elseif state == "paused" then
        StatusDot.BackgroundColor3 = C.GOLD
        StatusLbl.Text             = "Paused"
        StatusLbl.TextColor3       = C.GOLD
    else
        StatusDot.BackgroundColor3 = C.TEXT_MUT
        StatusLbl.Text             = "Idle"
        StatusLbl.TextColor3       = C.TEXT_DIM
    end
end

local function updateProgress(idx, total)
    local pct = total > 0 and (idx / total) or 0
    tween(ProgFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.1)
    ProgressCountLbl.Text = idx .. " / " .. total
end

-- ╔══════════════════════════════════════╗
-- ║         NOW PLAYING TICKER          ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "🎵  NOW PLAYING", 16)

local NowPlayFrame = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 17,
    ZIndex           = 12,
    ClipsDescendants = true,
})
corner(NowPlayFrame, 8)
stroke(NowPlayFrame, C.BORDER)

local NowPlayLabel = newLabel(NowPlayFrame, {
    Text           = "— nothing playing yet —",
    Size           = UDim2.new(1, -16, 1, 0),
    Position       = UDim2.new(0, 8, 0, 0),
    Font           = Enum.Font.Code,
    TextSize       = 11,
    TextColor3     = C.TEXT_MUT,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped    = false,
    ZIndex         = 13,
})

local function showNowPlaying(toks, activeIdx)
    local parts = {}
    local start = math.max(1, activeIdx - 4)
    local stop  = math.min(#toks, activeIdx + 7)
    for i = start, stop do
        local t = toks[i]
        local s
        if t.kind == "chord" then
            s = "[" .. table.concat(t.keys, "") .. "]"
        else
            s = t.keys[1]
        end
        if i == activeIdx then
            s = "►" .. s .. "◄"
        end
        table.insert(parts, s)
    end
    NowPlayLabel.Text       = table.concat(parts, "  ")
    NowPlayLabel.TextColor3 = C.IVORY
end

-- ╔══════════════════════════════════════╗
-- ║         LOG BOX                     ║
-- ╚══════════════════════════════════════╝
sectionLabel(ContentPad, "📋  LOG", 18)

local LogOuter = newFrame(ContentPad, {
    Size             = UDim2.new(1, 0, 0, 80),
    BackgroundColor3 = C.SURFACE2,
    LayoutOrder      = 19,
    ClipsDescendants = true,
    ZIndex           = 12,
})
corner(LogOuter, 8)
stroke(LogOuter, C.BORDER)

local LogScroll = newInst("ScrollingFrame", {
    Parent               = LogOuter,
    Size                 = UDim2.new(1, -6, 1, -4),
    Position             = UDim2.new(0, 3, 0, 2),
    BackgroundTransparency = 1,
    ScrollBarThickness   = 2,
    ScrollBarImageColor3 = C.BORDER,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize  = Enum.AutomaticSize.Y,
    ZIndex               = 13,
})
listLayout(LogScroll, 1)

local LOG_COLORS = {
    info    = C.GOLD,
    success = C.GREEN,
    chord   = C.BLUE,
    warn    = Color3.fromRGB(224, 136, 85),
    default = C.TEXT_DIM,
}

local function addLog(msg, logType)
    local col = LOG_COLORS[logType] or LOG_COLORS.default
    newLabel(LogScroll, {
        Text         = "» " .. msg,
        Size         = UDim2.new(1, -6, 0, 14),
        Font         = Enum.Font.Code,
        TextSize     = 9,
        TextColor3   = col,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex       = 14,
    })
    -- Limit to 60 entries to prevent memory bloat
    local kids  = LogScroll:GetChildren()
    local count = 0
    for _, c in ipairs(kids) do
        if c:IsA("TextLabel") then count = count + 1 end
    end
    if count > 60 then
        for _, c in ipairs(kids) do
            if c:IsA("TextLabel") then c:Destroy(); break end
        end
    end
    -- Auto-scroll to the latest entry
    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
    end)
end

-- Footer
newLabel(ContentPad, {
    Text        = "Made for Sky Music & Roblox Piano  ·  by Jepry_Jago112",
    Size        = UDim2.new(1, 0, 0, 20),
    Font        = Enum.Font.Gotham,
    TextSize    = 8,
    TextColor3  = C.TEXT_MUT,
    LayoutOrder = 20,
    ZIndex      = 12,
})

-- ╔══════════════════════════════════════════════════════════════════════════════
-- ║                          PLAY ENGINE                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local tokens     = {}
local currentIdx = 1
local isPaused   = false
local isPlaying  = false
local stopFlag   = false

-- Live statistics update as the user types/pastes sheet content
SheetBox.Changed:Connect(function(prop)
    if prop == "Text" and SheetBox.Text ~= "" then
        local toks = parseSheet(SheetBox.Text)
        updateStats(toks)
    end
end)

-- BUG FIX: resetPlayUI now accepts an optional 'clearedByUser' flag.
-- When true (Clear button) it shows "nothing playing yet".
-- When false/nil (song finished or stopped) it shows "finished ✓".
local function resetPlayUI(clearedByUser)
    isPlaying                 = false
    isPaused                  = false
    PlayBtn.BackgroundColor3  = C.GOLD
    PlayBtn.Active            = true
    PauseBtn.BackgroundColor3 = C.SURFACE3
    PauseLbl.TextColor3       = C.TEXT
    PauseIcon.Text            = "⏸"
    PauseLbl.Text             = "PAUSE"
    setStatus("idle")
    lightVisKeys({})
    if clearedByUser then
        NowPlayLabel.Text = "— nothing playing yet —"
    else
        NowPlayLabel.Text = "— finished ✓ —"
    end
    NowPlayLabel.TextColor3 = C.TEXT_MUT
end

-- ── PLAY ─────────────────────────────────────────────────────────────────────
PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then return end

    local raw = SheetBox.Text
    if not raw or raw == "" then
        addLog("Sheet is empty! Paste a sheet first 🎼", "warn")
        return
    end

    tokens = parseSheet(raw)
    if #tokens == 0 then
        addLog("No notes detected. Please check the sheet format.", "warn")
        return
    end

    updateStats(tokens)

    -- Count chords for the info log
    local chordCount = 0
    for _, t in ipairs(tokens) do
        if t.kind == "chord" then chordCount = chordCount + 1 end
    end
    addLog(string.format("Loaded %d tokens (%d chords) 🎵", #tokens, chordCount), "info")

    stopFlag   = false
    isPaused   = false
    isPlaying  = true
    currentIdx = 1

    PlayBtn.BackgroundColor3 = C.GOLD_DIM
    PlayBtn.Active           = false
    setStatus("playing")
    updateProgress(0, #tokens)

    task.spawn(function()
        task.wait(0.15)

        for i = 1, #tokens do
            if stopFlag then break end

            -- Pause loop: spin until resumed or stopped
            while isPaused and not stopFlag do
                task.wait(0.04)
            end
            if stopFlag then break end

            currentIdx = i
            local tok  = tokens[i]
            updateProgress(i, #tokens)
            showNowPlaying(tokens, i)

            if tok.kind == "chord" then
                lightVisKeys(tok.keys)
                pressKeys(tok.keys)
                addLog(string.format("♫ [%s]  (%d/%d)", table.concat(tok.keys, ""), i, #tokens), "chord")
            else
                lightVisKeys(tok.keys)
                pressKeys(tok.keys)
                addLog(string.format("♪ %s  (%d/%d)", tok.keys[1], i, #tokens), "success")
            end

            task.wait(getDelay() / 1000)
        end

        if not stopFlag then
            addLog("✅ Done! Sheet played completely.", "info")
        else
            addLog("⏹ Stopped.", "warn")
        end

        resetPlayUI(false)
        updateProgress(#tokens, #tokens)
    end)
end)

-- ── PAUSE / RESUME ────────────────────────────────────────────────────────────
PauseBtn.MouseButton1Click:Connect(function()
    if not isPlaying then return end
    isPaused = not isPaused

    if isPaused then
        PauseBtn.BackgroundColor3 = C.RED
        PauseIcon.Text            = "▶"
        PauseLbl.Text             = "RESUME"
        setStatus("paused")
        addLog(string.format("⏸ Paused at token %d", currentIdx), "warn")
    else
        PauseBtn.BackgroundColor3 = C.SURFACE3
        PauseIcon.Text            = "⏸"
        PauseLbl.Text             = "PAUSE"
        setStatus("playing")
        addLog(string.format("▶ Resumed from token %d", currentIdx), "info")
    end
end)

-- ── CLEAR ────────────────────────────────────────────────────────────────────
ClearBtn.MouseButton1Click:Connect(function()
    stopFlag      = true
    isPaused      = false
    SheetBox.Text = ""
    updateStats({})
    updateProgress(0, 0)
    lightVisKeys({})
    setStatus("idle")
    addLog("🗑 Sheet cleared", "warn")
    task.wait(0.1)  -- Allow the play coroutine to detect stopFlag and exit
    stopFlag = false
    resetPlayUI(true)  -- Pass true → shows "nothing playing yet"
end)

-- ── STATUS DOT PULSE ANIMATION ────────────────────────────────────────────────
task.spawn(function()
    while ScreenGui.Parent do
        if isPlaying and not isPaused then
            tween(StatusDot, { BackgroundTransparency = 0.6 }, 0.5)
            task.wait(0.5)
            tween(StatusDot, { BackgroundTransparency = 0   }, 0.5)
            task.wait(0.5)
        else
            StatusDot.BackgroundTransparency = 0
            task.wait(0.2)
        end
    end
end)

-- ── STARTUP LOG ──────────────────────────────────────────────────────────────
addLog("Auto Piano Player v2.0 ready ✓", "info")
addLog("Sky Music format supported · Mobile & PC", "info")
addLog("by Jepry_Jago112", "default")
