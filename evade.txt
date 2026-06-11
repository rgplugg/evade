-- EVADE Emote + Effect Changer | by @rgplugg

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toggleKey = Enum.KeyCode.U


local function navigateToPath(start, path)
    local current = start
    for part in string.gmatch(path, "([^%.]+)") do
        current = current and current:FindFirstChild(part)
        if not current then return nil end
    end
    return current
end

local function replaceContent(targetPath, sourcePath)
    local target = navigateToPath(ReplicatedStorage, targetPath)
    local source = navigateToPath(ReplicatedStorage, sourcePath)
    if not target or not source then
        warn(string.format("[rgplugg] Swap failed: %s or %s not found.", targetPath, sourcePath))
        return false
    end
    for _, child in pairs(target:GetChildren()) do child:Destroy() end
    for _, child in pairs(source:GetChildren()) do child:Clone().Parent = target end
    return true
end


local EMOTE_GROUPS = {
    {
        title      = "Rockin Stride",
        sourcePath = "Items.Emotes.RockinStride",
        color      = Color3.fromRGB(130, 80, 255),
        hover      = Color3.fromRGB(100, 55, 210),
        targets    = {
            { name = "Kickback",      path = "Items.Emotes.Kickback" },
            { name = "CasualSurfing", path = "Items.Emotes.CasualSurfing" },
            { name = "FrostDrake",    path = "Items.Emotes.FrostDrake" },
        },
    },
    {
        title      = "Zombie Stride",
        sourcePath = "Items.Emotes.ZombieStride",
        color      = Color3.fromRGB(80, 200, 120),
        hover      = Color3.fromRGB(55, 160, 90),
        targets    = {
            { name = "ToyTrainRide", path = "Items.Emotes.ToyTrainRide" },
            { name = "SolarSlayer",  path = "Items.Emotes.SolarSlayer" },
        },
    },
    {
        title      = "Broom of Doom",
        sourcePath = "Items.Emotes.Broom",
        color      = Color3.fromRGB(255, 100, 80),
        hover      = Color3.fromRGB(210, 70, 55),
        targets    = {
            { name = "BoldMarch", path = "Items.Emotes.BoldMarch" },
        },
    },
}



local EFFECT_BASE   = "Items.Cosmetics.PureLove"

local EFFECT_LIST = {
    { name = "ToxicInferno",     path = "Items.Cosmetics.ToxicInferno" },
    { name = "BluefirePortal",   path = "Items.Cosmetics.BluefirePortal" },
    { name = "DarkTendrils",     path = "Items.Cosmetics.DarkTendrils" },
    { name = "CursedEye",        path = "Items.Cosmetics.CursedEye" },
    { name = "FrostFlame",       path = "Items.Cosmetics.FrostFlame" },
    { name = "WinterChains",     path = "Items.Cosmetics.WinterChains" },
    { name = "AngelicRedemption",path = "Items.Cosmetics.AngelicRedemption" },
    { name = "GlacialOutburst",  path = "Items.Cosmetics.GlacialOutburst" },
    { name = "Euphoria",         path = "Items.Cosmetics.Euphoria" },
    { name = "CirclingBeams",    path = "Items.Cosmetics.CirclingBeams" },
    { name = "AlphaTester",      path = "Items.Cosmetics.AlphaTester" },
}



local snapshotRoot  = Instance.new("Folder")
snapshotRoot.Name   = "__rgplugg_snapshot"
snapshotRoot.Parent = ReplicatedStorage

local emoteSnaps  = {}   -- [targetPath] = Folder
local effectSnap  = nil  -- Folder (PureLove original)

-- snapshot emote targets
local seenPaths = {}
for _, group in ipairs(EMOTE_GROUPS) do
    for _, tgt in ipairs(group.targets) do
        if not seenPaths[tgt.path] then
            seenPaths[tgt.path] = true
            local inst = navigateToPath(ReplicatedStorage, tgt.path)
            if inst then
                local snap  = Instance.new("Folder")
                snap.Name   = tgt.path:gsub("%.", "_")
                snap.Parent = snapshotRoot
                for _, child in pairs(inst:GetChildren()) do child:Clone().Parent = snap end
                emoteSnaps[tgt.path] = snap
            end
        end
    end
