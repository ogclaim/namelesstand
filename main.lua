getgenv().NAMELESS_BOOT = true
local ControllerName = nil
local MySlot = 1
getgenv().SIZE_X, getgenv().SIZE_Y, getgenv().SIZE_Z = 21, 21, 21
getgenv().KnifeHitboxEnabled = true
getgenv().glue_active = false
getgenv().glue_offset_z = 3
getgenv().glue_position = "Back"
getgenv().use_unc_method = sethiddenproperty ~= nil
getgenv().connection_loop = nil
getgenv().target_players = getgenv().target_players or {}
getgenv()._StandGuiSilent = false
getgenv().KnifeRage = { Enabled = false, Interval = 0.12, CycleStart = tick() }
getgenv().FlashbackConfig = { Enabled = true, TriggerHP = 10, SavedCF = nil }

local FLY_ANIM_ID = "rbxassetid://3541044388"
local HOVER_ANIM_ID = "rbxassetid://973771746"
local FollowBack, FollowHeight, FollowSpacing, HeightPerRow = 3, 1.2, 2.5, 1
local GunOrbitDist, OrbitSpeed, OrbitHeight = 10, 30, 1
local FormationSpacing, StackHeight = 3.5, 3.2
local KillAuraRange, KillAuraDelay = 25, 0.08
local VoidY, VoidSpamDeep, VoidSpamSurface = -500, 0.3, 0.2
local BringCarryWait, BringTweenTime = 2.0, 0.1
local AntiStompDelay, StompBotSlot = 1.5, 1
local PostStompHold, SummonHold = 0.35, 0.45
local ForceHitFireRate, Prediction = 0.08, 0.135
local ForceHitFOV, DefaultFOV = 20, 70
local SLOT_DELAY = 0.064
local PREFIX = "nameless:!"

-- Fast kill / tween config (edit here)
local FastKillBehindDist = 100000   -- studs behind target
local FastKillHitDist = 7       -- triggerbot when this close
local FastKillFrontDist = 100000    -- studs in front after hit
local FastKillMoveSpeed = 1500000  -- studs/sec approach + front fly
local FastKillCamHeight = 28    -- top-down camera height
local FastKillClearObstacles = true -- hide walls/trees/fences (keep floors/roads)
local FastKillTriggerRate = 0.05

-- CFrame mode (pure CFrame, no PhysicsRep glue spoof)
local CFrameFollowEnabled = false -- follow/summon with pure CFrame
local CFrameKillEnabled = false   -- kill/autokill with pure CFrame
local FastKillStableLook = Vector3.new(0, 0, -1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
getgenv().LocalPlayer = LocalPlayer
getgenv().Players = Players
getgenv().RunService = RunService

local Character, Humanoid, Root
local function refreshChar(char)
    Character = char
    Humanoid = char and char:FindFirstChildOfClass("Humanoid")
    Root = char and (char:FindFirstChild("HumanoidRootPart") or (Humanoid and Humanoid.RootPart))
end
do
    local ch = LocalPlayer.Character
    if not ch then
        local okc, res = pcall(function()
            return LocalPlayer.CharacterAdded:Wait()
        end)
        ch = okc and res or LocalPlayer.Character
    end
    if ch then refreshChar(ch) end
end

local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
task.spawn(function()
    if not MainEvent then MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10) end
end)

local ExtraOwners = {}
local SentryEnabled, KillAuraEnabled = false, false
local VoidSpamEnabled, UseGun = false, true
local StompOnKill = true
local OrbitEnabled = true
local FastKillEnabled = false
local AutoStompEnabled = false
local AutoStompConnection = nil
local LastControllerHealth = 100
local CurrentAction = "idle"
local TargetPlayer, TargetList = nil, {}
local FormationTarget, FormationType = nil, nil
local SentryConnection, KillAuraConnection, CameraConnection = nil, nil, nil
local SlotSpamRunning = false
local PreVoidCFrame = nil
local CurrentDance, DancePersistent, LastDanceId = nil, false, nil
local FlyTrack, HoverTrack = nil, nil
local LastAuraShot, LastReload, _lastFHT = 0, 0, 0
local FrozenByPrivilege = false
local BringStage, GrabOnceDone = nil, false
local GlueTargetPlayer, GlueMode, CustomGlueCF = nil, "follow", nil
local AntiStompProcessing, koConn = false, nil
local PendingAutokill, SavedKillTargets = nil, nil
local KillPhase, StompDoneForCycle = "attack", false
local BotGui, FOVCircle = nil, nil
local GuiWindow, MenuOpen = nil, false

local GuiState = {
    Aimbot = false, AimbotMode = "Hold", AimbotKey = Enum.KeyCode.E,
    Triggerbot = false,
    CFrameSpeed = false, SpeedValue = 50, SpeedKey = Enum.KeyCode.LeftShift, SpeedKeyMode = "Hold",
    CFrameFly = false, FlySpeed = 50, FlyKey = Enum.KeyCode.F, FlyKeyMode = "Toggle",
    Viewing = false, ViewTarget = nil,
    HitboxSize = 21,
}
local GuiConns = {}

local Emotes = {
    Floss = "rbxassetid://10714340543",
    ["Yungblud Happier Jump"] = "rbxassetid://15609995579",
    ["take the L"] = "rbxassetid://118343267142519",
    darktriad = "rbxassetid://131564504226925",
}
local EmoteOrder = {
    { key = "floss", id = Emotes.Floss },
    { key = "happier", id = Emotes["Yungblud Happier Jump"] },
    { key = "takel", id = Emotes["take the L"] },
    { key = "darktriad", id = Emotes.darktriad },
}



LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.zero) end)
end)
task.spawn(function()
    while task.wait(2) do pcall(function() if MainEvent then MainEvent:FireServer("RequestAFKDisplay", true) end end) end
end)
local function SetFOV(fov)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = fov end
end
local function UpdateFOVCircle(visible)
    if not FOVCircle then return end
    local cam = workspace.CurrentCamera
    if not cam then FOVCircle.Visible = false return end
    FOVCircle.Visible = visible and true or false
    if visible then
        local vp = cam.ViewportSize
        FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        FOVCircle.Radius = math.clamp(200 - ForceHitFOV * 4, 40, 160)
    end
end

local function listHas(player, list)
    if not player or not list then return false end
    local n, d = player.Name:lower(), player.DisplayName and player.DisplayName:lower()
    for i = 1, #list do
        local e = tostring(list[i]):lower()
        if n == e or d == e then return true end
    end
    return false
end
local function GetPrivilegeList() return (getgenv().StandAccess and getgenv().StandAccess.PrivilegeList) or {} end
local function GetSuperOwners() return (getgenv().StandAccess and getgenv().StandAccess.SuperOwners) or {} end
local function IsPrivileged(p) return listHas(p, GetPrivilegeList()) end
local function IsSuperOwner(p) return listHas(p, GetSuperOwners()) end
local function GetController()
    if not ControllerName then return nil end
    local c = Players:FindFirstChild(ControllerName)
    if c then return c end
    local want = tostring(ControllerName):lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == want or (p.DisplayName and p.DisplayName:lower() == want) then return p end
    end
end
local function EnsureController(player)
    if not ControllerName and player then ControllerName = player.Name end
end
local function IsOwner(player)
    if not player then return false end
    if IsSuperOwner(player) then return true end
    if not ControllerName then return true end
    local want = tostring(ControllerName):lower()
    if player.Name:lower() == want then return true end
    if player.DisplayName and player.DisplayName:lower() == want then return true end
    for i = 1, #ExtraOwners do
        local e = ExtraOwners[i]:lower()
        if player.Name:lower() == e or (player.DisplayName and player.DisplayName:lower() == e) then return true end
    end
    return false
end
local function IsSelfControlled()
    if not ControllerName then return false end
    local want = tostring(ControllerName):lower()
    return LocalPlayer.Name:lower() == want or (LocalPlayer.DisplayName and LocalPlayer.DisplayName:lower() == want)
end
local function FindPlayerAny(name)
    if not name then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name or p.Name:lower():find(name, 1, true)
            or (p.DisplayName and (p.DisplayName:lower() == name or p.DisplayName:lower():find(name, 1, true))) then
            return p
        end
    end
end
local function FindPlayer(name)
    if not name then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(name, 1, true)
            or (p.DisplayName and p.DisplayName:lower():find(name, 1, true))) then
            return p
        end
    end
end
local function NameMatchesMe(str)
    if not str then return false end
    str = str:lower()
    local n, d = LocalPlayer.Name:lower(), LocalPlayer.DisplayName and LocalPlayer.DisplayName:lower()
    return n == str or n:find(str, 1, true) or (d and (d == str or d:find(str, 1, true)))
