TAB1 name=Main into
[...
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

local function ApplyThemeStroke(parent, thickness, transparency)
    local Stroke = Instance.new("UIStroke", parent)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = thickness or 1
    Stroke.Transparency = transparency or 0.2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    
    local Gradient = Instance.new("UIGradient", Stroke)
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 180)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 180))
    })
    Gradient.Rotation = 45
end

-- ==========================================
-- SYSTEM: อ่านข้อมูลคีย์ให้ตรงกับหน้า Login
-- ==========================================
local userType = "Unverified ❌" 
local userCredits = 0
local expireTime = 0
local isPermanent = false

local FOLDER_NAME = "Pomelo_System"
local FILE_NAME = FOLDER_NAME .. "/SysData.cfg"

local KEYWORD_URL = "https://raw.githubusercontent.com/bilibil31-lime/ilikepomelo555tyGGbyeJJK10101/main/Modules/mod_keyword.lua"
local KeywordMap = {}
local ReverseMap = {}
local SortedCodes = {}

local successFetch, responseFetch = pcall(function() return game:HttpGet(KEYWORD_URL) end)
if successFetch and responseFetch then
    for line in responseFetch:gmatch("[^\r\n]+") do
        local char, code = line:match("^(.)=(.+)$")
        if char and code then
            code = code:gsub("%s+$", "")
            KeywordMap[char] = code
            ReverseMap[code] = char
            table.insert(SortedCodes, code)
        end
    end
    table.sort(SortedCodes, function(a, b) return #a > #b end)
end

local function DecodeData(dataStr)
    local encodedStr = string.match(dataStr, "POMELO_SECURE_V1\n([^\n]+)\nEOF")
    if not encodedStr then return nil end
    
    local rawData = encodedStr
    for _, code in ipairs(SortedCodes) do
        local safeCode = code:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%0")
        rawData = rawData:gsub(safeCode, ReverseMap[code])
    end
    
    local k, t, e, c = string.match(rawData, "K:([^|]+)|T:([^|]+)|E:(%d+)|C:(%d+)")
    if k and t and e and c then return {key = k, type = t, expire = tonumber(e), credits = tonumber(c)} end
    return nil
end

local function CheckUserStatus()
    if isfile and isfile(FILE_NAME) then
        local success, dataStr = pcall(readfile, FILE_NAME)
        if success then
            local data = DecodeData(dataStr)
            if data then
                expireTime = data.expire
                userCredits = data.credits
                
                if data.type == "admin" then
                    userType = "Admin 👑"
                    isPermanent = true
                elseif data.type == "friend" then
                    userType = "Friend 🤝"
                    if expireTime > os.time() + (3650 * 24 * 3600) then isPermanent = true end
                elseif data.type == "user" or data.type == "normal" then 
                    userType = "Normal User 👤" 
                    isPermanent = false
                else
                    userType = "Normal User 👤"
                    isPermanent = false
                end
            end
        end
    end
end
pcall(CheckUserStatus)

-- ==========================================
-- SYSTEM: เช็คอุปกรณ์ที่เล่น
-- ==========================================
local deviceType = "Unknown ❓"
if UIS.KeyboardEnabled and UIS.MouseEnabled then
    deviceType = "PC 💻"
elseif UIS.TouchEnabled and not UIS.MouseEnabled then
    deviceType = "Mobile 📱"
elseif UIS.GamepadEnabled then
    deviceType = "Console 🎮"
end

-- ==========================================
-- SYSTEM: เช็คตัวรัน (Executor Detection)
-- ==========================================
local executorName = "Unknown ❓"
local function GetExecutorName()
    local success, name = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        local env = getgenv and getgenv() or _G
        if env.KRNL_LOADED then return "Krnl" end
        if env.syn then return "Synapse X" end
        if env.fluxus then return "Fluxus" end
        if getexecutorname then return getexecutorname() end
        return "Unknown"
    end)
    if success and type(name) == "string" and name ~= "" then
        return name
    end
    return "Unknown ❓"
