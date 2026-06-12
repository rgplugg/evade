-- EVADE Changer | by @rgplugg |

local RS      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local Players = game:GetService("Players")
local pGui    = Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleKey = Enum.KeyCode.U

local BG     = Color3.fromRGB( 9,  9, 13)
local PANEL  = Color3.fromRGB(18, 18, 26)
local PANEL2 = Color3.fromRGB(26, 26, 36)
local PANEL3 = Color3.fromRGB(38, 38, 52)
local BORDER = Color3.fromRGB(46, 46, 64)
local SEL    = Color3.fromRGB(54, 54, 74)
local TXT    = Color3.fromRGB(222, 222, 238)
local TXT2   = Color3.fromRGB(128, 128, 150)
local TXT3   = Color3.fromRGB(64,  64,  86)
local OK_C   = Color3.fromRGB(140, 210, 140)
local ERR_C  = Color3.fromRGB(210, 100, 100)

local function nav(root, path)
    local c = root
    for p in path:gmatch("([^%.]+)") do
        c = c and c:FindFirstChild(p)
        if not c then return nil end
    end
    return c
end

local function swapContent(tgt, src)
    local t = nav(RS, tgt); local s = nav(RS, src)
    if not t or not s then warn("[rg] miss:"..tgt.."/"..src); return false end
    for _, c in pairs(t:GetChildren()) do c:Destroy() end
    for _, c in pairs(s:GetChildren()) do c:Clone().Parent = t end
    return true
end

local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p end
local function bdr(p, col) local s=Instance.new("UIStroke"); s.Color=col or BORDER; s.Thickness=1; s.Parent=p end

local EMOTES = {
    { n="Rockin Stride", src="Items.Emotes.RockinStride",
      tgts={{ n="Kickback",      p="Items.Emotes.Kickback" },
            { n="CasualSurfing", p="Items.Emotes.CasualSurfing" },
            { n="FrostDrake",    p="Items.Emotes.FrostDrake" }} },
    { n="Zombie Stride", src="Items.Emotes.ZombieStride",
      tgts={{ n="ToyTrainRide", p="Items.Emotes.ToyTrainRide" },
            { n="SolarSlayer",  p="Items.Emotes.SolarSlayer" },
            { n="SwagWalk",     p="Items.Emotes.SwagWalk" }} },
    { n="Broom of Doom", src="Items.Emotes.Broom",
      tgts={{ n="BoldMarch", p="Items.Emotes.BoldMarch" },
            { n="SwagWalk",  p="Items.Emotes.SwagWalk" }} },
}

local BASES = {
    { n="BlueAbduction",  p="Items.Cosmetics.BlueAbduction" },
    { n="GreenAbduction", p="Items.Cosmetics.GreenAbduction" },
    { n="PureLove",       p="Items.Cosmetics.PureLove" },
    { n="RedAbduction",   p="Items.Cosmetics.RedAbduction" },
}

local EFFS = {
    { n="Adoration",          p="Items.Cosmetics.Adoration" },
    { n="AlphaTester",        p="Items.Cosmetics.AlphaTester" },
    { n="AngelicRedemption",  p="Items.Cosmetics.AngelicRedemption" },
    { n="AnimalAura",         p="Items.Cosmetics.AnimalAura" },
    { n="AuroranStag",        p="Items.Cosmetics.AuroranStag" },
    { n="BeeShield",          p="Items.Cosmetics.BeeShield" },
    { n="BionicRejuvination", p="Items.Cosmetics.BionicRejuvination" },
    { n="BloodMoon",          p="Items.Cosmetics.BloodMoon" },
    { n="BluefirePortal",     p="Items.Cosmetics.BluefirePortal" },
    { n="ChaoticRadiance",    p="Items.Cosmetics.ChaoticRadiance" },
    { n="CirclingBeams",      p="Items.Cosmetics.CirclingBeams" },
    { n="CursedEye",          p="Items.Cosmetics.CursedEye" },
    { n="DarkTendrils",       p="Items.Cosmetics.DarkTendrils" },
    { n="DoggoAura",          p="Items.Cosmetics.DoggoAura" },
    { n="EclipseCrown",       p="Items.Cosmetics.EclipseCrown" },
    { n="EclipseNova",        p="Items.Cosmetics.EclipseNova" },
    { n="Euphoria",           p="Items.Cosmetics.Euphoria" },
    { n="FrigidPerception",   p="Items.Cosmetics.FrigidPerception" },
    { n="FrostFlame",         p="Items.Cosmetics.FrostFlame" },
    { n="GildedStag",         p="Items.Cosmetics.GildedStag" },
    { n="GlacialOutburst",    p="Items.Cosmetics.GlacialOutburst" },
    { n="GlowingHaze",        p="Items.Cosmetics.GlowingHaze" },
    { n="HallowedSpecters",   p="Items.Cosmetics.HallowedSpecters" },
    { n="HellfirePortal",     p="Items.Cosmetics.HellfirePortal" },
    { n="KoiPond",            p="Items.Cosmetics.KoiPond" },
    { n="MidasTouch",         p="Items.Cosmetics.MidasTouch" },
    { n="OminousDemise",      p="Items.Cosmetics.OminousDemise" },
    { n="OozingMoney",        p="Items.Cosmetics.OozingMoney" },
    { n="ShimmeringCoronet",  p="Items.Cosmetics.ShimmeringCoronet" },
    { n="SpawnHalo",          p="Items.Cosmetics.SpawnHalo" },
    { n="Technotic",          p="Items.Cosmetics.Technotic" },
    { n="ToxicInferno",       p="Items.Cosmetics.ToxicInferno" },
    { n="VerdantStag",        p="Items.Cosmetics.VerdantStag" },
    { n="WinterChains",       p="Items.Cosmetics.WinterChains" },
}