end
local function ParseTargetsAndBots(args, startIndex)
    startIndex = startIndex or 2
    if not args[startIndex] then return {}, true end
    local botNames, targetNames = {}, {}
    for i = startIndex, #args do
        if NameMatchesMe(args[i]) then botNames[#botNames+1] = args[i] else targetNames[#targetNames+1] = args[i] end
    end
    local should = (#botNames == 0)
    for i = 1, #botNames do if NameMatchesMe(botNames[i]) then should = true break end end
    local targets = {}
    for i = 1, #targetNames do
        local p = FindPlayer(targetNames[i])
        if p then targets[#targets+1] = p end
    end
    return targets, should
end

getgenv().get_root_part = function()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return hum.RootPart or char:FindFirstChild("HumanoidRootPart")
end
getgenv().reset_velocity = function()
    local r = getgenv().get_root_part()
    if r then r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero end
end
getgenv().get_position_offset = function()
    local d, p = getgenv().glue_offset_z or 3, getgenv().glue_position or "Back"
    if p == "Front" then return CFrame.new(0, 0, -d) end
    if p == "Left Side" then return CFrame.new(-d, 0, 0) end
    return CFrame.new(0, 0, d)
end
local function SetPhysicsRepRootPart(selfRoot, targetPart)
    if not sethiddenproperty or not selfRoot or not targetPart then return end
    pcall(function()
        sethiddenproperty(selfRoot, "PhysicsRepRootPart", targetPart)
        if InstanceHandle then pcall(function() sethiddenproperty(selfRoot, "PhysicsRepRootRef", InstanceHandle.new(targetPart)) end) end
    end)
end
local function resolveTargetRoot()
    if GlueMode == "follow" then
        local c = GetController()
        return c and c.Character and c.Character:FindFirstChild("HumanoidRootPart")
    elseif GlueMode == "formation" then
        local t = FormationTarget
        return t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    elseif GlueMode == "knife" or GlueMode == "gun" or GlueMode == "stomp" then
        local t = GlueTargetPlayer
        return t and t.Character and (t.Character:FindFirstChild("HumanoidRootPart") or t.Character:FindFirstChild("UpperTorso"))
    elseif GlueMode == "custom" then
        local t = GlueTargetPlayer
        return t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    end
end
local function GetSummonWorldCF()
    local owner = GetController()
    if not owner or not owner.Character then return end
    local oRoot = owner.Character:FindFirstChild("HumanoidRootPart")
    if not oRoot then return end
    local slot = ((MySlot or 1) - 1) % 20 + 1
    local col = ((slot - 1) % 4) - 1.5
    local row = math.floor((slot - 1) / 4)
    local cf = oRoot.CFrame
    local pos = oRoot.Position - cf.LookVector * (FollowBack + row * 0.6)
        + cf.RightVector * (col * FollowSpacing)
        + Vector3.new(0, FollowHeight + row * HeightPerRow, 0)
    return CFrame.new(pos, pos + cf.LookVector)
end
local function GetFormationCF()
    if not FormationTarget or not FormationTarget.Character then return end
    local base = FormationTarget.Character:FindFirstChild("HumanoidRootPart")
    if not base then return end
    local i, b = ((MySlot or 1) - 1) % 20, base.CFrame
    if FormationType == "rline" then return b * CFrame.new(FormationSpacing * (i + 1), FollowHeight, 0)
    elseif FormationType == "lline" then return b * CFrame.new(-FormationSpacing * (i + 1), FollowHeight, 0)
    elseif FormationType == "bline" then return b * CFrame.new(0, FollowHeight, FormationSpacing * (i + 1))
    elseif FormationType == "circle" then
        local a = i * (2 * math.pi / 20)
        return b * CFrame.new(math.cos(a) * 7, FollowHeight, math.sin(a) * 7)
    elseif FormationType == "stackon" then return b * CFrame.new(0, StackHeight * (i + 1), 0) end
    return b
end
local function GetGunOrbitCF(tRoot)
    if not OrbitEnabled then
        local look = tRoot.CFrame.LookVector
        local pos = tRoot.Position - look * GunOrbitDist + Vector3.new(0, OrbitHeight, 0)
        return CFrame.lookAt(pos, tRoot.Position)
    end
    local a = tick() * OrbitSpeed + (MySlot or 1) * (math.pi * 2 / 20)
    return CFrame.lookAt(tRoot.Position + Vector3.new(math.cos(a)*GunOrbitDist, OrbitHeight, math.sin(a)*GunOrbitDist), tRoot.Position)
end
local function GetKnifeSurfaceCF(tRoot)
    local dist, s = getgenv().glue_offset_z or 3, MySlot or 1
    local off
    if s == 1 then off = Vector3.new(0, dist, 0)
    elseif s == 2 then off = Vector3.new(0, -dist, 0)
    elseif s == 3 then off = Vector3.new(0, 0, dist)
    elseif s == 4 then off = Vector3.new(0, 0, -dist)
    elseif s == 5 then off = Vector3.new(-dist, 0, 0)
    elseif s == 6 then off = Vector3.new(dist, 0, 0)
    else local ang = ((s-7)/14)*math.pi*2 off = Vector3.new(math.cos(ang)*dist, 1, math.sin(ang)*dist) end
    return tRoot.CFrame * CFrame.new(off)
end

getgenv().unc_connection = function()
    if getgenv().connection_loop then getgenv().connection_loop:Disconnect() getgenv().connection_loop = nil end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CanCollide = false end
    getgenv().connection_loop = RunService.Heartbeat:Connect(function()
        if not getgenv().glue_active then
            if getgenv().connection_loop then getgenv().connection_loop:Disconnect() getgenv().connection_loop = nil end
            getgenv().reset_velocity()
            local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if a then a.CanCollide = true SetPhysicsRepRootPart(a, a) end
            return
        end
        local selfRoot = getgenv().get_root_part()
        local targetRoot = resolveTargetRoot()
        if not selfRoot then return end
        local dest
        if GlueMode == "follow" then dest = GetSummonWorldCF()
        elseif GlueMode == "formation" then dest = GetFormationCF()
        elseif GlueMode == "gun" and targetRoot then dest = GetGunOrbitCF(targetRoot)
        elseif GlueMode == "knife" and targetRoot then
            dest = GetKnifeSurfaceCF(targetRoot)
            local KR = getgenv().KnifeRage
            if KR and KR.Enabled then
                local H = KR.Interval or 0.12
                if math.floor(tick()/H)%2==0 then
                    dest = CFrame.new(targetRoot.Position + Vector3.new(math.random()<0.5 and 900000 or -900000, 900000, math.random()<0.5 and 900000 or -900000))
                end
            end
        elseif GlueMode == "stomp" and targetRoot then
            dest = CFrame.new(targetRoot.Position + Vector3.new(0, 3.5, 0))
        elseif GlueMode == "custom" then dest = CustomGlueCF
        elseif targetRoot then dest = targetRoot.CFrame * getgenv().get_position_offset()
        end
        -- PhysicsRep glue spoof: on unless pure CFrame mode (cframe follow/kill toggles or fast kill)
        local isKill = (CurrentAction == "kill" or CurrentAction == "autokill")
        local isFollow = (CurrentAction == "follow" or CurrentAction == "formation" or GlueMode == "follow")
        local useCFrameOnly = FastKillEnabled
            or (isKill and CFrameKillEnabled)
            or (isFollow and CFrameFollowEnabled)
        if targetRoot and not useCFrameOnly then
            -- Re-apply every frame so glue holds while moving / after any external CFrame writes
            SetPhysicsRepRootPart(selfRoot, targetRoot)
            selfRoot.CanCollide = false
        else
            SetPhysicsRepRootPart(selfRoot, selfRoot)
        end
        if dest then
            selfRoot.AssemblyLinearVelocity = Vector3.zero
            selfRoot.AssemblyAngularVelocity = Vector3.zero
            selfRoot.CFrame = dest
        end
    end)
end

local function StartGlue(mode, targetPlayer)
    GlueMode = mode or "follow"
    GlueTargetPlayer = targetPlayer
    getgenv().glue_active = true
    if getgenv().KnifeRage then
        getgenv().KnifeRage.Enabled = (mode == "knife")
        getgenv().KnifeRage.CycleStart = tick()
    end
    getgenv().unc_connection()
end
local function StopGlue()
    getgenv().glue_active = false
    if getgenv().KnifeRage then getgenv().KnifeRage.Enabled = false end
    if getgenv().connection_loop then getgenv().connection_loop:Disconnect() getgenv().connection_loop = nil end
    getgenv().reset_velocity()
    local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if a then a.CanCollide = true SetPhysicsRepRootPart(a, a) end
    GlueTargetPlayer = nil
    CustomGlueCF = nil
end

-- 3rd-person mouse aim: move cursor toward target on screen (mousemoverel)
local function AimMouseAtTarget(target)
    local cam = workspace.CurrentCamera
    if not cam or not target or not target.Character then return end
    local part = target.Character:FindFirstChild("Head")
        or target.Character:FindFirstChild("UpperTorso")
        or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
    if not onScreen and screenPos.Z < 0 then return end
    local vp = cam.ViewportSize
    local dx = screenPos.X - (vp.X * 0.5)
    local dy = screenPos.Y - (vp.Y * 0.5)
    if math.abs(dx) < 1 and math.abs(dy) < 1 then return end
    -- clamp so one frame doesn't whip the camera too hard
    dx = math.clamp(dx, -120, 120)
    dy = math.clamp(dy, -120, 120)
    pcall(function()
        if mousemoverel then
            mousemoverel(dx, dy)
        elseif VirtualInputManager then
            -- fallback: relative move via VIM is not ideal; still try center click aim via camera nudge
            local look = (part.Position - cam.CFrame.Position)
            if look.Magnitude > 0.1 then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, part.Position)
            end
        end
    end)
end

-- 3rd-person camera lock: keep Custom camera on local humanoid + cursor tracks target
local function StartCameraLock(target)
    if CameraConnection then CameraConnection:Disconnect() CameraConnection = nil end
    CameraConnection = RunService.RenderStepped:Connect(function()
        if CurrentAction ~= "kill" and CurrentAction ~= "autokill" and CurrentAction ~= "bring" then return end
        if KillPhase ~= "attack" and CurrentAction ~= "bring" then return end
        local t = target or TargetPlayer
        if not t or not t.Character then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        -- 3rd person: never Scriptable — stay on local character
        cam.CameraType = Enum.CameraType.Custom
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then cam.CameraSubject = h end
        cam.FieldOfView = 70
        AimMouseAtTarget(t)
    end)
end
local function StopCameraLock()
    if CameraConnection then CameraConnection:Disconnect() CameraConnection = nil end
    SetFOV(DefaultFOV)
    local cam = workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then workspace.CurrentCamera.CameraSubject = h end
end

-- Obstacle clear: walls/trees/fences invisible + non-collide; keep floors & roads
local _fkObstacleCleared = {}
local _fkObstacleHooked = false
local function FastKillClearWorldObstacles()
    if not FastKillClearObstacles then return end
    local floorKeys = {
        "floor", "road", "street", "sidewalk", "pavement", "ground", "baseplate",
        "terrain", "asphalt", "path", "lot", "parking",
    }
    local obstacleKeys = {
        "wall", "fence", "tree", "bush", "hedge", "barrier", "gate", "railing",
        "pillar", "column", "sign", "trash", "bin", "pole", "lamp", "billboard",
        "building", "house", "shop", "store", "roof", "door", "window", "crate",
        "box", "container", "dumpster", "car", "vehicle", "prop",
    }
    local function hasKey(list, name)
        name = string.lower(name or "")
        for _, k in ipairs(list) do
            if string.find(name, k, 1, true) then return true end
        end
        return false
    end
    local function isFloor(part)
        if not part or not part:IsA("BasePart") then return false end
        local n = string.lower(part.Name)
        if hasKey(floorKeys, n) then return true end
        local size = part.Size
        if size.Y <= 4 and size.X >= 12 and size.Z >= 12 and part.Position.Y < 8 then return true end
        if (part.Material == Enum.Material.Asphalt or part.Material == Enum.Material.Cobblestone
            or part.Material == Enum.Material.Ground or part.Material == Enum.Material.Grass
            or part.Material == Enum.Material.Sand or part.Material == Enum.Material.Mud
            or part.Material == Enum.Material.LeafyGrass) and size.Y <= 6 then
            return true
        end
        return false
    end
    local function isObstacle(part)
        if not part or not part:IsA("BasePart") then return false end
        if isFloor(part) then return false end
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        local n = string.lower(part.Name)
        if hasKey(obstacleKeys, n) then return true end
        local size = part.Size
        if size.Y >= 6 and (size.X <= 8 or size.Z <= 8) then return true end
        if size.Y >= 10 and size.Y > size.X and size.Y > size.Z then return true end
        return false
    end
    local function tryClear(inst)
        if _fkObstacleCleared[inst] then return end
        if not inst:IsA("BasePart") then return end
        if isObstacle(inst) then
            _fkObstacleCleared[inst] = true
            pcall(function()
                inst.CanCollide = false
                inst.Transparency = 1
            end)
        end
    end
    for _, inst in ipairs(workspace:GetDescendants()) do
        tryClear(inst)
    end
    if not _fkObstacleHooked then
        _fkObstacleHooked = true
        workspace.DescendantAdded:Connect(function(inst)
            task.defer(tryClear, inst)
        end)
    end
end

local function EquipSlotNumber(n)
    local keys = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three }
    local key = keys[n]
    if key then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end
    local bag = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not bag or not hum or not char then return end
    local tools = {}
    for _, t in ipairs(bag:GetChildren()) do if t:IsA("Tool") and not t.Name:lower():find("knife") then tools[#tools+1] = t end end
    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and not t.Name:lower():find("knife") then tools[#tools+1] = t end end
    local tool = tools[n]
    if tool then pcall(function() hum:UnequipTools() tool.Parent = char hum:EquipTool(tool) end) end
end
local function StopSlotSpam() SlotSpamRunning = false end
local function StartSlotSpam()
    -- disabled: only first tool is used
    SlotSpamRunning = false
end

local function stopFlyAnims()
    if FlyTrack then pcall(function() FlyTrack:Stop(0.15) end) FlyTrack = nil end
    if HoverTrack then pcall(function() HoverTrack:Stop(0.15) end) HoverTrack = nil end
end
local function loadFlyAnims()
    stopFlyAnims()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    pcall(function()
        local f = Instance.new("Animation"); f.AnimationId = FLY_ANIM_ID
        local h = Instance.new("Animation"); h.AnimationId = HOVER_ANIM_ID
        FlyTrack = animator:LoadAnimation(f)
        HoverTrack = animator:LoadAnimation(h)
        FlyTrack.Looped = true
        HoverTrack.Looped = true
        FlyTrack.Priority = Enum.AnimationPriority.Action
        HoverTrack.Priority = Enum.AnimationPriority.Action
    end)
end
local function updateFlyAnim()
    if CurrentAction ~= "follow" and CurrentAction ~= "formation" then stopFlyAnims() return end
    if not FlyTrack or not HoverTrack then loadFlyAnims() end
    if not FlyTrack or not HoverTrack then return end
    local ctrl = GetController()
    local moving = false
    if ctrl and ctrl.Character then
        local ch = ctrl.Character:FindFirstChildOfClass("Humanoid")
        if ch and ch.MoveDirection.Magnitude > 0.08 then moving = true end
        local cr = ctrl.Character:FindFirstChild("HumanoidRootPart")
        if cr and cr.AssemblyLinearVelocity.Magnitude > 2 then moving = true end
    end
    if moving then
        if HoverTrack.IsPlaying then HoverTrack:Stop(0.2) end
        if not FlyTrack.IsPlaying then FlyTrack:Play(0.2, 1, 1) end
    else
        if FlyTrack.IsPlaying then FlyTrack:Stop(0.2) end
        if not HoverTrack.IsPlaying then HoverTrack:Play(0.2, 1, 1) end
    end
end
RunService.Heartbeat:Connect(function()
    if CurrentAction == "follow" or CurrentAction == "formation" then updateFlyAnim() end
end)

local function NL_ForceKill(char)
    if not char then return end
    if replicatesignal then pcall(replicatesignal, LocalPlayer.Kill) return end
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then pcall(function() h.Health = 0 end) return end
    pcall(function() char:BreakJoints() end)
end
local function HookKO(char)
    if koConn then koConn:Disconnect() koConn = nil end
    if not char then return end
    task.spawn(function()
        local be = char:WaitForChild("BodyEffects", 4)
        if not be then return end
        local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
        if not ko then return end
        koConn = ko:GetPropertyChangedSignal("Value"):Connect(function()
            if ko.Value then NL_ForceKill(char) end
        end)
        if ko.Value then NL_ForceKill(char) end
    end)
end
HookKO(Character)
task.spawn(function()
    while task.wait(0.15) do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local be = char:FindFirstChild("BodyEffects")
            local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
            local cfg = getgenv().FlashbackConfig
            if cfg and cfg.Enabled and hum and hrp then
                if hum.Health <= cfg.TriggerHP and not cfg.SavedCF then cfg.SavedCF = hrp.CFrame
                elseif hum.Health > cfg.TriggerHP and cfg.SavedCF then hrp.CFrame = cfg.SavedCF cfg.SavedCF = nil end
            end
            if ko and ko.Value and not AntiStompProcessing and hum and hum.Health > 0 then
                AntiStompProcessing = true
                task.delay(AntiStompDelay, function()
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local b = c and c:FindFirstChild("BodyEffects")
                    local k = b and (b:FindFirstChild("K.O") or b:FindFirstChild("KO"))
                    if k and k.Value and h and h.Health > 0 then NL_ForceKill(c) end
                    AntiStompProcessing = false
                end)
            end
        end
    end
end)

local function isKnocked(char)
    local be = char and char:FindFirstChild("BodyEffects")
    if not be then return false end
    local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
    local dead = be:FindFirstChild("Dead") or be:FindFirstChild("SDeath")
    return ko and ko.Value and not (dead and dead.Value)
end
local function isFullyAlive(p)
    local char = p and p.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or isKnocked(char) then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    return char:FindFirstChild("HumanoidRootPart") ~= nil
end
local function inGame(p) return p and p.Parent == Players end

local function applyKnifeHitbox()
    if not getgenv().KnifeHitboxEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local knife = char:FindFirstChild("[Knife]")
    if not knife then return end
    local handle = knife:FindFirstChild("Handle")
    if not handle then return end
    local hb = handle:FindFirstChild("HITBOX_PART") or handle
    if hb and hb:IsA("BasePart") then
        hb.Size = Vector3.new(getgenv().SIZE_X, getgenv().SIZE_Y, getgenv().SIZE_Z)
        hb.Transparency = 1
        hb.CanCollide = false
    end
end

local function EquipBestWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local bag = LocalPlayer:FindFirstChild("Backpack")
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local isKnife = equipped.Name:lower():find("knife") ~= nil
        if UseGun and not isKnife then return equipped end
        if not UseGun and isKnife then applyKnifeHitbox() return equipped end
    end
    local guns, knife = {}, nil
    local function scan(parent)
        if not parent then return end
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") then
                if t.Name:lower():find("knife") then knife = knife or t else guns[#guns+1] = t end
            end
        end
    end
    scan(char) scan(bag)
    -- Gun kill: only use the first tool (slot 1). Knife: prefer knife.
    local pick = UseGun and (guns[1] or knife) or (knife or guns[1])
    if not pick then return nil end
    pcall(function()
        if pick.Parent == bag then hum:UnequipTools() pick.Parent = char
        elseif pick.Parent ~= char then hum:EquipTool(pick) end
    end)
    if pick.Name:lower():find("knife") then applyKnifeHitbox() end
    return char:FindFirstChildOfClass("Tool") or pick
end
local function TryReload()
    if tick() - LastReload < 0.4 then return end
    LastReload = tick()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.04)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)
    if MainEvent then pcall(function() MainEvent:FireServer("Reload") end) end
end
local function getEquippedCombatTool()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Tool")
end
local function getMuzzleOrigin()
    local tool = getEquippedCombatTool()
    local handle = tool and tool:FindFirstChild("Handle")
    if handle then return handle.Position end
    local r = getgenv().get_root_part()
    return r and r.Position
end
local function validTarget(target)
    if not target or not target.Parent or not target.Character then return false end
    if target.Character:FindFirstChildOfClass("ForceField") then return false end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local be = target.Character:FindFirstChild("BodyEffects")
    local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
    if ko and ko.Value then return false end
    local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return false end
    return true, part
end
local function forceHitTick(target)
    if not MainEvent or not target then return end
    local now = tick()
    if now - _lastFHT < ForceHitFireRate then return end
    local tool = getEquippedCombatTool()
    if not tool then return end
    local targetChar = target.Character
    if not targetChar or targetChar:FindFirstChildOfClass("ForceField") then return end
    local cam = workspace.CurrentCamera
    local ok, part = validTarget(target)
    if not ok then return end
    local origin = getMuzzleOrigin()
    if not origin and cam then origin = cam.CFrame.Position end
    if not origin then return end
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    local vel = root and root.AssemblyLinearVelocity or Vector3.zero
    local hitPos = part.Position + vel * Prediction
    if cam and UseGun and (CurrentAction == "kill" or CurrentAction == "autokill" or CurrentAction == "bring") then
        local dist = (hitPos - cam.CFrame.Position).Magnitude
        hitPos = (cam.CFrame.Position + cam.CFrame.LookVector * dist):Lerp(hitPos, 0.35)
    end
    local dir = (hitPos - origin)
    if dir.Magnitude < 0.05 then dir = cam and cam.CFrame.LookVector or Vector3.new(0,0,-1) else dir = dir.Unit end
    pcall(function()
        MainEvent:FireServer("Shoot", {
            [1] = { [1] = { Normal = hitPos, Instance = part, Position = hitPos } },
            [2] = { [1] = { thePart = part, theOffset = Vector3.new(0, 0, 0) } },
            [3] = origin,
            [4] = hitPos + dir * 50,
            [5] = workspace:GetServerTimeNow(),
        })
    end)
    _lastFHT = now
end

local function DoSingleStomp(target)
    if (MySlot or 1) ~= StompBotSlot or not StompOnKill then return end
    local tc = target and target.Character
    if not tc then return end
    local ut = tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("HumanoidRootPart")
    local hrp = getgenv().get_root_part()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not ut or not hrp or not hum then return end
    StopGlue()
    StopCameraLock()
    StopSlotSpam()
    pcall(function() hum:UnequipTools() end)
    hum.Sit = false
    hum.PlatformStand = false
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    hrp.AssemblyLinearVelocity = Vector3.zero
    local stompOff = Vector3.new(0, 0, 0)
    hrp.CFrame = CFrame.new(ut.Position + stompOff)
    RunService.Heartbeat:Wait()
    for _ = 1, 5 do if MainEvent then pcall(function() MainEvent:FireServer("Stomp") end) end end
    local t0 = tick()
    while tick() - t0 < PostStompHold do
        if ut.Parent and hrp.Parent then hrp.CFrame = CFrame.new(ut.Position + stompOff) end
        RunService.Heartbeat:Wait()
    end
end

local function StopAll()
    CurrentAction = "idle"
    TargetPlayer, TargetList = nil, {}
    FormationTarget, FormationType = nil, nil
    BringStage, GrabOnceDone = nil, false
    KillPhase, StompDoneForCycle = "attack", false
    if StopKillAttackLoop then StopKillAttackLoop() end
    StopGlue()
    StopCameraLock()
    StopSlotSpam()
    stopFlyAnims()
    if not DancePersistent and CurrentDance then pcall(function() CurrentDance:Stop() end) CurrentDance = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false hum.Sit = false end
end
local function TryGrabOnce()
    if GrabOnceDone then return end
    GrabOnceDone = true
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
        task.wait(0.04)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
    end)
    if MainEvent then pcall(function() MainEvent:FireServer("Grabbing", true) end) end
end
pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end)
local function ForceReset()
    StopAll()
    PendingAutokill, SavedKillTargets = nil, nil
    NL_ForceKill(LocalPlayer.Character)