end
executorName = GetExecutorName()

-- ==========================================
-- UI: สร้างหน้าต่าง
-- ==========================================
local ProfileCard = Instance.new("Frame", TabContainer)
ProfileCard.Size = UDim2.new(1, -20, 0, 150) -- ปรับความสูงเพิ่มนิดหน่อยเผื่อรองรับ Badge ที่ 5
ProfileCard.Position = UDim2.new(0, 10, 0, 15)
ProfileCard.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ProfileCard.BackgroundTransparency = 0.5 
Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 10)
ApplyThemeStroke(ProfileCard, 1, 0.4) 

local AvatarFrame = Instance.new("Frame", ProfileCard)
AvatarFrame.Size = UDim2.new(0, 90, 0, 90)
AvatarFrame.Position = UDim2.new(0, 15, 0.5, 0)
AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0)
ApplyThemeStroke(AvatarFrame, 2, 0)

local AvatarImage = Instance.new("ImageLabel", AvatarFrame)
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local success, content, isReady = pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if success and isReady then AvatarImage.Image = content end
end)

local NameFrame = Instance.new("Frame", ProfileCard)
NameFrame.Size = UDim2.new(0.4, 0, 0, 60)
NameFrame.Position = UDim2.new(0, 120, 0.5, -5)
NameFrame.AnchorPoint = Vector2.new(0, 0.5)
NameFrame.BackgroundTransparency = 1

local NicknameLabel = Instance.new("TextLabel", NameFrame)
NicknameLabel.Size = UDim2.new(1, 0, 0, 30)
NicknameLabel.BackgroundTransparency = 1
NicknameLabel.Text = Player.DisplayName
NicknameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NicknameLabel.Font = Enum.Font.GothamBold
NicknameLabel.TextSize = 22
NicknameLabel.TextXAlignment = Enum.TextXAlignment.Left

local UsernameLabel = Instance.new("TextLabel", NameFrame)
UsernameLabel.Size = UDim2.new(1, 0, 0, 20)
UsernameLabel.Position = UDim2.new(0, 0, 0, 30)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. Player.Name
UsernameLabel.TextColor3 = Color3.fromRGB(255, 150, 220) 
UsernameLabel.Font = Enum.Font.GothamMedium
UsernameLabel.TextSize = 14
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsContainer = Instance.new("Frame", ProfileCard)
StatsContainer.Size = UDim2.new(0, 180, 1, -10)
StatsContainer.Position = UDim2.new(1, -10, 0.5, 0)
StatsContainer.AnchorPoint = Vector2.new(1, 0.5)
StatsContainer.BackgroundTransparency = 1