local snapRoot = Instance.new("Folder"); snapRoot.Name="__rg_snap5"; snapRoot.Parent=RS
local eSnaps={}; local bSnaps={}

local seen={}
for _, g in ipairs(EMOTES) do
    for _, t in ipairs(g.tgts) do
        if not seen[t.p] then seen[t.p]=true
            local inst=nav(RS,t.p)
            if inst then
                local f=Instance.new("Folder"); f.Name=t.p:gsub("%.","-"); f.Parent=snapRoot
                for _,c in pairs(inst:GetChildren()) do c:Clone().Parent=f end
                eSnaps[t.p]=f
            end
        end
    end
end

for _, b in ipairs(BASES) do
    local inst=nav(RS,b.p)
    if inst then
        local f=Instance.new("Folder"); f.Name="b-"..b.n; f.Parent=snapRoot
        for _,c in pairs(inst:GetChildren()) do c:Clone().Parent=f end
        bSnaps[b.p]=f
        print("[rg] snap:"..b.n)
    end
end

local function resetEmotes()
    local ok=true
    for path, snap in pairs(eSnaps) do
        local i=nav(RS,path)
        if i then
            for _,c in pairs(i:GetChildren()) do c:Destroy() end
            for _,c in pairs(snap:GetChildren()) do c:Clone().Parent=i end
        else ok=false end
    end; return ok
end

local function resetBase(p)
    local inst=nav(RS,p); local snap=bSnaps[p]
    if inst and snap then
        for _,c in pairs(inst:GetChildren()) do c:Destroy() end
        for _,c in pairs(snap:GetChildren()) do c:Clone().Parent=inst end
        return true end; return false
end

local W        = 280
local HDR_H    = 48
local KEY_H    = 30
local TAB_H    = 26
local CONT_Y   = HDR_H + 7 + KEY_H + 8 + TAB_H + 8   -- = 129
local CONT_H   = 270   -- content area height (both containers same height)
local STATUS_H = 20
local TOTAL_H  = CONT_Y + CONT_H + 8 + STATUS_H + 8   -- = 435

local sg = Instance.new("ScreenGui")
sg.Name="rgCosmic"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=pGui

local mf = Instance.new("Frame")
mf.Name="M"; mf.Size=UDim2.new(0,W,0,TOTAL_H)
mf.Position=UDim2.new(0,-W-10,0.5,-TOTAL_H/2)  -- starts off-screen left for slide-in
mf.BackgroundColor3=BG; mf.BorderSizePixel=0; mf.Parent=sg
corner(mf,10); bdr(mf,BORDER)

local starBg = Instance.new("Frame")
starBg.Size=UDim2.new(1,0,1,0); starBg.BackgroundTransparency=1
starBg.BorderSizePixel=0; starBg.ZIndex=1; starBg.Parent=mf

math.randomseed(os.clock() * 997)
local function rnd(a,b) return a + math.random() * (b-a) end