end
local function PlayEmote(id)
    if FrozenByPrivilege or not id then return end
    DancePersistent, LastDanceId = true, id
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    pcall(function()
        if CurrentDance then CurrentDance:Stop() end
        local a = Instance.new("Animation")
        a.AnimationId = id
        CurrentDance = animator:LoadAnimation(a)
        CurrentDance.Looped = true
        CurrentDance.Priority = Enum.AnimationPriority.Action4
        CurrentDance:Play(0.1, 1, 1)
    end)
end
local function EnsureDancePlaying()
    if DancePersistent and LastDanceId and not (CurrentDance and CurrentDance.IsPlaying) then PlayEmote(LastDanceId) end
end

-- NeverLarp-style auto stomp: sit on KO'd players nearby + spam Stomp remote
local function StartContinuousAutostomp()
    if AutoStompConnection then AutoStompConnection:Disconnect() AutoStompConnection = nil end
    AutoStompConnection = RunService.Heartbeat:Connect(function()
        if not AutoStompEnabled then return end
        local selfRoot = getgenv().get_root_part()
        if not selfRoot then return end
        -- Prefer current kill target if KO'd, else nearest KO'd player
        local best, bestD = nil, 18
        local function consider(p)
            if not p or p == LocalPlayer or not p.Character then return end
            if not isKnocked(p.Character) then return end
            local ut = p.Character:FindFirstChild("UpperTorso")
                or p.Character:FindFirstChild("HumanoidRootPart")
            if not ut then return end
            local d = (ut.Position - selfRoot.Position).Magnitude
            if d < bestD then bestD, best = d, ut end
        end
        if TargetPlayer then consider(TargetPlayer) end
        if not best then
            for _, p in ipairs(Players:GetPlayers()) do
                consider(p)
            end
        end
        if best then
            selfRoot.AssemblyLinearVelocity = Vector3.zero
            selfRoot.AssemblyAngularVelocity = Vector3.zero
            selfRoot.CFrame = CFrame.new(best.Position + Vector3.new(0, 1.2, 0))
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Sit = false
                hum.PlatformStand = false
            end
        end
        if MainEvent then
            for _ = 1, 3 do
                pcall(function() MainEvent:FireServer("Stomp") end)
            end
        end
    end)
