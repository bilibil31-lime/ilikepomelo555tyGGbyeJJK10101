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
local userType = "Unverified ❌" -- ลบคำว่า Guest ออกทั้งหมด
local userCredits = 0
local expireTime = 0
local isPermanent = false

local FOLDER_NAME = "Pomelo_System"
local FILE_NAME = FOLDER_NAME .. "/SysData.cfg"

local function DecodeData(dataStr)
    local hexData = string.match(dataStr, "POMELO_SECURE_V1\n([%a%d]+)\nEOF")
    if not hexData then return nil end
    local rawData = (hexData:gsub("%x%x", function(c) return string.char(tonumber(c, 16)) end))
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
                
                -- เช็คประเภทและตั้งค่าให้ตรง (รองรับทั้งไฟล์เซฟเก่าและใหม่)
                if data.type == "admin" then
                    userType = "Admin 👑"
                    isPermanent = true
                elseif data.type == "friend" then
                    userType = "Friend 🤝"
                    -- ถ้าเวลาเกิน 10 ปี ให้ถือว่าถาวร
                    if expireTime > os.time() + (3650 * 24 * 3600) then isPermanent = true end
                elseif data.type == "user" or data.type == "normal" then 
                    -- รองรับ data.type == "normal" จากไฟล์เก่าที่คุณเคยรันก่อนหน้านี้ด้วย
                    userType = "Normal User 👤" 
                    isPermanent = false
                else
                    -- ถ้าหลุดเคสอื่นมา แต่มี expireTime ก็ให้นับเป็น Normal User ไว้ก่อน
                    userType = "Normal User 👤"
                    isPermanent = false
                end
            end
        end
    end
end
pcall(CheckUserStatus)

-- เช็คอุปกรณ์ที่เล่น
local deviceType = "Unknown ❓"
if UIS.KeyboardEnabled and UIS.MouseEnabled then
    deviceType = "PC 💻"
elseif UIS.TouchEnabled and not UIS.MouseEnabled then
    deviceType = "Mobile 📱"
elseif UIS.GamepadEnabled then
    deviceType = "Console 🎮"
end

local ProfileCard = Instance.new("Frame", TabContainer)
ProfileCard.Size = UDim2.new(1, -20, 0, 130) 
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
local CreditsLabel = CreateStatBadge("💎 Credits: <b>" .. (userCredits > 9000 and "Unlimited" or tostring(userCredits)) .. "</b>")
CreateStatBadge("🎮 Device: <b>" .. deviceType .. "</b>")

-- ==========================================
-- UPDATE: ระบบ Loop คำนวณเวลานับถอยหลัง
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if not TimeLeftLabel or not TimeLeftLabel.Parent then break end
        
        -- ถ้ายอด expireTime เป็น 0 หรือไม่มีคีย์ ให้ขึ้น No Key
        if expireTime == 0 or userType == "Unverified ❌" then
            TimeLeftLabel.Text = "⏳ Time Left: <b>No Key ❌</b>"
        elseif isPermanent then
            TimeLeftLabel.Text = "⏳ Time Left: <b>Lifetime ♾️</b>"
        else
            -- ระบบนับเวลาถอยหลังแบบเรียลไทม์
            local diff = expireTime - os.time()
            
            if diff <= 0 then
                TimeLeftLabel.Text = "⏳ Time Left: <b>Expired ❌</b>"
            else
                local days = math.floor(diff / 86400)
                local hours = math.floor((diff % 86400) / 3600)
                local minutes = math.floor((diff % 3600) / 60)
                local seconds = diff % 60
                
                -- อัปเดตข้อความเรื่อยๆ ตามวินาทีที่เดิน
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
FooterContainer.Size = UDim2.new(1, -20, 1, -165)
FooterContainer.Position = UDim2.new(0, 10, 0, 155)
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

BottomText.Text = [[
<font size='16' color='rgb(255,180,220)'><b>💎 ACCOUNT & PRIVILEGES 💎</b></font>
<font size='11' color='rgb(200,200,200)'><i>"Live sync with Pomelo Security Protocols"</i></font>

<font color='rgb(255,100,180)'><b>🔹 User Access Status</b></font>
• <b>Normal User:</b> Standard tier obtained via the free public key generation system. Grants full access to baseline features for a temporary duration of 24 hours per session.
• <b>Friend / Admin:</b> Premium whitelisted status granting permanent lifetime privileges, absolute bypass authority, and exclusive access to advanced core functions.

<font color='rgb(255,100,180)'><b>🔹 Key Expiration & Time Left</b></font>
• Displays a real-time countdown monitoring your active session authorization. Once this timer reaches zero, the current key expires, requiring a new key generation through the official link to restore full utility.

<font color='rgb(255,100,180)'><b>🔹 Execution Credits</b></font>
• <b>Normal User:</b> Displays the remaining session credits allocated to your profile. Credits are dynamically updated upon new key validation to balance server load and maintain network integrity against automated spamming.
• <b>Friend / Admin:</b> Fully unrestricted and unlimited usage with zero execution barriers or credit enforcement rules.

<font color='rgb(255,100,180)'><b>🔹 Hardware Optimization</b></font>
• Intelligent cross-platform environment detection (PC, Mobile, or Console) engineered to automatically calibrate script parameters, maximize frame rates, and ensure ultimate runtime stability.

<font color='rgb(255,150,150)'><i>💖 Secure, Reliable, and Engineered for Excellence 💖</i></font>
]]
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
CreateToggle("Ultra Smooth Graphics", "Adjusts colors and makes the world smooth for better FPS.", false, function(state)
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
CreateToggle("Low Detail Mode (FPS Boost)", "Removes textures and turns materials to smooth plastic.", false, function(state)
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
