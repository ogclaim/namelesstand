--[[ Nameless.cc live client - quiet, defaults off ]]
local CONTROL_URL = "https://nameless-cc-default-rtdb.asia-southeast1.firebasedatabase.app/nameless.json"
local CONTROL_HEADER_KEY = ""
local POLL = 0.1

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = Workspace.CurrentCamera

local function httpRequest(opts)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end
    local ok, res = pcall(req, opts)
    return ok and res or nil
end

local CFG = {
    main = {
        camlock = false, camKey = "Q", camSmooth = 0.35, camPredict = 0.12,
        camSticky = true, camWall = true, camKnock = true,
        silent = false, silentKey = "E", silentPred = 0.136, silentClosestPart = true,
        silentWall = true, silentDeath = true, silentHighlight = false, silentTracer = false,
        silentFov = 40, silentFovVisible = false,
        trigger = false, trigKey = "T", trigRange = 80, trigWall = true, trigKnock = true
    },
    esp = { enabled = false, key = "Y", name = true, health = true, tool = true, distance = true, box = false },
    misc = { walkspeed = false, walkValue = 24, cframeSpeed = false, cframeValue = 50, fly = false, flySpeed = 50, teleport = "" },
    rage = {
        enabled = false, key = "R", target = "", teamCheck = true, autoBuyLmg = true,
        range = 200, spread = 0, rapid = false, rapidRate = 0.05,
        autobuyGuns = false, autobuyAmmo = false, autobuyArmor = false,
        antistomp = false, spamstomp = true, kill = false, autokill = false, fling = false, stop = false
    },
    _rev = 0
}

local stickyCam, stickySilent = nil, nil
local lastShot, lastRev, lastBuy = 0, -1, 0
local hl = nil
local MainEvent = RS:FindFirstChild("MainEvent") or RS:FindFirstChild("MAINEVENT")
local silentPrey = nil

local BODY_PARTS = {"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}

local function keyCode(name)
    name = tostring(name or ""):gsub("%s+","")
    if #name == 1 then name = string.upper(name) end
    return Enum.KeyCode[name] or Enum.KeyCode.Unknown
end

local function root(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
end

local function isKO(char)
    if not char then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    local be = char:FindFirstChild("BodyEffects")
    if be then
        local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
        if ko and ko.Value then return true end
        local dead = be:FindFirstChild("Dead")
        if dead and dead.Value then return true end
    end
    if char:FindFirstChildOfClass("ForceField") then return true end
    return false
end

local function isGrabbed(plr)
    local c = plr and plr.Character
    return c and c:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
end

local function visible(from, to, ignoreChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, Camera }
    local res = Workspace:Raycast(from, to - from, params)
    if not res then return true end
    if ignoreChar and res.Instance and res.Instance:IsDescendantOf(ignoreChar) then return true end
    return (res.Position - to).Magnitude < 4
end

local function getClosestBodyPart(char)
    if not char then return nil end
    Camera = Workspace.CurrentCamera
    if not Camera then return nil end
    local best, bestD = nil, 1e9
    local mx, my = Mouse.X, Mouse.Y
    for _, name in ipairs(BODY_PARTS) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            local sp, on = Camera:WorldToViewportPoint(p.Position)
            if on and sp.Z > 0 then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(mx, my)).Magnitude
                if d < bestD then bestD, best = d, p end
            end
        end
    end
    if not best then
        for _, x in ipairs(char:GetChildren()) do
            if x:IsA("BasePart") and not string.find(x.Name, "Gun") then
                local sp, on = Camera:WorldToViewportPoint(x.Position)
                if on and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(mx, my)).Magnitude
                    if d < bestD then bestD, best = d, x end
                end
            end
        end
    end
    return best
end

local function getHitPart(char)
    if CFG.main.silentClosestPart then
        return getClosestBodyPart(char) or char:FindFirstChild("Head") or root(char)
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or root(char)
end