local StatLayout = Instance.new("UIListLayout", StatsContainer)
StatLayout.FillDirection = Enum.FillDirection.Vertical
StatLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatLayout.Padding = UDim.new(0, 4)
StatLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function CreateStatBadge(text)
    local Badge = Instance.new("Frame", StatsContainer)
    Badge.Size = UDim2.new(1, 0, 0, 24)
    Badge.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Badge.BackgroundTransparency = 0.4
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
    
    local BadgeStroke = Instance.new("UIStroke", Badge)
    BadgeStroke.Color = Color3.fromRGB(255, 255, 255)
    BadgeStroke.Transparency = 0.85
    BadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", Badge)
    Lbl.Size = UDim2.new(1, -15, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.RichText = true 
    return Lbl
end

local TimeLeftLabel = CreateStatBadge("⏳ Time Left: <b>Calculating...</b>")
local StatusLabel = CreateStatBadge("⭐ Status: <b>" .. userType .. "</b>")
local CreditsLabel = CreateStatBadge("💎 Credits: <b>" .. tostring(userCredits) .. "</b>")
CreateStatBadge("🎮 Device: <b>" .. deviceType .. "</b>")
CreateStatBadge("🚀 Executor: <b>" .. executorName .. "</b>") -- เพิ่มบรรทัดบอกตัวรันตรงนี้

-- ==========================================
-- UPDATE: ระบบ Loop คำนวณเวลานับถอยหลัง
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if not TimeLeftLabel or not TimeLeftLabel.Parent then break end
        
        if expireTime == 0 or userType == "Unverified ❌" then
            TimeLeftLabel.Text = "⏳ Time Left: <b>No Key ❌</b>"
        elseif isPermanent then
            TimeLeftLabel.Text = "⏳ Time Left: <b>Lifetime ♾️</b>"
        else
            local diff = expireTime - os.time()
            
            if diff <= 0 then
                TimeLeftLabel.Text = "⏳ Time Left: <b>Expired ❌</b>"
            else
                local days = math.floor(diff / 86400)
                local hours = math.floor((diff % 86400) / 3600)
                local minutes = math.floor((diff % 3600) / 60)
                local seconds = diff % 60
                
                if days > 0 then
                    TimeLeftLabel.Text = string.format("⏳ Time Left: <b>%dd %02dh %02dm %02ds</b>", days, hours, minutes, seconds)
                else
                    TimeLeftLabel.Text = string.format("⏳ Time Left: <b>%02dh %02dm %02ds</b>", hours, minutes, seconds)
                end
            end
        end
    end
end)

local FooterContainer = Instance.new("ScrollingFrame", TabContainer)
FooterContainer.Size = UDim2.new(1, -20, 1, -185) -- ขยับเผื่อ ProfileCard ที่สูงขึ้น
FooterContainer.Position = UDim2.new(0, 10, 0, 175)
FooterContainer.BackgroundTransparency = 1
FooterContainer.BorderSizePixel = 0
FooterContainer.ScrollBarThickness = 3 
FooterContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 180) 
FooterContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FooterContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y 

local UIListLayoutFooter = Instance.new("UIListLayout", FooterContainer)
UIListLayoutFooter.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutFooter.Padding = UDim.new(0, 8)
UIListLayoutFooter.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SymbolDivider = Instance.new("TextLabel", FooterContainer)
SymbolDivider.Size = UDim2.new(1, 0, 0, 15)
SymbolDivider.BackgroundTransparency = 1
SymbolDivider.Text = "✦ • ✨ • ✦"
SymbolDivider.TextColor3 = Color3.fromRGB(255, 100, 180)
SymbolDivider.Font = Enum.Font.Gotham
SymbolDivider.TextSize = 10

local BottomText = Instance.new("TextLabel", FooterContainer)
BottomText.Size = UDim2.new(1, -10, 0, 0)
BottomText.BackgroundTransparency = 1
BottomText.TextColor3 = Color3.fromRGB(150, 150, 160)
BottomText.Font = Enum.Font.Gotham
BottomText.TextSize = 12
BottomText.TextYAlignment = Enum.TextYAlignment.Top 
BottomText.RichText = true
BottomText.TextWrapped = true 
BottomText.AutomaticSize = Enum.AutomaticSize.Y 

-- ==========================================
-- UPDATE: ดึงข้อความจาก Github (Live Message)
-- ==========================================
local LIVE_MESSAGE_URL = "https://raw.githubusercontent.com/bilibil31-lime/ilikepomelo555tyGGbyeJJK10101/main/Modules/mod_message123.lua"

BottomText.Text = "<i>Loading live data from server...</i>"

task.spawn(function()
    local success, response = pcall(function()
        return game:HttpGet(LIVE_MESSAGE_URL)
    end)
    
    if success and response and response ~= "" then
        BottomText.Text = response
    else
        BottomText.Text = "<font color='rgb(255,100,100)'>[ERROR] Failed to fetch live message from server.</font>"
    end
end)
]...
TAB2 name=Setting
[...
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer
local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

-- [[ ================== CORE UI LOGIC (ห้ามแก้ตรงนี้) ================== ]]
local function ApplyThemeStroke(parent, thickness, transparency)
    local Stroke = Instance.new("UIStroke", parent)
    Stroke.Color, Stroke.Thickness, Stroke.Transparency = Color3.fromRGB(255, 255, 255), thickness or 1, transparency or 0.2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    local Gradient = Instance.new("UIGradient", Stroke)
    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 180)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 180))})
    Gradient.Rotation = 45
