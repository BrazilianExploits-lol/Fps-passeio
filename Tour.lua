--[[ 
    BRAZILIAN EXPLOITS | [FPS] Passeio V11
    Owner: NILLGHOST300
    UI: WindUI
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local Window = WindUI:CreateWindow({
    Title = "BRAZILIAN EXPLOITS | [FPS] Passeio",
    Icon = "rbxassetid://4483345998",
    Author = "Owner: NILLGHOST300",
    Folder = "BrazilianExploits",
    Size = UDim2.fromOffset(650, 550),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = false,
})

-- ==========================================
-- ABA 1: INFO (BOAS-VINDAS, TEMPO E DISCORD)
-- ==========================================
local InfoTab = Window:Tab({ Title = "Info", Icon = "user" })

-- Texto de Boas-Vindas
InfoTab:Paragraph({
    Title = "Welcome, " .. LocalPlayer.Name,
    Desc = "Obrigado por usar o Brazilian Exploits!"
})

-- Sistema de Tempo de Uso
local StartTime = tick() -- Marca o tempo que o script começou
local TempoLabel = InfoTab:Paragraph({
    Title = "⏱️ Tempo de Uso:",
    Desc = "00:00:00"
})

-- Loop pra atualizar o tempo a cada 1 segundo
task.spawn(function()
    while true do
        task.wait(1)
        local TempoDecorrido = tick() - StartTime
        local Horas = math.floor(TempoDecorrido / 3600)
        local Minutos = math.floor((TempoDecorrido % 3600) / 60)
        local Segundos = math.floor(TempoDecorrido % 60)
        
        -- Atualiza o texto no menu
        TempoLabel:SetDesc(string.format("%02d:%02d:%02d", Horas, Minutos, Segundos))
    end
end)

-- Botão do Discord
InfoTab:Button({
    Title = "🔗 Entrar no Discord (Brazilian Exploits)",
    Desc = "Clique para copiar o link do nosso servidor",
    Callback = function() 
        pcall(function() setclipboard("https://discord.gg/pRVGa4PqSC") end)
        Window:Notify({ Title = "Copiado!", Content = "Link do Discord copiado!", Icon = "check" })
    end
})

-- ==========================================
-- ABA 2: AIMBOT HEAD (COM WALL CHECK)
-- ==========================================
local CombatTab = Window:Tab({ Title = "Aimbot Head", Icon = "crosshair" })
local AimbotEnabled, AutoShootEnabled = false, false

local function isPlayerVisible(targetCharacter)
    if not targetCharacter or not targetCharacter:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local destination = targetCharacter.Head.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult == nil
end

CombatTab:Toggle({ Title = "Aimbot Head (Travar Mira)", Default = false, Callback = function(v) AimbotEnabled = v end })
CombatTab:Toggle({ Title = "Auto Shoot (Atirar)", Default = false, Callback = function(v) AutoShootEnabled = v end })

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local shortestDistance = math.huge
    local closestPlayerHead = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local head = char.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local visible = isPlayerVisible(char)
                
                if onScreen and visible then
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closestPlayerHead = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    if closestPlayerHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayerHead.Position)
        if AutoShootEnabled then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end
    end
end)

-- ==========================================
-- ABA 3: ESP (TODOS OS TIPOS)
-- ==========================================
local VisualTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local ESP = { Box = false, Name = false, HealthBar = false, Distance = false, Skeleton = false, Snapline = false, Arrow = false, Chams = false }
local GlobalESPColor = Color3.fromRGB(255, 0, 0)
local Highlights, Drawings = {}, {}

VisualTab:Toggle({ Title = "1. ESP Caixa (Quadrado)", Default = false, Callback = function(v) ESP.Box = v end })
VisualTab:Toggle({ Title = "2. Chams (Brilho no Corpo)", Default = false, Callback = function(v) 
    ESP.Chams = v
    if not v then for _, h in pairs(Highlights) do h:Destroy() end Highlights = {} end
end })
VisualTab:Toggle({ Title = "3. ESP Nome", Default = false, Callback = function(v) ESP.Name = v end })
VisualTab:Toggle({ Title = "4. ESP Vida (Barra)", Default = false, Callback = function(v) ESP.HealthBar = v end })
VisualTab:Toggle({ Title = "5. ESP Distância", Default = false, Callback = function(v) ESP.Distance = v end })
VisualTab:Toggle({ Title = "6. ESP Skeleton", Default = false, Callback = function(v) ESP.Skeleton = v end })
VisualTab:Toggle({ Title = "7. Snapline", Default = false, Callback = function(v) ESP.Snapline = v end })
VisualTab:Toggle({ Title = "8. Seta na Cabeça", Default = false, Callback = function(v) ESP.Arrow = v end })

