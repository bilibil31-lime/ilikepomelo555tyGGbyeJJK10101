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
local Player = Players.LocalPlayer

local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

-- ==========================================
-- SYSTEM: Setup Hidden Folders & Files
-- ==========================================
local HIDDEN_FOLDER = "Roblox_Crash_Dump"
local SYSDATA_FILE = "Pomelo_System/SysData.cfg" -- อ่านเงินจากที่เดิม
local STOREDATA_FILE = HIDDEN_FOLDER .. "/win32_cache.dmp" -- ซ่อนไฟล์ประวัติการซื้อในชื่อหลอกๆ

if makefolder and not isfolder(HIDDEN_FOLDER) then
    pcall(makefolder, HIDDEN_FOLDER)
end

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
    if isfile and isfile(SYSDATA_FILE) then
        local s, dataStr = pcall(readfile, SYSDATA_FILE)
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
    if writefile then pcall(writefile, SYSDATA_FILE, EncodeData(rawStr)) end
end

-- ==========================================
-- SYSTEM: Store Memory (Crash Dump format)
-- ==========================================
local function GetPurchasedScripts()
    local purchased = {}
    if isfile and isfile(STOREDATA_FILE) then
        local s, dataStr = pcall(readfile, STOREDATA_FILE)
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
    if writefile then pcall(writefile, STOREDATA_FILE, EncodeData(table.concat(list, "|"))) end
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

-- ==========================================
-- Fetch Data
-- ==========================================
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
-- UI: Main Structure
-- ==========================================
local MainBackground = Instance.new("Frame", TabContainer)
MainBackground.Size = UDim2.new(1, 0, 1, 0)
MainBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- พื้นหลังสีเทาเข้ม
MainBackground.BorderSizePixel = 0

-- Header: P.store
local StoreTitle = Instance.new("TextLabel", MainBackground)
StoreTitle.Size = UDim2.new(0, 150, 0, 40)
StoreTitle.Position = UDim2.new(0, 20, 0, 15)
StoreTitle.BackgroundTransparency = 1
StoreTitle.Text = "P.store"
StoreTitle.TextColor3 = Color3.fromRGB(255, 102, 204) -- สีชมพู
StoreTitle.Font = Enum.Font.GothamBold
StoreTitle.TextSize = 38
StoreTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Header: Credit Display (Added for convenience)
local CreditDisplay = Instance.new("TextLabel", MainBackground)
CreditDisplay.Size = UDim2.new(0, 100, 0, 20)
CreditDisplay.Position = UDim2.new(0, 20, 0, 55)
CreditDisplay.BackgroundTransparency = 1
CreditDisplay.TextColor3 = Color3.fromRGB(220, 220, 220)
CreditDisplay.Font = Enum.Font.GothamMedium
CreditDisplay.TextSize = 14
CreditDisplay.TextXAlignment = Enum.TextXAlignment.Left

-- Header: Search Bar (Pink BG, Purple Stroke)
local SearchFrame = Instance.new("Frame", MainBackground)
SearchFrame.Size = UDim2.new(0.4, 0, 0, 40)
SearchFrame.Position = UDim2.new(1, -20, 0, 15)
SearchFrame.AnchorPoint = Vector2.new(1, 0)
SearchFrame.BackgroundColor3 = Color3.fromRGB(255, 102, 204) -- สีชมพู
local SearchCorner = Instance.new("UICorner", SearchFrame)
SearchCorner.CornerRadius = UDim.new(0, 6)
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Color3.fromRGB(153, 51, 255) -- กรอบสีม่วง
SearchStroke.Thickness = 3

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -40, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(255, 200, 230)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.GothamBold
SearchBox.TextSize = 16
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Text = ""

local SearchIcon = Instance.new("TextLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0, 30, 0, 30)
SearchIcon.Position = UDim2.new(1, -5, 0.5, 0)
SearchIcon.AnchorPoint = Vector2.new(1, 0.5)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 20

-- Scroll Area & Grid Layout
local ScrollContainer = Instance.new("ScrollingFrame", MainBackground)
ScrollContainer.Size = UDim2.new(1, -40, 1, -90)
ScrollContainer.Position = UDim2.new(0, 20, 0, 80)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 102, 204)