end
local function StopContinuousAutostomp()
    if AutoStompConnection then AutoStompConnection:Disconnect() AutoStompConnection = nil end
end

-- Fast kill cycle (pure CFrame — glue fully off):
-- 1) Snap BEHIND target (stable look — does not break if target stops walking)
-- 2) Approach at FastKillMoveSpeed; triggerbot at FastKillHitDist
-- 3) Fly FRONT at FastKillMoveSpeed
-- 4) Repeat until dead
-- Top-down camera lock on target. Obstacles cleared on start.
local FastKillPhase = "behind" -- behind | hit | front
local FastKillFrontCF = nil
local FastKillTweening = false
local FastKillTweenStart = 0
local FastKillTweenFrom = nil
local FastKillLastStep = 0
local FastKillLastTrigger = 0

local function ForceGlueOff()
    if getgenv().glue_active or getgenv().connection_loop then
        getgenv().glue_active = false
        if getgenv().KnifeRage then getgenv().KnifeRage.Enabled = false end
        if getgenv().connection_loop then
            getgenv().connection_loop:Disconnect()
            getgenv().connection_loop = nil
        end
        getgenv().reset_velocity()
        local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if a then
            a.CanCollide = true
            SetPhysicsRepRootPart(a, a)
        end
        GlueTargetPlayer = nil
        CustomGlueCF = nil
    end
end

-- Stable horizontal facing: move dir → LookVector → last good (won't collapse when target stops)
local function getFastKillStableLook(tRoot)
    if not tRoot then return FastKillStableLook end
    local hum = tRoot.Parent and tRoot.Parent:FindFirstChildOfClass("Humanoid")
    local md = hum and hum.MoveDirection or Vector3.zero
    local horiz
    if md.Magnitude > 0.15 then
        horiz = Vector3.new(md.X, 0, md.Z)
    else
        local lv = tRoot.CFrame.LookVector
        horiz = Vector3.new(lv.X, 0, lv.Z)
    end
    if horiz.Magnitude > 0.05 then
        FastKillStableLook = horiz.Unit
    end
    return FastKillStableLook
end

local function FastKillTriggerBot(target)
    if tick() - FastKillLastTrigger < FastKillTriggerRate then return end
    FastKillLastTrigger = tick()
    if target then AimMouseAtTarget(target) end
    local tool = EquipBestWeapon()
    if not tool then return end
    if tool.Name:lower():find("knife") then applyKnifeHitbox() end
    -- click at screen center (cursor already aimed via mousemoverel)
    local cam = workspace.CurrentCamera
    local cx = cam and (cam.ViewportSize.X * 0.5) or 0
    local cy = cam and (cam.ViewportSize.Y * 0.5) or 0
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)
    pcall(function() tool:Activate() end)
    if UseGun and TryReload then TryReload() end
end

local function FastKillStep(target)
    local tChar = target and target.Character
    if not tChar then return false end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("UpperTorso")
    local r = getgenv().get_root_part()
    if not tRoot or not r then return false end

    local hum = tChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or isKnocked(tChar) then
        FastKillPhase = "behind"
        FastKillFrontCF = nil
        FastKillTweening = false
        FastKillTweenFrom = nil
        return true
    end

    local now = tick()
    local dt = FastKillLastStep > 0 and math.clamp(now - FastKillLastStep, 0, 0.05) or 0.016
    FastKillLastStep = now

    local look = getFastKillStableLook(tRoot)
    local behindPos = tRoot.Position - look * FastKillBehindDist + Vector3.new(0, 1.2, 0)
    local frontPos = tRoot.Position + look * FastKillFrontDist + Vector3.new(0, 1.2, 0)

    -- Keep 3rd-person camera + cursor on target (started by StartKill)
    -- PhysicsRep on target so what you see matches server better
    ForceGlueOff()
    SetPhysicsRepRootPart(r, tRoot)
    r.CanCollide = false
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero

    if FastKillPhase == "behind" then
        r.CFrame = CFrame.lookAt(behindPos, tRoot.Position)
        if (r.Position - behindPos).Magnitude < 6 then
            FastKillPhase = "hit"
        end
        return false
    end

    if FastKillPhase == "hit" then
        local dist = (r.Position - tRoot.Position).Magnitude
        if dist > FastKillHitDist then
            local goal = tRoot.Position + Vector3.new(0, 1.2, 0)
            local dir = goal - r.Position
            if dir.Magnitude > 0.05 then
                local step = math.min(FastKillMoveSpeed * dt, math.max(0, dir.Magnitude - (FastKillHitDist - 0.5)))
                if step > 0 then
                    r.CFrame = CFrame.lookAt(r.Position + dir.Unit * step, tRoot.Position)
                else
                    r.CFrame = CFrame.lookAt(r.Position, tRoot.Position)
                end
            end
        else
            r.CFrame = CFrame.lookAt(r.Position, tRoot.Position)
            AimMouseAtTarget(target)
            FastKillTriggerBot(target)
            FastKillPhase = "front"
            FastKillFrontCF = CFrame.lookAt(frontPos, tRoot.Position)
            FastKillTweenFrom = r.CFrame
            FastKillTweenStart = now
            FastKillTweening = true
        end
        return false
    end

    if FastKillPhase == "front" then
        local goal = frontPos
        local dir = goal - r.Position
        local dist = dir.Magnitude
        if dist < 4 then
            FastKillTweening = false
            FastKillTweenFrom = nil
            FastKillPhase = "behind"
            r.CFrame = CFrame.lookAt(goal, tRoot.Position)
        else
            local step = math.min(FastKillMoveSpeed * dt, dist)
            r.CFrame = CFrame.lookAt(r.Position + dir.Unit * step, tRoot.Position)
        end
        return false
    end

    return false