local function closestFromMouse(maxDist)
    maxDist = maxDist or 500
    local best, bestD = nil, maxDist
    Camera = Workspace.CurrentCamera
    if not Camera then return nil end
    local fov = CFG.main.silentFov or 40
    local mx, my = Mouse.X, Mouse.Y
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isKO(p.Character) then
            if CFG.rage.teamCheck and p.Team and LP.Team and p.Team == LP.Team then
            else
                local part = getHitPart(p.Character)
                if part then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(mx, my)).Magnitude
                        if d < bestD and d <= fov * 3 then
                            if not CFG.main.silentWall or visible(Camera.CFrame.Position, part.Position, p.Character) then
                                if not CFG.main.silentDeath or not isKO(p.Character) then
                                    bestD, best = d, p
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function closestInRange(range)
    local my = root(LP.Character)
    if not my then return nil end
    local best, bestD = nil, range or 200
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isKO(p.Character) then
            if CFG.rage.teamCheck and p.Team and LP.Team and p.Team == LP.Team then
            else
                local r = root(p.Character)
                if r then
                    local d = (r.Position - my.Position).Magnitude
                    if d < bestD then bestD, best = d, p end
                end
            end
        end
    end
    return best
end

local function findPlayer(name)
    if not name or name == "" then return nil end
    name = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name, 1, true)
            or (p.DisplayName and string.find(string.lower(p.DisplayName), name, 1, true)) then
            return p
        end
    end
end

local function hasLMG()
    local bag = LP:FindFirstChild("Backpack")
    local char = LP.Character
    local function scan(parent)
        if not parent then return false end
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") and (t.Name == "[LMG]" or t.Name == "LMG" or string.find(t.Name, "LMG")) then
                return true
            end
        end
        return false
    end
    return scan(bag) or scan(char)
end

local function equipLMG()
    local bag = LP:FindFirstChild("Backpack")
    local char = LP.Character
    if not bag or not char then return false end
    for _, t in ipairs(bag:GetChildren()) do
        if t:IsA("Tool") and (t.Name == "[LMG]" or t.Name == "LMG" or string.find(t.Name, "LMG")) then
            t.Parent = char
            return true
        end
    end
    return false
end

local function buyLMG()
    if hasLMG() then return true end
    local ignored = Workspace:FindFirstChild("Ignored")
    local shop = ignored and ignored:FindFirstChild("Shop")
    if not shop then return false end
    local my = root(LP.Character)
    if not my then return false end
    local saved = my.CFrame
    for _, obj in ipairs(shop:GetDescendants()) do
        local n = string.lower(obj.Name)
        if obj:IsA("BasePart") and string.find(n, "lmg") then
            my.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
            task.wait(0.35)
            local cd = obj.Parent and obj.Parent:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end) end
            task.wait(0.5)
            break
        end
    end
    if my.Parent then my.CFrame = saved end
    return hasLMG()
end

local function equipAnyGun()
    local char = LP.Character
    local bag = LP:FindFirstChild("Backpack")
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") and not string.find(string.lower(tool.Name), "knife") then return tool end
    if bag then
        for _, t in ipairs(bag:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("Handle") and not string.find(string.lower(t.Name), "knife") then
                t.Parent = char
                return t
            end
        end
    end
end

local function shootTarget(targetChar)
    if not MainEvent then MainEvent = RS:FindFirstChild("MainEvent") or RS:FindFirstChild("MAINEVENT") end
    if not MainEvent or not targetChar then return end
    local tool = equipAnyGun()
    if not tool then
        if CFG.rage.autoBuyLmg then buyLMG() equipLMG() tool = equipAnyGun() end
        if not tool then return end
    end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local targetRoot = root(targetChar)
    local my = root(LP.Character)
    if not targetRoot or not my then return end
    my.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 30, 0), targetRoot.Position)
    local part = getHitPart(targetChar) or targetChar:FindFirstChild("Head") or targetRoot
    local pred = CFG.main.silentPred or 0.136
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    local aim = part.Position + vel * pred
    local rate = CFG.rage.rapid and (CFG.rage.rapidRate or 0.05) or 0.05
    if tick() - lastShot < rate then return end
    lastShot = tick()
    for _ = 1, 5 do
        pcall(function()
            MainEvent:FireServer("ShootGun", handle, handle.Position, aim, part, Vector3.new())
        end)
        task.wait(0.02)
    end
    pcall(function() tool:Activate() end)
end

local function stompTarget(targetChar, targetPlr)
    if not targetChar then return end
    local be = targetChar:FindFirstChild("BodyEffects")
    local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
    if not ko or not ko.Value then return end
    if targetPlr and isGrabbed(targetPlr) then return end
    local my = root(LP.Character)
    if not my then return end
    local last = my.Position
    local torso = targetChar:FindFirstChild("UpperTorso") or root(targetChar)
    if torso then
        my.CFrame = CFrame.new(torso.Position)
        if MainEvent then
            for _ = 1, 8 do pcall(function() MainEvent:FireServer("Stomp") end) end
        end
        task.wait(0.15)
        if my.Parent then my.CFrame = CFrame.new(last) end
    end
