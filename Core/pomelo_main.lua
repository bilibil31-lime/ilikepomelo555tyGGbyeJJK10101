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
local userType = "Unverified" 
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
                    userType = "Admin"
                    isPermanent = true
                elseif data.type == "friend" then
                    userType = "Friend"
                    if expireTime > os.time() + (3650 * 24 * 3600) then isPermanent = true end
                elseif data.type == "user" or data.type == "normal" then 
                    userType = "Normal User" 
                    isPermanent = false
                else
                    userType = "Normal User"
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
local deviceType = "Unknown"
if UIS.KeyboardEnabled and UIS.MouseEnabled then
    deviceType = "PC"
elseif UIS.TouchEnabled and not UIS.MouseEnabled then
    deviceType = "Mobile"
elseif UIS.GamepadEnabled then
    deviceType = "Console"
end

-- ==========================================
-- SYSTEM: เช็คตัวรัน (Executor Detection)
-- ==========================================
local executorName = "Unknown"
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
    return "Unknown"
end
executorName = GetExecutorName()

-- ==========================================
-- UI: สร้างหน้าต่าง
-- ==========================================
local ProfileCard = Instance.new("Frame", TabContainer)
ProfileCard.Size = UDim2.new(1, -20, 0, 150)
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

local TimeLeftLabel = CreateStatBadge("Time Left: <b>Calculating...</b>")
local StatusLabel = CreateStatBadge("Status: <b>" .. userType .. "</b>")
local CreditsLabel = CreateStatBadge("Credits: <b>" .. tostring(userCredits) .. "</b>")
CreateStatBadge("Device: <b>" .. deviceType .. "</b>")
CreateStatBadge("Executor: <b>" .. executorName .. "</b>")

-- ==========================================
-- UPDATE: ระบบ Loop คำนวณเวลานับถอยหลัง & เช็คเครดิต Real-time
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if not TimeLeftLabel or not TimeLeftLabel.Parent then break end
        
        -- อ่านข้อมูลเครดิตและสถานะแบบ Real-time
        pcall(CheckUserStatus)
        if CreditsLabel then
            CreditsLabel.Text = "Credits: <b>" .. tostring(userCredits) .. "</b>"
        end
        if StatusLabel then
            StatusLabel.Text = "Status: <b>" .. userType .. "</b>"
        end
        
        -- ระบบคำนวณเวลาถอยหลัง
        if expireTime == 0 or userType == "Unverified" then
            TimeLeftLabel.Text = "Time Left: <b>No Key</b>"
        elseif isPermanent then
            TimeLeftLabel.Text = "Time Left: <b>Lifetime</b>"
        else
            local diff = expireTime - os.time()
            
            if diff <= 0 then
                TimeLeftLabel.Text = "Time Left: <b>Expired</b>"
            else
                local days = math.floor(diff / 86400)
                local hours = math.floor((diff % 86400) / 3600)
                local minutes = math.floor((diff % 3600) / 60)
                local seconds = diff % 60
                
                if days > 0 then
                    TimeLeftLabel.Text = string.format("Time Left: <b>%dd %02dh %02dm %02ds</b>", days, hours, minutes, seconds)
                else
                    TimeLeftLabel.Text = string.format("Time Left: <b>%02dh %02dm %02ds</b>", hours, minutes, seconds)
                end
            end
        end
    end
end)

local FooterContainer = Instance.new("ScrollingFrame", TabContainer)
FooterContainer.Size = UDim2.new(1, -20, 1, -185)
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
SymbolDivider.Text = "--------------------"
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
-- UPDATE: ดึงข้อความจาก Github (Live Message) แก้ไขระบบ Cache
-- ==========================================
local LIVE_MESSAGE_URL = "https://raw.githubusercontent.com/bilibil31-lime/ilikepomelo555tyGGbyeJJK10101/main/Modules/mod_message123.lua"

BottomText.Text = "<i>Loading live data from server...</i>"