local function animStar(s)
    while s and s.Parent do
        local dur = rnd(9, 22)
        TS:Create(s, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position            = UDim2.new(0, math.random(1, W-3), 0, math.random(1, TOTAL_H-3)),
            BackgroundTransparency = rnd(0.05, 0.72),
        }):Play()
        task.wait(dur)
    end
end

for i = 1, 32 do
    local sz = math.random(1,2)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(0, sz, 0, sz)
    s.Position = UDim2.new(0, math.random(1,W-3), 0, math.random(1,TOTAL_H-3))
    local br = math.random(195, 255)
    s.BackgroundColor3 = Color3.fromRGB(br, br, math.min(255, br+20))
    s.BackgroundTransparency = rnd(0.1, 0.65)
    s.BorderSizePixel=0; s.ZIndex=1; s.Parent=starBg
    corner(s, 2)
    task.spawn(animStar, s)
end

local hdr = Instance.new("Frame")
hdr.Size=UDim2.new(1,0,0,HDR_H); hdr.BackgroundTransparency=1; hdr.ZIndex=2; hdr.Parent=mf

local function lbl(txt, fs, col, sz, pos, fa, par)
    local l=Instance.new("TextLabel"); l.Text=txt; l.Font=fa or Enum.Font.Gotham
    l.TextSize=fs; l.TextColor3=col; l.BackgroundTransparency=1
    l.Size=sz; l.Position=pos; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=3; l.Parent=par
    return l
end

lbl("EVADE  Changer", 14, TXT, UDim2.new(1,-46,0,20), UDim2.new(0,14,0,6), Enum.Font.GothamBold, hdr)
lbl("by @rgplugg",    10, TXT,  UDim2.new(1,-46,0,16), UDim2.new(0,14,0,28), nil, hdr)

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,24,0,24); closeBtn.Position=UDim2.new(1,-31,0,12)
closeBtn.Text="x"; closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=11
closeBtn.TextColor3=TXT2; closeBtn.BackgroundColor3=PANEL2; closeBtn.BorderSizePixel=0
closeBtn.AutoButtonColor=false; closeBtn.ZIndex=3; closeBtn.Parent=hdr; corner(closeBtn,5)
closeBtn.MouseButton1Click:Connect(function() snapRoot:Destroy(); sg:Destroy() end)

local function sep(y) local f=Instance.new("Frame"); f.Size=UDim2.new(1,-20,0,1); f.Position=UDim2.new(0,10,0,y); f.BackgroundColor3=BORDER; f.BorderSizePixel=0; f.ZIndex=2; f.Parent=mf; return f end
sep(HDR_H)

local kyY = HDR_H + 7
local kyRow = Instance.new("Frame")
kyRow.Size=UDim2.new(1,-20,0,KEY_H); kyRow.Position=UDim2.new(0,10,0,kyY)
kyRow.BackgroundColor3=PANEL; kyRow.BorderSizePixel=0; kyRow.ZIndex=2; kyRow.Parent=mf
corner(kyRow); bdr(kyRow)

lbl("TOGGLE:", 9, TXT3, UDim2.new(0,58,1,0), UDim2.new(0,8,0,0), Enum.Font.GothamBold, kyRow)

local keyBtn = Instance.new("TextButton")
keyBtn.Size=UDim2.new(0,40,0,20); keyBtn.Position=UDim2.new(0,68,0.5,-10)
keyBtn.Text=toggleKey.Name; keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=10
keyBtn.TextColor3=TXT; keyBtn.BackgroundColor3=PANEL2; keyBtn.BorderSizePixel=0
keyBtn.AutoButtonColor=false; keyBtn.ZIndex=3; keyBtn.Parent=kyRow; corner(keyBtn,4); bdr(keyBtn)

local kyHint=lbl("click to rebind", 8, TXT3, UDim2.new(1,-116,1,0), UDim2.new(0,114,0,0), nil, kyRow)

local listeningForKey=false
keyBtn.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey=true; keyBtn.Text="..."; keyBtn.TextColor3=Color3.fromRGB(200,195,100)
    kyHint.Text="press any key"
    local conn; conn=UIS.InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            toggleKey=inp.KeyCode; keyBtn.Text=inp.KeyCode.Name; keyBtn.TextColor3=TXT
            kyHint.Text="click to rebind"; conn:Disconnect()
            task.defer(function() listeningForKey=false end)
        end
    end)