end

-- Silent aim: Mouse.Hit redirect (KeanW style)
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, k)
        if CFG.main.silent and self == Mouse and tostring(k) == "Hit" then
            local prey = closestFromMouse(400)
            silentPrey = prey
            if prey and prey.Character then
                local part = getHitPart(prey.Character)
                if part then
                    local pred = CFG.main.silentPred or 0.136
                    local vel = part.AssemblyLinearVelocity or Vector3.zero
                    return part.CFrame + (vel * pred)
                end
            end
        end
        return old(self, k)
    end)
    setreadonly(mt, true)
end)

-- Input keybinds
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local code = input.KeyCode
    if code == keyCode(CFG.main.camKey) then
        CFG.main.camlock = not CFG.main.camlock
        if not CFG.main.camlock then stickyCam = nil end
    elseif code == keyCode(CFG.main.silentKey) then
        CFG.main.silent = not CFG.main.silent
        if not CFG.main.silent then stickySilent = nil if hl then pcall(function() hl:Destroy() end) hl = nil end end
    elseif code == keyCode(CFG.main.trigKey) then
        CFG.main.trigger = not CFG.main.trigger
    elseif code == keyCode(CFG.esp.key) then
        CFG.esp.enabled = not CFG.esp.enabled
    elseif code == keyCode(CFG.rage.key) then
        CFG.rage.enabled = not CFG.rage.enabled
    end
end)

RunService.RenderStepped:Connect(function()
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    if CFG.main.camlock then
        local t = stickyCam
        if not (CFG.main.camSticky and stickyCam and stickyCam.Parent and stickyCam.Character and not isKO(stickyCam.Character)) then
            t = closestFromMouse(250)
            if CFG.main.camSticky and t then stickyCam = t end
        end
        if t and t.Character then
            local part = getHitPart(t.Character)
            if part then
                local pred = (part.AssemblyLinearVelocity or Vector3.zero) * (CFG.main.camPredict or 0.12)
                local goal = CFrame.lookAt(Camera.CFrame.Position, part.Position + pred)
                Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(CFG.main.camSmooth or 0.35, 0.05, 1))
            end
        end
    end
    if CFG.main.silent and CFG.main.silentHighlight then
        local prey = silentPrey or closestFromMouse(400)
        if prey and prey.Character then
            if not hl or hl.Adornee ~= prey.Character then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 60, 60)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.55
                hl.Parent = prey.Character
                hl.Adornee = prey.Character
            end
        elseif hl then pcall(function() hl:Destroy() end) hl = nil end
    elseif hl then pcall(function() hl:Destroy() end) hl = nil end
end)

RunService.Heartbeat:Connect(function()
    -- triggerbot: closest real body part under mouse ray / nearest part
    if CFG.main.trigger then
        local prey = closestFromMouse(CFG.main.trigRange or 80)
        if prey and prey.Character and not isKO(prey.Character) then
            local part = getClosestBodyPart(prey.Character)
            local my = root(LP.Character)
            if part and my then
                local d = (part.Position - my.Position).Magnitude
                if d <= (CFG.main.trigRange or 80) then
                    if not CFG.main.trigWall or visible(my.Position, part.Position, prey.Character) then
                        if not MainEvent then MainEvent = RS:FindFirstChild("MainEvent") end
                        local tool = equipAnyGun()
                        if tool and MainEvent and tick() - lastShot > 0.08 then
                            lastShot = tick()
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                pcall(function()
                                    MainEvent:FireServer("ShootGun", handle, handle.Position, part.Position, part, Vector3.new())
                                end)
                                pcall(function() tool:Activate() end)
                            end
                        end
                    end
                end
            end
        end
    end

    -- ragebot (working v3 style)
    if CFG.rage.enabled or CFG.rage.kill or CFG.rage.autokill then
        local target = nil
        if CFG.rage.target and CFG.rage.target ~= "" then
            target = findPlayer(CFG.rage.target)
        else
            target = closestInRange(CFG.rage.range or 200)
        end
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            local be = target.Character:FindFirstChild("BodyEffects")
            local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
            if hum and hum.Health > 0 and (not ko or ko.Value == false) then
                if CFG.rage.autoBuyLmg and not hasLMG() and tick() - lastBuy > 5 then
                    lastBuy = tick()
                    pcall(buyLMG)
                    pcall(equipLMG)
                end
                shootTarget(target.Character)
            else
                if CFG.rage.spamstomp ~= false then
                    stompTarget(target.Character, target)
                    if MainEvent then pcall(function() MainEvent:FireServer("Stomp") end) end
                end
            end
        end
    end

    if CFG.rage.stop then
        CFG.rage.enabled = false CFG.rage.kill = false CFG.rage.autokill = false CFG.rage.fling = false CFG.rage.stop = false
    end
    if CFG.rage.fling then
        local t = findPlayer(CFG.rage.target) or closestInRange(80)
        local my = root(LP.Character)
        local their = t and root(t.Character)
        if my and their then
            my.CFrame = their.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
            my.AssemblyLinearVelocity = Vector3.new(0, 80, 0)
        end
    end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = root(char)
    if hum and CFG.misc.walkspeed then hum.WalkSpeed = CFG.misc.walkValue or 24 end
    if hrp and hum and CFG.misc.cframeSpeed then
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir.Unit * ((CFG.misc.cframeValue or 50) / 60) end
    end
    if hrp and CFG.misc.fly then
        local move = Vector3.zero
        local cf = Camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame + move.Unit * ((CFG.misc.flySpeed or 50) / 40)
        end
    end
    if CFG.rage.antistomp and char then
        local be = char:FindFirstChild("BodyEffects")
        local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
        if ko and ko.Value and hum and hum.Health > 0 then pcall(function() hum.Health = 0 end) end
    end
end)

