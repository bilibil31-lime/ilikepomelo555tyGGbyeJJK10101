TAB1 name=Main
[...
-- ==================================================
-- MAIN TAB UI COMPONENTS
-- ==================================================
local TabContainer = _G.CurrentPomeloTab
if not TabContainer then return end

-- 1. Create a ScrollingFrame so we can scroll if there are many items
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = TabContainer
Scroll.Size = UDim2.new(1, -10, 1, -10)
Scroll.Position = UDim2.new(0, 5, 0, 5)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

-- 2. Create UIListLayout to automatically arrange elements from top to bottom
local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==================================================
-- FUNCTIONS TO CREATE UI ELEMENTS (BUTTONS & TOGGLES)
-- ==================================================

-- Function: Create a Button
local function AddButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Scroll
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    -- Hover Effect
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 85) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(65, 65, 70) end)
    
    Btn.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- Function: Create a Toggle (Switch)
local function AddToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = Scroll
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Switch = Instance.new("TextButton")
    Switch.Parent = Frame
    Switch.Size = UDim2.new(0, 25, 0, 25)
    Switch.Position = UDim2.new(1, -35, 0.5, 0)
    Switch.AnchorPoint = Vector2.new(0, 0.5)
    Switch.BackgroundColor3 = Color3.fromRGB(255, 70, 70) -- Red (Off)
    Switch.Text = ""
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 6)

    local toggled = false
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Switch.BackgroundColor3 = Color3.fromRGB(70, 255, 100) -- Green (On)
        else
            Switch.BackgroundColor3 = Color3.fromRGB(255, 70, 70) -- Red (Off)
        end
        callback(toggled)
    end)
end

-- ==================================================
-- ADD YOUR FEATURES HERE
-- ==================================================

-- 🟢 Toggle: Auto Farm
AddToggle("Auto Farm (Level)", function(state)
    _G.AutoFarm = state
    print("Auto Farm is now:", state)
    -- ใส่โค้ด Auto Farm ของคุณตรงนี้
end)

-- 🟢 Toggle: Auto Quest
AddToggle("Auto Quest", function(state)
    _G.AutoQuest = state
    print("Auto Quest is now:", state)
    -- ใส่โค้ด Auto Quest ตรงนี้
end)

-- 🔵 Button: Redeem All Codes
AddButton("Redeem All Codes", function()
    print("Redeeming Codes...")
    -- ใส่โค้ดใส่โค้ดแจกของฟรีตรงนี้
end)

-- 🔵 Button: Teleport to Safe Zone
AddButton("Teleport to Safe Zone", function()
    print("Teleporting...")
    -- ใส่โค้ดวาปตรงนี้
end)

]...