task.spawn(function()
    local cacheBypassUrl = LIVE_MESSAGE_URL .. "?t=" .. tostring(os.time())
    
    local success, response = pcall(function()
        return game:HttpGet(cacheBypassUrl)
    end)
    
    if success and response and response ~= "" then
        if string.find(response, "404: Not Found") then
            BottomText.Text = "<font color='rgb(255,100,100)'>[ERROR] File 404 Not Found - ไม่พบไฟล์บน GitHub ตรวจสอบชื่อไฟล์อีกครั้ง</font>"
        else
            BottomText.Text = response
        end
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
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

-- ==========================================
-- SYSTEM: Dual Folder Sync Setup
-- ==========================================
local FOLDER_1 = "Pomelo_System"
local FOLDER_2 = "Roblox_Crash_Dump"

local SYS_F1 = FOLDER_1 .. "/SysData.cfg"
local SYS_F2 = FOLDER_2 .. "/SysData.cfg"
local DUMP_F1 = FOLDER_1 .. "/win32_cache.dmp"
local DUMP_F2 = FOLDER_2 .. "/win32_cache.dmp"

if makefolder then
    if not isfolder(FOLDER_1) then pcall(makefolder, FOLDER_1) end
    if not isfolder(FOLDER_2) then pcall(makefolder, FOLDER_2) end
end

local function SyncMissingFile(pathA, pathB)
    if isfile and readfile and writefile then
        local hasA = isfile(pathA)
        local hasB = isfile(pathB)
        
        if hasA and not hasB then
            pcall(function() writefile(pathB, readfile(pathA)) end)
        elseif hasB and not hasA then
            pcall(function() writefile(pathA, readfile(pathB)) end)
        end
    end
end

SyncMissingFile(SYS_F1, SYS_F2)
SyncMissingFile(DUMP_F1, DUMP_F2)

-- ==========================================
-- SYSTEM: Encryption / Decryption
-- ==========================================
local KEYWORD_URL = "https://raw.githubusercontent.com/bilibil31-lime/ilikepomelo555tyGGbyeJJK10101/main/Modules/mod_keyword.lua"
local KeywordMap, ReverseMap, SortedCodes = {}, {}, {}

pcall(function()
    local responseFetch = game:HttpGet(KEYWORD_URL)
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
end)

local function EncodeData(rawData)
    local encoded = ""
    for i = 1, #rawData do
        local char = rawData:sub(i, i)
        encoded = encoded .. (KeywordMap[char] or char)
    end
    return "POMELO_SECURE_V1\n" .. encoded .. "\nEOF"
end

local function DecodeData(dataStr)
    if not dataStr then return nil end
    local encodedStr = string.match(dataStr, "POMELO_SECURE_V1\n([^\n]+)\nEOF")
    if not encodedStr then return nil end
    local rawData = encodedStr
    for _, code in ipairs(SortedCodes) do
        local safeCode = code:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%0")
        rawData = rawData:gsub(safeCode, ReverseMap[code])
    end
    return rawData
end

local function GetSysData()
    SyncMissingFile(SYS_F1, SYS_F2)
    local targetFile = isfile(SYS_F1) and SYS_F1 or (isfile(SYS_F2) and SYS_F2 or nil)
    if targetFile then
        local s, dataStr = pcall(readfile, targetFile)
        if s then
            local rawData = DecodeData(dataStr)
            if rawData then
                local k, t, e, c = string.match(rawData, "K:([^|]+)|T:([^|]+)|E:(%d+)|C:(%d+)")
                if k and t and e and c then
                    return { key = k, type = t, expire = tonumber(e), credits = tonumber(c) }
                end
            end
        end
    end
    return { key = "", type = "user", expire = 0, credits = 0 }
end

local function SaveSysData(data)
    local rawStr = string.format("K:%s|T:%s|E:%d|C:%d", data.key, data.type, data.expire, data.credits)
    local encoded = EncodeData(rawStr)
    if writefile then
        pcall(writefile, SYS_F1, encoded)
        pcall(writefile, SYS_F2, encoded)
    end
end

local function GetPurchasedScripts()
    SyncMissingFile(DUMP_F1, DUMP_F2)
    local purchased = {}
    local targetFile = isfile(DUMP_F1) and DUMP_F1 or (isfile(DUMP_F2) and DUMP_F2 or nil)
    if targetFile then
        local s, dataStr = pcall(readfile, targetFile)
        if s then
            local rawData = DecodeData(dataStr)
            if rawData then
                for itemBlock in string.gmatch(rawData, "([^|]+)") do
                    local name, exp = string.match(itemBlock, "(.-):(.+)")
                    if name and exp then purchased[name] = tonumber(exp) end
                end
            end
        end
    end
    return purchased
end

local function AddPurchasedScript(internalName, durationSeconds)
    local purchased = GetPurchasedScripts()
    local expireTimestamp = -1
    if durationSeconds > 0 then expireTimestamp = os.time() + durationSeconds end
    
    purchased[internalName] = expireTimestamp
    local list = {}
    for name, exp in pairs(purchased) do table.insert(list, name .. ":" .. tostring(exp)) end
    local encoded = EncodeData(table.concat(list, "|"))
    
    if writefile then
        pcall(writefile, DUMP_F1, encoded)
        pcall(writefile, DUMP_F2, encoded)
    end
end

local function ParseTimeToSeconds(timeStr)
    if not timeStr or timeStr == "" then return -1 end
    local num, unit = timeStr:match("(%d+)([dhm])")
    if num and unit then
        num = tonumber(num)
        if unit == "d" then return num * 86400
        elseif unit == "h" then return num * 3600
        elseif unit == "m" then return num * 60 end
    end
    return -1 
end

local STORE_URL = "https://raw.githubusercontent.com/bilibil31-lime/ilikepomelo555tyGGbyeJJK10101/main/Core/pomelo_strore.lua"
local function FetchStoreItems()
    local items = {}
    local s, response = pcall(function() return game:HttpGet(STORE_URL .. "?t=" .. tostring(os.time())) end)
    if s and response and not response:find("404: Not Found") then
        local currentItem = nil
        for line in response:gmatch("[^\r\n]+") do
            line = line:match("^%s*(.-)%s*$")
            if line:find("^script%d+%s+name=") then
                if currentItem and currentItem.internalName then table.insert(items, currentItem) end
                currentItem = { internalName = line:match("name=(.+)"), code = "", description = "No Description", price = 0, timeRaw = "", uidmap = nil }
            elseif currentItem then
                if line:sub(1, 1) == "=" then currentItem.code = line:sub(2)
                elseif line:lower():find("^description=") then currentItem.description = line:match("=(.+)")
                elseif line:lower():find("^price=") then currentItem.price = tonumber(line:match("=(%d+)")) or 0
                elseif line:lower():find("^time=") then currentItem.timeRaw = line:match("=(.+)")
                elseif line:lower():find("^uidmap=") then currentItem.uidmap = tonumber(line:match("=(%d+)"))
                end
            end
        end
        if currentItem and currentItem.internalName then table.insert(items, currentItem) end
    end
    return items
end

-- ==========================================
-- UI: Base Structure
-- ==========================================
local MainBackground = Instance.new("Frame", TabContainer)
MainBackground.Size = UDim2.new(1, 0, 1, 0)
MainBackground.BackgroundTransparency = 1 

-- Header Area
local HeaderFrame = Instance.new("Frame", MainBackground)
HeaderFrame.Size = UDim2.new(1, 0, 0, 50)
HeaderFrame.BackgroundTransparency = 1

local StoreTitle = Instance.new("TextLabel", HeaderFrame)
StoreTitle.Size = UDim2.new(0, 130, 1, 0) 
StoreTitle.Position = UDim2.new(0, 15, 0, 0)
StoreTitle.BackgroundTransparency = 1
StoreTitle.Text = "P.STORE"
StoreTitle.TextColor3 = Color3.fromRGB(255, 200, 240)
StoreTitle.Font = Enum.Font.Arcade 
StoreTitle.TextSize = 32
StoreTitle.TextXAlignment = Enum.TextXAlignment.Left

local TitleStroke = Instance.new("UIStroke", StoreTitle)
TitleStroke.Color = Color3.fromRGB(255, 100, 180) 
TitleStroke.Thickness = 1
TitleStroke.Transparency = 0.3

-- [FIX 1]: ปรับขนาด Search Bar ให้ยาวขึ้นแบบ Dynamic Width
local SearchFrame = Instance.new("Frame", HeaderFrame)
SearchFrame.Size = UDim2.new(1, -290, 0, 30) -- ยืดเต็มพื้นที่ว่างระหว่างโลโก้กับเครดิต
SearchFrame.Position = UDim2.new(0, 150, 0.5, 0)
SearchFrame.AnchorPoint = Vector2.new(0, 0.5)
SearchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)