-- ESP only when enabled
local espFolder = Instance.new("Folder")
espFolder.Name = "NamelessCC_ESP"
espFolder.Parent = LP:WaitForChild("PlayerGui")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, c in ipairs(espFolder:GetChildren()) do c:Destroy() end
            if not CFG.esp.enabled then return end
            local my = root(LP.Character)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = root(p.Character)
                    if head then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 120, 0, 40)
                        bb.AlwaysOnTop = true
                        bb.Adornee = head
                        bb.Parent = espFolder
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0.5
                        label.Font = Enum.Font.Gotham
                        label.TextSize = 12
                        label.Parent = bb
                        local parts = {}
                        if CFG.esp.name then table.insert(parts, p.Name) end
                        if CFG.esp.health and hum then table.insert(parts, math.floor(hum.Health) .. "hp") end
                        if CFG.esp.tool then
                            local tool = p.Character:FindFirstChildOfClass("Tool")
                            if tool then table.insert(parts, tool.Name) end
                        end
                        if CFG.esp.distance and my and r then
                            table.insert(parts, math.floor((r.Position - my.Position).Magnitude) .. "m")
                        end
                        label.Text = table.concat(parts, " | ")
                    end
                end
            end
        end)
    end
end)

local function deepMerge(dst, src)
    if type(src) ~= "table" then return end
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then deepMerge(dst[k], v)
        else dst[k] = v end
    end
end

local function pullConfig()
    if not CONTROL_URL or CONTROL_URL == "" or string.find(CONTROL_URL, "PASTE_SYNC") then return false end
    local url = CONTROL_URL
    if not string.find(url, "%?") then
        url = url .. "?_=" .. tostring(math.floor(tick()*1000))
    end
    local headers = { ["Accept"] = "application/json", ["Content-Type"] = "application/json" }
    if CONTROL_HEADER_KEY ~= "" then headers["X-Master-Key"] = CONTROL_HEADER_KEY end
    local res = httpRequest({ Url = url, Method = "GET", Headers = headers })
    if not res or (res.StatusCode or 0) < 200 or (res.StatusCode or 0) >= 300 then return false end
    local body = res.Body or res.body
    if not body then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(data) ~= "table" then return false end
    local record = data.record or data
    if type(record) ~= "table" then return false end
    if record.profiles then
        local live = {}
        for k, v in pairs(record) do if k ~= "profiles" then live[k] = v end end
        record = live
    end
    deepMerge(CFG, record)
    lastRev = tonumber(record._rev) or 0
    return true
end

task.spawn(function()
    while true do
        pcall(pullConfig)
        if CFG.misc.teleport and CFG.misc.teleport ~= "" then
            local p = findPlayer(CFG.misc.teleport)
            local my = root(LP.Character)
            local their = p and root(p.Character)
            if my and their then my.CFrame = their.CFrame + Vector3.new(0, 3, 0) end
            CFG.misc.teleport = ""
        end
        task.wait(POLL)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nameless.cc", Text = "executed", Duration = 3
    })
end)