end)

sep(kyY + KEY_H + 4)

local tabY = kyY + KEY_H + 9
local tabRow = Instance.new("Frame")
tabRow.Size=UDim2.new(1,-20,0,TAB_H); tabRow.Position=UDim2.new(0,10,0,tabY)
tabRow.BackgroundColor3=PANEL; tabRow.BorderSizePixel=0; tabRow.ZIndex=2; tabRow.Parent=mf
corner(tabRow,6); bdr(tabRow)

local function makeTabBtn(text, xScale, xOff)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.5,-3,1,-4); b.Position=UDim2.new(xScale,xOff,0,2)
    b.Text=text; b.Font=Enum.Font.GothamBold; b.TextSize=10
    b.TextColor3=TXT2; b.BackgroundColor3=PANEL; b.BorderSizePixel=0
    b.AutoButtonColor=false; b.ZIndex=3; b.Parent=tabRow; corner(b,5)
    return b
end
local tabE=makeTabBtn("EMOTES",   0,  2)
local tabF=makeTabBtn("EFFECTS",0.5,  1)
-- set initial active state
tabE.TextColor3=TXT; tabE.BackgroundColor3=PANEL2

sep(tabY + TAB_H + 4)

local statusY = CONT_Y + CONT_H + 8
local statusLbl = Instance.new("TextLabel")
statusLbl.Text=""; statusLbl.Font=Enum.Font.Gotham; statusLbl.TextSize=10
statusLbl.TextColor3=TXT2; statusLbl.BackgroundTransparency=1
statusLbl.Size=UDim2.new(1,-20,0,STATUS_H); statusLbl.Position=UDim2.new(0,10,0,statusY)
statusLbl.TextXAlignment=Enum.TextXAlignment.Left; statusLbl.ZIndex=3; statusLbl.Parent=mf

local function flash(msg, ok)
    statusLbl.TextColor3=ok and OK_C or ERR_C; statusLbl.Text=msg
    task.delay(3, function() if statusLbl and statusLbl.Parent then statusLbl.Text="" end end)
end