end
local SettingsScroll = Instance.new("ScrollingFrame", TabContainer)
SettingsScroll.Size, SettingsScroll.Position = UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10)
SettingsScroll.BackgroundTransparency, SettingsScroll.BorderSizePixel = 1, 0
SettingsScroll.ScrollBarThickness, SettingsScroll.ScrollBarImageColor3 = 3, Color3.fromRGB(255, 100, 180)
SettingsScroll.CanvasSize, SettingsScroll.AutomaticCanvasSize = UDim2.new(0, 0, 0, 0), Enum.AutomaticSize.Y
local ListLayout = Instance.new("UIListLayout", SettingsScroll)
ListLayout.SortOrder, ListLayout.Padding, ListLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 10), Enum.HorizontalAlignment.Center
local function CreateSection(title)
    local SectionLabel = Instance.new("TextLabel", SettingsScroll)
    SectionLabel.Size, SectionLabel.BackgroundTransparency = UDim2.new(1, -10, 0, 25), 1
    SectionLabel.Text, SectionLabel.TextColor3, SectionLabel.Font, SectionLabel.TextSize = "  " .. title, Color3.fromRGB(255, 150, 220), Enum.Font.GothamBold, 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    local Line = Instance.new("Frame", SectionLabel)
    Line.Size, Line.Position, Line.BackgroundColor3, Line.BorderSizePixel, Line.BackgroundTransparency = UDim2.new(1, -10, 0, 1), UDim2.new(0, 10, 1, 0), Color3.fromRGB(255, 100, 180), 0, 0.5
end
local function CreateToggle(title, description, defaultState, callback)
    local ToggleFrame = Instance.new("TextButton", SettingsScroll)
    ToggleFrame.Size, ToggleFrame.BackgroundColor3, ToggleFrame.BackgroundTransparency, ToggleFrame.Text, ToggleFrame.AutoButtonColor = UDim2.new(1, -10, 0, 50), Color3.fromRGB(35, 35, 42), 0.5, "", false
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
    ApplyThemeStroke(ToggleFrame, 1, 0.4)
    local TitleLabel = Instance.new("TextLabel", ToggleFrame)
    TitleLabel.Size, TitleLabel.Position, TitleLabel.BackgroundTransparency, TitleLabel.Text, TitleLabel.TextColor3, TitleLabel.Font, TitleLabel.TextSize, TitleLabel.TextXAlignment = UDim2.new(0.7, 0, 0, 20), UDim2.new(0, 15, 0, 8), 1, title, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left
    local DescLabel = Instance.new("TextLabel", ToggleFrame)
    DescLabel.Size, DescLabel.Position, DescLabel.BackgroundTransparency, DescLabel.Text, DescLabel.TextColor3, DescLabel.Font, DescLabel.TextSize, DescLabel.TextXAlignment = UDim2.new(0.7, 0, 0, 15), UDim2.new(0, 15, 0, 28), 1, description, Color3.fromRGB(150, 150, 160), Enum.Font.Gotham, 11, Enum.TextXAlignment.Left
    local SwitchBG = Instance.new("Frame", ToggleFrame)
    SwitchBG.Size, SwitchBG.Position, SwitchBG.BackgroundColor3 = UDim2.new(0, 40, 0, 20), UDim2.new(1, -55, 0.5, -10), defaultState and Color3.fromRGB(255, 100, 180) or Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)
    local SwitchCircle = Instance.new("Frame", SwitchBG)
    SwitchCircle.Size, SwitchCircle.Position, SwitchCircle.BackgroundColor3 = UDim2.new(0, 16, 0, 16), defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)
    local isOn = defaultState
    ToggleFrame.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = isOn and Color3.fromRGB(255, 100, 180) or Color3.fromRGB(50, 50, 60)}):Play()
        TweenService:Create(SwitchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        pcall(callback, isOn)
    end)
    task.spawn(function() if defaultState then pcall(callback, defaultState) end end)