end

-- snapshot PureLove
local pureLoveInst = navigateToPath(ReplicatedStorage, EFFECT_BASE)
if pureLoveInst then
    effectSnap        = Instance.new("Folder")
    effectSnap.Name   = "effect_PureLove_snap"
    effectSnap.Parent = snapshotRoot
    for _, child in pairs(pureLoveInst:GetChildren()) do child:Clone().Parent = effectSnap end
    print("[rgplugg] Effect snapshot saved: PureLove")
else
    warn("[rgplugg] Could not snapshot PureLove — path not found yet.")
end

local function resetEmotes()
    local ok = true
    for path, snap in pairs(emoteSnaps) do
        local inst = navigateToPath(ReplicatedStorage, path)
        if inst then
            for _, child in pairs(inst:GetChildren()) do child:Destroy() end
            for _, child in pairs(snap:GetChildren()) do child:Clone().Parent = inst end
        else ok = false end
    end
    return ok
end

local function resetEffect()
    local inst = navigateToPath(ReplicatedStorage, EFFECT_BASE)
    if inst and effectSnap then
        for _, child in pairs(inst:GetChildren()) do child:Destroy() end
        for _, child in pairs(effectSnap:GetChildren()) do child:Clone().Parent = inst end
        return true
    end
    return false
end



local W           = 320
local HEADER_H    = 52
local KEYBIND_H   = 32
local TAB_H       = 30
local PAD         = 10
local CARD_H      = 82
local CARD_GAP    = 8
local RESET_H     = 34
local STATUS_H    = 20

-- y where tab content starts (same for both tabs)
local CONTENT_Y = HEADER_H + 6 + KEYBIND_H + 8 + TAB_H + 8

-- emote content height (inside tab)
local EMOTE_CONTENT_H = #EMOTE_GROUPS * (CARD_H + CARD_GAP)
                      + PAD + RESET_H + PAD + STATUS_H + PAD

-- effect content height: grid rows + reset + status
local EFF_COLS     = 3
local EFF_ROWS     = math.ceil(#EFFECT_LIST / EFF_COLS)
local EFF_BTN_H    = 28
local EFF_BTN_GAP  = 5
local EFF_LABEL_H  = 22
local EFFECT_CONTENT_H = PAD + EFF_LABEL_H + PAD
                       + EFF_ROWS * (EFF_BTN_H + EFF_BTN_GAP)
                       + PAD + RESET_H + PAD + STATUS_H + PAD

local TOTAL_H = CONTENT_Y + math.max(EMOTE_CONTENT_H, EFFECT_CONTENT_H)


local screenGui            = Instance.new("ScreenGui")
screenGui.Name             = "rgpluggEmoteChanger"
screenGui.ResetOnSpawn     = false
screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
screenGui.Parent           = playerGui

local mainFrame            = Instance.new("Frame")
mainFrame.Name             = "MainFrame"
mainFrame.Size             = UDim2.new(0, W, 0, TOTAL_H)
mainFrame.Position         = UDim2.new(0, 24, 0.5, -TOTAL_H / 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel  = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent           = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local accent               = Instance.new("Frame")
accent.Size                = UDim2.new(0, 3, 1, 0)
accent.BackgroundColor3    = Color3.fromRGB(130, 80, 255)
accent.BorderSizePixel     = 0
accent.ZIndex              = 2
accent.Parent              = mainFrame
Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)



local header                   = Instance.new("Frame")
header.Size                    = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundTransparency  = 1
header.Parent                  = mainFrame

local titleLabel               = Instance.new("TextLabel")
titleLabel.Text                = "EVADE  Changer"
titleLabel.Font                = Enum.Font.GothamBold
titleLabel.TextSize            = 14
titleLabel.TextColor3          = Color3.fromRGB(240, 240, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size                = UDim2.new(1, -50, 0, 22)
titleLabel.Position            = UDim2.new(0, 14, 0, 6)
titleLabel.TextXAlignment      = Enum.TextXAlignment.Left
titleLabel.Parent              = header

local authorLabel              = Instance.new("TextLabel")
authorLabel.Text               = "by @rgplugg"
authorLabel.Font               = Enum.Font.Gotham
authorLabel.TextSize           = 11
authorLabel.TextColor3         = Color3.fromRGB(120, 130, 160)
authorLabel.BackgroundTransparency = 1
authorLabel.Size               = UDim2.new(1, -50, 0, 16)
authorLabel.Position           = UDim2.new(0, 14, 0, 30)
authorLabel.TextXAlignment     = Enum.TextXAlignment.Left
authorLabel.Parent             = header

local closeBtn                 = Instance.new("TextButton")
closeBtn.Size                  = UDim2.new(0, 28, 0, 28)
closeBtn.Position              = UDim2.new(1, -36, 0, 12)
closeBtn.Text                  = "x"
closeBtn.Font                  = Enum.Font.GothamBold
closeBtn.TextSize              = 13
closeBtn.TextColor3            = Color3.fromRGB(160, 160, 180)
closeBtn.BackgroundColor3      = Color3.fromRGB(35, 35, 46)
closeBtn.BorderSizePixel       = 0
closeBtn.AutoButtonColor       = false
closeBtn.Parent                = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size     = UDim2.new(0, W, 0, 0),
        Position = mainFrame.Position + UDim2.new(0, 0, 0, TOTAL_H / 2),
    }):Play()
    task.delay(0.3, function() snapshotRoot:Destroy(); screenGui:Destroy() end)