local function makeDropdown(parent, x, y, w, label, options, placeholder, onSelect)
    local PAD_X = 10
    local TRIG_H = 26
    local ITEM_H = 25

    local wrapper = Instance.new("Frame")
    wrapper.Size=UDim2.new(0,w,0,TRIG_H + #options*ITEM_H + 4)
    wrapper.Position=UDim2.new(0,x,0,y)
    wrapper.BackgroundTransparency=1; wrapper.ZIndex=8; wrapper.ClipsDescendants=false
    wrapper.BorderSizePixel=0; wrapper.Parent=parent


    local lbAbove=Instance.new("TextLabel")
    lbAbove.Text=label; lbAbove.Font=Enum.Font.GothamBold; lbAbove.TextSize=9
    lbAbove.TextColor3=TXT3; lbAbove.BackgroundTransparency=1
    lbAbove.Size=UDim2.new(1,0,0,12); lbAbove.Position=UDim2.new(0,0,0,-14)
    lbAbove.TextXAlignment=Enum.TextXAlignment.Left; lbAbove.ZIndex=3; lbAbove.Parent=wrapper

    local trig=Instance.new("Frame")
    trig.Size=UDim2.new(1,0,0,TRIG_H); trig.Position=UDim2.new(0,0,0,0)
    trig.BackgroundColor3=PANEL2; trig.BackgroundTransparency=0.45; trig.BorderSizePixel=0; trig.ZIndex=3; trig.Parent=wrapper
    corner(trig); bdr(trig)

    local selLbl=Instance.new("TextLabel")
    selLbl.Text=placeholder; selLbl.Font=Enum.Font.Gotham; selLbl.TextSize=11
    selLbl.TextColor3=TXT2; selLbl.BackgroundTransparency=1
    selLbl.Size=UDim2.new(1,-26,1,0); selLbl.Position=UDim2.new(0,PAD_X,0,0)
    selLbl.TextXAlignment=Enum.TextXAlignment.Left; selLbl.ZIndex=4; selLbl.Parent=trig

    local chev=Instance.new("TextLabel")
    chev.Text="v"; chev.Font=Enum.Font.GothamBold; chev.TextSize=9
    chev.TextColor3=TXT3; chev.BackgroundTransparency=1
    chev.Size=UDim2.new(0,20,1,0); chev.Position=UDim2.new(1,-22,0,0)
    chev.TextXAlignment=Enum.TextXAlignment.Center; chev.ZIndex=4; chev.Parent=trig


    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""
    hit.ZIndex=5; hit.Parent=trig


    local listH = #options * ITEM_H + 4
    local listF=Instance.new("Frame")
    listF.Size=UDim2.new(1,0,0,listH); listF.Position=UDim2.new(0,0,0,TRIG_H+2)
    listF.BackgroundColor3=PANEL3; listF.BorderSizePixel=0; listF.ZIndex=10
    listF.Visible=false; listF.Parent=wrapper; corner(listF); bdr(listF)

    for i, opt in ipairs(options) do
        local itemBtn=Instance.new("TextButton")
        itemBtn.Size=UDim2.new(1,-4,0,ITEM_H); itemBtn.Position=UDim2.new(0,2,0,(i-1)*ITEM_H+2)
        itemBtn.Text=opt.n; itemBtn.Font=Enum.Font.Gotham; itemBtn.TextSize=11
        itemBtn.TextColor3=TXT; itemBtn.BackgroundTransparency=1; itemBtn.BorderSizePixel=0
        itemBtn.AutoButtonColor=false; itemBtn.ZIndex=11; itemBtn.Parent=listF; corner(itemBtn,4)

        itemBtn.MouseEnter:Connect(function()
            TS:Create(itemBtn,TweenInfo.new(0.08),{BackgroundTransparency=0,BackgroundColor3=SEL}):Play()
        end)
        itemBtn.MouseLeave:Connect(function()
            TS:Create(itemBtn,TweenInfo.new(0.08),{BackgroundTransparency=1}):Play()
        end)
        itemBtn.MouseButton1Click:Connect(function()
            selLbl.Text=opt.n; selLbl.TextColor3=TXT
            listF.Visible=false; chev.Text="v"
            onSelect(opt, i)
        end)
    end

    local isOpen=false
    hit.MouseButton1Click:Connect(function()
        isOpen=not isOpen; listF.Visible=isOpen; chev.Text=isOpen and "^" or "v"
    end)

    return wrapper, selLbl
end

local emCont=Instance.new("Frame")
emCont.Size=UDim2.new(1,0,0,CONT_H); emCont.Position=UDim2.new(0,0,0,CONT_Y)
emCont.BackgroundTransparency=1; emCont.BorderSizePixel=0; emCont.ClipsDescendants=false
emCont.ZIndex=2; emCont.Visible=true; emCont.Parent=mf


local emDropW=W-20


local emCard=Instance.new("Frame")
emCard.Size=UDim2.new(1,-20,0,105); emCard.Position=UDim2.new(0,10,0,76)
emCard.BackgroundColor3=PANEL; emCard.BorderSizePixel=0; emCard.ZIndex=2
emCard.Visible=false; emCard.Parent=emCont; corner(emCard); bdr(emCard)

local emCardTitle=Instance.new("TextLabel")
emCardTitle.Text=""; emCardTitle.Font=Enum.Font.GothamBold; emCardTitle.TextSize=11
emCardTitle.TextColor3=TXT; emCardTitle.BackgroundTransparency=1
emCardTitle.Size=UDim2.new(1,-90,0,18); emCardTitle.Position=UDim2.new(0,10,0,8)
emCardTitle.TextXAlignment=Enum.TextXAlignment.Left; emCardTitle.ZIndex=3; emCardTitle.Parent=emCard


local emApplyBtn=Instance.new("TextButton")
emApplyBtn.Size=UDim2.new(0,60,0,22); emApplyBtn.Position=UDim2.new(1,-68,0,8)
emApplyBtn.Text="APPLY"; emApplyBtn.Font=Enum.Font.GothamBold; emApplyBtn.TextSize=10
emApplyBtn.TextColor3=TXT; emApplyBtn.BackgroundColor3=PANEL3; emApplyBtn.BorderSizePixel=0
emApplyBtn.AutoButtonColor=false; emApplyBtn.ZIndex=3; emApplyBtn.Parent=emCard
corner(emApplyBtn); bdr(emApplyBtn)

local emTgtLabel=Instance.new("TextLabel")
emTgtLabel.Text="Replace:"; emTgtLabel.Font=Enum.Font.Gotham; emTgtLabel.TextSize=9
emTgtLabel.TextColor3=TXT3; emTgtLabel.BackgroundTransparency=1
emTgtLabel.Size=UDim2.new(1,-16,0,14); emTgtLabel.Position=UDim2.new(0,10,0,38)
emTgtLabel.TextXAlignment=Enum.TextXAlignment.Left; emTgtLabel.ZIndex=3; emTgtLabel.Parent=emCard


local emTgtRow=Instance.new("Frame")
emTgtRow.Size=UDim2.new(1,-16,0,28); emTgtRow.Position=UDim2.new(0,8,0,54)
emTgtRow.BackgroundTransparency=1; emTgtRow.BorderSizePixel=0; emTgtRow.ZIndex=3; emTgtRow.Parent=emCard

local emResetBtn=Instance.new("TextButton")
emResetBtn.Size=UDim2.new(1,-20,0,26); emResetBtn.Position=UDim2.new(0,10,0,188)
emResetBtn.Text="RESET ALL EMOTES"; emResetBtn.Font=Enum.Font.GothamBold; emResetBtn.TextSize=10
emResetBtn.TextColor3=TXT2; emResetBtn.BackgroundColor3=PANEL2; emResetBtn.BorderSizePixel=0
emResetBtn.AutoButtonColor=false; emResetBtn.ZIndex=2; emResetBtn.Parent=emCont
corner(emResetBtn); bdr(emResetBtn)

emResetBtn.MouseEnter:Connect(function() TS:Create(emResetBtn,TweenInfo.new(0.1),{BackgroundColor3=PANEL3}):Play() end)
emResetBtn.MouseLeave:Connect(function() TS:Create(emResetBtn,TweenInfo.new(0.1),{BackgroundColor3=PANEL2}):Play() end)
emResetBtn.MouseButton1Click:Connect(function()
    emResetBtn.Text="Restoring..."
    local ok=resetEmotes()
    emResetBtn.Text=ok and "RESTORED" or "FAILED"
    emResetBtn.TextColor3=ok and OK_C or ERR_C
    flash(ok and "All emotes restored!" or "Some restores failed.", ok)
    task.delay(2,function()
        if emResetBtn and emResetBtn.Parent then emResetBtn.Text="RESET ALL EMOTES"; emResetBtn.TextColor3=TXT2 end
    end)
end)


local curGroup=nil
local curTgtIdx=1
local tgtBtns={}

local function rebuildTargetRow(group)

    for _,b in ipairs(tgtBtns) do b:Destroy() end; tgtBtns={}
    curTgtIdx=1

    local n=#group.tgts
    local btnW=math.floor((emTgtRow.AbsoluteSize.X>0 and emTgtRow.AbsoluteSize.X or (emDropW-16)) / n) - 3

    for i,tgt in ipairs(group.tgts) do
        local xOff=(i-1)*(btnW+3)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,btnW,1,0); b.Position=UDim2.new(0,xOff,0,0)
        b.Text=tgt.n; b.Font=Enum.Font.Gotham; b.TextSize=10
        b.TextColor3=i==1 and TXT or TXT2
        b.BackgroundColor3=i==1 and SEL or PANEL2
        b.BorderSizePixel=0; b.AutoButtonColor=false; b.ZIndex=4; b.Parent=emTgtRow
        corner(b,5)
        if i==1 then bdr(b,Color3.fromRGB(80,80,105)) end
        tgtBtns[i]=b

        b.MouseButton1Click:Connect(function()
            curTgtIdx=i
            for k,tb in ipairs(tgtBtns) do
                local s=tb:FindFirstChildOfClass("UIStroke")
                tb.TextColor3=k==i and TXT or TXT2
                tb.BackgroundColor3=k==i and SEL or PANEL2
                if s then s:Destroy() end
                if k==i then bdr(tb,Color3.fromRGB(80,80,105)) end
            end
        end)
    end