local GridLayout = Instance.new("UIGridLayout", ScrollContainer)
GridLayout.CellSize = UDim2.new(0, 140, 0, 170) -- ขนาดการ์ด
GridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- ==========================================
-- RENDER: Create Grid Cards
-- ==========================================
local CardList = {} -- เก็บไว้ทำระบบ Search

local function RenderStoreList()
    for _, child in ipairs(ScrollContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    table.clear(CardList)
    
    local storeItems = FetchStoreItems()
    local purchasedMap = GetPurchasedScripts()
    local currentUserData = GetSysData()
    CreditDisplay.Text = "Credits: " .. currentUserData.credits .. " 💎"

    for _, item in ipairs(storeItems) do
        local durationSeconds = ParseTimeToSeconds(item.timeRaw)
        local expireTimestamp = purchasedMap[item.internalName]
        local isOwned = (expireTimestamp and (expireTimestamp == -1 or expireTimestamp > os.time()))
        
        -- คอนเทนเนอร์ล่องหน (สำหรับรักษาระยะ Grid ไม่ให้พังตอน Hover)
        local GridCell = Instance.new("Frame", ScrollContainer)
        GridCell.BackgroundTransparency = 1
        
        -- การ์ดของจริง (Visual Card) ที่จะขยายใหญ่ขึ้นได้
        local Card = Instance.new("Frame", GridCell)
        Card.Size = UDim2.new(1, 0, 1, 0)
        Card.Position = UDim2.new(0.5, 0, 0.5, 0)
        Card.AnchorPoint = Vector2.new(0.5, 0.5)
        Card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Card.ClipsDescendants = true
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        
        -- เก็บไว้สำหรับ Search
        table.insert(CardList, {cell = GridCell, name = item.internalName:lower()})
        
        -- ครึ่งบน: ภาพปก (Pink Placeholder แบบในภาพอ้างอิง)
        local ImageTop = Instance.new("ImageLabel", Card)
        ImageTop.Size = UDim2.new(1, 0, 0.55, 0)
        ImageTop.BackgroundColor3 = Color3.fromRGB(255, 102, 204)
        ImageTop.BorderSizePixel = 0
        ImageTop.ScaleType = Enum.ScaleType.Crop
        
        -- ดึงรูปจาก Roblox (ถ้าพังจะเป็นสีชมพู)
        task.spawn(function()
            if item.uidmap then
                local s, info = pcall(function() return MarketplaceService:GetProductInfo(item.uidmap) end)
                if s and info then
                    ImageTop.Image = "rbxassetid://" .. info.IconImageAssetId
                    -- เก็บชื่อจริงไว้ใช้กับ Search ได้ด้วย
                    CardList[#CardList].name = info.Name:lower()
                end
            end
        end)

        -- ครึ่งล่าง: ข้อมูล
        local BottomHalf = Instance.new("Frame", Card)
        BottomHalf.Size = UDim2.new(1, 0, 0.45, 0)
        BottomHalf.Position = UDim2.new(0, 0, 0.55, 0)
        BottomHalf.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        BottomHalf.BorderSizePixel = 0
        
        -- ไล่สีเทาเข้ม->ดำ แบบในภาพ
        local BtmGradient = Instance.new("UIGradient", BottomHalf)
        BtmGradient.Color = ColorSequence.new(Color3.fromRGB(60, 60, 60), Color3.fromRGB(20, 20, 20))
        BtmGradient.Rotation = 90
        
        local NameLbl = Instance.new("TextLabel", BottomHalf)
        NameLbl.Size = UDim2.new(1, -10, 0, 20)
        NameLbl.Position = UDim2.new(0, 5, 0, 5)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = item.internalName
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextSize = 13
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local DescLbl = Instance.new("TextLabel", BottomHalf)
        DescLbl.Size = UDim2.new(1, -10, 0, 15)
        DescLbl.Position = UDim2.new(0, 5, 0, 25)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text = item.description
        DescLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        DescLbl.Font = Enum.Font.Gotham
        DescLbl.TextSize = 10
        DescLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local PriceLbl = Instance.new("TextLabel", BottomHalf)
        PriceLbl.Size = UDim2.new(1, -10, 0, 20)
        PriceLbl.Position = UDim2.new(0, 5, 1, -25)
        PriceLbl.BackgroundTransparency = 1
        PriceLbl.Text = item.price .. " 💎"
        PriceLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        PriceLbl.Font = Enum.Font.GothamBold
        PriceLbl.TextSize = 12
        PriceLbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Hover Overlay (ซ่อนไว้ โชว์ตอนชี้/แตะ)
        local BuyOverlay = Instance.new("TextButton", Card)
        BuyOverlay.Size = UDim2.new(1, 0, 1, 0)
        BuyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BuyOverlay.BackgroundTransparency = 1 -- 1 = ซ่อน
        BuyOverlay.Text = ""
        BuyOverlay.AutoButtonColor = false
        
        local OverlayText = Instance.new("TextLabel", BuyOverlay)
        OverlayText.Size = UDim2.new(1, 0, 1, 0)
        OverlayText.BackgroundTransparency = 1
        OverlayText.TextColor3 = Color3.fromRGB(255, 255, 255)
        OverlayText.Font = Enum.Font.GothamBold
        OverlayText.TextSize = 18
        OverlayText.TextTransparency = 1
        
        if isOwned then
            OverlayText.Text = "OWNED ✅"
            OverlayText.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            OverlayText.Text = "BUY 🛒"
        end

        -- ==========================================
        -- Animation & Interaction
        -- ==========================================
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- ขยายขึ้นตอนชี้ / เลื่อนเมาส์
        BuyOverlay.MouseEnter:Connect(function()
            TweenService:Create(Card, tweenInfo, {Size = UDim2.new(1.08, 0, 1.08, 0)}):Play()
            TweenService:Create(BuyOverlay, tweenInfo, {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(OverlayText, tweenInfo, {TextTransparency = 0}):Play()
        end)
        
        -- กลับขนาดเดิมตอนเอาเมาส์ออก
        BuyOverlay.MouseLeave:Connect(function()
            TweenService:Create(Card, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
            TweenService:Create(BuyOverlay, tweenInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(OverlayText, tweenInfo, {TextTransparency = 1}):Play()
        end)
        
        -- ระบบกดซื้อ
        BuyOverlay.MouseButton1Click:Connect(function()
            if isOwned then return end -- มีอยู่แล้ว ข้ามไป
            
            local userNow = GetSysData()
            if userNow.credits >= item.price then
                userNow.credits = userNow.credits - item.price
                SaveSysData(userNow)
                AddPurchasedScript(item.internalName, durationSeconds)
                
                OverlayText.Text = "SUCCESS!"
                OverlayText.TextColor3 = Color3.fromRGB(100, 255, 150)
                task.wait(0.5)
                RenderStoreList() -- รีโหลดหน้าต่างหลังซื้อ
            else
                OverlayText.Text = "No Credit!"
                OverlayText.TextColor3 = Color3.fromRGB(255, 100, 100)
                task.wait(1)
                OverlayText.Text = "BUY 🛒"
                OverlayText.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        -- อัปเดตชื่อให้สวยๆ ถ้าหาใน Roblox เจอ
        task.spawn(function()
            if item.uidmap then
                local s, info = pcall(function() return MarketplaceService:GetProductInfo(item.uidmap) end)
                if s and info then
                    NameLbl.Text = info.Name
                end
            end
        end)
    end
    
    -- คำนวณความสูงของ Scroll (ให้เลื่อนลงได้)
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, GridLayout.AbsoluteContentSize.Y + 30)
end

-- ==========================================
-- SYSTEM: Search Logic (ช่องค้นหา)
-- ==========================================
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, itemData in ipairs(CardList) do
        if query == "" or itemData.name:find(query) then
            itemData.cell.Visible = true
        else
            itemData.cell.Visible = false
        end
    end
    -- อัปเดตขนาด Canvas ใหม่
    task.wait(0.1)
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, GridLayout.AbsoluteContentSize.Y + 30)
end)

-- Initial Load
task.spawn(RenderStoreList)
]...