local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Color3.fromRGB(255, 100, 180)
SearchStroke.Thickness = 1
SearchStroke.Transparency = 0.5

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -30, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search scripts..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.Jura
SearchBox.TextSize = 14
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Text = ""

-- Credits 
local CreditDisplay = Instance.new("TextLabel", HeaderFrame)
CreditDisplay.Size = UDim2.new(0, 120, 1, 0)
CreditDisplay.Position = UDim2.new(1, -15, 0, 0)
CreditDisplay.AnchorPoint = Vector2.new(1, 0)
CreditDisplay.BackgroundTransparency = 1
CreditDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditDisplay.Font = Enum.Font.Jura
CreditDisplay.TextSize = 13
CreditDisplay.TextXAlignment = Enum.TextXAlignment.Right

-- Grid Scroll Area
local ScrollContainer = Instance.new("ScrollingFrame", MainBackground)
ScrollContainer.Size = UDim2.new(1, -30, 1, -60)
ScrollContainer.Position = UDim2.new(0, 15, 0, 55)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 180)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y -- แก้ไขบัคเลื่อนไม่ได้
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local GridLayout = Instance.new("UIGridLayout", ScrollContainer)
GridLayout.CellSize = UDim2.new(0, 135, 0, 160) 
GridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [FIX 2]: อัปเดตขนาดสกอร์บาร์แบบเรียลไทม์
GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, GridLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
-- UI: Confirmation Modal
-- ==========================================
local ModalBackdrop = Instance.new("Frame", MainBackground)
ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
ModalBackdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ModalBackdrop.BackgroundTransparency = 0.3
ModalBackdrop.ZIndex = 50
ModalBackdrop.Visible = false