end

makeDropdown(emCont, 10, 18, emDropW, "SELECT EMOTE", EMOTES, "-- choose emote --",
    function(opt, idx)
        curGroup=opt; emCardTitle.Text=opt.n
        rebuildTargetRow(opt); emCard.Visible=true
    end)

emApplyBtn.MouseButton1Click:Connect(function()
    if not curGroup then flash("Select an emote first!", false); return end
    emApplyBtn.Text="..."
    local tgt=curGroup.tgts[curTgtIdx]
    local ok=swapContent(tgt.p, curGroup.src)
    emApplyBtn.Text=ok and "DONE" or "FAIL"
    emApplyBtn.TextColor3=ok and OK_C or ERR_C
    flash(ok and (tgt.n.." -> "..curGroup.n) or ("Failed: "..tgt.n), ok)
    task.delay(1.8,function()
        if emApplyBtn and emApplyBtn.Parent then emApplyBtn.Text="APPLY"; emApplyBtn.TextColor3=TXT end
    end)
end)

emApplyBtn.MouseEnter:Connect(function() TS:Create(emApplyBtn,TweenInfo.new(0.1),{BackgroundColor3=SEL}):Play() end)
emApplyBtn.MouseLeave:Connect(function() TS:Create(emApplyBtn,TweenInfo.new(0.1),{BackgroundColor3=PANEL3}):Play() end)