end

-- Heartbeat driver for fast kill / normal kill attack (smooth on bot's screen)
local KillAttackConn = nil
local function StopKillAttackLoop()
    if KillAttackConn then KillAttackConn:Disconnect() KillAttackConn = nil end
end
local function StartKillAttackLoop()
    StopKillAttackLoop()
    KillAttackConn = RunService.Heartbeat:Connect(function()
        if CurrentAction ~= "kill" and CurrentAction ~= "autokill" then return end
        if KillPhase ~= "attack" then return end
        local t = TargetPlayer
        if not t or not inGame(t) then return end
        local tChar = t.Character
        if not tChar or isKnocked(tChar) then return end
        local hum = tChar:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if FastKillEnabled then
            FastKillStep(t)
        else
            GlueTargetPlayer = t
            if not getgenv().glue_active then
                StartGlue(UseGun and "gun" or "knife", t)
            end
            AimMouseAtTarget(t)
            local tool = EquipBestWeapon()
            if tool then
                if not UseGun or tool.Name:lower():find("knife") then
                    applyKnifeHitbox()
                    pcall(function() tool:Activate() end)
                else
                    if tick() - LastReload > 2.5 then TryReload() end
                    pcall(function() tool:Activate() end)
                    forceHitTick(t)
                end
            end
        end
    end)
end

local StartKill, StartFollow, OnChatted, RunSilent

RunSilent = function(cmdLine)
    getgenv()._StandGuiSilent = true
    pcall(function() OnChatted(LocalPlayer, PREFIX .. cmdLine) end)
    getgenv()._StandGuiSilent = false
end

local function DestroyBotGui()
    if BotGui then BotGui:Destroy() BotGui = nil end
    GuiWindow = nil
    MenuOpen = false
end

local function clearGuiConn(k)
    if GuiConns[k] then GuiConns[k]:Disconnect() GuiConns[k] = nil end
end

local function CreateNamelessGui()
    DestroyBotGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    BotGui = Instance.new("ScreenGui")
    BotGui.Name = "NAMELESS"
    BotGui.ResetOnSpawn = false
    BotGui.IgnoreGuiInset = true
    BotGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BotGui.Parent = pg

    local SIDE_W, PANEL_W, PANEL_H, SIDE_H = 78, 230, 340, 300

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.AnchorPoint = Vector2.new(0, 0.5)
    root.Position = UDim2.new(0, 10, 0.5, 0)
    root.Size = UDim2.new(0, SIDE_W, 0, SIDE_H)
    root.BackgroundTransparency = 1
    root.Parent = BotGui

    local shell = Instance.new("Frame")
    shell.Name = "Side"
    shell.Size = UDim2.new(0, SIDE_W, 1, 0)
    shell.Position = UDim2.new(0, 0, 0, 0)
    shell.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    shell.BackgroundTransparency = 0.35
    shell.BorderSizePixel = 0
    shell.Parent = root
    Instance.new("UICorner", shell).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -6, 0, 28)
    title.Position = UDim2.new(0, 3, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.Text = "NAMELESS"
    title.TextWrapped = true
    title.Parent = shell

    local tabRow = Instance.new("Frame")
    tabRow.Size = UDim2.new(1, -8, 1, -40)
    tabRow.Position = UDim2.new(0, 4, 0, 36)
    tabRow.BackgroundTransparency = 1
    tabRow.Parent = shell
    local tabLay = Instance.new("UIListLayout", tabRow)
    tabLay.FillDirection = Enum.FillDirection.Vertical
    tabLay.Padding = UDim.new(0, 5)

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 0, 0, PANEL_H)
    panel.Position = UDim2.new(0, SIDE_W + 6, 0.5, -PANEL_H / 2)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    panel.BackgroundTransparency = 0.35
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Visible = false
    panel.Parent = root
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = panel
    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    local pages = {}
    local tabButtons = {}
    local openTabName = nil
    local animating = false

    local function clearPage()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end

    local function addLabel(text)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -4, 0, 16)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.TextSize = 11
        t.TextColor3 = Color3.fromRGB(180, 180, 200)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextTransparency = 0.15
        t.Text = text
        t.Parent = scroll
        return t
    end

    local function addToggle(label, get, set, keyGet, keySet)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 26)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.92
        row.BorderSizePixel = 0
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local right = keyGet and 90 or 46
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -right - 8, 1, 0)
        t.Position = UDim2.new(0, 8, 0, 0)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(235, 235, 240)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = label
        t.Parent = row
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 40, 0, 18)
        b.Position = UDim2.new(1, -46, 0.5, -9)
        b.BackgroundColor3 = get() and Color3.fromRGB(90, 160, 110) or Color3.fromRGB(50, 50, 58)
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = get() and "on" or "off"
        b.Parent = row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            set(not get())
            b.Text = get() and "on" or "off"
            b.BackgroundColor3 = get() and Color3.fromRGB(90, 160, 110) or Color3.fromRGB(50, 50, 58)
        end)
        if keyGet and keySet then
            local kb = Instance.new("TextButton")
            kb.Size = UDim2.new(0, 40, 0, 18)
            kb.Position = UDim2.new(1, -90, 0.5, -9)
            kb.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            kb.BackgroundTransparency = 0.2
            kb.BorderSizePixel = 0
            kb.Font = Enum.Font.GothamBold
            kb.TextSize = 9
            kb.TextColor3 = Color3.fromRGB(230, 230, 240)
            local k = keyGet()
            kb.Text = (typeof(k) == "EnumItem" and k.Name) or tostring(k)
            kb.Parent = row
            Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 4)
            local listening = false
            kb.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                kb.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                    if key == Enum.KeyCode.Escape then
                        kb.Text = (typeof(keyGet()) == "EnumItem" and keyGet().Name) or "?"
                        listening = false
                        conn:Disconnect()
                        return
                    end
                    keySet(key)
                    kb.Text = (typeof(key) == "EnumItem" and key.Name) or tostring(key)
                    listening = false
                    conn:Disconnect()
                end)
            end)
        end
    end

    local function addSlider(label, min, max, get, set)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 40)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.92
        row.BorderSizePixel = 0
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -12, 0, 16)
        t.Position = UDim2.new(0, 8, 0, 2)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Gotham
        t.TextSize = 11
        t.TextColor3 = Color3.fromRGB(230, 230, 235)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = label .. ": " .. tostring(get())
        t.Parent = row
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -16, 0, 8)
        bar.Position = UDim2.new(0, 8, 0, 24)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        bar.BackgroundTransparency = 0.3
        bar.BorderSizePixel = 0
        bar.Parent = row
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(math.clamp((get() - min) / (max - min), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
        fill.BackgroundTransparency = 0.2
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
        local sliding = false
        local function update(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local val = math.floor(min + (max - min) * rel + 0.5)
            set(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            t.Text = label .. ": " .. tostring(val)
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                update(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position.X)
            end
        end)
    end

    local function addBox(placeholder, flag)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -4, 0, 26)
        box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        box.BackgroundTransparency = 0.9
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextColor3 = Color3.fromRGB(240, 240, 245)
        box.PlaceholderText = placeholder
        box.Text = ""
        box.ClearTextOnFocus = false
        box.Parent = scroll
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
        box:SetAttribute("flag", flag or "")
        return box
    end

    local function addBtn(text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundTransparency = 0.9
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(235, 235, 240)
        b.Text = text
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local targetBoxes = {}

    local function buildMain()
        clearPage()
        addLabel("combat")
        addToggle("aimbot", function() return GuiState.Aimbot end, function(v)
            GuiState.Aimbot = v
            clearGuiConn("aimbot")
            if v then
                GuiConns.aimbot = RunService.RenderStepped:Connect(function()
                    if not GuiState.Aimbot then return end
                    if GuiState.AimbotMode == "Hold" then
                        local k = GuiState.AimbotKey
                        if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then
                            if not UserInputService:IsKeyDown(k) then return end
                        end
                    end
                    local mouse = UserInputService:GetMouseLocation()
                    local best, bestD = nil, 140
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local head = p.Character:FindFirstChild("Head")
                            if head then
                                local sp, on = Camera:WorldToViewportPoint(head.Position)
                                if on then
                                    local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                                    if d < bestD then bestD, best = d, head end
                                end
                            end
                        end
                    end
                    if best then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, best.Position) end
                end)
            end
        end, function() return GuiState.AimbotKey end, function(k) GuiState.AimbotKey = k end)
        addToggle("aimbot hold (off = toggle)", function() return GuiState.AimbotMode == "Hold" end, function(v)
            GuiState.AimbotMode = v and "Hold" or "Toggle"
        end)
        addToggle("triggerbot", function() return GuiState.Triggerbot end, function(v)
            GuiState.Triggerbot = v
            clearGuiConn("trigger")
            if v then
                GuiConns.trigger = RunService.Heartbeat:Connect(function()
                    if not GuiState.Triggerbot then return end
                    local t = LocalPlayer:GetMouse().Target
                    if not t then return end
                    local m = t:FindFirstAncestorOfClass("Model")
                    local h = m and m:FindFirstChildOfClass("Humanoid")
                    local pl = m and Players:GetPlayerFromCharacter(m)
                    if h and pl and pl ~= LocalPlayer and h.Health > 0 then
                        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end)
            end
        end)
        addLabel("movement")
        addToggle("cframe speed", function() return GuiState.CFrameSpeed end, function(v)
            GuiState.CFrameSpeed = v
            clearGuiConn("speed")
            if v then
                GuiConns.speed = RunService.Heartbeat:Connect(function()
                    if not GuiState.CFrameSpeed then return end
                    if GuiState.SpeedKeyMode == "Hold" then
                        local k = GuiState.SpeedKey
                        if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode and not UserInputService:IsKeyDown(k) then return end
                    end
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.MoveDirection.Magnitude > 0 then
                        root.CFrame = root.CFrame + hum.MoveDirection.Unit * (GuiState.SpeedValue / 50)
                    end
                end)
            end
        end, function() return GuiState.SpeedKey end, function(k) GuiState.SpeedKey = k end)
        addSlider("speed", 10, 200, function() return GuiState.SpeedValue end, function(v) GuiState.SpeedValue = v end)
        addToggle("cframe fly", function() return GuiState.CFrameFly end, function(v)
            GuiState.CFrameFly = v
            clearGuiConn("fly")
            if v then
                GuiConns.fly = RunService.Heartbeat:Connect(function()
                    if not GuiState.CFrameFly then return end
                    if GuiState.FlyKeyMode == "Hold" then
                        local k = GuiState.FlyKey
                        if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode and not UserInputService:IsKeyDown(k) then return end
                    end
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local cam = Camera.CFrame
                    local move = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
                    root.AssemblyLinearVelocity = Vector3.zero
                    if move.Magnitude > 0 then root.CFrame = root.CFrame + move.Unit * (GuiState.FlySpeed / 40) end
                end)
            end
        end, function() return GuiState.FlyKey end, function(k) GuiState.FlyKey = k end)
        addSlider("fly speed", 10, 200, function() return GuiState.FlySpeed end, function(v) GuiState.FlySpeed = v end)
        addLabel("player")
        local vb = addBox("target name", "view")
        targetBoxes.view = vb
        addBtn("view", function()
            local p = FindPlayer(vb.Text)
            if not p then return end
            GuiState.Viewing, GuiState.ViewTarget = true, p
            clearGuiConn("view")
            GuiConns.view = RunService.RenderStepped:Connect(function()
                if GuiState.Viewing and GuiState.ViewTarget and GuiState.ViewTarget.Character then
                    local h = GuiState.ViewTarget.Character:FindFirstChildOfClass("Humanoid")
                    if h then Camera.CameraSubject = h end
                end
            end)
        end)
        addBtn("unview", function()
            GuiState.Viewing = false
            clearGuiConn("view")
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then Camera.CameraSubject = h end
        end)
        addBtn("teleport", function()
            local p = FindPlayer(vb.Text)
            local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local b = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if a and b then a.CFrame = b.CFrame + Vector3.new(0, 3, 0) end
        end)
        addBtn("bring", function()
            if vb.Text ~= "" then RunSilent("bring " .. vb.Text) end
        end)
    end

    local function buildToggles()
        clearPage()
        addLabel("glue")
        addToggle("glue", function() return getgenv().glue_active end, function(v)
            if v then
                local ctrl = GetController and GetController() or nil
                if ctrl then
                    StartGlue(UseGun and "gun" or "knife", ctrl)
                else
                    StartGlue("knife", nil)
                end
            else
                StopGlue()
            end
        end)
        addLabel("weapon mode")
        addToggle("gun mode", function() return UseGun end, function(v)
            UseGun = v
            if v then RunSilent("gun") else RunSilent("knife") end
        end)
        addToggle("knife mode", function() return not UseGun end, function(v)
            UseGun = not v
            if not v then RunSilent("gun") else RunSilent("knife") end
        end)
        addLabel("other")
        addToggle("voidspam", function() return VoidSpamEnabled end, function(v) RunSilent(v and "voidspam on" or "voidspam off") end)
        addToggle("dance", function() return DancePersistent end, function(v) RunSilent(v and "dance" or "stop") end)
        addToggle("antistomp", function() return getgenv().FlashbackConfig and getgenv().FlashbackConfig.Enabled end, function(v)
            if getgenv().FlashbackConfig then getgenv().FlashbackConfig.Enabled = v end
        end)
    end

    local function buildRagebot()
        clearPage()
        addLabel("glue")
        addToggle("glue", function() return getgenv().glue_active end, function(v)
            if v then
                local ctrl = GetController and GetController() or nil
                if ctrl then
                    StartGlue(UseGun and "gun" or "knife", ctrl)
                else
                    StartGlue("knife", nil)
                end
            else
                StopGlue()
            end
        end)
        addSlider("glue offset", 1, 15, function() return getgenv().glue_offset_z or 3 end, function(v)
            getgenv().glue_offset_z = v
        end)
        addLabel("cframe")
        addToggle("cframe follow", function() return CFrameFollowEnabled end, function(v)
            CFrameFollowEnabled = v
            -- Re-apply follow with new mode if currently following
            if CurrentAction == "follow" then
                local ctrl = GetController and GetController() or nil
                if ctrl then StartGlue("follow", ctrl) end
            end
        end)
        addToggle("cframe kill", function() return CFrameKillEnabled end, function(v)
            CFrameKillEnabled = v
        end)
        addLabel("orbit")
        addToggle("orbit", function() return OrbitEnabled end, function(v) OrbitEnabled = v end)
        addSlider("height", 0, 20, function() return OrbitHeight end, function(v) OrbitHeight = v end)
        addSlider("speed", 5, 80, function() return OrbitSpeed end, function(v) OrbitSpeed = v end)
        addSlider("distance", 3, 30, function() return GunOrbitDist end, function(v) GunOrbitDist = v end)
        addLabel("kill")
        addToggle("fast kill", function() return FastKillEnabled end, function(v)
            FastKillEnabled = v
            FastKillPhase = "behind"
            FastKillFrontCF = nil
            FastKillTweening = false
        end)
        addToggle("autostomp", function() return AutoStompEnabled end, function(v)
            AutoStompEnabled = v
            if v then StartContinuousAutostomp() else StopContinuousAutostomp() end
        end)
        addToggle("gun killing", function() return UseGun end, function(v)
            UseGun = v
            if v then RunSilent("gun") else RunSilent("knife") end
        end)
        addToggle("knife killing", function() return not UseGun end, function(v)
            UseGun = not v
            if not v then RunSilent("gun") else RunSilent("knife") end
        end)
        addSlider("knife hitbox", 2, 50, function() return getgenv().SIZE_X or 21 end, function(v)
            getgenv().SIZE_X, getgenv().SIZE_Y, getgenv().SIZE_Z = v, v, v
            getgenv().KnifeHitboxEnabled = true
            applyKnifeHitbox()
        end)
        local rb = addBox("target", "rage")
        addBtn("kill", function() if rb.Text ~= "" then RunSilent("kill " .. rb.Text) end end)
        addBtn("autokill", function() if rb.Text ~= "" then RunSilent("autokill " .. rb.Text) end end)
        addBtn("stop", function() RunSilent("stop") end)
    end

    local function buildCommands()
        clearPage()
        local cb = addBox("target / args", "cmd")
        local function a() return (cb.Text or ""):match("^%s*(.-)%s*$") or "" end
        for _, c in ipairs({
            { "summon", function() return "summon" end },
            { "stop", function() return "stop" end },
            { "gun", function() return "gun" end },
            { "knife", function() return "knife" end },
            { "kill", function() local x=a() return x~="" and ("kill "..x) or nil end },
            { "autokill", function() local x=a() return x~="" and ("autokill "..x) or nil end },
            { "bring", function() local x=a() return x~="" and ("bring "..x) or nil end },
            { "stomp on", function() return "stomp on" end },
            { "stomp off", function() return "stomp off" end },
            { "voidspam on", function() return "voidspam on" end },
            { "voidspam off", function() return "voidspam off" end },
            { "dance", function() return "dance" end },
            { "transfer me", function() return "transfer me" end },
            { "reset", function() return "r" end },
        }) do
            addBtn(c[1], function()
                local line = c[2]()
                if line then RunSilent(line) end
            end)
        end
    end

    pages.Main = buildMain
    pages.Toggles = buildToggles
    pages.Ragebot = buildRagebot
    pages.Commands = buildCommands

    local function openTab(name)
        if animating then return end
        if openTabName == name then
            animating = true
            TweenService:Create(panel, TweenInfo.new(0.18), { Size = UDim2.new(0, 0, 0, PANEL_H) }):Play()
            task.delay(0.2, function()
                clearPage()
                panel.Visible = false
                openTabName = nil
                animating = false
            end)
            for n, btn in pairs(tabButtons) do
                btn.BackgroundTransparency = 0.75
            end
            return
        end
        animating = true
        for n, btn in pairs(tabButtons) do
            btn.BackgroundTransparency = (n == name) and 0.35 or 0.75
        end
        local function showPanel()
            clearPage()
            if pages[name] then pages[name]() end
            openTabName = name
            panel.Visible = true
            panel.Size = UDim2.new(0, 0, 0, PANEL_H)
            TweenService:Create(panel, TweenInfo.new(0.2), { Size = UDim2.new(0, PANEL_W, 0, PANEL_H) }):Play()
            task.delay(0.22, function() animating = false end)
        end
        if openTabName then
            TweenService:Create(panel, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, PANEL_H) }):Play()
            task.delay(0.12, showPanel)
        else
            showPanel()
        end
    end

    for _, name in ipairs({ "Main", "Toggles", "Ragebot", "Commands" }) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundTransparency = 0.75
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 11
        b.TextColor3 = Color3.fromRGB(240, 240, 245)
        b.Text = name
        b.Parent = tabRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        tabButtons[name] = b
        b.MouseButton1Click:Connect(function() openTab(name) end)
    end

    MenuOpen = true