end)

local divider1             = Instance.new("Frame")
divider1.Size              = UDim2.new(1, -20, 0, 1)
divider1.Position          = UDim2.new(0, 10, 0, HEADER_H)
divider1.BackgroundColor3  = Color3.fromRGB(40, 40, 55)
divider1.BorderSizePixel   = 0
divider1.Parent            = mainFrame


local keybindY    = HEADER_H + 6

local keybindRow            = Instance.new("Frame")
keybindRow.Size             = UDim2.new(1, -20, 0, KEYBIND_H)
keybindRow.Position         = UDim2.new(0, 10, 0, keybindY)
keybindRow.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
keybindRow.BorderSizePixel  = 0
keybindRow.Parent           = mainFrame
Instance.new("UICorner", keybindRow).CornerRadius = UDim.new(0, 6)

local keybindIcon           = Instance.new("TextLabel")
keybindIcon.Text            = "TOGGLE KEY:"
keybindIcon.Font            = Enum.Font.GothamBold
keybindIcon.TextSize        = 10
keybindIcon.TextColor3      = Color3.fromRGB(110, 120, 150)
keybindIcon.BackgroundTransparency = 1
keybindIcon.Size            = UDim2.new(0, 100, 1, 0)
keybindIcon.Position        = UDim2.new(0, 10, 0, 0)
keybindIcon.TextXAlignment  = Enum.TextXAlignment.Left
keybindIcon.Parent          = keybindRow

local keyBtn                = Instance.new("TextButton")
keyBtn.Size                 = UDim2.new(0, 44, 0, 22)
keyBtn.Position             = UDim2.new(0, 112, 0.5, -11)
keyBtn.Text                 = toggleKey.Name
keyBtn.Font                 = Enum.Font.GothamBold
keyBtn.TextSize             = 11
keyBtn.TextColor3           = Color3.fromRGB(240, 240, 255)
keyBtn.BackgroundColor3     = Color3.fromRGB(50, 50, 68)
keyBtn.BorderSizePixel      = 0
keyBtn.AutoButtonColor      = false
keyBtn.Parent               = keybindRow
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", keyBtn).Color        = Color3.fromRGB(90, 90, 120)

