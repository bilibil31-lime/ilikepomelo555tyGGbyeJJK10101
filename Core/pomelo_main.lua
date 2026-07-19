TAB1 name=Main into
[...
-- ==================================================
-- MAIN TAB : PLAYER PROFILE UI
-- ==================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

-- 1. สร้างกรอบรวมด้านบน (สำหรับโปรไฟล์และกล่องดำ)
local TopContainer = Instance.new("Frame")
TopContainer.Parent = TabContainer
TopContainer.Size = UDim2.new(1, -20, 0, 140)
TopContainer.Position = UDim2.new(0, 10, 0, 15)
TopContainer.BackgroundTransparency = 1

-- ==================================================
-- 2. รูปโปรไฟล์ผู้เล่น (ซ้ายมือ)
-- ==================================================
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Parent = TopContainer
AvatarFrame.Size = UDim2.new(0, 120, 0, 120)
AvatarFrame.Position = UDim2.new(0, 0, 0.5, 0)
AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0) -- ทำให้เป็นวงกลม

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Parent = AvatarFrame
AvatarStroke.Color = Color3.fromRGB(138, 43, 226) -- สีม่วงตามรูป
AvatarStroke.Thickness = 3

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AvatarFrame
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

-- ดึงรูปหน้าผู้เล่นมาใส่
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)
if isReady then
    AvatarImage.Image = content
end

-- ==================================================
-- 3. กล่องข้อมูลสีดำ (ขวามือ)
-- ==================================================
local InfoBox = Instance.new("Frame")
InfoBox.Parent = TopContainer
InfoBox.Size = UDim2.new(1, -140, 1, -10)
InfoBox.Position = UDim2.new(0, 140, 0.5, 0)
InfoBox.AnchorPoint = Vector2.new(0, 0.5)
InfoBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- สีดำ
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 8)

-- ชื่อเล่น (Nickname)
local NicknameLabel = Instance.new("TextLabel")
NicknameLabel.Parent = InfoBox
NicknameLabel.Size = UDim2.new(0.5, -20, 0, 30)
NicknameLabel.Position = UDim2.new(0, 15, 0, 20)
NicknameLabel.BackgroundTransparency = 1
NicknameLabel.Text = Player.DisplayName
NicknameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NicknameLabel.Font = Enum.Font.GothamBold
NicknameLabel.TextSize = 20
NicknameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ชื่อผู้ใช้ (@username)
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = InfoBox
UsernameLabel.Size = UDim2.new(0.5, -20, 0, 30)
UsernameLabel.Position = UDim2.new(0, 15, 0, 70)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. Player.Name
UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.TextSize = 16
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ==================================================
-- 4. กล่องสีเทา (ข้อมูลไอดี / เครดิต)
-- ==================================================
local StatsBox = Instance.new("Frame")
StatsBox.Parent = InfoBox
StatsBox.Size = UDim2.new(0.5, -15, 1, -30)
StatsBox.Position = UDim2.new(0.5, 0, 0.5, 0)
StatsBox.AnchorPoint = Vector2.new(0, 0.5)
StatsBox.BackgroundColor3 = Color3.fromRGB(120, 120, 120) -- สีเทา
Instance.new("UICorner", StatsBox).CornerRadius = UDim.new(0, 6)

local function CreateStatText(text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = StatsBox
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ข้อมูลด้านในกล่องเทา (อายุไอดีจะดึงของจริงมาใส่ให้เลย)
CreateStatText("Account Age: " .. tostring(Player.AccountAge) .. " Days", 10)
CreateStatText("Time Left: Unlimited (Dev)", 40)
CreateStatText("Credits: 9,999 Coins", 70)

-- ==================================================
-- 5. ข้อความสคริปต์เครดิตด้านล่าง
-- ==================================================
local BottomText = Instance.new("TextLabel")
BottomText.Parent = TabContainer
BottomText.Size = UDim2.new(1, -20, 1, -170)
BottomText.Position = UDim2.new(0, 10, 0, 160)
BottomText.BackgroundTransparency = 1
BottomText.Text = "Script Info & Credits\n\nCreated by [Your Name]\nVersion 1.0.0"
BottomText.TextColor3 = Color3.fromRGB(180, 180, 180)
BottomText.Font = Enum.Font.Gotham
BottomText.TextSize = 16
BottomText.TextYAlignment = Enum.TextYAlignment.Top
]...
TAB2 name=Main2
[...
my 
]...