end

local function ToggleLoadGui()
    if BotGui and MenuOpen then
        DestroyBotGui()
    else
        CreateNamelessGui()
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    refreshChar(char)
    StopGlue()
    StopCameraLock()
    StopSlotSpam()
    stopFlyAnims()
    HookKO(char)
    if DancePersistent and LastDanceId then task.delay(0.5, function() PlayEmote(LastDanceId) end) end
    if PendingAutokill and SavedKillTargets then
        task.delay(0.55, function()
            if PendingAutokill and SavedKillTargets then StartKill(SavedKillTargets, true) end
        end)
    end
end)

StartFollow = function()
    if FrozenByPrivilege then return end
    local ctrl = GetController()
    if not ctrl then return end
    local keepA, keepT = PendingAutokill, SavedKillTargets
    StopAll()
    PendingAutokill, SavedKillTargets = keepA, keepT
    CurrentAction = "follow"
    StartGlue("follow", ctrl)
    loadFlyAnims()
    updateFlyAnim()
end

local function StartFormation(ft, name)
    if FrozenByPrivilege then return end
    local t = name and FindPlayer(name) or GetController()
    if not t then return end
    PendingAutokill, SavedKillTargets = nil, nil
    StopAll()
    CurrentAction = "formation"
    FormationType, FormationTarget = ft, t
    StartGlue("formation", t)
    loadFlyAnims()