local ModalCard = Instance.new("Frame", ModalBackdrop)
ModalCard.Size = UDim2.new(0, 280, 0, 150)
ModalCard.Position = UDim2.new(0.5, 0, 0.5, 0)
ModalCard.AnchorPoint = Vector2.new(0.5, 0.5)
ModalCard.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ModalCard.ZIndex = 51
Instance.new("UICorner", ModalCard).CornerRadius = UDim.new(0, 8)
local ModalStroke = Instance.new("UIStroke", ModalCard)
ModalStroke.Color = Color3.fromRGB(255, 100, 180)
ModalStroke.Thickness = 1

local ModalTitle = Instance.new("TextLabel", ModalCard)
ModalTitle.Size = UDim2.new(1, 0, 0, 30)
ModalTitle.Position = UDim2.new(0, 0, 0, 15)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "CONFIRM PURCHASE"
ModalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModalTitle.Font = Enum.Font.Jura
ModalTitle.TextSize = 16
ModalTitle.ZIndex = 52

local ModalDesc = Instance.new("TextLabel", ModalCard)
ModalDesc.Size = UDim2.new(1, -20, 0, 40)
ModalDesc.Position = UDim2.new(0, 10, 0, 45)
ModalDesc.BackgroundTransparency = 1
ModalDesc.Text = ""
ModalDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
ModalDesc.Font = Enum.Font.Gotham
ModalDesc.TextSize = 12
ModalDesc.TextWrapped = true
ModalDesc.ZIndex = 52

local BtnConfirm = Instance.new("TextButton", ModalCard)
BtnConfirm.Size = UDim2.new(0, 100, 0, 30)
BtnConfirm.Position = UDim2.new(0.5, -110, 1, -45)
BtnConfirm.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
BtnConfirm.Text = "CONFIRM"
BtnConfirm.TextColor3 = Color3.fromRGB(0, 0, 0)
BtnConfirm.Font = Enum.Font.GothamBold
BtnConfirm.TextSize = 12
BtnConfirm.ZIndex = 52
Instance.new("UICorner", BtnConfirm).CornerRadius = UDim.new(0, 6)

local BtnCancel = Instance.new("TextButton", ModalCard)
BtnCancel.Size = UDim2.new(0, 100, 0, 30)
BtnCancel.Position = UDim2.new(0.5, 10, 1, -45)
BtnCancel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
BtnCancel.Text = "CANCEL"
BtnCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnCancel.Font = Enum.Font.GothamBold
BtnCancel.TextSize = 12
BtnCancel.ZIndex = 52
Instance.new("UICorner", BtnCancel).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- RENDER: Create Grid Cards
-- ==========================================
local CardList = {} 