local keybindHint           = Instance.new("TextLabel")
keybindHint.Text            = "click to rebind"
keybindHint.Font            = Enum.Font.Gotham
keybindHint.TextSize        = 9
keybindHint.TextColor3      = Color3.fromRGB(80, 90, 120)
keybindHint.BackgroundTransparency = 1
keybindHint.Size            = UDim2.new(1, -170, 1, 0)
keybindHint.Position        = UDim2.new(0, 164, 0, 0)
keybindHint.TextXAlignment  = Enum.TextXAlignment.Left
keybindHint.Parent          = keybindRow

local listeningForKey = false

keyBtn.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey     = true
    keyBtn.Text         = "..."
    keyBtn.TextColor3   = Color3.fromRGB(255, 200, 80)
    keybindHint.Text    = "press any key"

    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey         = input.KeyCode
            keyBtn.Text       = input.KeyCode.Name
            keyBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
            keybindHint.Text  = "click to rebind"
            conn:Disconnect()
            task.defer(function() listeningForKey = false end)
        end
    end)
end)


local tabY = keybindY + KEYBIND_H + 8

local tabRow             = Instance.new("Frame")
tabRow.Size              = UDim2.new(1, -20, 0, TAB_H)
tabRow.Position          = UDim2.new(0, 10, 0, tabY)
tabRow.BackgroundColor3  = Color3.fromRGB(24, 24, 32)
tabRow.BorderSizePixel   = 0
tabRow.Parent            = mainFrame
Instance.new("UICorner", tabRow).CornerRadius = UDim.new(0, 7)

local TAB_ACT_BG  = Color3.fromRGB(50, 50, 68)
local TAB_IDLE_BG = Color3.fromRGB(24, 24, 32)
local TAB_ACT_TX  = Color3.fromRGB(240, 240, 255)
local TAB_IDLE_TX = Color3.fromRGB(90, 100, 130)

local tabEmoteBtn        = Instance.new("TextButton")
tabEmoteBtn.Size         = UDim2.new(0.5, -3, 1, -6)
tabEmoteBtn.Position     = UDim2.new(0, 3, 0, 3)
tabEmoteBtn.Text         = "EMOTES"
tabEmoteBtn.Font         = Enum.Font.GothamBold
tabEmoteBtn.TextSize     = 11
tabEmoteBtn.TextColor3   = TAB_ACT_TX
tabEmoteBtn.BackgroundColor3 = TAB_ACT_BG
tabEmoteBtn.BorderSizePixel  = 0
tabEmoteBtn.AutoButtonColor  = false
tabEmoteBtn.Parent       = tabRow
Instance.new("UICorner", tabEmoteBtn).CornerRadius = UDim.new(0, 5)

local tabEffectBtn       = Instance.new("TextButton")
tabEffectBtn.Size        = UDim2.new(0.5, -3, 1, -6)
tabEffectBtn.Position    = UDim2.new(0.5, 0, 0, 3)
tabEffectBtn.Text        = "EFFECTS"
tabEffectBtn.Font        = Enum.Font.GothamBold
tabEffectBtn.TextSize    = 11
tabEffectBtn.TextColor3  = TAB_IDLE_TX
tabEffectBtn.BackgroundColor3 = TAB_IDLE_BG
tabEffectBtn.BorderSizePixel  = 0
tabEffectBtn.AutoButtonColor  = false
tabEffectBtn.Parent      = tabRow
Instance.new("UICorner", tabEffectBtn).CornerRadius = UDim.new(0, 5)

local divider2             = Instance.new("Frame")
divider2.Size              = UDim2.new(1, -20, 0, 1)
divider2.Position          = UDim2.new(0, 10, 0, tabY + TAB_H + 4)
divider2.BackgroundColor3  = Color3.fromRGB(40, 40, 55)
divider2.BorderSizePixel   = 0
divider2.Parent            = mainFrame