VisualTab:Colorpicker({ Title = "🎨 Cor do ESP", Default = GlobalESPColor, Callback = function(color) GlobalESPColor = color end })

local function LimparESP(p)
    if Drawings[p] then
        if Drawings[p].Box then Drawings[p].Box:Remove() end
        if Drawings[p].Name then Drawings[p].Name:Remove() end
        if Drawings[p].HealthBg then Drawings[p].HealthBg:Remove() end
        if Drawings[p].HealthBar then Drawings[p].HealthBar:Remove() end
        if Drawings[p].Distance then Drawings[p].Distance:Remove() end
        if Drawings[p].Snapline then Drawings[p].Snapline:Remove() end
        if Drawings[p].Arrow then Drawings[p].Arrow:Remove() end
        if Drawings[p].Skeleton then for _, line in pairs(Drawings[p].Skeleton) do line:Remove() end end
        Drawings[p] = nil
    end
    if Highlights[p] then
        Highlights[p]:Destroy()
        Highlights[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or p.Character.Humanoid.Health <= 0 then
            LimparESP(p)
        else
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            
            if head and char:FindFirstChild("Humanoid") then
                if not Drawings[p] then
                    Drawings[p] = {
                        Box = Drawing.new("Square"), Name = Drawing.new("Text"), 
                        HealthBg = Drawing.new("Square"), HealthBar = Drawing.new("Square"),
                        Distance = Drawing.new("Text"), Skeleton = {}, Snapline = Drawing.new("Line"), Arrow = Drawing.new("Triangle")
                    }
                    for i = 1, 15 do Drawings[p].Skeleton[i] = Drawing.new("Line") end
                end
                
                local d = Drawings[p]
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                
                -- Caixa
                if ESP.Box and onScreen then
                    local height = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0)).Y)
                    d.Box.Size = Vector2.new(height/2, height)
                    d.Box.Position = Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.Box.Color = GlobalESPColor; d.Box.Thickness = 2; d.Box.Visible = true
                else d.Box.Visible = false end
                
                -- Chams
                if ESP.Chams and onScreen then
                    if not Highlights[p] then
                        local h = Instance.new("Highlight", char)
                        h.FillTransparency = 0.5
                        Highlights[p] = h
                    end
                    Highlights[p].FillColor = GlobalESPColor
                elseif Highlights[p] then Highlights[p]:Destroy(); Highlights[p] = nil end

                -- Nome
                if ESP.Name and headOnScreen then
                    d.Name.Text = p.Name; d.Name.Position = Vector2.new(headPos.X, headPos.Y - 45)
                    d.Name.Color = GlobalESPColor; d.Name.Size = 16; d.Name.Visible = true
                else d.Name.Visible = false end

                -- Distância
                if ESP.Distance and headOnScreen then
                    local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    d.Distance.Text = tostring(dist) .. "m"; d.Distance.Position = Vector2.new(headPos.X, headPos.Y - 30)
                    d.Distance.Color = Color3.fromRGB(255, 255, 255); d.Distance.Size = 14; d.Distance.Visible = true
                else d.Distance.Visible = false end

                -- Vida
                if ESP.HealthBar and onScreen then
                    local height = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0)).Y)
                    local healthPercent = char.Humanoid.Health / char.Humanoid.MaxHealth
                    
                    d.HealthBg.Size = Vector2.new(4, height)
                    d.HealthBg.Position = Vector2.new(pos.X - (height/4) - 10, pos.Y - height/2)
                    d.HealthBg.Color = Color3.fromRGB(0, 0, 0); d.HealthBg.Filled = true; d.HealthBg.Visible = true
                    
                    d.HealthBar.Size = Vector2.new(4, height * healthPercent)
                    d.HealthBar.Position = Vector2.new(pos.X - (height/4) - 10, pos.Y - (height/2) + (height * (1 - healthPercent)))
                    
                    if healthPercent > 0.5 then d.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.2 then d.HealthBar.Color = Color3.fromRGB(255, 255, 0)
                    else d.HealthBar.Color = Color3.fromRGB(255, 0, 0) end
                    
                    d.HealthBar.Filled = true; d.HealthBar.Visible = true
                else d.HealthBg.Visible = false; d.HealthBar.Visible = false end

                -- Skeleton
                if ESP.Skeleton and onScreen and char:FindFirstChild("UpperTorso") then
                    local bones = {
                        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                    }
                    for i, bone in ipairs(bones) do
                        local line = d.Skeleton[i]
                        local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                        if p1 and p2 then
                            local v1, v2 = Camera:WorldToViewportPoint(p1.Position), Camera:WorldToViewportPoint(p2.Position)
                            if v1.Z > 0 and v2.Z > 0 then
                                line.From = Vector2.new(v1.X, v1.Y); line.To = Vector2.new(v2.X, v2.Y); line.Color = GlobalESPColor; line.Visible = true
                            else line.Visible = false end
                        end
                    end
                else for _, line in pairs(d.Skeleton) do line.Visible = false end end

                -- Snapline
                if ESP.Snapline and onScreen then
                    d.Snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    d.Snapline.To = Vector2.new(pos.X, pos.Y); d.Snapline.Color = GlobalESPColor; d.Snapline.Visible = true
                else d.Snapline.Visible = false end

                -- Seta
                if ESP.Arrow and headOnScreen then
                    local size = 10
                    d.Arrow.PointA = Vector2.new(headPos.X, headPos.Y - 15); d.Arrow.PointB = Vector2.new(headPos.X - size/2, headPos.Y - 25); d.Arrow.PointC = Vector2.new(headPos.X + size/2, headPos.Y - 25)
                    d.Arrow.Color = GlobalESPColor; d.Arrow.Visible = true
                else d.Arrow.Visible = false end
            end
        end
    end
