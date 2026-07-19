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
local userType = "Unverified ❌" -- เปลี่ยนจาก Guest เป็น Unverified หากไม่พบคีย์
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
                
                -- เช็คประเภทและตั้งค่าให้ตรงกับหน้าที่บันทึกคีย์มา
                if data.type == "admin" then
                    userType = "Admin 👑"
                    isPermanent = true
                elseif data.type == "friend" then
                    userType = "Friend 🤝"
                    -- ถ้าเวลาเกิน 10 ปี ให้ถือว่าถาวร
                    if expireTime > os.time() + (3650 * 24 * 3600) then isPermanent = true end
                elseif data.type == "user" then
                    userType = "Normal User 👤" -- ผู้ใช้คีย์ธรรมดา 24 ชั่วโมง
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
        
        if userType == "Unverified ❌" then
            TimeLeftLabel.Text = "⏳ Time Left: <b>No Key ❌</b>"
        elseif isPermanent then
            TimeLeftLabel.Text = "⏳ Time Left: <b>Lifetime ♾️</b>"
        else
            -- คำนวณเวลาถอยหลัง (วินาที)
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

<font color='rgb(255,100,180)'><b>🔹 Status (สถานะผู้ใช้งาน)</b></font>
• <b>Normal User:</b> ระดับปกติ ได้รับจากการหาคีย์ฟรี (อายุใช้งาน 24 ชั่วโมง)
• <b>Friend / Admin:</b> ระดับพิเศษ สิทธิ์แบบถาวรและฟังก์ชันเข้าถึงสคริปต์ขั้นสูง

<font color='rgb(255,100,180)'><b>🔹 Time Left (เวลาคงเหลือ)</b></font>
• แสดงเวลานับถอยหลังก่อนที่คีย์ปัจจุบันจะหมดอายุ หากเวลาเป็น 0 คุณจะต้องไปรับคีย์ใหม่ผ่านระบบเพื่อเข้าใช้งานอีกครั้ง

<font color='rgb(255,100,180)'><b>🔹 Credits (เครดิตการเข้าใช้)</b></font>
• <b>Normal User:</b> จำกัดเครดิตการรันสคริปต์ ระบบจะหักเครดิตทุกครั้งที่รันเพื่อป้องกันการสแปม
• <b>Friend / Admin:</b> ใช้งานได้แบบ Unlimited ไม่มีวันหมด

<font color='rgb(255,100,180)'><b>🔹 Device (อุปกรณ์)</b></font>
• ระบบจะตรวจสอบอุปกรณ์ (PC / Mobile / Console) อัตโนมัติเพื่อรีดประสิทธิภาพการประมวลผลสคริปต์ให้เสถียรที่สุด

<font color='rgb(255,150,150)'><i>💖 Secure, Reliable, and Engineered for Excellence 💖</i></font>
]]
]...
TAB2 name=Main2
[...
my 
]...