local efCont=Instance.new("Frame")
efCont.Size=UDim2.new(1,0,0,CONT_H); efCont.Position=UDim2.new(0,0,0,CONT_Y)
efCont.BackgroundTransparency=1; efCont.BorderSizePixel=0; efCont.ClipsDescendants=false
efCont.ZIndex=2; efCont.Visible=false; efCont.Parent=mf


local curBase=nil

local efBaseDrop, efBaseSelLbl = makeDropdown(efCont, 10, 18, W-20, "SELECT BASE COSMETIC", BASES, "-- choose base --",
    function(opt, idx) curBase=opt end)


local effListLbl=Instance.new("TextLabel")
effListLbl.Text="SELECT EFFECT"; effListLbl.Font=Enum.Font.GothamBold; effListLbl.TextSize=9
effListLbl.TextColor3=TXT3; effListLbl.BackgroundTransparency=1
effListLbl.Size=UDim2.new(1,-20,0,12); effListLbl.Position=UDim2.new(0,10,0,80)
effListLbl.TextXAlignment=Enum.TextXAlignment.Left; effListLbl.ZIndex=3; effListLbl.Parent=efCont


local EFF_ITEM_H = 26
local EFF_LIST_H = 150
local scrollF=Instance.new("ScrollingFrame")
scrollF.Size=UDim2.new(1,-20,0,EFF_LIST_H); scrollF.Position=UDim2.new(0,10,0,94)
scrollF.CanvasSize=UDim2.new(0,0,0,#EFFS*EFF_ITEM_H+4)
scrollF.ScrollBarThickness=4; scrollF.ScrollBarImageColor3=BORDER
scrollF.BackgroundColor3=PANEL; scrollF.BorderSizePixel=0; scrollF.ZIndex=2
scrollF.Parent=efCont; corner(scrollF); bdr(scrollF)

local activeEffBtn=nil

for i, eff in ipairs(EFFS) do
    local yp=(i-1)*EFF_ITEM_H+2
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-4,0,EFF_ITEM_H-2); row.Position=UDim2.new(0,2,0,yp)
    row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3; row.Parent=scrollF
    corner(row,4)

    local effLbl=Instance.new("TextLabel")
    effLbl.Text=eff.n; effLbl.Font=Enum.Font.Gotham; effLbl.TextSize=11
    effLbl.TextColor3=TXT; effLbl.BackgroundTransparency=1
    effLbl.Size=UDim2.new(1,-68,1,0); effLbl.Position=UDim2.new(0,8,0,0)
    effLbl.TextXAlignment=Enum.TextXAlignment.Left; effLbl.ZIndex=4; effLbl.Parent=row

 
    local effApply=Instance.new("TextButton")
    effApply.Size=UDim2.new(0,54,0,18); effApply.Position=UDim2.new(1,-58,0.5,-9)
    effApply.Text="APPLY"; effApply.Font=Enum.Font.GothamBold; effApply.TextSize=9
    effApply.TextColor3=TXT2; effApply.BackgroundColor3=PANEL2; effApply.BorderSizePixel=0
    effApply.AutoButtonColor=false; effApply.ZIndex=4; effApply.Parent=row
    corner(effApply,4); bdr(effApply)

    effApply.MouseEnter:Connect(function() TS:Create(effApply,TweenInfo.new(0.08),{BackgroundColor3=SEL}):Play() end)
    effApply.MouseLeave:Connect(function()
        if effApply~=(activeEffBtn and activeEffBtn:FindFirstChildOfClass("TextButton")) then
            TS:Create(effApply,TweenInfo.new(0.08),{BackgroundColor3=PANEL2}):Play()
        end
    end)

    effApply.MouseButton1Click:Connect(function()
        if not curBase then flash("Select a base cosmetic first!", false); return end
        effApply.Text="..."
        resetBase(curBase.p)
        local ok=swapContent(curBase.p, eff.p)

      
        if activeEffBtn and activeEffBtn~=row then
            activeEffBtn.BackgroundTransparency=1
            local prevApply=activeEffBtn:FindFirstChildOfClass("TextButton")
            if prevApply then prevApply.TextColor3=TXT2; prevApply.BackgroundColor3=PANEL2 end
        end

        if ok then
            activeEffBtn=row
            row.BackgroundTransparency=0; row.BackgroundColor3=SEL
            effApply.Text="ON"; effApply.TextColor3=OK_C; effApply.BackgroundColor3=PANEL3
            flash(curBase.n.." -> "..eff.n, true)
        else
            effApply.Text="FAIL"; effApply.TextColor3=ERR_C
            flash("Failed: "..eff.n, false)
            task.delay(1.5,function()
                if effApply and effApply.Parent then effApply.Text="APPLY"; effApply.TextColor3=TXT2 end
            end)
        end
    end)