end)

-- ==========================================
-- ABA 4: HITBOX & UTILIDADES
-- ==========================================
local UtilTab = Window:Tab({ Title = "Hitbox & Util", Icon = "box" })
local HitboxEnabled, HitboxSize = false, 10

UtilTab:Toggle({ 
    Title = "Hitbox Invisível (Cabeça Gigante)", 
    Default = false, 
    Callback = function(v) 
        HitboxEnabled = v 
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    local hb = p.Character.Head:FindFirstChild("BE_Hitbox")
                    if hb then hb:Destroy() end
                end
            end
        end
    end 
})

UtilTab:Slider({ Title = "Tamanho da Hitbox", Step = 1, Value = { Min = 2, Max = 30, Default = 10 }, Callback = function(v) HitboxSize = v end })

RunService.RenderStepped:Connect(function()
    if not HitboxEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if not head:FindFirstChild("BE_Hitbox") then
                local hb = Instance.new("Part")
                hb.Name = "BE_Hitbox"
                hb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hb.Transparency = 1
                hb.CanCollide = false
                hb.Massless = true
                hb.Parent = head
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = head
                weld.Part1 = hb
                weld.Parent = hb
            else
                head.BE_Hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            end
        end
    end
end)

UtilTab:Slider({ Title = "Velocidade (WalkSpeed)", Step = 1, Value = { Min = 16, Max = 150, Default = 16 }, Callback = function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
end })

UtilTab:Slider({ Title = "Força do Pulo", Step = 1, Value = { Min = 50, Max = 300, Default = 50 }, Callback = function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end 
end })

-- ==========================================
-- ABA 5: CRÉDITOS
-- ==========================================
local CreditsTab = Window:Tab({ Title = "Créditos", Icon = "info" })
CreditsTab:Paragraph({
    Title = "BRAZILIAN EXPLOITS | [FPS] Passeio",
    Desc = "Owner: NILLGHOST300\n\nAimbot, ESP Completo, Hitbox e Utilidades.\nObrigado por confiar no nosso trabalho!"
})

Window:Notify({ Title = "BRAZILIAN EXPLOITS", Content = "Bem-vindo, " .. LocalPlayer.Name .. "!", Icon = "check", Duration = 5 })