local statusLabel          = Instance.new("TextLabel")
statusLabel.Text           = ""
statusLabel.Font           = Enum.Font.Gotham
statusLabel.TextSize       = 11
statusLabel.TextColor3     = Color3.fromRGB(100, 220, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Size           = UDim2.new(1, -20, 0, STATUS_H)
statusLabel.Position       = UDim2.new(0, 14, 1, -(STATUS_H + PAD))
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent         = mainFrame

local function flashStatus(msg, success)
    statusLabel.TextColor3 = success
        and Color3.fromRGB(100, 220, 130)
        or  Color3.fromRGB(255, 90, 90)
    statusLabel.Text = msg
    task.delay(3, function()
        if statusLabel and statusLabel.Parent then statusLabel.Text = "" end
    end)
end



local emoteContainer       = Instance.new("Frame")
emoteContainer.Size        = UDim2.new(1, 0, 0, EMOTE_CONTENT_H)
emoteContainer.Position    = UDim2.new(0, 0, 0, CONTENT_Y)
emoteContainer.BackgroundTransparency = 1
emoteContainer.Visible     = true
emoteContainer.Parent      = mainFrame

local SEL_COLOR   = Color3.fromRGB(50, 50, 68)
local UNSEL_COLOR = Color3.fromRGB(30, 30, 42)
local SEL_TEXT    = Color3.fromRGB(240, 240, 255)
local UNSEL_TEXT  = Color3.fromRGB(100, 110, 140)

for i, group in ipairs(EMOTE_GROUPS) do
    local yPos = (i - 1) * (CARD_H + CARD_GAP)

    local card               = Instance.new("Frame")
    card.Size                = UDim2.new(1, -20, 0, CARD_H)
    card.Position            = UDim2.new(0, 10, 0, yPos)
    card.BackgroundColor3    = Color3.fromRGB(24, 24, 34)
    card.BorderSizePixel     = 0
    card.Parent              = emoteContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local bar                = Instance.new("Frame")
    bar.Size                 = UDim2.new(0, 4, 0.75, 0)
    bar.Position             = UDim2.new(0, 0, 0.125, 0)
    bar.BackgroundColor3     = group.color
    bar.BorderSizePixel      = 0
    bar.Parent               = card
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local srcLabel           = Instance.new("TextLabel")
    srcLabel.Text            = group.title
    srcLabel.Font            = Enum.Font.GothamBold
    srcLabel.TextSize        = 13
    srcLabel.TextColor3      = Color3.fromRGB(235, 235, 250)
    srcLabel.BackgroundTransparency = 1
    srcLabel.Size            = UDim2.new(1, -110, 0, 20)
    srcLabel.Position        = UDim2.new(0, 14, 0, 8)
    srcLabel.TextXAlignment  = Enum.TextXAlignment.Left
    srcLabel.Parent          = card

    local replaceLabel       = Instance.new("TextLabel")
    replaceLabel.Text        = "Replace:"
    replaceLabel.Font        = Enum.Font.Gotham
    replaceLabel.TextSize    = 10
    replaceLabel.TextColor3  = Color3.fromRGB(90, 100, 130)
    replaceLabel.BackgroundTransparency = 1
    replaceLabel.Size        = UDim2.new(0, 55, 0, 16)
    replaceLabel.Position    = UDim2.new(0, 14, 0, 32)
    replaceLabel.TextXAlignment = Enum.TextXAlignment.Left
    replaceLabel.Parent      = card

    local selectedIdx = 1
    local targetBtns  = {}
    local targetAreaW = W - 20 - 14 - 55 - 4 - 78 - 8
    local tBtnW       = math.floor(targetAreaW / #group.targets) - 3

    for j, tgt in ipairs(group.targets) do
        local xOffset = 14 + 55 + 4 + (j - 1) * (tBtnW + 3)

        local tBtn               = Instance.new("TextButton")
        tBtn.Size                = UDim2.new(0, tBtnW, 0, 20)
        tBtn.Position            = UDim2.new(0, xOffset, 0, 32)
        tBtn.Text                = tgt.name
        tBtn.Font                = Enum.Font.Gotham
        tBtn.TextSize            = 10
        tBtn.TextColor3          = j == 1 and SEL_TEXT or UNSEL_TEXT
        tBtn.BackgroundColor3    = j == 1 and SEL_COLOR or UNSEL_COLOR
        tBtn.BorderSizePixel     = 0
        tBtn.AutoButtonColor     = false
        tBtn.TextTruncate        = Enum.TextTruncate.AtEnd
        tBtn.Parent              = card
        Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)
        if j == 1 then
            local s = Instance.new("UIStroke"); s.Color = group.color; s.Thickness = 1; s.Parent = tBtn
        end
        targetBtns[j] = { btn = tBtn, stroke = tBtn:FindFirstChildOfClass("UIStroke") }

        tBtn.MouseButton1Click:Connect(function()
            selectedIdx = j
            for k, tb in ipairs(targetBtns) do
                tb.btn.TextColor3     = k == j and SEL_TEXT or UNSEL_TEXT
                tb.btn.BackgroundColor3 = k == j and SEL_COLOR or UNSEL_COLOR
                if tb.stroke then tb.stroke:Destroy(); targetBtns[k].stroke = nil end
                if k == j then
                    local s = Instance.new("UIStroke"); s.Color = group.color; s.Thickness = 1; s.Parent = tb.btn
                    targetBtns[k].stroke = s
                end
            end
        end)
    end

    local applyBtn           = Instance.new("TextButton")
    applyBtn.Size            = UDim2.new(0, 78, 0, 56)
    applyBtn.Position        = UDim2.new(1, -86, 0, 13)
    applyBtn.Text            = "APPLY"
    applyBtn.Font            = Enum.Font.GothamBold
    applyBtn.TextSize        = 12
    applyBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
    applyBtn.BackgroundColor3 = group.color
    applyBtn.BorderSizePixel = 0
    applyBtn.AutoButtonColor = false
    applyBtn.Parent          = card
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

    applyBtn.MouseEnter:Connect(function()
        TweenService:Create(applyBtn, TweenInfo.new(0.12), { BackgroundColor3 = group.hover }):Play()
    end)
    applyBtn.MouseLeave:Connect(function()
        TweenService:Create(applyBtn, TweenInfo.new(0.12), { BackgroundColor3 = group.color }):Play()
    end)

    applyBtn.MouseButton1Click:Connect(function()
        applyBtn.Text = "..."
        local chosenTarget = group.targets[selectedIdx]
        local ok = replaceContent(chosenTarget.path, group.sourcePath)
        applyBtn.Text       = ok and "DONE v" or "FAILED"
        applyBtn.TextColor3 = ok and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 80, 80)
        flashStatus(
            ok and (chosenTarget.name .. "  replaced by  " .. group.title)
               or ("Failed: " .. chosenTarget.name), ok)
        task.delay(1.8, function()
            if applyBtn and applyBtn.Parent then
                applyBtn.Text = "APPLY"; applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end)
end


local emoteResetY  = #EMOTE_GROUPS * (CARD_H + CARD_GAP) + PAD

local emoteResetBtn            = Instance.new("TextButton")
emoteResetBtn.Size             = UDim2.new(1, -20, 0, RESET_H)
emoteResetBtn.Position         = UDim2.new(0, 10, 0, emoteResetY)
emoteResetBtn.Text             = "RESET ALL EMOTES"
emoteResetBtn.Font             = Enum.Font.GothamBold
emoteResetBtn.TextSize         = 12
emoteResetBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
emoteResetBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
emoteResetBtn.BorderSizePixel  = 0
emoteResetBtn.AutoButtonColor  = false
emoteResetBtn.Parent           = emoteContainer
Instance.new("UICorner", emoteResetBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", emoteResetBtn).Color        = Color3.fromRGB(85, 85, 110)

emoteResetBtn.MouseEnter:Connect(function()
    TweenService:Create(emoteResetBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(62, 62, 80) }):Play()
end)
emoteResetBtn.MouseLeave:Connect(function()
    TweenService:Create(emoteResetBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(48, 48, 62) }):Play()
end)
emoteResetBtn.MouseButton1Click:Connect(function()
    emoteResetBtn.Text = "Restoring..."
    local ok = resetEmotes()
    emoteResetBtn.Text      = ok and "RESTORED v" or "FAILED"
    emoteResetBtn.TextColor3 = ok and Color3.fromRGB(100, 220, 130) or Color3.fromRGB(255, 80, 80)
    flashStatus(ok and "All emotes restored!" or "Some restores failed.", ok)
    task.delay(2, function()
        if emoteResetBtn and emoteResetBtn.Parent then
            emoteResetBtn.Text = "RESET ALL EMOTES"; emoteResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end)


local effectContainer      = Instance.new("Frame")
effectContainer.Size       = UDim2.new(1, 0, 0, EFFECT_CONTENT_H)
effectContainer.Position   = UDim2.new(0, 0, 0, CONTENT_Y)
effectContainer.BackgroundTransparency = 1
effectContainer.Visible    = false
effectContainer.Parent     = mainFrame

-- "Current effect" label
local effCurLabel          = Instance.new("TextLabel")
effCurLabel.Text           = "Base: PureLove  |  Select effect below"
effCurLabel.Font           = Enum.Font.Gotham
effCurLabel.TextSize       = 10
effCurLabel.TextColor3     = Color3.fromRGB(100, 110, 140)
effCurLabel.BackgroundTransparency = 1
effCurLabel.Size           = UDim2.new(1, -20, 0, EFF_LABEL_H)
effCurLabel.Position       = UDim2.new(0, 10, 0, PAD)
effCurLabel.TextXAlignment = Enum.TextXAlignment.Left
effCurLabel.Parent         = effectContainer


local EFF_COLOR   = Color3.fromRGB(80, 140, 255)
local EFF_HOVER   = Color3.fromRGB(55, 110, 210)
local EFF_ACTIVE  = Color3.fromRGB(50, 180, 120)

local effBtnW     = math.floor((W - 20 - (EFF_COLS - 1) * EFF_BTN_GAP) / EFF_COLS)
local effGridY    = PAD + EFF_LABEL_H + PAD

local activeEffBtn = nil   -- track the currently active effect button

for idx, eff in ipairs(EFFECT_LIST) do
    local col = (idx - 1) % EFF_COLS
    local row = math.floor((idx - 1) / EFF_COLS)

    local xPos = 10 + col * (effBtnW + EFF_BTN_GAP)
    local yPos = effGridY + row * (EFF_BTN_H + EFF_BTN_GAP)

    local effBtn             = Instance.new("TextButton")
    effBtn.Size              = UDim2.new(0, effBtnW, 0, EFF_BTN_H)
    effBtn.Position          = UDim2.new(0, xPos, 0, yPos)
    effBtn.Text              = eff.name
    effBtn.Font              = Enum.Font.Gotham
    effBtn.TextSize          = 10
    effBtn.TextColor3        = Color3.fromRGB(220, 220, 240)
    effBtn.BackgroundColor3  = Color3.fromRGB(28, 28, 40)
    effBtn.BorderSizePixel   = 0
    effBtn.AutoButtonColor   = false
    effBtn.TextTruncate      = Enum.TextTruncate.AtEnd
    effBtn.Parent            = effectContainer
    Instance.new("UICorner", effBtn).CornerRadius = UDim.new(0, 6)

    local effStroke          = Instance.new("UIStroke")
    effStroke.Color          = Color3.fromRGB(50, 50, 70)
    effStroke.Thickness      = 1
    effStroke.Parent         = effBtn

    effBtn.MouseEnter:Connect(function()
        if effBtn ~= activeEffBtn then
            TweenService:Create(effBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(38, 38, 55) }):Play()
        end
    end)
    effBtn.MouseLeave:Connect(function()
        if effBtn ~= activeEffBtn then
            TweenService:Create(effBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(28, 28, 40) }):Play()
        end
    end)

    effBtn.MouseButton1Click:Connect(function()
        -- auto-reset PureLove first, then apply new effect
        resetEffect()
        local ok = replaceContent(EFFECT_BASE, eff.path)

        -- deactivate previous active button
        if activeEffBtn and activeEffBtn ~= effBtn then
            TweenService:Create(activeEffBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(28, 28, 40),
            }):Play()
            local prevStroke = activeEffBtn:FindFirstChildOfClass("UIStroke")
            if prevStroke then prevStroke.Color = Color3.fromRGB(50, 50, 70) end
        end

        if ok then
            activeEffBtn = effBtn
            TweenService:Create(effBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(30, 60, 40),
            }):Play()
            effStroke.Color = EFF_ACTIVE
            effCurLabel.Text = "Active: " .. eff.name
            flashStatus("Effect applied: " .. eff.name, true)
        else
            flashStatus("Failed to apply: " .. eff.name, false)
        end
    end)