end


local efResetBtn=Instance.new("TextButton")
efResetBtn.Size=UDim2.new(1,-20,0,26); efResetBtn.Position=UDim2.new(0,10,0,252)
efResetBtn.Text="RESET EFFECT"; efResetBtn.Font=Enum.Font.GothamBold; efResetBtn.TextSize=10
efResetBtn.TextColor3=TXT2; efResetBtn.BackgroundColor3=PANEL2; efResetBtn.BorderSizePixel=0
efResetBtn.AutoButtonColor=false; efResetBtn.ZIndex=2; efResetBtn.Parent=efCont
corner(efResetBtn); bdr(efResetBtn)

efResetBtn.MouseEnter:Connect(function() TS:Create(efResetBtn,TweenInfo.new(0.1),{BackgroundColor3=PANEL3}):Play() end)
efResetBtn.MouseLeave:Connect(function() TS:Create(efResetBtn,TweenInfo.new(0.1),{BackgroundColor3=PANEL2}):Play() end)
efResetBtn.MouseButton1Click:Connect(function()
    if not curBase then flash("Select a base first.", false); return end
    efResetBtn.Text="Restoring..."
    local ok=resetBase(curBase.p)
    if ok and activeEffBtn then
        activeEffBtn.BackgroundTransparency=1
        local ap=activeEffBtn:FindFirstChildOfClass("TextButton")
        if ap then ap.Text="APPLY"; ap.TextColor3=TXT2; ap.BackgroundColor3=PANEL2 end
        activeEffBtn=nil
    end
    efResetBtn.Text=ok and "RESTORED" or "FAILED"
    efResetBtn.TextColor3=ok and OK_C or ERR_C
    flash(ok and (curBase.n.." restored!") or "Reset failed.", ok)
    task.delay(2,function()
        if efResetBtn and efResetBtn.Parent then efResetBtn.Text="RESET EFFECT"; efResetBtn.TextColor3=TXT2 end
    end)
end)


local function switchTab(toEffects)
    emCont.Visible=not toEffects; efCont.Visible=toEffects
    tabE.TextColor3=toEffects and TXT2 or TXT; tabE.BackgroundColor3=toEffects and PANEL or PANEL2
    tabF.TextColor3=toEffects and TXT  or TXT2; tabF.BackgroundColor3=toEffects and PANEL2 or PANEL
end
tabE.MouseButton1Click:Connect(function() switchTab(false) end)
tabF.MouseButton1Click:Connect(function() switchTab(true) end)


local drag,dStart,dPos=false,nil,nil
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;dStart=i.Position;dPos=mf.Position end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dStart
        mf.Position=UDim2.new(dPos.X.Scale,dPos.X.Offset+d.X,dPos.Y.Scale,dPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)


local menuVis=true
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if listeningForKey then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==toggleKey then
        menuVis=not menuVis; mf.Visible=menuVis
    end
end)


TS:Create(mf, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position=UDim2.new(0,20,0.5,-TOTAL_H/2)
}):Play()

print("[rg] EVADE Changer v5 loaded | "..toggleKey.Name.." to toggle")