end

StartKill = function(targets, isAuto)
    if FrozenByPrivilege then return end
    if typeof(targets) ~= "table" then targets = { targets } end
    if #targets == 0 then return end
    StopAll()
    TargetList, TargetPlayer = targets, targets[1]
    CurrentAction = isAuto and "autokill" or "kill"
    KillPhase, StompDoneForCycle = "attack", false
    FastKillPhase, FastKillFrontCF, FastKillTweening = "behind", nil, false
    FastKillTweenFrom = nil
    if isAuto then PendingAutokill, SavedKillTargets = true, targets else PendingAutokill, SavedKillTargets = nil, nil end
    if FastKillEnabled then
        ForceGlueOff() -- pure CFrame only; all glue off
        -- seed stable look from target facing
        local tr = TargetPlayer and TargetPlayer.Character and (
            TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            or TargetPlayer.Character:FindFirstChild("UpperTorso")
        )
        if tr then
            local lv = tr.CFrame.LookVector
            local h = Vector3.new(lv.X, 0, lv.Z)
            if h.Magnitude > 0.05 then FastKillStableLook = h.Unit end
        end
        FastKillLastStep = 0
        task.spawn(FastKillClearWorldObstacles)
    else
        StartGlue(UseGun and "gun" or "knife", TargetPlayer)
    end
    StartCameraLock(TargetPlayer) -- 3rd person + cursor tracks target
    StopSlotSpam() -- always first tool only; never slot-spam
    StartKillAttackLoop() -- Heartbeat: smooth movement + hits on bot's screen
    task.spawn(function()
        while CurrentAction == "kill" or CurrentAction == "autokill" do
            local t = TargetPlayer
            if not inGame(t) then
                PendingAutokill, SavedKillTargets = nil, nil
                StopKillAttackLoop()
                if not IsSelfControlled() then StartFollow() else StopAll() end
                break
            end
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not myHum or myHum.Health <= 0 then
                StopKillAttackLoop()
                break
            end
            EnsureDancePlaying()
            local tChar = t.Character
            local hum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local ko = tChar and isKnocked(tChar)
            local dead = hum and hum.Health <= 0
            if KillPhase == "attack" then
                -- combat is driven by StartKillAttackLoop (Heartbeat)
                if not tChar or ko or dead then
                    pcall(function()
                        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h then h:UnequipTools() end
                    end)
                    StopKillAttackLoop()
                    StopCameraLock()
                    StopSlotSpam()
                    ForceGlueOff()
                    KillPhase = "stomp"
                    StompDoneForCycle = false
                end
            elseif KillPhase == "stomp" then
                if not StompDoneForCycle then DoSingleStomp(t) StompDoneForCycle = true end
                if IsSelfControlled() then
                    if isAuto then KillPhase = "waitff"
                    else PendingAutokill, SavedKillTargets = nil, nil StopAll() break end
                else KillPhase = "summon" end
            elseif KillPhase == "summon" then
                StopKillAttackLoop()
                StopCameraLock()
                StopSlotSpam()
                StartFollow()
                CurrentAction = isAuto and "autokill" or "kill"
                task.wait(SummonHold)
                if not isAuto then
                    PendingAutokill, SavedKillTargets = nil, nil
                    CurrentAction = "follow"
                    break
                end
                KillPhase = "waitff"
            elseif KillPhase == "waitff" then
                if not inGame(t) then
                    PendingAutokill, SavedKillTargets = nil, nil
                    if not IsSelfControlled() then StartFollow() else StopAll() end
                    break
                end
                if isFullyAlive(t) then
                    StompDoneForCycle = false
                    KillPhase = "attack"
                    FastKillPhase, FastKillFrontCF, FastKillTweening, FastKillTweenFrom = "behind", nil, false, nil
                    FastKillLastStep = 0
                    if FastKillEnabled then
                        ForceGlueOff()
                    else
                        StartGlue(UseGun and "gun" or "knife", t)
                    end
                    StartCameraLock(t)
                    StopSlotSpam()
                    CurrentAction = "autokill"
                    StartKillAttackLoop()
                else
                    if not IsSelfControlled() then
                        if GetController() and CurrentAction == "autokill" and GlueMode ~= "follow" then
                            StartGlue("follow", GetController())
                        end
                    else
                        ForceGlueOff()
                    end
                    task.wait(0.2)
                end
            end
            task.wait(KillPhase == "attack" and 0.05 or 0.08)
        end
        StopKillAttackLoop()
        StopCameraLock()
        StopSlotSpam()
    end)
end

local function StartBring(targets)
    if FrozenByPrivilege then return end
    local target = typeof(targets) == "table" and targets[1] or targets
    if not target then return end
    PendingAutokill, SavedKillTargets = nil, nil
    StopAll()
    CurrentAction, TargetPlayer, BringStage, GrabOnceDone = "bring", target, "kill", false
    StartGlue(UseGun and "gun" or "knife", target)
    if UseGun then StartCameraLock(target) StartSlotSpam() end
    task.spawn(function()
        while CurrentAction == "bring" do
            if not inGame(TargetPlayer) then
                if not IsSelfControlled() then StartFollow() else StopAll() end
                break
            end
            local tChar = TargetPlayer.Character
            if BringStage == "kill" then
                if tChar and (isKnocked(tChar) or (tChar:FindFirstChildOfClass("Humanoid") and tChar.Humanoid.Health <= 0)) then
                    StopCameraLock()
                    StopSlotSpam()
                    StopGlue()
                    pcall(function()
                        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h then h:UnequipTools() end
                    end)
                    if (MySlot or 1) ~= 1 then CurrentAction = "idle" break end
                    BringStage = "tween"
                else
                    local tool = EquipBestWeapon()
                    if tool then
                        if not UseGun or tool.Name:lower():find("knife") then
                            applyKnifeHitbox()
                            pcall(function() tool:Activate() end)
                        else
                            if not CameraConnection then StartCameraLock(TargetPlayer) end
                            if not SlotSpamRunning then StartSlotSpam() end
                            pcall(function() tool:Activate() end)
                            forceHitTick(TargetPlayer)
                        end
                    end
                end
            elseif BringStage == "tween" then
                local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local r = getgenv().get_root_part()
                if thrp and r then
                    local tw = TweenService:Create(r, TweenInfo.new(BringTweenTime, Enum.EasingStyle.Linear), { CFrame = CFrame.new(thrp.Position + Vector3.new(0, 2.2, 0)) })
                    tw:Play()
                    tw.Completed:Wait()
                end
                if CurrentAction ~= "bring" then break end
                BringStage = "grab"
            elseif BringStage == "grab" then
                local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local r = getgenv().get_root_part()
                if thrp and r then r.CFrame = CFrame.new(thrp.Position + Vector3.new(0, 2.2, 0)) end
                TryGrabOnce()
                local holdEnd = tick() + BringCarryWait
                while tick() < holdEnd and CurrentAction == "bring" do
                    thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    r = getgenv().get_root_part()
                    if thrp and r then
                        r.CFrame = CFrame.new(thrp.Position + Vector3.new(0, 2.2, 0))
                        r.AssemblyLinearVelocity = Vector3.zero
                    end
                    RunService.Heartbeat:Wait()
                end
                if not IsSelfControlled() then StartFollow() else StopAll() end
                break
            end
            task.wait(0.04)
        end
        StopCameraLock()
        StopSlotSpam()
    end)
end

local function ParsePrefix(msg)
    local lower = msg:lower()
    if lower:sub(1, 10) == "nameless:!" then return msg:sub(11):match("^%s*(.-)%s*$") end
    if lower:sub(1, 9) == "nameless:" then
        local b = msg:sub(10)
        if b:sub(1,1) == "!" then b = b:sub(2) end
        return b:match("^%s*(.-)%s*$")
    end
    if lower:sub(1,1) == "!" then return msg:sub(2):match("^%s*(.-)%s*$") end
    return nil
end