-- [FIX 3]: ส่งฟังก์ชัน Update กลับมาทำเฉพาะปุ่ม ไม่ต้องรีเฟรชใหม่ทั้งหน้า
local function ShowConfirmModal(item, durationSeconds, updateCardFunc)
    ModalBackdrop.Visible = true
    ModalDesc.Text = string.format("Are you sure you want to buy\n%s\nfor %d Credits?", item.internalName, item.price)
    
    local connConfirm, connCancel
    
    local function Cleanup()
        ModalBackdrop.Visible = false
        if connConfirm then connConfirm:Disconnect() end
        if connCancel then connCancel:Disconnect() end
    end
    
    connCancel = BtnCancel.MouseButton1Click:Connect(Cleanup)
    
    connConfirm = BtnConfirm.MouseButton1Click:Connect(function()
        local userNow = GetSysData()
        if userNow.credits >= item.price then
            userNow.credits = userNow.credits - item.price
            SaveSysData(userNow)
            AddPurchasedScript(item.internalName, durationSeconds)
            CreditDisplay.Text = "CREDITS: " .. userNow.credits
            if updateCardFunc then updateCardFunc() end -- อัปเดตเฉพาะปุ่มนั้น ไม่เกิดการกะพริบ
            Cleanup()
        else
            ModalDesc.Text = "INSUFFICIENT CREDITS!"
            ModalDesc.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(1.5)
            Cleanup()
        end
    end)
end

