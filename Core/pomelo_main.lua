-- [[ Pomelo Byte : Main UI ]] --
print("Main UI Loaded Successfully!")

-- ตรงนี้คือโค้ด UI ตัวเต็มของคุณ 
-- เมื่อผู้ใช้กดปุ่มต่างๆ ใน UI มันก็จะไปดึงข้อมูลจากโฟลเดอร์ Modules

local function loadCredit()
    -- โหลดข้อมูลเครดิตที่คุณวาดไว้ในแผนผัง
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB_NAME/PomeloByte_Project/main/Modules/mod_credit.lua"))()
end

-- ทำงานเมื่อคลิกปุ่ม Credit
loadCredit()