OnChatted = function(player, message)
    message = message:gsub("%s+", " "):match("^%s*(.-)%s*$") or message
    local raw = message:lower()
    if player == LocalPlayer and (raw == "!load" or raw == "load" or raw == "nameless:!load" or raw == "nameless:load") then
        ToggleLoadGui()
        return
    end
    local body = ParsePrefix(message)
    if not body then return end
    local args = {}
    for w in body:gmatch("%S+") do args[#args+1] = w:lower() end
    local cmd = args[1]
    if not cmd then return end
    local fromGui = (player == LocalPlayer and getgenv()._StandGuiSilent == true)
    if cmd == "load" then
        if player == LocalPlayer then ToggleLoadGui() end
        return
    end
    if cmd == "slot" and args[2] then
        local n = tonumber(args[2])
        if n and n >= 1 and n <= 20 and (IsOwner(player) or player == LocalPlayer or fromGui) then MySlot = math.floor(n) end
        return
    end
    if cmd == "transfer" and args[2] then
        local can = (not ControllerName) or IsOwner(player) or IsSuperOwner(player) or player == LocalPlayer or fromGui
            or (ControllerName and player.Name:lower() == tostring(ControllerName):lower())
        if not can then return end
        if args[2] == "me" or args[2] == "self" then
            ControllerName = player.Name
            ExtraOwners = {}
            FrozenByPrivilege = false
            return
        end
        local t = FindPlayerAny(args[2])
        ControllerName = t and t.Name or args[2]
        FrozenByPrivilege = false
        return
    end
    if IsPrivileged(player) then
        if cmd == "freeze" then StopAll() FrozenByPrivilege = true local r=getgenv().get_root_part() if r then r.Anchored=true end return end
        if cmd == "kick" then pcall(function() LocalPlayer:Kick("kicked") end) return end
        if cmd == "steal" or cmd == "take" then ControllerName=player.Name ExtraOwners={} FrozenByPrivilege=false StopAll() return end
        if cmd == "reset" or cmd == "r" then ForceReset() return end
    end
    if not IsOwner(player) and not fromGui then return end
    EnsureController(player)
    if FrozenByPrivilege then return end
    local function withBots(i, fn)
        local targets, should = ParseTargetsAndBots(args, i)
        if should then fn(targets) end
    end
    if cmd == "stop" or cmd == "idle" then
        PendingAutokill, SavedKillTargets = nil, nil
        DancePersistent, LastDanceId = false, nil
        if CurrentDance then pcall(function() CurrentDance:Stop() end) CurrentDance = nil end
        StopAll()
        VoidSpamEnabled = false
    elseif cmd == "summon" or cmd == "follow" or cmd == "come" then
        PendingAutokill, SavedKillTargets = nil, nil
        StartFollow()
    elseif cmd == "stomp" then
        if args[2] == "on" then StompOnKill = true
        elseif args[2] == "off" then StompOnKill = false
        else StompOnKill = not StompOnKill end
    elseif cmd == "gun" then UseGun = true
    elseif cmd == "knife" and not args[2] then UseGun = false
    elseif cmd == "kill" or cmd == "kc" or (cmd == "knife" and args[2]) then
        withBots(2, function(t) if #t > 0 then StartKill(t, false) end end)
    elseif cmd == "autokill" or cmd == "ak" then
        withBots(2, function(t) if #t > 0 then StartKill(t, true) end end)
    elseif cmd == "bring" or cmd == "get" then
        withBots(2, function(t) if #t > 0 then StartBring(t) end end)
    elseif cmd == "void" then
        StopAll()
        CurrentAction = "void"
        StartGlue("custom", nil)
        task.spawn(function()
            while CurrentAction == "void" do CustomGlueCF = CFrame.new(0, VoidY, 0) task.wait(0.1) end
        end)
    elseif cmd == "voidspam" or cmd == "spamvoid" then
        if args[2] == "on" then
            VoidSpamEnabled = true
            task.spawn(function()
                local timer = 0
                while VoidSpamEnabled do
                    local r = getgenv().get_root_part()
                    if r then
                        if not PreVoidCFrame then PreVoidCFrame = r.CFrame end
                        timer += task.wait()
                        if timer < VoidSpamDeep then r.CFrame = PreVoidCFrame + Vector3.new(0, -800, 0)
                        else
                            r.CFrame = PreVoidCFrame
                            if timer >= VoidSpamDeep + VoidSpamSurface then timer = 0 PreVoidCFrame = r.CFrame end
                        end
                    else task.wait(0.1) end
                end
            end)
        elseif args[2] == "off" then VoidSpamEnabled = false end
    elseif cmd == "rline" then StartFormation("rline", args[2])
    elseif cmd == "lline" then StartFormation("lline", args[2])
    elseif cmd == "bline" then StartFormation("bline", args[2])
    elseif cmd == "circle" then StartFormation("circle", args[2])
    elseif cmd == "stackon" then StartFormation("stackon", args[2])
    elseif cmd == "dance" then
        if args[2] then
            for _, e in ipairs(EmoteOrder) do if e.key == args[2] then PlayEmote(e.id) break end end
        else PlayEmote(EmoteOrder[math.random(1, #EmoteOrder)].id) end
    elseif cmd == "floss" then PlayEmote(Emotes.Floss)
    elseif cmd == "happier" or cmd == "jump" then PlayEmote(Emotes["Yungblud Happier Jump"])
    elseif cmd == "takel" or cmd == "l" then PlayEmote(Emotes["take the L"])
    elseif cmd == "darktriad" or cmd == "dark" then PlayEmote(Emotes.darktriad)
    elseif cmd == "sentry" then
        if args[2] == "on" then
            SentryEnabled = true
            if SentryConnection then SentryConnection:Disconnect() end
            SentryConnection = RunService.Heartbeat:Connect(function()
                if not SentryEnabled then return end
                local c = GetController()
                if not c or not c.Character then return end
                local h = c.Character:FindFirstChildOfClass("Humanoid")
                local hr = c.Character:FindFirstChild("HumanoidRootPart")
                if not h or not hr then return end
                if h.Health < LastControllerHealth and h.Health > 0 then
                    local best, bd = nil, 40
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and not IsOwner(p) and p.Character then
                            local pr = p.Character:FindFirstChild("HumanoidRootPart")
                            if pr then
                                local d = (pr.Position - hr.Position).Magnitude
                                if d < bd then bd, best = d, p end
                            end
                        end
                    end
                    if best then StartKill({ best }, true) end
                end
                LastControllerHealth = h.Health
            end)
        elseif args[2] == "off" then
            SentryEnabled = false
            if SentryConnection then SentryConnection:Disconnect() SentryConnection = nil end
        end
    elseif cmd == "killaura" or cmd == "aura" then
        if args[2] == "on" then
            KillAuraEnabled = true
            if KillAuraConnection then KillAuraConnection:Disconnect() end
            KillAuraConnection = RunService.Heartbeat:Connect(function()
                if not KillAuraEnabled or tick() - LastAuraShot < KillAuraDelay then return end
                local c = GetController()
                if not c or not c.Character then return end
                local tool = EquipBestWeapon()
                if not tool or tool.Name:lower():find("knife") then return end
                local best, bd = nil, KillAuraRange
                local cr = c.Character:FindFirstChild("HumanoidRootPart")
                if not cr then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and not IsOwner(p) and isFullyAlive(p) then
                        local d = (p.Character.HumanoidRootPart.Position - cr.Position).Magnitude
                        if d < bd then bd, best = d, p end
                    end
                end
                if best then
                    pcall(function() tool:Activate() end)
                    forceHitTick(best)
                    LastAuraShot = tick()
                end
            end)
        elseif args[2] == "off" then
            KillAuraEnabled = false
            if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
        end
    elseif cmd == "orbit" then
        if args[2] == "on" then OrbitEnabled = true
        elseif args[2] == "off" then OrbitEnabled = false
        else OrbitEnabled = not OrbitEnabled end
    elseif cmd == "fastkill" then
        if args[2] == "on" then FastKillEnabled = true
        elseif args[2] == "off" then FastKillEnabled = false
        else FastKillEnabled = not FastKillEnabled end
    elseif cmd == "autostomp" then
        if args[2] == "on" then AutoStompEnabled = true StartContinuousAutostomp()
        elseif args[2] == "off" then AutoStompEnabled = false StopContinuousAutostomp()
        else AutoStompEnabled = not AutoStompEnabled if AutoStompEnabled then StartContinuousAutostomp() else StopContinuousAutostomp() end end
    elseif cmd == "reset" or cmd == "r" then ForceReset()
    elseif cmd == "leave" and IsSuperOwner(player) then pcall(function() LocalPlayer:Kick("left") end)
    elseif cmd == "addowner" and args[2] then ExtraOwners[#ExtraOwners+1] = args[2]
    elseif cmd == "removeowner" and args[2] then
        for i = #ExtraOwners, 1, -1 do if ExtraOwners[i]:lower() == args[2] then table.remove(ExtraOwners, i) end end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(m) OnChatted(p, m) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(m) OnChatted(p, m) end)
end)
Players.PlayerRemoving:Connect(function(p)
    if TargetPlayer == p and (CurrentAction == "kill" or CurrentAction == "autokill" or CurrentAction == "bring") then
        PendingAutokill, SavedKillTargets = nil, nil
        if not IsSelfControlled() then task.defer(StartFollow) else task.defer(StopAll) end
    end
end)

getgenv().StandAccess = getgenv().StandAccess or {
    PrivilegeList = { "HackerUser1" },
    ImmuneList = { "verceyy" },
    SuperOwners = { "verceyy" },
}
getgenv().StandRunSilent = RunSilent
getgenv().StandStartKill = StartKill
getgenv().StandStartFollow = StartFollow

task.spawn(function()
    task.wait(0.5)
    local msg = "Script loaded successfully! say !load to load the gui."
    warn("[NAMELESS] " .. msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = msg,
            Color = Color3.fromRGB(180, 220, 255),
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
        })
    end)
    pcall(function()
        local TCS = game:GetService("TextChatService")
        local channels = TCS:FindFirstChild("TextChannels")
        local channel = channels and (channels:FindFirstChild("RBXSystem") or channels:FindFirstChild("RBXGeneral"))
        if channel and channel.DisplaySystemMessage then
            channel:DisplaySystemMessage(msg)
        end
    end)
    pcall(function()
        local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if ev and ev:FindFirstChild("SayMessageRequest") then
            -- do not chat publicly; system only
        end
    end)
end)