local function RenderStoreList()
    for _, child in ipairs(ScrollContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    table.clear(CardList)
    
    local storeItems = FetchStoreItems()
    local currentUserData = GetSysData()
    CreditDisplay.Text = "CREDITS: " .. currentUserData.credits

    for _, item in ipairs(storeItems) do
        local durationSeconds = ParseTimeToSeconds(item.timeRaw)
        
        local GridCell = Instance.new("Frame", ScrollContainer)
        GridCell.BackgroundTransparency = 1
        
        local Card = Instance.new("Frame", GridCell)
        Card.Size = UDim2.new(1, 0, 1, 0)
        Card.Position = UDim2.new(0.5, 0, 0.5, 0)
        Card.AnchorPoint = Vector2.new(0.5, 0.5)
        Card.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        Card.ClipsDescendants = true
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardStroke = Instance.new("UIStroke", Card)
        CardStroke.Color = Color3.fromRGB(50, 50, 60)
        
        table.insert(CardList, {cell = GridCell, name = item.internalName:lower()})
        
        local ImageTop = Instance.new("ImageLabel", Card)
        ImageTop.Size = UDim2.new(1, 0, 0.5, 0)
        ImageTop.BackgroundColor3 = Color3.fromRGB(255, 100, 180)
        ImageTop.BorderSizePixel = 0
        ImageTop.ScaleType = Enum.ScaleType.Crop
        
        task.spawn(function()
            if item.uidmap then
                local s, info = pcall(function() return MarketplaceService:GetProductInfo(item.uidmap) end)
                if s and info then
                    ImageTop.Image = "rbxassetid://" .. info.IconImageAssetId
                    CardList[#CardList].name = info.Name:lower()
                end
            end
        end)

        local BottomHalf = Instance.new("Frame", Card)
        BottomHalf.Size = UDim2.new(1, 0, 0.5, 0)
        BottomHalf.Position = UDim2.new(0, 0, 0.5, 0)
        BottomHalf.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        BottomHalf.BorderSizePixel = 0
        
        local NameLbl = Instance.new("TextLabel", BottomHalf)
        NameLbl.Size = UDim2.new(1, -10, 0, 18)
        NameLbl.Position = UDim2.new(0, 5, 0, 5)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = item.internalName
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.Font = Enum.Font.Jura
        NameLbl.TextSize = 13
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local DescLbl = Instance.new("TextLabel", BottomHalf)
        DescLbl.Size = UDim2.new(1, -10, 0, 20)
        DescLbl.Position = UDim2.new(0, 5, 0, 23)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text = item.description
        DescLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        DescLbl.Font = Enum.Font.Gotham
        DescLbl.TextSize = 10
        DescLbl.TextWrapped = true
        DescLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local PriceLbl = Instance.new("TextLabel", BottomHalf)
        PriceLbl.Size = UDim2.new(1, -10, 0, 20)
        PriceLbl.Position = UDim2.new(0, 5, 1, -22)
        PriceLbl.BackgroundTransparency = 1
        PriceLbl.Text = "Price: " .. item.price
        PriceLbl.TextColor3 = Color3.fromRGB(255, 200, 240)
        PriceLbl.Font = Enum.Font.GothamBold
        PriceLbl.TextSize = 11
        PriceLbl.TextXAlignment = Enum.TextXAlignment.Left

        local BuyOverlay = Instance.new("TextButton", Card)
        BuyOverlay.Size = UDim2.new(1, 0, 1, 0)
        BuyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BuyOverlay.BackgroundTransparency = 1 
        BuyOverlay.Text = ""
        BuyOverlay.AutoButtonColor = false
        
        local OverlayText = Instance.new("TextLabel", BuyOverlay)
        OverlayText.Size = UDim2.new(1, 0, 1, 0)
        OverlayText.BackgroundTransparency = 1
        OverlayText.TextColor3 = Color3.fromRGB(255, 255, 255)
        OverlayText.Font = Enum.Font.Jura
        OverlayText.TextSize = 14
        OverlayText.TextTransparency = 1
        
        -- ฟังก์ชันเช็คสถานะว่ามีของชิ้นนี้อยู่แล้วหรือยัง
        local function IsItemOwned()
            local purchasedMap = GetPurchasedScripts()
            local expireTimestamp = purchasedMap[item.internalName]
            return (expireTimestamp and (expireTimestamp == -1 or expireTimestamp > os.time()))
        end

        -- ฟังก์ชันรีเฟรชเฉพาะ UI ของการ์ดใบนี้
        local function UpdateCardState()
            if IsItemOwned() then
                OverlayText.Text = "OWNED"
                OverlayText.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                OverlayText.Text = "HOLD TO BUY"
                OverlayText.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        UpdateCardState() -- รันครั้งแรก

        local ProgressFrame = Instance.new("Frame", BuyOverlay)
        ProgressFrame.Size = UDim2.new(0, 0, 0, 4)
        ProgressFrame.Position = UDim2.new(0, 0, 1, -4)
        ProgressFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 180)
        ProgressFrame.BorderSizePixel = 0
        ProgressFrame.BackgroundTransparency = 1

        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local isHovering, isHolding, holdConnection = false, false, nil
        
        BuyOverlay.MouseEnter:Connect(function()
            if ModalBackdrop.Visible then return end
            isHovering = true
            TweenService:Create(Card, tweenInfo, {Size = UDim2.new(1.05, 0, 1.05, 0)}):Play()
            TweenService:Create(BuyOverlay, tweenInfo, {BackgroundTransparency = 0.6}):Play()
            TweenService:Create(OverlayText, tweenInfo, {TextTransparency = 0}):Play()
        end)
        
        BuyOverlay.MouseLeave:Connect(function()
            isHovering, isHolding = false, false
            TweenService:Create(Card, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
            TweenService:Create(BuyOverlay, tweenInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(OverlayText, tweenInfo, {TextTransparency = 1}):Play()
            TweenService:Create(ProgressFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1}):Play()
            if not IsItemOwned() then OverlayText.Text = "HOLD TO BUY" end
        end)
        
        BuyOverlay.InputBegan:Connect(function(input)
            if IsItemOwned() or ModalBackdrop.Visible then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isHolding = true
                local startTime = os.clock()
                
                ProgressFrame.BackgroundTransparency = 0
                TweenService:Create(ProgressFrame, TweenInfo.new(3, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 4)}):Play()
                
                if holdConnection then holdConnection:Disconnect() end
                holdConnection = RunService.Heartbeat:Connect(function()
                    if not isHolding then holdConnection:Disconnect(); return end
                    
                    local elapsed = os.clock() - startTime
                    local remain = math.ceil(3 - elapsed)
                    OverlayText.Text = "HOLD... " .. remain
                    
                    if elapsed >= 3 then
                        isHolding = false
                        holdConnection:Disconnect()
                        OverlayText.Text = "PROCESSING"
                        TweenService:Create(ProgressFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1}):Play()
                        -- โยนฟังก์ชัน UpdateCardState เข้าไปตอนกดซื้อสำเร็จ
                        ShowConfirmModal(item, durationSeconds, UpdateCardState)
                    end
                end)
            end
        end)

        BuyOverlay.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isHolding = false
                TweenService:Create(ProgressFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1}):Play()
                if not IsItemOwned() and isHovering then OverlayText.Text = "HOLD TO BUY" end
            end
        end)
        
        task.spawn(function()
            if item.uidmap then
                local s, info = pcall(function() return MarketplaceService:GetProductInfo(item.uidmap) end)
                if s and info then NameLbl.Text = info.Name end
            end
        end)
    end
end

-- ==========================================
-- SYSTEM: Search Logic
-- ==========================================
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, itemData in ipairs(CardList) do
        itemData.cell.Visible = (query == "" or itemData.name:find(query) ~= nil)
    end
    -- [FIX 4]: ลบ task.wait(0.1) ออก เพื่อไม่ให้รบกวนระบบ GridLayout 
end)

task.spawn(RenderStoreList)
]...