end

local OriginalLighting = { Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd }
local AntiAfkConnection = nil
-- [[ ================================================================= ]]


-- [[ ========================= โซนเพิ่มปุ่มของกุ ========================== ]]

local smoothOriginalMaterials = {}
local smoothHiddenTextures = {}

CreateSection("🎨 Graphics")

-- 1...\
CreateToggle("Make The WORD Sweet!", "Adjusts colors and makes the world smooth and SWEET (Try using it with FPS Boost so SWEET!)", false, function(state)
    local Lighting = game:GetService("Lighting")
    
    if state then
        local bloom = Lighting:FindFirstChild("PomeloBloom") or Instance.new("BloomEffect", Lighting)
        bloom.Name = "PomeloBloom"
        bloom.Intensity, bloom.Size, bloom.Threshold = 0.2, 5, 0.8

        local cc = Lighting:FindFirstChild("PomeloCC") or Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "PomeloCC"
        cc.Brightness, cc.Contrast, cc.Saturation = 0.05, 0.1, 0.3
        cc.TintColor = Color3.fromRGB(255, 245, 250)

        local atmos = Lighting:FindFirstChild("PomeloAtmos") or Instance.new("Atmosphere", Lighting)
        atmos.Name = "PomeloAtmos"
        atmos.Density = 0.2

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                if not smoothOriginalMaterials[v] then 
                    smoothOriginalMaterials[v] = v.Material 
                end
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if not smoothHiddenTextures[v] then 
                    smoothHiddenTextures[v] = v.Transparency 
                end
                v.Transparency = 1
            end
        end
    else
        if Lighting:FindFirstChild("PomeloBloom") then Lighting.PomeloBloom:Destroy() end
        if Lighting:FindFirstChild("PomeloCC") then Lighting.PomeloCC:Destroy() end
        if Lighting:FindFirstChild("PomeloAtmos") then Lighting.PomeloAtmos:Destroy() end

        for part, mat in pairs(smoothOriginalMaterials) do
            if part and part.Parent then part.Material = mat end
        end
        for tex, trans in pairs(smoothHiddenTextures) do
            if tex and tex.Parent then tex.Transparency = trans end
        end
        table.clear(smoothOriginalMaterials)
        table.clear(smoothHiddenTextures)
    end
end)
-- 1.../

CreateSection("🚀 Performance")

-- 1...\
CreateToggle("Unlock FPS", "Bypass standard 60 FPS limit", false, function(state)
    pcall(function()
        if setfpscap then
            setfpscap(state and 999 or 60)
        end
    end)
end)
-- 1.../

-- 2...\
CreateToggle("FPS Boost", "Removes textures and turns materials to smooth plastic.", false, function(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end
end)
-- 2.../

-- 3...\
CreateToggle("igihjigjigjbg", "thothotkhoktohktoht", false, function(state)
end)
-- 3.../

CreateSection("👁️ Visuals")

-- 1...\
CreateToggle("Fullbright", "Removes shadows and makes the map bright.", false, function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)
-- 1.../

-- 2...\
CreateToggle("No Fog", "Removes atmosphere fog for infinite sight.", false, function(state)
    if state then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end)
-- 2.../


CreateSection("⚙️ System")

-- 1...\
CreateToggle("Anti-AFK", "Prevents 20-minute idle kick.", true, function(state)
    if state then
        AntiAfkConnection = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
    end
end)
-- 1.../
]...

TAB3 name=Main3
[...
hjhh
]...