end


local effResetY = effGridY + EFF_ROWS * (EFF_BTN_H + EFF_BTN_GAP) + PAD

local effResetBtn              = Instance.new("TextButton")
effResetBtn.Size               = UDim2.new(1, -20, 0, RESET_H)
effResetBtn.Position           = UDim2.new(0, 10, 0, effResetY)
effResetBtn.Text               = "RESET EFFECT"
effResetBtn.Font               = Enum.Font.GothamBold
effResetBtn.TextSize           = 12
effResetBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
effResetBtn.BackgroundColor3   = Color3.fromRGB(48, 48, 62)
effResetBtn.BorderSizePixel    = 0
effResetBtn.AutoButtonColor    = false
effResetBtn.Parent             = effectContainer
Instance.new("UICorner", effResetBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", effResetBtn).Color        = Color3.fromRGB(85, 85, 110)

effResetBtn.MouseEnter:Connect(function()
    TweenService:Create(effResetBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(62, 62, 80) }):Play()
end)
effResetBtn.MouseLeave:Connect(function()
    TweenService:Create(effResetBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(48, 48, 62) }):Play()
end)

effResetBtn.MouseButton1Click:Connect(function()
    effResetBtn.Text = "Restoring..."
    local ok = resetEffect()
    -- clear active button highlight
    if activeEffBtn then
        TweenService:Create(activeEffBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(28, 28, 40) }):Play()
        local s = activeEffBtn:FindFirstChildOfClass("UIStroke")
        if s then s.Color = Color3.fromRGB(50, 50, 70) end
        activeEffBtn = nil
    end
    effCurLabel.Text = "Base: PureLove  |  Select effect below"
    effResetBtn.Text       = ok and "RESTORED v" or "FAILED"
    effResetBtn.TextColor3 = ok and Color3.fromRGB(100, 220, 130) or Color3.fromRGB(255, 80, 80)
    flashStatus(ok and "Effect restored to PureLove!" or "Reset failed.", ok)
    task.delay(2, function()
        if effResetBtn and effResetBtn.Parent then
            effResetBtn.Text = "RESET EFFECT"; effResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end)



local function switchTab(toEffects)
    emoteContainer.Visible  = not toEffects
    effectContainer.Visible = toEffects

    tabEmoteBtn.TextColor3       = toEffects and TAB_IDLE_TX or TAB_ACT_TX
    tabEmoteBtn.BackgroundColor3 = toEffects and TAB_IDLE_BG or TAB_ACT_BG
    tabEffectBtn.TextColor3      = toEffects and TAB_ACT_TX  or TAB_IDLE_TX
    tabEffectBtn.BackgroundColor3= toEffects and TAB_ACT_BG  or TAB_IDLE_BG
end

tabEmoteBtn.MouseButton1Click:Connect(function()  switchTab(false) end)
tabEffectBtn.MouseButton1Click:Connect(function() switchTab(true)  end)



local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)



local menuVisible = true

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if listeningForKey then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
        menuVisible = not menuVisible
        mainFrame.Visible = menuVisible
    end
end)



local savedSize = mainFrame.Size
mainFrame.Size  = UDim2.new(0, W, 0, 0)
mainFrame.BackgroundTransparency = 1

TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size                   = savedSize,
    BackgroundTransparency = 0,
}):Play()

print(string.format("[rgplugg] EVADE Changer loaded | Toggle: %s", toggleKey.Name))
