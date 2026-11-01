--[[
    NAMELESS.HVH - Stand Controller
]]
------------------------ EDIT THESE ------------------------
local ControllerName = "imitationed"
local OriginalControllerName = ControllerName
local BotListOrdered = {
    "JadeVenture3876",
    "cepit775B9",
    "UHCaltForShewwsh7",
    "", -- 4
    "", -- 5
    "", -- 6
    "", -- 7
    "", -- 8
    "", -- 9
    "", -- 10
    "", -- 11
    "", -- 12
    "", -- 13
    "", -- 14
    "", -- 15
    "", -- 16
    "", -- 17
    "", -- 18
    "", -- 19
    "", -- 20
}
local MaxBots = 20
local PREFIX = "NAMELESS.HVH | !"
-------------------------------------------------------------

getgenv().NAMELESS_BOOT = true

task.spawn(function()
    pcall(function()
        local MainEvent = game:GetService("ReplicatedStorage"):FindFirstChild("MainEvent")
            or game:GetService("ReplicatedStorage"):WaitForChild("MainEvent", 8)
        if not MainEvent then return end
        getgenv().NamelessPingSpoof = true
        getgenv().NamelessPingValue = 100000
        pcall(function()
            if hookfunction then
                local old
                old = hookfunction(MainEvent.FireServer, function(self, ...)
                    local args = {...}
                    if getgenv().NamelessPingSpoof and args[1] == "GetPing" and not (checkcaller and checkcaller()) then
                        return
                    end
                    return old(self, ...)
                end)
            end
        end)
        while true do
            if getgenv().NamelessPingSpoof then
                pcall(function() MainEvent:FireServer("GetPing", 100000 / 1000) end)
            end
            task.wait(1)
        end
    end)
end)


-- Chat tag for Nameless users + local chat spy
getgenv().NAMELESS_USERS = getgenv().NAMELESS_USERS or {}
getgenv().NAMELESS_USERS[game:GetService("Players").LocalPlayer.Name] = true
-- broadcast presence via attribute on character
task.spawn(function()
    local lp = game:GetService("Players").LocalPlayer
    local function tagChar(char)
        if not char then return end
        pcall(function() char:SetAttribute("NamelessUser", true) end)
    end
    if lp.Character then tagChar(lp.Character) end
    lp.CharacterAdded:Connect(tagChar)
end)

local function isNamelessPlayer(plr)
    if not plr then return false end
    if getgenv().NAMELESS_USERS[plr.Name] then return true end
    local c = plr.Character
    if c and c:GetAttribute("NamelessUser") then return true end
    return false
end

-- Chat spy: print all chats with [NAMELESS USER] tag when applicable
pcall(function()
    local Players = game:GetService("Players")
    local function onChatted(plr, msg)
        local tag = isNamelessPlayer(plr) and "[NAMELESS USER] " or ""
        local line = string.format("%s%s: %s", tag, plr.Name, tostring(msg))
        pcall(function()
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = line,
                Color = isNamelessPlayer(plr) and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.SourceSans,
                TextSize = 15,
            })
        end)
        print(line)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        plr.Chatted:Connect(function(msg) onChatted(plr, msg) end)
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.Chatted:Connect(function(msg) onChatted(plr, msg) end)
    end)
end)

getgenv()._NL = getgenv()._NL or {}
local NL = getgenv()._NL
local F = {}
F.EnsureDancePlaying = function() end
F.StartDefaultEmote = function() end
F.PlayEmote = function() end
local MySlot = 1
SyncBotsEnabled = false
ForceHitCmdTarget = nil
ForceHit2Active = false
ForceHit1Active = false
StompSelectedTarget = false
ForceHitStompTarget = nil


local VAULT_EMOTES = {
    ["tornado"] = "rbxassetid://135373056067761",
    ["skibidi"] = "rbxassetid://127154705636043",
    ["kotonai"] = "rbxassetid://83558835860072",
    ["spin"] = "rbxassetid://2516930867",
    ["armspin"] = "rbxassetid://900850443",
    ["xavier"] = "rbxassetid://90802740360125",
    ["headless1"] = "rbxassetid://102316572910864",
    ["headless2"] = "rbxassetid://113923411401265",
    ["headless_freestyle"] = "rbxassetid://93812617855212",
    ["headless_baller"] = "rbxassetid://106775793056597",
    ["headless_chill"] = "rbxassetid://70910259430368",
    ["headless_pose"] = "rbxassetid://128238620435715",
    ["headless"] = "rbxassetid://124867258365082",
    ["headless_pushup"] = "rbxassetid://72742846788078",
    ["headless_med"] = "rbxassetid://125973137149810",
    ["headless_flex"] = "rbxassetid://128614920168305",
    ["headless_sit"] = "rbxassetid://80040448997448",
    ["headless_aura"] = "rbxassetid://98893149829644",
    ["headless_zen"] = "rbxassetid://137275141227243",
    ["head_loop"] = "rbxassetid://107431480470988",
    ["head_poop"] = "rbxassetid://82634894325877",
    ["head_armroll"] = "rbxassetid://123410142940842",
    ["headless_dwerk"] = "rbxassetid://70808617005150",
    ["headless_flex2"] = "rbxassetid://70480222544121",
    ["headless_follow"] = "rbxassetid://74784275429427",
    ["headless_chase"] = "rbxassetid://92587008873915",
    ["headless_dunk"] = "rbxassetid://133849580193807",
    ["headless_korblox"] = "rbxassetid://97069996546256",
    ["worship"] = "rbxassetid://116988148875769",
    ["headless_ball"] = "rbxassetid://134801596045887",
    ["headless_juggle"] = "rbxassetid://110307029446528",
    ["glitch"] = "rbxassetid://136168809732700",
    ["spider"] = "rbxassetid://113923275362771",
    ["tornado2"] = "rbxassetid://86806707642727",
    ["headspin"] = "rbxassetid://84962043563270",
    ["kawaii"] = "rbxassetid://134158414691793",
    ["box"] = "rbxassetid://80007036319743",
    ["sliced"] = "rbxassetid://101359105365571",
    ["chillin"] = "rbxassetid://139303960137368",
    ["motorcycle"] = "rbxassetid://91127325280565",
    ["chicken"] = "rbxassetid://109440710171976",
    ["float_up"] = "rbxassetid://77202519147824",
    ["loading"] = "rbxassetid://73427334946341",
    ["plane"] = "rbxassetid://118953599654100",
    ["rotating"] = "rbxassetid://111837740238997",
    ["sleepy"] = "rbxassetid://128596207712728",
    ["aura"] = "rbxassetid://105274889965322",
    ["noggin"] = "rbxassetid://102414724686360",
    ["fan"] = "rbxassetid://130864341071646",
    ["rat"] = "rbxassetid://137848451890166",
    ["dh_dance"] = "rbxassetid://107883894275340",
    ["float_head"] = "rbxassetid://82892160853081",
    ["arm_spin"] = "rbxassetid://95419822203554",
    ["spin2"] = "rbxassetid://124865481751043",
    ["mwahaha"] = "rbxassetid://94430046835624",
    ["handstand"] = "rbxassetid://130153009143999",
    ["dance"] = "rbxassetid://118683780156744",
    ["penguini"] = "rbxassetid://86612834365351",
    ["human_tornado"] = "rbxassetid://94566164803307",
}

getgenv().SIZE_X, getgenv().SIZE_Y, getgenv().SIZE_Z = 50, 50, 50
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
-- Autoheal triggers like antistomp, but heals instead of reset (percent of MaxHealth)
local AutoHealTriggerPct = 0.30

-- Summon/formation fly emotes ONLY (not dance)
-- !flyV1 default: idle Super Hero Aura | move Superman Hero Flying
-- !flyV2: idle Headless King Floating | move Flying Airplane
local FlyVariant = 1
FlyMode = "Hover" -- Glide | Fly | Hover | Heaven | gogo (Stando)
local FLY_MODE_OFFSET = {
    Hover = { y = 2.5, back = 0, lerp = 0.35 },
    Glide = { y = 4, back = 1, lerp = 0.18 },
    Fly = { y = 12, back = 2, lerp = 0.22 },
    Heaven = { y = 45, back = 0, lerp = 0.12 },
    gogo = { y = 1.2, back = -1.5, lerp = 0.55 },
}
local FLY_EMOTES = {
    [1] = {
        idle = "rbxassetid://72443677762664",
        move = "rbxassetid://101170675501592",
    },
    [2] = {
        idle = "rbxassetid://134638696656624",
        move = "rbxassetid://114990390232933",
    },
}
local ANIM_FADE = 0.2
local ANIM_SPEED = 1
local BringMoveSpeed = 80
local BringArriveDist = 4
local NoRenderEnabled = false
local FollowBack, FollowHeight, FollowSpacing, HeightPerRow = 3, 1.2, 2.5, 1
local FormationRows = 1       -- 1 = single row; >1 = multi-row
local FormationPerRow = 50    -- bots per row when multi-row (no hard slot cap)
local GunOrbitDist, OrbitSpeed, OrbitHeight = 10, 30, 1
local FormationSpacing, StackHeight = 3.5, 3.2
local KillAuraRange, KillAuraDelay = 80, 0.06
local KillAuraRowSpacing = 3.5
-- Knife kill-aura orbit (slot 1 base dist 8, +6 per slot; height -8; speed 1000)
local KA_OrbitBaseDist = 8
local KA_OrbitDistStep = 6
local KA_OrbitHeight = -8
local KA_OrbitSpeed = 1000
local KA_SummonHold = 0.1
local VoidY, VoidSpamDeep, VoidSpamSurface = -500, 0.3, 0.2
-- spamvoid in/out customisable (seconds)
local SpamVoidInTime = 0.30   -- time spent in void
local SpamVoidOutTime = 0.15  -- time on surface after void before next shot
local WaitFFDelay = 2.35      -- fixed forcefield wait (not in commands)
-- kill position for orbit / spamvoid (and visual orbit spoof)
local KillPosition = "Top"    -- Back | Front | Left | Right | Top | Bottom
local KillDistance = 10       -- studs from target for orbit/spamvoid
-- tween path direction (independent of KillPosition)
local TweenPath = "backfront" -- backfront | leftright | topbottom | diag_tlbr | diag_trbl | diag_bltr | diag_brtl
local BringCarryWait, BringTweenTime = 2.0, 0.1
local AntiStompDelay, StompBotSlot = 1.5, 1
local PostStompHold, SummonHold = 0.35, 0.45
-- Stomp height above body (code only, not in GUI)
local StompHeight = 3.4
local ForceHitFireRate, Prediction = 0.08, 0.135
RapidFireEnabled = true
RapidFireRate = 0.0           -- no throttle between volleys when rapid
NormalFireRate = 0.08         -- normal human-ish spacing
RapidFireVolleys = 4          -- packets per burst (faster than real guns)
ForceHitFireRate = RapidFireEnabled and RapidFireRate or NormalFireRate
getgenv().FH_Index = getgenv().FH_Index or 0
BotEspEnabled = true
AntiLagEnabled = true         -- blackscreen + norender on stands
OptMode = true -- FPS/MS priority for low-end / 4GB virtual phones
OptCullRange = 50
OptConn = nil
VisualStripEnabled = false
VisualStripConn = nil
SelectedGunKey = nil
PingSpoofEnabled = false
PingSpoofValue = 30
_OrigWarn = warn

ForceHitFOV, DefaultFOV = 20, 70
ForceHitFOVEnabled = false
ForceHitFOVCircleVisible = true
ForceHitKeybindTarget = nil
ForceHitTracerEnabled = false
ForceHitKeyCode = Enum.KeyCode.Q
ForceHitKeyListening = false
-- NeverLarp forcehit only (no dual modes)
ForceHitMode = "nl"
local ForceHitMyEnabled = false
local ForceHitTestEnabled = true
getgenv().KillAura = getgenv().KillAura or {
    Enabled = false,
    Range = 80,
    Delay = 0.06,
    HitPart = "Head",
    WallCheck = true,
    KnockedCheck = true,
    ForceFieldCheck = true,
    DeathCheck = true,
    Whitelist = {},
    CurrentTarget = nil,
    ApplyForceHitVisuals = false,
}
local ShiftSpamInterval = 0.1
-- PREFIX set at top
SyncBotsEnabled = false
ForceHitCmdTarget = nil -- set by !forcehit <user>
ForceHit2Active = false
ForceHit1Active = false
StompSelectedTarget = false
ForceHitStompTarget = nil
PlayerRelation = PlayerRelation or {} -- name.lower -> friendly|neutral|enemy
CtrlOrbitMode = 1
CtrlOrbitDist = 10
CtrlOrbitSpeed = 10
CtrlOrbitInDist = 5
CtrlOrbitOutDist = 10
SpinbotEnabled = false
SpinbotSpeed = 25
KillVisualSpoof = false
FastKillPhase = "behind"
FastKillLastStep = 0
FastKillLastTrigger = 0


-- Fast kill defaults (declared before lite overrides)
local FastKillBehindDist = 100
local FastKillHitDist = 6
local FastKillHitHold = 0.05
local FastKillFrontDist = 100
local FastKillMoveSpeed = 1000
local SpamVoidTweenSpeed = 100000
local SpamVoidDepth = 500
local FastKillCamHeight = 28
local FastKillClearObstacles = true
local FastKillTriggerRate = 0.04
local GunSpamVoidIn, GunSpamVoidOut = 4.0, 2.0
local KnifeSpamVoidIn, KnifeSpamVoidOut = 2.0, 1.0

-- ========== LITE / MOBILE MODE ==========
-- Detects mobile / low-end (Delta cloud phones, tablets) and cuts CPU/GPU load.
-- ForceHit + KillAura stay enabled.
local LiteMode = false
local detectLiteDevice
detectLiteDevice = function()
    local lite = false
    pcall(function()
        local UIS = game:GetService("UserInputService")
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then lite = true end
        if UIS.TouchEnabled and UIS.GyroscopeEnabled then lite = true end
    end)
    pcall(function()
        local name = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or ""
        name = tostring(name):lower()
        if name:find("delta") then
            -- Delta on mobile / cloud often reports touch
            local UIS = game:GetService("UserInputService")
            if UIS.TouchEnabled then lite = true end
        end
    end)
    pcall(function()
        if getgenv().FORCE_LITE == true then lite = true end
        if getgenv().FORCE_LITE == false then lite = false end
    end)
    return lite
end
LiteMode = detectLiteDevice()
getgenv().NamelessLiteMode = LiteMode
if LiteMode then
    -- Throttle heavy systems (keep forcehit + killaura)
    FastKillClearObstacles = false
    FastKillTriggerRate = 0.06
    FastKillMoveSpeed = 800
    -- firerate NOT slowed on lite (rapid fire still works)

    OrbitSpeed = math.min(OrbitSpeed or 30, 12)
    ANIM_SPEED = 0.5
    NoRenderEnabled = true
    KillVisualSpoof = false
end


-- Executor quality (Hood Customs safer profiles)
local ExecutorName = ""
pcall(function()
    ExecutorName = tostring((identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or ""):lower()
end)
local BadExecutor = false
if LiteMode then BadExecutor = true end
if type(ExecutorName) == "string" then
    if ExecutorName:find("xeno") or ExecutorName:find("solara") or ExecutorName:find("electron") or ExecutorName:find("jjsploit") then
        BadExecutor = true
    end
end
pcall(function()
    if getgenv().FORCE_BAD_EXEC == true then BadExecutor = true end
    if getgenv().FORCE_BAD_EXEC == false then BadExecutor = false end
end)

-- Fast kill / knife-tween config (adjust for executor)
-- Good exec: 100 back/front @ 1000 | Bad/mobile: 50/50 @ 100
FastKillBehindDist = BadExecutor and 50 or 100
FastKillHitDist = 6
FastKillHitHold = 0.05
FastKillFrontDist = BadExecutor and 50 or 100
FastKillMoveSpeed = BadExecutor and 100 or 1000
SpamVoidTweenSpeed = BadExecutor and 5000 or 100000
SpamVoidDepth = 500
FastKillCamHeight = 28
FastKillClearObstacles = not BadExecutor
FastKillTriggerRate = 0.04
GunSpamVoidIn, GunSpamVoidOut = 4.0, 2.0
KnifeSpamVoidIn, KnifeSpamVoidOut = 2.0, 1.0
SpamVoidWeapon = "gun"
ProtectOwnerEnabled = false
ProtectOwnerConn = nil
KnifeTweenEnabled = false

-- CFrame mode (pure CFrame, no PhysicsRep glue spoof)
local CFrameFollowEnabled = false -- follow/summon with pure CFrame
local CFrameKillEnabled = false   -- kill/autokill with pure CFrame
local FastKillStableLook = Vector3.new(0, 0, -1)

-- Whitelist / bot list
local Whitelist = {} -- [name:lower()] = true
local BotList = {}   -- [name:lower()] = true
for i, name in ipairs(BotListOrdered or {}) do
    if type(name) == "string" and name ~= "" then
        BotList[name:lower()] = true
    end
end
-- Assign slot from BotListOrdered if this account is listed
do
    local me = game:GetService("Players").LocalPlayer.Name:lower()
    for i, name in ipairs(BotListOrdered or {}) do
        if type(name) == "string" and name:lower() == me then
            MySlot = i
            break
        end
    end
end
local HoldMode = nil -- "knife" | "gun" | "both" | nil while summoned
local LastShiftSpam = 0
local KA_Phase = "orbit" -- orbit | summon
local KA_OrbitAngle = 0
local KA_OrbitAccum = 0
local KA_SummonUntil = 0
local KA_LastStep = 0
local AutoSummonAfterReset = false
local AutoHealEnabled = false
local AutoHealBusy = false
local AutoChatEnabled = true
local KillChatPhrases = {
    "This is a simple stand dude",
    "Lock in",
    "Nearly there!",
    "OMG THIS IS FREE",
    "Get n4meless today!",
    "Get the win, or go home..",
}
LastKillChat = 0
local AutoHealShop = Vector3.new(-390.07, 34.70, -587.01)
local AutoHealEat = {
    Vector3.new(-198.28, 71.75, -53.94),
    Vector3.new(163.90, 71.75, 53.94),
    Vector3.new(-163.20, 71.75, -55.94), -- last coord pushed back by 2
}
local AutoHealTweenSpeed = 1000
local HideTweenSpeed = 100
local HideAtShop = false

-- Client-side Joao Chiken avatar (only visible on this client)
local CHICKEN_BUNDLE_ID = 168489901382453

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
function F.refreshChar(char)
    Character = char
    Humanoid = char and char:FindFirstChildOfClass("Humanoid")
    Root = char and (char:FindFirstChild("HumanoidRootPart") or (Humanoid and Humanoid.RootPart))
    F.Character, F.Humanoid, F.Root = Character, Humanoid, Root
end
do
    local ch = LocalPlayer.Character
    if not ch then
        local okc, res = pcall(function()
            return LocalPlayer.CharacterAdded:Wait()
        end)
        ch = okc and res or LocalPlayer.Character
    end
    if ch then F.refreshChar(ch) end
end

MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
task.spawn(function()
    if not MainEvent then MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10) end
end)

local ExtraOwners = {}
local SentryEnabled, KillAuraEnabled = false, false
local VoidSpamEnabled, UseGun = false, true
StompOnKill = true
OrbitEnabled = true
FastKillEnabled = false -- orbit is default kill method
-- Kill method: "tween" | "orbit" | "spamvoid"
KillMethod = getgenv().NamelessKillMethod or "orbit"
getgenv().NamelessKillMethod = KillMethod
SpamVoidPhase = "surface" -- surface | void
SpamVoidUntil = 0
SpamVoidSurfaceCF = nil
SpamVoidHitDone = false
ShowBotsTab = false -- only after !controller
KillMethodPaint = {} -- GUI radio paint callbacks

function F.GetKillMethod()
    return getgenv().NamelessKillMethod or KillMethod or "tween"
end

function F.SetKillMethod(m)
    if m ~= "tween" and m ~= "orbit" and m ~= "spamvoid" then
        m = "tween"
    end
    KillMethod = m
    getgenv().NamelessKillMethod = m
    FastKillEnabled = (m == "tween")
    if m == "tween" then
        FastKillPhase = "behind"
        FastKillFrontCF = nil
        FastKillTweening = false
        FastKillTweenFrom = nil
        FastKillTweenStart = 0
    elseif m == "spamvoid" then
        SpamVoidPhase = "surface"
        SpamVoidUntil = 0
        SpamVoidSurfaceCF = nil
        SpamVoidHitDone = false
    end
    for name, paint in pairs(KillMethodPaint) do
        pcall(paint)
    end
    -- hot-swap if mid-kill
    if (CurrentAction == "kill" or CurrentAction == "autokill") and KillPhase == "attack" then
        pcall(function() F.StartKillAttackLoop() end)
    end
return m
end
pcall(function() F.SetKillMethod(KillMethod or "orbit") end)
AutoStompEnabled = false
AutoStompConnection = nil
LastControllerHealth = 100
CurrentAction = "idle"
local TargetPlayer, TargetList = nil, {}
local FormationTarget, FormationType = nil, nil
local SentryConnection, KillAuraConnection, CameraConnection = nil, nil, nil
local SlotSpamRunning = false
PreVoidCFrame = nil
local CurrentDance, DancePersistent, LastDanceId = nil, false, nil
local FlyTrack, HoverTrack = nil, nil
local LastAuraShot, LastReload, _lastFHT = 0, 0, 0
FrozenByPrivilege = false
local BringStage, GrabOnceDone = nil, false
local GlueTargetPlayer, GlueMode, CustomGlueCF = nil, "follow", nil
local AntiStompProcessing, koConn = false, nil
local PendingAutokill, SavedKillTargets = nil, nil
local KillPhase, StompDoneForCycle = "attack", false
WaitFFUntil = nil
local BotGui, FOVCircle = nil, nil
local GuiWindow, MenuOpen = nil, false

GuiState = {
    Aimbot = false, AimbotMode = "Hold", AimbotKey = Enum.KeyCode.E,
    Triggerbot = false,
    CFrameSpeed = false, SpeedValue = 50, SpeedKey = Enum.KeyCode.LeftShift, SpeedKeyMode = "Hold",
    CFrameFly = false, FlySpeed = 50, FlyKey = Enum.KeyCode.F, FlyKeyMode = "Toggle",
    Viewing = false, ViewTarget = nil,
    HitboxSize = 21,
}
GuiConns = {}

local Emotes = {
    Floss = "rbxassetid://10714340543",
    ["Yungblud Happier Jump"] = "rbxassetid://15609995579",
    ["take the L"] = "rbxassetid://118343267142519",
    darktriad = "rbxassetid://131564504226925",
    -- Vampire Upside Down Idle (catalog 70751304705790)
    vampire = "rbxassetid://70751304705790",
}
local EmoteOrder = {
    { key = "floss", id = Emotes.Floss },
    { key = "happier", id = Emotes["Yungblud Happier Jump"] },
    { key = "takel", id = Emotes["take the L"] },
    { key = "darktriad", id = Emotes.darktriad },
    { key = "vampire", id = Emotes.vampire },
}
-- merge VAULT_EMOTES into EmoteOrder (working dance list)
if VAULT_EMOTES then
    for k, id in pairs(VAULT_EMOTES) do
        local exists = false
        for _, e in ipairs(EmoteOrder) do
            if e.key == k then exists = true break end
        end
        if not exists then
            EmoteOrder[#EmoteOrder + 1] = { key = k, id = id }
        end
    end
end

-- Default emote on execute: Vampire Upside Down Idle
local DefaultEmoteKey = "vampire"
local DefaultEmoteId = Emotes.vampire
for _, e in ipairs(EmoteOrder) do
    if e.key == DefaultEmoteKey then DefaultEmoteId = e.id break end
end
local ExecuteEmoteForced = true -- always re-apply default when dance is cleared



-- Keep default/execute emote looping (slower on lite)
task.spawn(function()
    while task.wait(LiteMode and 2.5 or 0.75) do
        pcall(function()
            if LiteMode then return end -- skip persistent emote spam on mobile
            if FrozenByPrivilege then return end
            if not LastDanceId then LastDanceId = DefaultEmoteId end
            DancePersistent = true
            F.EnsureDancePlaying()
        end)
    end
end)

LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.zero) end)
end)
task.spawn(function()
    while task.wait(2) do pcall(function() if MainEvent then MainEvent:FireServer("RequestAFKDisplay", true) end end) end
end)
function F.SetFOV(fov)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = fov end
end
function F.UpdateFOVCircle(visible)
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

function F.listHas(player, list)
    if not player or not list then return false end
    local n, d = player.Name:lower(), player.DisplayName and player.DisplayName:lower()
    for i = 1, #list do
        local e = tostring(list[i]):lower()
        if n == e or d == e then return true end
    end
    return false
end
function F.GetPrivilegeList() return (getgenv().StandAccess and getgenv().StandAccess.PrivilegeList) or {} end
function F.GetSuperOwners() return (getgenv().StandAccess and getgenv().StandAccess.SuperOwners) or {} end
function F.IsPrivileged(p) return F.listHas(p, F.GetPrivilegeList()) end
function F.IsSuperOwner(p) return F.listHas(p, F.GetSuperOwners()) end

function F.GetController()
    if not ControllerName then return nil end
    local c = Players:FindFirstChild(ControllerName)
    if c then return c end
    local want = tostring(ControllerName):lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == want or (p.DisplayName and p.DisplayName:lower() == want) then return p end
    end
    return nil
end
function F.EnsureController(player)
    if not ControllerName and player then ControllerName = player.Name end
end
function F.IsOwner(player)
    if not player then return false end
    if F.IsSuperOwner(player) then return true end
    if not ControllerName then return true end
    local want = tostring(ControllerName):lower()
    if player.Name:lower() == want then return true end
    if player.DisplayName and player.DisplayName:lower() == want then return true end
    for i = 1, #ExtraOwners do
        local e = tostring(ExtraOwners[i]):lower()
        if player.Name:lower() == e or (player.DisplayName and player.DisplayName:lower() == e) then return true end
    end
    return false
end
function F.IsSelfControlled()
    if not ControllerName or ControllerName == "" then return false end
    local want = tostring(ControllerName):lower()
    return LocalPlayer.Name:lower() == want or (LocalPlayer.DisplayName and LocalPlayer.DisplayName:lower() == want)
end

-- Controller client = no ControllerName set, OR this account IS the controller
function F.IsControllerClient()
    if not ControllerName or ControllerName == "" then return true end
    return F.IsSelfControlled()
end

-- Stand/bot client = controller is set and is someone else
function F.IsStandClient()
    if not ControllerName or ControllerName == "" then return false end
    if F.IsSelfControlled() then return false end
    return true
end

function F.IsListedBot(name)
    name = tostring(name or ""):lower()
    return BotList[name] == true
end

-- Summon/formations only when a *different* controller is set
function F.CanSummon()
    local c = F.GetController()
    if not c then return false end
    if c == LocalPlayer then return false end
    return true
end

function F.SayKillChat()
    if not AutoChatEnabled then return end
    if tick() - LastKillChat < 1.2 then return end
    LastKillChat = tick()
    local phrase = KillChatPhrases[math.random(1, #KillChatPhrases)]
    pcall(function()
        local TCS = TextChatService
        local channels = TCS:FindFirstChild("TextChannels")
        local ch = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("RBXSystem"))
        if ch and ch.SendAsync then
            ch:SendAsync(phrase)
            return
        end
    end)
    pcall(function()
        local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if ev and ev:FindFirstChild("SayMessageRequest") then
            ev.SayMessageRequest:FireServer(phrase, "All")
        end
    end)
end

function F.CFrameMoveTo(pos, speed)
    local r = getgenv().get_root_part()
    if not r then return false end
    speed = speed or AutoHealTweenSpeed
    local start = tick()
    while (r.Position - pos).Magnitude > 3 do
        local dt = task.wait()
        r = getgenv().get_root_part()
        if not r then return false end
        local dir = pos - r.Position
        local step = math.min(speed * dt, dir.Magnitude)
        if step < 0.05 then break end
        r.CanCollide = false
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = CFrame.new(r.Position + dir.Unit * step)
        if tick() - start > 25 then break end
    end
    if r then r.CFrame = CFrame.new(pos) end
    return true
end

function F.HasBurger()
    local char = LocalPlayer.Character
    local bag = LocalPlayer:FindFirstChild("Backpack")
    local function scan(parent)
        if not parent then return false end
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("burger") then return true, t end
        end
        return false
    end
    local ok, tool = scan(char)
    if ok then return true, tool end
    return scan(bag)
end

function F.ClickScreen()
    local cam = workspace.CurrentCamera
    local cx = cam and (cam.ViewportSize.X * 0.5) or 400
    local cy = cam and (cam.ViewportSize.Y * 0.5) or 300
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)
end

function F.TryBuyBurger()
    -- Fire common Da Hood shop remotes / click
    pcall(function()
        if MainEvent then
            MainEvent:FireServer("BuyBurger")
            MainEvent:FireServer("Purchase", "Burger")
            MainEvent:FireServer("BuyItem", "Burger")
        end
    end)
    -- Also try clicking nearby shop prompts
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and (d.Parent and d.Parent.Name:lower():find("burger") or d.ActionText:lower():find("buy") or d.ObjectText:lower():find("burger")) then
                fireproximityprompt(d)
            end
        end
    end)
end

function F.RunAutoHealCycle()
    if AutoHealBusy then return end
    AutoHealBusy = true
    local ok, err = pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health >= 30 then return end
        -- Go to shop
        F.CFrameMoveTo(AutoHealShop, AutoHealTweenSpeed)
        task.wait(0.15)
        local has = F.HasBurger()
        if not has then
            F.TryBuyBurger()
            task.wait(0.3)
            has = F.HasBurger()
        end
        if not has then
            -- First person + click until burger
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam then cam.CameraType = Enum.CameraType.Custom end
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then cam.CameraSubject = h end
            end)
            local deadline = tick() + 8
            while tick() < deadline and not F.HasBurger() do
                F.TryBuyBurger()
                F.ClickScreen()
                task.wait(0.12)
            end
        end
        has = F.HasBurger()
        if not has then return end
        -- Eat at waypoints
        for _, pos in ipairs(AutoHealEat) do
            hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 80 then break end
            if not F.HasBurger() then break end
            F.CFrameMoveTo(pos, AutoHealTweenSpeed)
            local eatUntil = tick() + 6
            while tick() < eatUntil do
                hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health > 80 then break end
                local okb, tool = F.HasBurger()
                if not okb then break end
                pcall(function()
                    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if h and tool then
                        h:UnequipTools()
                        tool.Parent = LocalPlayer.Character
                        tool:Activate()
                    end
                end)
                F.ClickScreen()
                task.wait(0.15)
            end
        end
    end)
    if not ok then warn("[NAMELESS] autoheal: " .. tostring(err)) end
    AutoHealBusy = false
end

function F.StartHide()
    if FrozenByPrivilege then return end
    HideAtShop = true
    F.StopAll()
    CurrentAction = "hide"
    task.spawn(function()
        local spots = AutoHealEat
        local spd = HideTweenSpeed or 100
        while CurrentAction == "hide" and HideAtShop do
            if #spots == 0 then break end
            -- Random selection between the 3 coordinates
            local pos = spots[math.random(1, #spots)]
            F.CFrameMoveTo(pos, spd)
            -- Brief hold so it isn't a pure spam blink
            local holdUntil = tick() + 0.15
            while tick() < holdUntil and CurrentAction == "hide" and HideAtShop do
                local r = getgenv().get_root_part()
                if r then
                    r.CanCollide = false
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.CFrame = CFrame.new(pos)
                end
                task.wait()
            end
        end
    end)
end

function F.StartPole(targetName)
    if FrozenByPrivilege then return end
    if not F.CanSummon() and not targetName then return end
    local t = targetName and F.FindPlayer(targetName) or F.GetController()
    if not t then return end
    F.StopAll()
    CurrentAction = "pole"
    FormationTarget = t
    task.spawn(function()
        while CurrentAction == "pole" do
            local tChar = FormationTarget and FormationTarget.Character
            local lt = tChar and (tChar:FindFirstChild("LowerTorso") or tChar:FindFirstChild("HumanoidRootPart"))
            local r = getgenv().get_root_part()
            if lt and r then
                local slot = MySlot or 1
                -- Stack facing down on lower torso
                local pos = lt.Position + Vector3.new(0, 0.5 * (slot - 1), 0)
                r.CanCollide = false
                r.AssemblyLinearVelocity = Vector3.zero
                F.SetPhysicsRepRootPart(r, lt)
                -- Face down
                r.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(-90), 0, 0)
                F.ForceLocalVisibility()
            end
            task.wait()
        end
    end)
end

-- Defined AFTER F.IsOwner / F.GetController so nothing is nil
function F.IsOriginalController(player)
    if not player then return false end
    local orig = tostring(OriginalControllerName or ControllerName or ""):lower()
    if orig == "" then return false end
    if player.Name:lower() == orig then return true end
    if player.DisplayName and player.DisplayName:lower() == orig then return true end
    return false
end

function F.isProtectedWhitelistName(name)
    if not name or name == "" then return false end
    local n = tostring(name):lower()
    if BotList[n] then return true end
    for _, b in ipairs(BotListOrdered or {}) do
        if type(b) == "string" and b:lower() == n then return true end
    end
    if ControllerName and tostring(ControllerName):lower() == n then return true end
    if OriginalControllerName and tostring(OriginalControllerName):lower() == n then return true end
    return false
end

function F.GetRelation(p)
    if not p then return "neutral" end
    local n = p.Name:lower()
    if PlayerRelation[n] then return PlayerRelation[n] end
    if F.isWhitelisted and F.isWhitelisted(p) then return "friendly" end
    return "neutral"
end
function F.SetRelation(p, rel)
    if not p then return end
    PlayerRelation[p.Name:lower()] = rel
end
function F.isWhitelisted(p)
    if not p then return false end
    local n = p.Name:lower()
    local d = p.DisplayName and p.DisplayName:lower() or ""
    if Whitelist[n] or (d ~= "" and Whitelist[d]) then return true end
    if BotList[n] or (d ~= "" and BotList[d]) then return true end
    if F.isProtectedWhitelistName(n) or (d ~= "" and F.isProtectedWhitelistName(d)) then return true end
    if F.IsSuperOwner(p) then return true end
    if ControllerName then
        local want = tostring(ControllerName):lower()
        if n == want or d == want then return true end
    end
    if OriginalControllerName then
        local o = tostring(OriginalControllerName):lower()
        if n == o or d == o then return true end
    end
    for i = 1, #ExtraOwners do
        local e = tostring(ExtraOwners[i]):lower()
        if n == e or d == e then return true end
    end
    return false
end

function F.addWhitelistName(name)
    if not name or name == "" then return false end
    Whitelist[tostring(name):lower()] = true
    return true
end

function F.removeWhitelistName(name)
    if not name or name == "" then return false, "empty"
    end
    local n = tostring(name):lower()
    if F.isProtectedWhitelistName(n) then
        return false, "protected"
    end
    Whitelist[n] = nil
    return true
end

function F.ListWhitelistNames()
    local out = {}
    for k, v in pairs(Whitelist) do
        if v then out[#out + 1] = k end
    end
    table.sort(out)
    return out
end

-- Auto-whitelist every bot in BotListOrdered + controller (protected)
function F.SyncBotWhitelist()

function F.SetRapidFire(on)
    RapidFireEnabled = on and true or false
    ForceHitFireRate = RapidFireEnabled and RapidFireRate or NormalFireRate
    FastKillTriggerRate = RapidFireEnabled and 0.0 or 0.05
end

function F.SetAntiLag(on)
    AntiLagEnabled = on and true or false
    if not F.IsStandClient() then
        pcall(_OrigWarn or warn, "[NAMELESS] antilag is for stand clients (blackscreen/render)")
        return
    end
    if AntiLagEnabled then
        pcall(F.CreateBlackScreen)
        pcall(function() F.SetNoRender(true) end)
    else
        pcall(F.DestroyBlackScreen)
        pcall(function() F.SetNoRender(false) end)
    end
    pcall(_OrigWarn or warn, "[NAMELESS] antilag " .. (AntiLagEnabled and "ON" or "OFF"))
end

-- ========== OPTIMIZATION (FPS/MS priority, no full map wipe) ==========
function F.BotChat(msg)
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS and TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TCS:FindFirstChild("TextChannels")
            local ch = channels and channels:FindFirstChild("RBXGeneral")
            if ch and ch.SendAsync then
                ch:SendAsync(tostring(msg))
                return
            end
        end
    end)
    pcall(function()
        local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local say = ev and ev:FindFirstChild("SayMessageRequest")
        if say then say:FireServer(tostring(msg), "All") end
    end)
end

local GUN_ALIASES = {
    uzi = {"uzi", "[uzi]", "smg"},
    rev = {"revolver", "[revolver]", "rev"},
    db = {"double-barrel", "doublebarrel", "[double-barrel]", "db", "double barrel"},
    sg = {"shotgun", "[shotgun]", "sg"},
    tacticalsg = {"tacticalshotgun", "tactical shotgun", "[tactical shotgun]", "tacticalsg", "tactical"},
    silencer = {"silencer", "[silencer]", "silencers"},
}

function F.FindGunByKey(key)
    key = tostring(key or ""):lower()
    local aliases = GUN_ALIASES[key]
    if not aliases then return nil end
    local guns = F.CollectGuns and F.CollectGuns() or {}
    for _, tool in ipairs(guns) do
        local n = tool.Name:lower()
        for _, a in ipairs(aliases) do
            if n == a or n:find(a, 1, true) then
                return tool
            end
        end
    end
    return nil
end

function F.SelectGun(key)
    key = tostring(key or ""):lower()
    if not GUN_ALIASES[key] then
        F.BotChat("Selected gun = " .. key .. " not found!")
        return false
    end
    SelectedGunKey = key
    local tool = F.FindGunByKey(key)
    if tool then
        UseGun = true
        F.EquipOnlyTool(tool)
        LockedGunTool = tool
        F.BotChat("Selected gun = " .. key .. " found!")
        return true
    end
    F.BotChat("Selected gun = " .. key .. " not found!")
    return false
end

function F.EquipSelectedGun()
    if SelectedGunKey then
        local tool = F.FindGunByKey(SelectedGunKey)
        if tool then
            pcall(function() tool.Parent = LocalPlayer.Character end)
            LockedGunTool = tool
            return tool
        end
    end
    return F.EquipGunBySlot and F.EquipGunBySlot(1) or nil
end

function F.HasWallBetween(fromPos, toPos)
    local ok, hit = pcall(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        if LocalPlayer.Character then filter[#filter + 1] = LocalPlayer.Character end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then filter[#filter + 1] = plr.Character end
        end
        params.FilterDescendantsInstances = filter
        local dir = toPos - fromPos
        local result = workspace:Raycast(fromPos, dir, params)
        return result
    end)
    if not ok then return false end
    return hit ~= nil
end

function F.ApplyFFlags()
    -- Executor FFlags / settings for lower lag (safe pcalls)
    pcall(function()
        if setfpscap then setfpscap(60) end
    end)
    local flags = {
        {"RenderShadow","false"},
        {"ShadowDensity","0"},
        {"Shadows","false"},
        {"DFIntTextureCompositorActiveJobs","1"},
        {"DFIntTexturePoolSizeKB","32"},
        {"FFlagDebugDisableParticleRendering","true"},
        {"FFlagDisablePostFx","true"},
        {"FFlagDebugDisplayFPS","false"},
        {"DFIntMaxFrameBufferSize","2"},
        {"DFIntTaskSchedulerTargetFps","30"},
        {"FFlagEnableLocalRenderingInVR","false"},
        {"FFlagRenderDebugCheckOrderingCheck","false"},
        {"DFIntDebugFRMQualityLevelOverride","1"},
        {"FIntRenderShadowIntensity","0"},
        {"FIntRenderLocalLightUpdatesMax","0"},
        {"FIntRenderLocalLightUpdatesMin","0"},
        {"DFIntTextureQualityOverride","1"},
        {"FFlagDontCreatePingHttp","true"},
    }
    for _, pair in ipairs(flags) do
        pcall(function()
            if setfflag then setfflag(pair[1], pair[2]) end
        end)
        pcall(function()
            if setflag then setflag(pair[1], pair[2]) end
        end)
    end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
    end)
end

function F.StripLightingAndEffects()
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Brightness = 2
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.ClockTime = 12
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        for _, v in ipairs(Lighting:GetDescendants()) do
            -- keep Sky (skybox) unchanged
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
                or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") then
                pcall(function() v:Destroy() end)
            end
        end
    end)
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end
    end)
end

function F.StripWorldEffects(root)
    -- Remove particles/beams/trails/sounds near play (stomp blood, gun FX, etc.)
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
                or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles")
                or d:IsA("Explosion") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("Sound") or d:IsA("SoundGroup") then
                pcall(function()
                    if d:IsA("Sound") then d.Volume = 0 d:Stop() end
                end)
            end
        end
    end)
end

local GREY = Color3.fromRGB(128, 128, 128)
function F.StripCharacterVisual(char)
    if not char then return end
    pcall(function()
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("Accessory") or d:IsA("Hat") or d:IsA("Shirt") or d:IsA("Pants")
                or d:IsA("ShirtGraphic") or d:IsA("BodyColors") or d:IsA("CharacterMesh")
                or d:IsA("Clothing") then
                pcall(function() d:Destroy() end)
            end
        end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Accessory") or d:IsA("Hat") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("Decal") or d:IsA("Texture") then
                -- keep face optional: grey/remove
                pcall(function() d.Transparency = 1 end)
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
                or d:IsA("Fire") or d:IsA("Smoke") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("SpecialMesh") then
                pcall(function() d.TextureId = "" end)
            elseif d:IsA("MeshPart") then
                pcall(function()
                    d.TextureID = ""
                    d.Color = GREY
                    d.Material = Enum.Material.SmoothPlastic
                end)
            elseif d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                pcall(function()
                    d.Color = GREY
                    d.Material = Enum.Material.SmoothPlastic
                    d.Reflectance = 0
                    d.CastShadow = false
                end)
            elseif d:IsA("Tool") then
                -- strip gun skins / meshes under tools
                for _, td in ipairs(d:GetDescendants()) do
                    if td:IsA("ParticleEmitter") or td:IsA("Trail") or td:IsA("Beam") then
                        pcall(function() td:Destroy() end)
                    elseif td:IsA("MeshPart") then
                        pcall(function() td.TextureID = "" td.Color = GREY end)
                    elseif td:IsA("BasePart") then
                        pcall(function() td.Color = GREY td.Material = Enum.Material.SmoothPlastic end)
                    elseif td:IsA("SpecialMesh") then
                        pcall(function() td.TextureId = "" end)
                    end
                end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end)
        end
    end)
end

function F.StripAllCharacters()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            F.StripCharacterVisual(plr.Character)
        end
    end
end

-- Optimization state (batched - no full workspace scan per tick)
OptBuildingGreyDone = false
OptSoundHooked = false
OptCullIndex = 1
OptCullCache = {}
OptCullCacheTime = 0
GREY_BUILD = Color3.fromRGB(140, 140, 140)

function F.ApplyFullbright()
    -- InfYield-style fullbright (controller comfort)
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        for _, v in ipairs(Lighting:GetChildren()) do
            -- never remove / replace skybox
            if v:IsA("Sky") or v.ClassName == "Sky" then
                -- keep
            elseif v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
                or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                pcall(function() v:Destroy() end)
            end
end
    end)
end

function F.MuteSoundsSmart()
    -- Controller: mute all except voice-related. Bots: mute everything.
    local isCtrl = F.IsControllerClient and F.IsControllerClient()
    pcall(function()
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") then
                local n = string.lower(s.Name)
                local keepVoice = isCtrl and (n:find("voice") or n:find("mic") or n:find("audio")
                    or n:find("channel") or n:find("vc") or s:GetAttribute("VoiceChat"))
                if keepVoice then
                    -- leave voicechat
                else
                    s.Volume = 0
                    pcall(function() s:Stop() end)
                end
            end
        end
        local SS = game:GetService("SoundService")
        for _, s in ipairs(SS:GetDescendants()) do
            if s:IsA("Sound") then
                local n = string.lower(s.Name)
                if isCtrl and (n:find("voice") or n:find("mic")) then
                    -- keep
                else
                    s.Volume = 0
                end
            end
        end
    end)
end

function F.GreyBuildingsBatch(budget)
    -- Paint world parts grey SmoothPlastic a few per frame (no freeze)
    budget = budget or 40
    if not OptCullCache or #OptCullCache == 0 then return end
    local n = 0
    while OptCullIndex <= #OptCullCache and n < budget do
        local part = OptCullCache[OptCullIndex]
        OptCullIndex = OptCullIndex + 1
        n = n + 1
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function()
                part.Color = GREY_BUILD
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
                part.CastShadow = false
            end)
        end
    end
    if OptCullIndex > #OptCullCache then
        OptBuildingGreyDone = true
    end
end

function F.RebuildCullCache()
    -- Build list of world BaseParts once (or rarely) - not every tick
    local cache = {}
    local charSet = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then charSet[plr.Character] = true end
    end
    pcall(function()
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Terrain") or child.Name == "Terrain" or child:IsA("Camera") then
                -- skip
            elseif charSet[child] then
                -- skip characters
            else
                if child:IsA("BasePart") then
                    cache[#cache + 1] = child
                else
                    local count = 0
                    for _, d in ipairs(child:GetDescendants()) do
                        if d:IsA("BasePart") then
                            cache[#cache + 1] = d
                            count = count + 1
                            if count > 400 then break end -- cap per model
                        end
                    end
                end
            end
            if #cache > 8000 then break end -- hard cap
        end
    end)
    OptCullCache = cache
    OptCullIndex = 1
    OptCullCacheTime = tick()
end

function F.CullNearbyObjectsBatched()
    -- Process limited parts per call using cache; yield-friendly
    local root = (getgenv().get_root_part and getgenv().get_root_part())
        or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not root then return end
    if not OptCullCache or #OptCullCache == 0 or (tick() - (OptCullCacheTime or 0)) > 8 then
        F.RebuildCullCache()
    end
    local origin = root.Position
    local range = OptCullRange or 50
    local range2 = range * range
    local start = OptCullIndex
    local budget = 60 -- parts per pulse (prevents hitch)
    local i = start
    local n = 0
    while n < budget and #OptCullCache > 0 do
        if i > #OptCullCache then i = 1 end
        local part = OptCullCache[i]
        i = i + 1
        n = n + 1
        if part and part.Parent and part:IsA("BasePart") then
            local d = part.Position - origin
            local d2 = d.X * d.X + d.Y * d.Y + d.Z * d.Z
            local hide = d2 > range2
            pcall(function()
                part.LocalTransparencyModifier = hide and 1 or 0
                part.CastShadow = false
            end)
        end
        if i == start then break end
    end
    OptCullIndex = i
end

function F.ApplyOptSettings()
    F.ApplyFFlags()
    if F.IsControllerClient and F.IsControllerClient() then
        F.ApplyFullbright()
    else
        F.StripLightingAndEffects()
    end
    F.MuteSoundsSmart()
    if not OptSoundHooked then
        OptSoundHooked = true
        pcall(function()
            workspace.DescendantAdded:Connect(function(d)
                if not OptMode then return end
                if d:IsA("Sound") then
                    task.defer(function()
                        if not OptMode then return end
                        local isCtrl = F.IsControllerClient and F.IsControllerClient()
                        local n = string.lower(d.Name)
                        if isCtrl and (n:find("voice") or n:find("mic") or n:find("vc")) then return end
                        pcall(function() d.Volume = 0 end)
                    end)
                end
            end)
        end)
    end
    OrbitSpeed = math.min(OrbitSpeed or 12, 10)
    RapidFireVolleys = math.min(RapidFireVolleys or 4, 2)
    KillVisualSpoof = false
    FastKillClearObstacles = false
    OptBuildingGreyDone = false
    F.RebuildCullCache()
end

function F.SetVisualStrip(on)
    VisualStripEnabled = on and true or false
    if VisualStripConn then
        pcall(function() VisualStripConn:Disconnect() end)
        VisualStripConn = nil
    end
    if not VisualStripEnabled then
return
    end
    F.StripAllCharacters()
VisualStripConn = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            if VisualStripEnabled then
                task.wait(0.5)
                F.StripCharacterVisual(char)
            end
        end)
    end)
    for _, plr in ipairs(Players:GetPlayers()) do
        plr.CharacterAdded:Connect(function(char)
            if VisualStripEnabled then
                task.wait(0.5)
                F.StripCharacterVisual(char)
            end
        end)
    end
    -- slow refresh only (was 1.25s full strip = hitch)
    task.spawn(function()
        while VisualStripEnabled do
            task.wait(4)
            if not VisualStripEnabled then break end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    F.StripCharacterVisual(plr.Character)
                    task.wait(0.05)
                end
            end
        end
    end)
end

function F.SetOptMode(on)
    OptMode = on and true or false
    if OptConn then
        pcall(function() OptConn:Disconnect() end)
        OptConn = nil
    end
    if not OptMode then
return
    end
    F.ApplyOptSettings()
-- single slow loop: cull batch + grey batch + occasional mute
    task.spawn(function()
        local tickN = 0
        while OptMode do
            tickN = tickN + 1
            F.CullNearbyObjectsBatched()
            if not OptBuildingGreyDone then
                F.GreyBuildingsBatch(35)
            end
            if tickN % 15 == 0 then
                F.MuteSoundsSmart()
            end
            if F.IsControllerClient and F.IsControllerClient() and tickN % 20 == 0 then
                F.ApplyFullbright()
            end
            task.wait(0.2) -- 5 Hz pulse, never whole-workspace per frame
        end
    end)
end

function F.SetPingSpoof(on)
    PingSpoofEnabled = on and true or false
    if getgenv().NamelessPingSpoof then
        getgenv().NamelessPingSpoof.PingSpoofEnabled = PingSpoofEnabled
        getgenv().NamelessPingSpoof.PingValue = PingSpoofValue or 30
    end
end

function F.StartProtectOwner()
    ProtectOwnerEnabled = true
    if ProtectOwnerConn then pcall(function() ProtectOwnerConn:Disconnect() end) ProtectOwnerConn = nil end
    ProtectOwnerConn = RunService.Heartbeat:Connect(function()
        if not ProtectOwnerEnabled then return end
        if F.IsControllerClient() then return end
        local c = F.GetController()
        if not c or not c.Character then return end
        local cr = c.Character:FindFirstChild("HumanoidRootPart")
        local r = getgenv().get_root_part and getgenv().get_root_part()
        if cr and r then
            r.CFrame = cr.CFrame
            pcall(function() r.AssemblyLinearVelocity = Vector3.zero end)
        end
    end)
end

function F.StopProtectOwner()
    ProtectOwnerEnabled = false
    if ProtectOwnerConn then pcall(function() ProtectOwnerConn:Disconnect() end) ProtectOwnerConn = nil end
end

task.spawn(function()
    local Config = { PingSpoofEnabled = false, PingValue = 30 }
    getgenv().NamelessPingSpoof = Config
    PingSpoofEnabled = false
    PingSpoofValue = 30
    local ME = ReplicatedStorage:FindFirstChild("MainEvent") or ReplicatedStorage:WaitForChild("MainEvent", 15)
    if not ME then return end
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        setreadonly(mt, false)
        local oldnc = mt.__namecall
        mt.__namecall = function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" and self == ME and args[1] == "GetPing" then
                if (Config.PingSpoofEnabled or PingSpoofEnabled) and not checkcaller() then
                    return
                end
            end
            return oldnc(self, ...)
        end
        setreadonly(mt, true)
    end)
    while true do
        Config.PingSpoofEnabled = PingSpoofEnabled
        Config.PingValue = PingSpoofValue or 30
        if Config.PingSpoofEnabled and ME then
            pcall(function() ME:FireServer("GetPing", (Config.PingValue or 30) / 1000) end)
        end
        task.wait(1.0)
    end
end)


    for _, name in ipairs(BotListOrdered or {}) do
        if type(name) == "string" and name ~= "" then
            Whitelist[name:lower()] = true
        end
    end
    for name, _ in pairs(BotList or {}) do
        if type(name) == "string" and name ~= "" then
            Whitelist[name:lower()] = true
        end
    end
    if ControllerName and ControllerName ~= "" then
        Whitelist[tostring(ControllerName):lower()] = true
    end
    if OriginalControllerName and OriginalControllerName ~= "" then
        Whitelist[tostring(OriginalControllerName):lower()] = true
    end
    if LocalPlayer then
        Whitelist[LocalPlayer.Name:lower()] = true
    end
end
F.SyncBotWhitelist()
function F.addBotName(name)
    if not name or name == "" then return end
    BotList[tostring(name):lower()] = true
end
function F.removeBotName(name)
    if not name or name == "" then return end
    BotList[tostring(name):lower()] = nil
end
function F.FindPlayerAny(name)
    if not name then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name or p.Name:lower():find(name, 1, true)
            or (p.DisplayName and (p.DisplayName:lower() == name or p.DisplayName:lower():find(name, 1, true))) then
            return p
        end
    end
end
function F.FindPlayer(name)
    if not name then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(name, 1, true)
            or (p.DisplayName and p.DisplayName:lower():find(name, 1, true))) then
            return p
        end
    end
end
function F.NameMatchesMe(str)
    if not str then return false end
    str = str:lower()
    local n, d = LocalPlayer.Name:lower(), LocalPlayer.DisplayName and LocalPlayer.DisplayName:lower()
    return n == str or n:find(str, 1, true) or (d and (d == str or d:find(str, 1, true)))
end
function F.ParseTargetsAndBots(args, startIndex)
    startIndex = startIndex or 2
    if not args[startIndex] then return {}, true end
    -- expand comma-separated tokens: "u1,u2" -> u1 u2
    local flat = {}
    for i = startIndex, #args do
        local token = tostring(args[i] or "")
        for part in token:gmatch("[^,]+") do
            part = part:match("^%s*(.-)%s*$")
            if part and part ~= "" then flat[#flat + 1] = part end
        end
    end
    local botNames, targetNames = {}, {}
    for i = 1, #flat do
        if F.NameMatchesMe(flat[i]) then
            botNames[#botNames + 1] = flat[i]
        else
            targetNames[#targetNames + 1] = flat[i]
        end
    end
    local should = (#botNames == 0)
    for i = 1, #botNames do
        if F.NameMatchesMe(botNames[i]) then should = true break end
    end
    local targets = {}
    for i = 1, #targetNames do
        local p = F.FindPlayer(targetNames[i]) or F.FindPlayerAny(targetNames[i])
        if p then targets[#targets + 1] = p end
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
function F.SetPhysicsRepRootPart(selfRoot, targetPart)
    if not selfRoot or not targetPart then return end
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(selfRoot, "PhysicsRepRootPart", targetPart)
        end)
        pcall(function()
            if InstanceHandle then
                sethiddenproperty(selfRoot, "PhysicsRepRootRef", InstanceHandle.new(targetPart))
            end
        end)
    end
    -- Also try network ownership helpers some executors expose
    pcall(function()
        if setsimulationradius then setsimulationradius(math.huge, math.huge) end
    end)
end

-- Keep local character fully visible (fixes "bot disappears" after CanCollide/PhysicsRep)
function F.ForceLocalVisibility(char)
    char = char or LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.LocalTransparencyModifier = 0
                if d.Name ~= "HumanoidRootPart" and d.Transparency > 0.9 and d.Name ~= "Handle" then
                    -- don't force tool handles
                end
            end)
        elseif d:IsA("Decal") or d:IsA("Texture") then
            pcall(function() d.LocalTransparencyModifier = 0 end)
        end
    end
end
function F.resolveTargetRoot()
    if GlueMode == "follow" then
        local c = F.GetController()
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
function F.GetSummonWorldCF()
    local owner = F.GetController()
    if not owner or not owner.Character then return end
    local oRoot = owner.Character:FindFirstChild("HumanoidRootPart")
    if not oRoot then return end
    local slot = math.max(1, math.floor(MySlot or 1))
    local rows = math.max(1, math.floor(FormationRows or 1))
    local perRow = math.max(1, math.floor(FormationPerRow or 50))
    local col, row
    if rows <= 1 then
        -- One single row - unlimited slots across
        col = slot - 1
        row = 0
    else
        col = (slot - 1) % perRow
        row = math.floor((slot - 1) / perRow)
    end
    -- Center the row around controller
    local center = (rows <= 1) and ((slot - 1) * 0.5) or ((perRow - 1) * 0.5)
    -- Use slot index as offset from 0 so unlimited slots stay spaced
    local x = (col - (rows <= 1 and 0 or center)) * FollowSpacing
    if rows <= 1 then
        x = (slot - 1) * FollowSpacing
    end
    local cf = oRoot.CFrame
    local fm = FLY_MODE_OFFSET and FLY_MODE_OFFSET[FlyMode or "Hover"] or { y = 2.5, back = 0, lerp = 0.35 }
    local pos = oRoot.Position
        - cf.LookVector * (FollowBack + row * 0.75 + (fm.back or 0))
        + cf.RightVector * x
        + Vector3.new(0, FollowHeight + row * HeightPerRow + (fm.y or 0), 0)
    return CFrame.new(pos, pos + cf.LookVector)
end
function F.GetControllerOrbitCF()
    local c = F.GetController()
    local cr = c and c.Character and c.Character:FindFirstChild("HumanoidRootPart")
    if not cr then return nil end
    local slot = math.max(1, math.floor(MySlot or 1))
    local n = 10
    pcall(function()
        local count = 0
        for _ in pairs(BotList or {}) do count = count + 1 end
        if count > 0 then n = math.max(count, 10) end
    end)
    local phase = ((slot - 1) / n) * math.pi * 2
    local t = tick() * (CtrlOrbitSpeed or 10)
    local mode = CtrlOrbitMode or 1
    local origin = cr.Position
    local pos
    if mode == 2 then
        local right = cr.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        local ang = t + phase
        local d = CtrlOrbitDist or 10
        pos = origin + right * (math.cos(ang) * d) + up * (math.sin(ang) * d)
    elseif mode == 3 then
        local ang = t + phase
        local pulse = (math.sin(t * 1.5) + 1) * 0.5
        local d = (CtrlOrbitInDist or 5) + pulse * ((CtrlOrbitOutDist or 10) - (CtrlOrbitInDist or 5))
        pos = origin + Vector3.new(math.cos(ang) * d, 2, math.sin(ang) * d)
    else
        local ang = t + phase
        local d = CtrlOrbitDist or 10
        pos = origin + Vector3.new(math.cos(ang) * d, 3, math.sin(ang) * d)
    end
    return CFrame.new(pos, origin)
end

function F.GetFormationCF()
    if FormationType == "corbit" then
        return F.GetControllerOrbitCF()
    end
    if not FormationTarget or not FormationTarget.Character then return end
    local base = FormationTarget.Character:FindFirstChild("HumanoidRootPart")
    if not base then return end
    local slot = math.max(1, math.floor(MySlot or 1))
    local i = slot - 1
    local b = base.CFrame
    local look = b.LookVector
    local right = b.RightVector
    local up = Vector3.new(0, 1, 0)
    local origin = base.Position
    local ft = FormationType or "bline"
    local space = FormationSpacing or 3.5

    -- !bline - single line behind controller
    if ft == "bline" then
        local pos = origin - look * (FollowBack + space * (i + 1)) + Vector3.new(0, FollowHeight, 0)
        return CFrame.new(pos, pos + look)
    end

    -- !back - square grid behind controller
    if ft == "back" then
        local side = math.max(2, math.ceil(math.sqrt(math.max(slot, 4))))
        local col = i % side
        local row = math.floor(i / side)
        local cx = (side - 1) * 0.5
        local x = (col - cx) * space
        local z = FollowBack + space * (row + 1)
        local pos = origin - look * z + right * x + Vector3.new(0, FollowHeight, 0)
        return CFrame.new(pos, pos + look)
    end

    -- !pole - stack on heads (on top of each other)
    if ft == "pole" or ft == "stackon" then
        local h = (StackHeight or 3.2) * slot
        local pos = origin + Vector3.new(0, h, 0)
        return CFrame.new(pos, pos + look)
    end

    -- !around - 4 cardinals then stack upward on those pillars
    if ft == "around" then
        local dist, baseH = 5, 5
        local dirs = {
            -look,
            look,
            -right,
            right,
        }
        local pillar = ((slot - 1) % 4) + 1
        local stack = math.floor((slot - 1) / 4)
        local d = dirs[pillar]
        local pos = origin + d * dist + Vector3.new(0, baseH + stack * (StackHeight or 3.2), 0)
        return CFrame.new(pos, pos + look)
    end

    -- !line - left/right wings, extras stack up
    if ft == "line" then
        local wing = ((slot - 1) % 2) + 1
        local stack = math.floor((slot - 1) / 2)
        local side = (wing == 1) and -1 or 1
        local along = math.floor(stack / 2) + 1
        local layer = stack
        local pos = origin + right * (side * space * along) + Vector3.new(0, FollowHeight + layer * (StackHeight or 3.2), 0)
        return CFrame.new(pos, pos + look)
    end

    -- legacy
    if ft == "rline" then
        local pos = origin + right * (space * (i + 1)) + Vector3.new(0, FollowHeight, 0)
        return CFrame.new(pos, pos + look)
    elseif ft == "lline" then
        local pos = origin - right * (space * (i + 1)) + Vector3.new(0, FollowHeight, 0)
        return CFrame.new(pos, pos + look)
    elseif ft == "circle" then
        local a = i * 0.35
        local pos = origin + Vector3.new(math.cos(a) * (7 + i * 0.15), FollowHeight, math.sin(a) * (7 + i * 0.15))
        return CFrame.new(pos, origin)
    end
    return CFrame.new(origin, origin + look)
end
function F.GetGunOrbitCF(tRoot)
    if not OrbitEnabled then
        local look = tRoot.CFrame.LookVector
        local pos = tRoot.Position - look * GunOrbitDist + Vector3.new(0, OrbitHeight, 0)
        return CFrame.lookAt(pos, tRoot.Position)
    end
    local a = tick() * OrbitSpeed + (MySlot or 1) * (math.pi * 2 / 20)
    return CFrame.lookAt(tRoot.Position + Vector3.new(math.cos(a)*GunOrbitDist, OrbitHeight, math.sin(a)*GunOrbitDist), tRoot.Position)
end
function F.GetKnifeSurfaceCF(tRoot)
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
            if a then if not NoclipEnabled then a.CanCollide = true end F.SetPhysicsRepRootPart(a, a) end
            return
        end
        local selfRoot = getgenv().get_root_part()
        local targetRoot = F.resolveTargetRoot()
        if not selfRoot then return end
        -- Fast kill drives CFrame itself - still keep PhysicsRep on target for replication
        -- Kill / autokill always driven by FastKillStep - do not glue-orbit
        if CurrentAction == "kill" or CurrentAction == "autokill" then
            if targetRoot then
                F.SetPhysicsRepRootPart(selfRoot, targetRoot)
                selfRoot.CanCollide = false
            end
            F.ForceLocalVisibility()
            return
        end
        local dest
        if GlueMode == "follow" then dest = F.GetSummonWorldCF()
        elseif GlueMode == "formation" then dest = F.GetFormationCF()
        elseif GlueMode == "gun" and targetRoot then dest = F.GetGunOrbitCF(targetRoot)
        elseif GlueMode == "knife" and targetRoot then
            dest = F.GetKnifeSurfaceCF(targetRoot)
            local KR = getgenv().KnifeRage
            if KR and KR.Enabled then
                local H = KR.Interval or 0.12
                if math.floor(tick()/H)%2==0 then
                    dest = CFrame.new(targetRoot.Position + Vector3.new(math.random()<0.5 and 900000 or -900000, 900000, math.random()<0.5 and 900000 or -900000))
                end
            end
        elseif GlueMode == "stomp" and targetRoot then
            dest = CFrame.new(targetRoot.Position + Vector3.new(0, StompHeight or 1.2, 0))
        elseif GlueMode == "custom" then dest = CustomGlueCF
        elseif targetRoot then dest = targetRoot.CFrame * getgenv().get_position_offset()
        end
        -- ALWAYS PhysicsRep to target when available so controller/others see the bot
        -- Only skip when pure CFrame toggles are explicitly on
        local isKill = (CurrentAction == "kill" or CurrentAction == "autokill")
        local isFollow = (CurrentAction == "follow" or CurrentAction == "formation" or GlueMode == "follow")
        local useCFrameOnly = (isKill and CFrameKillEnabled) or (isFollow and CFrameFollowEnabled)
        if targetRoot and not useCFrameOnly then
            F.SetPhysicsRepRootPart(selfRoot, targetRoot)
            selfRoot.CanCollide = false
        elseif targetRoot and useCFrameOnly then
            -- Still spoof for replication - pure CFrame alone is invisible to others
            F.SetPhysicsRepRootPart(selfRoot, targetRoot)
            selfRoot.CanCollide = false
        else
            -- Follow with no target root yet: spoof to self to avoid nil
            F.SetPhysicsRepRootPart(selfRoot, selfRoot)
        end
        if dest then
            selfRoot.AssemblyLinearVelocity = Vector3.zero
            selfRoot.AssemblyAngularVelocity = Vector3.zero
            selfRoot.CFrame = dest
        end
        F.ForceLocalVisibility()
    end)
end

function F.StartGlue(mode, targetPlayer)
    GlueMode = mode or "follow"
    GlueTargetPlayer = targetPlayer
    getgenv().glue_active = true
    if getgenv().KnifeRage then
        getgenv().KnifeRage.Enabled = (mode == "knife")
        getgenv().KnifeRage.CycleStart = tick()
    end
    getgenv().unc_connection()
end
function F.StopGlue()
    getgenv().glue_active = false
    if getgenv().KnifeRage then getgenv().KnifeRage.Enabled = false end
    if getgenv().connection_loop then getgenv().connection_loop:Disconnect() getgenv().connection_loop = nil end
    getgenv().reset_velocity()
    local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if a then if not NoclipEnabled then a.CanCollide = true end F.SetPhysicsRepRootPart(a, a) end
    GlueTargetPlayer = nil
    CustomGlueCF = nil
end

-- 3rd-person mouse aim: move cursor toward target on screen (mousemoverel)
function F.AimMouseAtTarget(target)
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

-- Camera lock: sticky on TargetPlayer only - no switching; unlock immediately on death/KO
function F.StartCameraLock(target)
    if LiteMode then return end
    if CameraConnection then CameraConnection:Disconnect() CameraConnection = nil end
    -- freeze sticky target at start (do not re-pick while locking)
    local lockedTarget = target or TargetPlayer
    CameraConnection = RunService.RenderStepped:Connect(function()
        if CurrentAction ~= "kill" and CurrentAction ~= "autokill" and CurrentAction ~= "bring" then return end
        local t = lockedTarget or TargetPlayer
        -- unlock immediately if dead / KO / left
        if not t or not F.inGame(t) or not t.Character or F.isKnocked(t.Character) then
            return
        end
        local hum = t.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            return
        end
        local tPart = t.Character:FindFirstChild("Head")
            or t.Character:FindFirstChild("UpperTorso")
            or t.Character:FindFirstChild("HumanoidRootPart")
        if not tPart then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CameraType = Enum.CameraType.Custom
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then cam.CameraSubject = h end
        cam.FieldOfView = 70
        -- hard lock look at target head (sticky)
        local from = cam.CFrame.Position
        cam.CFrame = CFrame.lookAt(from, tPart.Position)
        F.AimMouseAtTarget(t)
    end)
end
function F.StopCameraLock()
    if CameraConnection then CameraConnection:Disconnect() CameraConnection = nil end
    F.SetFOV(DefaultFOV)
    local cam = workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h and cam then cam.CameraSubject = h end
end

-- Obstacle clear: walls/trees/fences invisible + non-collide; keep floors & roads
local _fkObstacleCleared = {}
local _fkObstacleHooked = false
function F.FastKillClearWorldObstacles()
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

function F.EquipSlotNumber(n)
    -- disabled: never switch guns (anti-kick)
end
function F.StopSlotSpam() SlotSpamRunning = false end
function F.StartSlotSpam()
    -- fully disabled - switching guns kicks
    SlotSpamRunning = false
end

-- Summon/formation fly emotes only (never used as dance)
local FlyAnimChar = nil
local FlyAnimLastLoad = 0

function F.stopFlyAnims()
    if FlyTrack then pcall(function() FlyTrack:Stop(0.05) end) FlyTrack = nil end
    if HoverTrack then pcall(function() HoverTrack:Stop(0.05) end) HoverTrack = nil end
    FlyAnimChar = nil
end

function F.getFlyEmoteIds()
    local pack = FLY_EMOTES[FlyVariant] or FLY_EMOTES[1]
    return pack.idle, pack.move
end

function F.loadFlyAnims()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- Reload if character changed
    if FlyAnimChar == char and (FlyTrack or HoverTrack) and (tick() - FlyAnimLastLoad) < 2 then
        return
    end
    F.stopFlyAnims()
    FlyAnimChar = char
    FlyAnimLastLoad = tick()

    -- Disable default Animate so it cannot override summon fly
    local animate = char:FindFirstChild("Animate")
    if animate then
        pcall(function()
            animate.Disabled = true
            for _, d in ipairs(animate:GetDescendants()) do
                if d:IsA("Animation") then
                    -- leave assets; just keep script disabled
                end
            end
        end)
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    -- Never stop the persistent execute/dance emote
    pcall(function()
        for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
            if tr ~= CurrentDance then
                tr:Stop(0)
            end
        end
    end)
    -- re-assert dance after clearing other tracks
    if DancePersistent and LastDanceId then
        task.defer(function() F.EnsureDancePlaying() end)
    end

    local idleId, moveId = F.getFlyEmoteIds()
    -- Public fallbacks if catalog emote IDs fail to load in-game
    local FALLBACK_IDLE = "rbxassetid://616006778"
    local FALLBACK_MOVE = "rbxassetid://3541044388"

    local function tryLoad(id)
        local ok, track = pcall(function()
            local a = Instance.new("Animation")
            a.AnimationId = tostring(id)
            local t = animator:LoadAnimation(a)
            t.Looped = true
            t.Priority = Enum.AnimationPriority.Action4
            return t
        end)
        if ok and track then
            -- validate length (0 often means failed asset)
            local lenOk = true
            pcall(function()
                if track.Length and track.Length == 0 then lenOk = false end
            end)
            if lenOk then return track end
        end
        return nil
    end

    HoverTrack = tryLoad(idleId) or tryLoad(FALLBACK_IDLE)
    FlyTrack = tryLoad(moveId) or tryLoad(FALLBACK_MOVE)

    -- Kick idle immediately so user sees something on summon
    if HoverTrack then
        pcall(function() HoverTrack:Play(0.15, 1, ANIM_SPEED or 1) end)
    elseif FlyTrack then
        pcall(function() FlyTrack:Play(0.15, 1, ANIM_SPEED or 1) end)
    end
end

function F.updateFlyAnim()
    -- ONLY summon / formation
    if CurrentAction ~= "follow" and CurrentAction ~= "formation" then
        return
    end
    -- Persistent execute emote always wins over fly anims
    if DancePersistent and LastDanceId then
        F.EnsureDancePlaying()
        return
    end
    if not LocalPlayer.Character or LocalPlayer.Character ~= FlyAnimChar then
        F.loadFlyAnims()
    end
    if not FlyTrack and not HoverTrack then
        F.loadFlyAnims()
    end
    if not FlyTrack and not HoverTrack then return end

    local ctrl = F.GetController()
    local moving = false
    if ctrl and ctrl.Character then
        local ch = ctrl.Character:FindFirstChildOfClass("Humanoid")
        if ch and ch.MoveDirection.Magnitude > 0.08 then moving = true end
        local cr = ctrl.Character:FindFirstChild("HumanoidRootPart")
        if cr and cr.AssemblyLinearVelocity.Magnitude > 2.5 then moving = true end
    end

    local fade = ANIM_FADE or 0.2
    local spd = ANIM_SPEED or 1
    if moving then
        if HoverTrack and HoverTrack.IsPlaying then HoverTrack:Stop(fade) end
        if FlyTrack and not FlyTrack.IsPlaying then
            pcall(function() FlyTrack:Play(fade, 1, spd) end)
        elseif not FlyTrack and HoverTrack and not HoverTrack.IsPlaying then
            pcall(function() HoverTrack:Play(fade, 1, spd) end)
        end
    else
        if FlyTrack and FlyTrack.IsPlaying then FlyTrack:Stop(fade) end
        if HoverTrack and not HoverTrack.IsPlaying then
            pcall(function() HoverTrack:Play(fade, 1, spd) end)
        elseif not HoverTrack and FlyTrack and not FlyTrack.IsPlaying then
            pcall(function() FlyTrack:Play(fade, 1, spd) end)
        end
    end
end

function F.SetNoRender(on)
    NoRenderEnabled = on and true or false
    pcall(function()
        RunService:Set3dRenderingEnabled(not NoRenderEnabled)
    end)
    pcall(function()
        if NoRenderEnabled then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

-- Always-on noclip for this bot character
local NoclipEnabled = true
function F.ApplyNoclip(char)
    char = char or LocalPlayer.Character
    if not char or not NoclipEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end
RunService.Stepped:Connect(function()
    if NoclipEnabled then
        F.ApplyNoclip(LocalPlayer.Character)
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    LockedGunTool = nil
    task.defer(function() F.ApplyNoclip(char) end)
end)
if LocalPlayer.Character then
    task.defer(function() F.ApplyNoclip(LocalPlayer.Character) end)
end

RunService.Heartbeat:Connect(function()
    if SpinbotEnabled then
        local r = getgenv().get_root_part and getgenv().get_root_part()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(SpinbotSpeed or 25), 0)
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if CurrentAction == "follow" or CurrentAction == "formation" then
        F.updateFlyAnim()
    else
        -- stop summon fly emotes when not summoned/formation
        if FlyTrack or HoverTrack then
            F.stopFlyAnims()
        end
    end
    -- Weapon hold works even when not summoned
    if HoldMode then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bag = LocalPlayer:FindFirstChild("Backpack")
        if hum and char then
            local equipped = char:FindFirstChildOfClass("Tool")
            local gun, knife = nil, nil
            local function scan(parent)
                if not parent then return end
                for _, t in ipairs(parent:GetChildren()) do
                    if t:IsA("Tool") then
                        if t.Name:lower():find("knife") then knife = knife or t
                        else gun = gun or t end
                    end
                end
            end
            scan(char) scan(bag)
            local pick = nil
            if HoldMode == "both" then
                if (math.floor(tick() * 2) % 2 == 0) then pick = gun or knife else pick = knife or gun end
            elseif HoldMode == "knife" then
                pick = knife or gun
            else
                pick = gun or knife
            end
            if pick and equipped ~= pick then
                pcall(function() hum:UnequipTools() pick.Parent = char end)
            end
        end
    end
end)

function F.SpamShiftIfGun()
    -- disabled (rapid input / kick risk)
end

-- Pick a unique aura target per bot slot (separate targets)
function F.GetKillAuraTargetForSlot(centerPos)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and F.isFullyAlive(p) and not F.isWhitelisted(p) then
            local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if pr then
                list[#list + 1] = { p = p, d = (pr.Position - centerPos).Magnitude }
            end
        end
    end
    if #list == 0 then return nil end
    table.sort(list, function(a, b) return a.d < b.d end)
    -- Filter to range, then assign by slot
    local inRange = {}
    for i = 1, #list do
        if list[i].d <= KillAuraRange then inRange[#inRange + 1] = list[i].p end
    end
    if #inRange == 0 then return list[1].p end -- nearest even if outside soft range
    local idx = ((MySlot or 1) - 1) % #inRange + 1
    return inRange[idx]
end

function F.GetKnifeOrbitDist()
    local slot = math.clamp(MySlot or 1, 1, 20)
    return KA_OrbitBaseDist + (slot - 1) * KA_OrbitDistStep
end

function F.GetSummonCFQuick()
    local cf = F.GetSummonWorldCF()
    if cf then return cf end
    local c = F.GetController()
    local cr = c and c.Character and c.Character:FindFirstChild("HumanoidRootPart")
    if cr then return cr.CFrame * CFrame.new(0, 0, FollowBack) end
    return nil
end

function F.NL_ForceKill(char)
    -- Antistomp force-kill (stands + controller). KO only - normal Reset still works when not KO.
    if not char then return end
    if replicatesignal then pcall(replicatesignal, LocalPlayer.Kill) return end
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then pcall(function() h.Health = 0 end) return end
    pcall(function() char:BreakJoints() end)
end
function F.HookKO(char)
    if koConn then koConn:Disconnect() koConn = nil end
    if not char then return end
    task.spawn(function()
        local be = char:WaitForChild("BodyEffects", 4)
        if not be then return end
        local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
        if not ko then return end
        koConn = ko:GetPropertyChangedSignal("Value"):Connect(function()
            if ko.Value then F.NL_ForceKill(char) end
        end)
        if ko.Value then F.NL_ForceKill(char) end
    end)
end
F.HookKO(LocalPlayer.Character)
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
            if AutoHealEnabled and not AutoHealBusy and not HideAtShop and hum and hum.Health > 0 then
                local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                if hum.Health / maxH <= (AutoHealTriggerPct or 0.30) then
                    task.spawn(function()
                        F.RunAutoHealCycle()
                        if F.CanSummon() then
                            task.defer(F.StartFollow)
                        end
                    end)
                end
            end
            if ko and ko.Value and not AntiStompProcessing and hum and hum.Health > 0 then
                AntiStompProcessing = true
                task.delay(AntiStompDelay, function()
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local b = c and c:FindFirstChild("BodyEffects")
                    local k = b and (b:FindFirstChild("K.O") or b:FindFirstChild("KO"))
                    if k and k.Value and h and h.Health > 0 then
                        if not (F.IsControllerClient and F.IsControllerClient()) then
                            AutoSummonAfterReset = true
                        end
                        F.NL_ForceKill(c)
                    end
                    AntiStompProcessing = false
                end)
            end
        end
    end
end)

function F.isKnocked(char)
    local be = char and char:FindFirstChild("BodyEffects")
    if not be then return false end
    local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
    local dead = be:FindFirstChild("Dead") or be:FindFirstChild("SDeath")
    return ko and ko.Value and not (dead and dead.Value)
end
function F.isFullyAlive(p)
    local char = p and p.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or F.isKnocked(char) then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    return char:FindFirstChild("HumanoidRootPart") ~= nil
end
function F.inGame(p) return p and p.Parent == Players end

function F.applyKnifeHitbox()
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

LockedGunTool = nil
LockedGunSlot = 1

function F.CollectGuns()
    local guns = {}
    local char = LocalPlayer.Character
    local bag = LocalPlayer:FindFirstChild("Backpack")
    local function add(tool)
        if tool and tool:IsA("Tool") and not tool.Name:lower():find("knife") then
            guns[#guns + 1] = tool
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do add(tool) end
    end
    if bag then
        for _, tool in ipairs(bag:GetChildren()) do add(tool) end
    end
    return guns
end


function F.UnequipAllTools()
    local char = LocalPlayer.Character
    local bag = LocalPlayer:FindFirstChild("Backpack")
    if not char then return end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and bag then
            pcall(function() t.Parent = bag end)
        end
    end
end

function F.EquipOnlyTool(tool)
    if not tool then return nil end
    F.UnequipAllTools()
    local char = LocalPlayer.Character
    if not char then return nil end
    pcall(function() tool.Parent = char end)
    return tool
end

function F.EquipGunBySlot(slot)
    slot = math.max(1, math.floor(tonumber(slot) or 1))
    local guns = F.CollectGuns()
    if #guns == 0 then return nil end
    local gun = guns[math.min(slot, #guns)]
    local char = LocalPlayer.Character
    if not char or not gun then return nil end
    F.EquipOnlyTool(gun)
    LockedGunTool = gun
    LockedGunSlot = slot
    return gun
end

function F.EquipBestWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local equipped = char:FindFirstChildOfClass("Tool")
    local wantSlot = LockedGunSlot or 1

    if UseGun then
        if equipped and not equipped.Name:lower():find("knife") then
            if wantSlot > 1 then
                local guns = F.CollectGuns()
                if #guns >= wantSlot and equipped ~= guns[wantSlot] then
                    return F.EquipGunBySlot(wantSlot) or equipped
                end
            end
            LockedGunTool = equipped
            return equipped
        end
        return F.EquipGunBySlot(wantSlot) or equipped
    end

    -- knife mode
    if equipped and equipped.Name:lower():find("knife") then
        F.applyKnifeHitbox()
        return equipped
    end
    local knife = nil
    local function findKnife(parent)
        if not parent then return end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("knife") then
                knife = tool
                return
            end
        end
    end
    findKnife(bag)
    findKnife(char)
    if knife then
        pcall(function() knife.Parent = char end)
        F.applyKnifeHitbox()
        return knife
    end
    return equipped
end
-- NeverLarp-style auto reload: only when Ammo IntValue is 0
local _ReloadLast = {} -- [toolName] = tick
local _ReloadCD = 0.8

function F.TryReload()
    local char = LocalPlayer.Character
    if not char then return end
    local TOOLS = { "[Revolver]", "[DoubleBarrel]", "[TacticalShotgun]", "[SMG]", "[Shotgun]", "[Silencer]", "[Uzi]" }
    for _, name in ipairs(TOOLS) do
        local tool = char:FindFirstChild(name)
        if tool then
            local last = (_ReloadLast and _ReloadLast[name]) or 0
            if tick() - last >= (_ReloadCD or 1) then
                local scr = tool:FindFirstChild("Script")
                local ammo = scr and scr:FindFirstChild("Ammo")
                if ammo and ammo:IsA("IntValue") and ammo.Value == 0 then
                    if not _ReloadLast then _ReloadLast = {} end
                    _ReloadLast[name] = tick()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end)
                end
            end
        end
    end
    -- also any equipped tool with Ammo 0
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and not tool.Name:lower():find("knife") then
            local scr = tool:FindFirstChild("Script")
            local ammo = scr and scr:FindFirstChild("Ammo")
            if ammo and ammo:IsA("IntValue") and ammo.Value == 0 then
                local n = tool.Name
                local last = (_ReloadLast and _ReloadLast[n]) or 0
                if tick() - last >= 1 then
                    if not _ReloadLast then _ReloadLast = {} end
                    _ReloadLast[n] = tick()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end)
                end
            end
        end
    end
end

if getgenv()._NamelessAutoReloadConn then pcall(function() getgenv()._NamelessAutoReloadConn:Disconnect() end) end
getgenv()._NamelessAutoReloadConn = RunService.RenderStepped:Connect(function()
    F.TryReload()
end)


function F.getEquippedCombatTool()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Tool")
end
-- ========== UNIFIED FORCEHIT (NeverLarp-style, NO camera lock) ==========
-- Same packet used by forcehit + kill aura
function F.getMuzzleOrigin()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if handle then
            local muzzle = handle:FindFirstChild("Muzzle") or handle
            return muzzle.Position
        end
    end
    local head = char:FindFirstChild("Head")
    if head then return head.Position + head.CFrame.LookVector * 3 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + hrp.CFrame.LookVector * 4 end
    return nil
end

function F.validTarget(target, fromPos)
    if not target or not target.Character then return false end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    local be = char:FindFirstChild("BodyEffects")
    local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
    if ko and ko.Value then return false end
    local part = char:FindFirstChild("Head")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("HumanoidRootPart")
    if not part then return false end
    return true, part
end

-- Core fire: NeverLarp FH packet + rapid volleys + controller-only tracers
_lastFHFire = 0
FHTracerFolder = nil

function F.DrawForceHitTracer(...) end
function F.DrawForceHitTracer_DISABLED(origin, hitPos)
    -- ONLY controller sees bullet tracers (bots skip for FPS)
    if not F.IsControllerClient() then return end
    if not origin or not hitPos then return end
    pcall(function()
        if not FHTracerFolder or not FHTracerFolder.Parent then
            local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
            if not pg then return end
            FHTracerFolder = Instance.new("Folder")
            FHTracerFolder.Name = "NAMELESS_FH_TRACERS"
            FHTracerFolder.Parent = pg
        end
        local att0 = Instance.new("Part")
        att0.Name = "FH_A0"
        att0.Anchored = true
        att0.CanCollide = false
        att0.CanQuery = false
        att0.CanTouch = false
        att0.Transparency = 1
        att0.Size = Vector3.new(0.1, 0.1, 0.1)
        att0.CFrame = CFrame.new(origin)
        att0.Parent = workspace.Terrain
        local att1 = att0:Clone()
        att1.Name = "FH_A1"
        att1.CFrame = CFrame.new(hitPos)
        att1.Parent = workspace.Terrain
        local a0 = Instance.new("Attachment")
        a0.Parent = att0
        local a1 = Instance.new("Attachment")
        a1.Parent = att1
        local beam = Instance.new("Beam")
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = 0.12
        beam.Width1 = 0.04
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 80, 40))
        beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(1, 0.85),
        })
        beam.Parent = att0
        task.delay(0.12, function()
            pcall(function() att0:Destroy() end)
            pcall(function() att1:Destroy() end)
        end)
    end)
end

-- Controller-only: visual tracers from online bots toward nearest enemy
task.spawn(function()
    while task.wait(0.08) do
        if F.IsControllerClient() and BotEspEnabled and RapidFireEnabled then
            for _, name in ipairs(BotListOrdered or {}) do
                if type(name) == "string" then
                    local plr = Players:FindFirstChild(name)
                    if not plr then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Name:lower() == name:lower() then plr = p break end
                        end
                    end
                    if plr and plr.Character then
                        local tool = plr.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("Handle") and not tool.Name:lower():find("knife") then
                            local origin = tool.Handle.Position
                            local best, bestD = nil, 120
                            for _, enemy in ipairs(Players:GetPlayers()) do
                                if enemy ~= plr and enemy ~= LocalPlayer and not F.isWhitelisted(enemy) then
                                    local h = enemy.Character and (enemy.Character:FindFirstChild("Head") or enemy.Character:FindFirstChild("HumanoidRootPart"))
                                    if h then
                                        local d = (h.Position - origin).Magnitude
                                        if d < bestD then best, bestD = h, d end
                                    end
                                end
                            end
                            if best then
                                F.DrawForceHitTracer(origin, best.Position)
                            end
                        end
                    end
                end
            end
        end
    end
end)

function F.FireForceHit(target)
    if not MainEvent or not target then return false end
    -- optional lock: only the cmd target
    if ForceHitCmdTarget and ForceHitCmdTarget.Parent then
        if target ~= ForceHitCmdTarget and target.Name ~= ForceHitCmdTarget.Name then
            return false
        end
    end
    local now = tick()
    local rate = ForceHitFireRate or 0.08
    if rate > 0 and now - (_lastFHFire or 0) < rate then return false end
    local tChar = target.Character
    if not tChar then return false end
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    if not tHum or tHum.Health <= 0 then return false end
    local be = tChar:FindFirstChild("BodyEffects")
    if be then
        local ko = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
        local dead = be:FindFirstChild("Dead")
        if (ko and ko.Value) or (dead and dead.Value) then return false end
        local hp = be:FindFirstChild("Health") or be:FindFirstChild("Health_CLIENT")
        if hp and hp.Value <= 0 then return false end
    end
    if tChar:FindFirstChildOfClass("ForceField") then return false end
    local hitPart = tChar:FindFirstChild("Head")
        or tChar:FindFirstChild("UpperTorso")
        or tChar:FindFirstChild("HumanoidRootPart")
    if not hitPart or not hitPart:IsA("BasePart") then return false end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool or not tool:FindFirstChild("Handle") then
        if F.EquipBestWeapon then tool = F.EquipBestWeapon() end
    end
    if not tool or not tool:FindFirstChild("Handle") then return false end
    if tool.Name:lower():find("knife") then return false end
    local handlePos = tool.Handle.Position
    local hitPos = hitPart.Position
    local name = string.lower(tool.Name)
    local pellets = 1
    if string.find(name, "shotgun") or string.find(name, "tactical") or string.find(name, "db") or string.find(name, "double") then
        pellets = 5
    end
    -- Rapid: send multiple full packets in one frame (faster than any real firerate)
    local volleys = RapidFireEnabled and (RapidFireVolleys or 4) or 1
    for v = 1, volleys do
        local hits = {}
        for i = 1, pellets do
            local pos = hitPos
            if pellets > 1 or RapidFireEnabled then
                pos = hitPos + Vector3.new(
                    math.random(-20, 20) / 100,
                    math.random(-20, 20) / 100,
                    math.random(-20, 20) / 100
                )
            end
            hits[i] = {
                PELLET = i,
                POSITION = pos,
                MODEL = tChar,
                PART = hitPart,
            }
        end
        local aim = hitPos + (hitPos - handlePos).Unit * 25
        getgenv().FH_Index = ((getgenv().FH_Index or 0) + 1) % 100
        local packet = {
            INDEX = getgenv().FH_Index,
            AIM = aim,
            ORIGIN = handlePos,
            HITS = hits,
        }
        pcall(function() MainEvent:FireServer("Shoot", packet) end)
    end
    -- tracer disabled
    _lastFHFire = now
    _lastFHT = now
    return true
end

function F.forceHitTick(target)
    -- NeverLarp FH_Fire only
    F.FireForceHit(target)
    F.TryReload()
end
function F.forceHitTickMy(target)
    F.forceHitTick(target)
end
function F.forceHitTickTest(target)
    F.forceHitTick(target)
end

function F.StartKillAura()
    if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
    local ka = getgenv().KillAura
    if not ka then
        getgenv().KillAura = {
            Enabled = true, Range = KillAuraRange or 80, Delay = KillAuraDelay or 0.06,
            HitPart = "Head", WallCheck = true, KnockedCheck = true,
            ForceFieldCheck = true, DeathCheck = true, CurrentTarget = nil,
        }
        ka = getgenv().KillAura
    end
    ka.Enabled = true
    ka.WallCheck = true
    ka.KnockedCheck = true
    KillAuraEnabled = true
    UseGun = true
    pcall(function() F.EquipSelectedGun() end)
    local lastShot = 0
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        ka = getgenv().KillAura
        if not ka or not ka.Enabled then
            if ka then ka.CurrentTarget = nil end
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            ka.CurrentTarget = nil
            return
        end
        UseGun = true
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or tool.Name:lower():find("knife") then
            tool = F.EquipSelectedGun()
        end
        if not tool or tool.Name:lower():find("knife") then
            ka.CurrentTarget = nil
            return
        end
        local range = ka.Range or KillAuraRange or 80
        local delay = ka.Delay or KillAuraDelay or 0.06
        local best, bestD = nil, range + 0.01
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not (F.isWhitelisted and F.isWhitelisted(plr)) then
                local c = plr.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        local skip = false
                        -- knocked / KO check
                        if ka.KnockedCheck ~= false or ka.DeathCheck then
                            if F.isKnocked(c) then skip = true end
                            local be = c:FindFirstChild("BodyEffects")
                            local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
                            local dead = be and be:FindFirstChild("Dead")
                            if (ko and ko.Value) or (dead and dead.Value) then skip = true end
                        end
                        if not skip and ka.ForceFieldCheck and c:FindFirstChildOfClass("ForceField") then
                            skip = true
                        end
                        local part = c:FindFirstChild(ka.HitPart or "Head")
                            or c:FindFirstChild("Head")
                            or c:FindFirstChild("HumanoidRootPart")
                        if not skip and part then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d <= range then
                                -- wall check
                                if ka.WallCheck and F.HasWallBetween(hrp.Position, part.Position) then
                                    skip = true
                                end
                                if not skip and d < bestD then
                                    best, bestD = plr, d
                                end
                            end
                        end
                    end
                end
            end
        end
        ka.CurrentTarget = best
        if not best then return end
        if tick() - lastShot < delay then return end
        if F.FireForceHit(best) then
            lastShot = tick()
        end
    end)
end

function F.StopKillAura()
    KillAuraEnabled = false
    if getgenv().KillAura then
        getgenv().KillAura.Enabled = false
        getgenv().KillAura.CurrentTarget = nil
    end
    if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
end

function F.DoSingleStomp(target)
    if (MySlot or 1) ~= StompBotSlot or not StompOnKill then return end
    local tc = target and target.Character
    if not tc then return end
    local ut = tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("HumanoidRootPart")
    local hrp = getgenv().get_root_part()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not ut or not hrp or not hum then return end
    F.StopGlue()
    F.StopCameraLock()
    F.StopSlotSpam()
    pcall(function() hum:UnequipTools() end)
    hum.Sit = false
    hum.PlatformStand = false
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    hrp.AssemblyLinearVelocity = Vector3.zero
    local stompOff = Vector3.new(0, StompHeight or 1.2, 0)
    hrp.CFrame = CFrame.new(ut.Position + stompOff)
    RunService.Heartbeat:Wait()
    for _ = 1, 5 do if MainEvent then pcall(function() MainEvent:FireServer("Stomp") end) end end
    local t0 = tick()
    while tick() - t0 < PostStompHold do
        if ut.Parent and hrp.Parent then hrp.CFrame = CFrame.new(ut.Position + stompOff) end
        RunService.Heartbeat:Wait()
    end
end

function F.StopAll()
    CurrentAction = "idle"
    TargetPlayer, TargetList = nil, {}
    FormationTarget, FormationType = nil, nil
    BringStage, GrabOnceDone = nil, false
    KillPhase, StompDoneForCycle = "attack", false
    if F.StopKillAttackLoop then F.StopKillAttackLoop() end
    if F.StopKillVisualSpoof then F.StopKillVisualSpoof() end
    F.StopGlue()
    F.StopCameraLock()
    F.StopSlotSpam()
    F.stopFlyAnims()
    if not DancePersistent and CurrentDance then pcall(function() CurrentDance:Stop() end) CurrentDance = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false hum.Sit = false end
end
function F.TryGrabOnce()
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
function F.ForceReset()
    F.StopAll()
    PendingAutokill, SavedKillTargets = nil, nil
    F.NL_ForceKill(LocalPlayer.Character)
end
function F.PlayEmote(id)
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

function pcall(function() if F.StartDefaultEmote then F.StartDefaultEmote() end end)
    local id = DefaultEmoteId or Emotes.darktriad
    if not id or id == "" then return end
    DancePersistent = true
    LastDanceId = id
    F.PlayEmote(id)
end

function F.EnsureDancePlaying()
    -- always keep an emote playing (default if none set)
    if not LastDanceId then
        LastDanceId = DefaultEmoteId
        DancePersistent = true
    end
    if DancePersistent and LastDanceId then
        if not (CurrentDance and CurrentDance.IsPlaying) then
            F.PlayEmote(LastDanceId)
        end
    elseif ExecuteEmoteForced then
        pcall(function() if F.StartDefaultEmote then F.StartDefaultEmote() end end)
    end
end

-- Auto stomp: ONLY the current kill target when KO'd (no nearest scan)
function F.StartContinuousAutostomp()
    if AutoStompConnection then AutoStompConnection:Disconnect() AutoStompConnection = nil end
    AutoStompConnection = RunService.Heartbeat:Connect(function()
        if not AutoStompEnabled then return end
        local selfRoot = getgenv().get_root_part()
        if not selfRoot then return end
        local t = TargetPlayer
        if not t or not t.Character or not F.isKnocked(t.Character) then return end
        local ut = t.Character:FindFirstChild("UpperTorso")
            or t.Character:FindFirstChild("HumanoidRootPart")
        if not ut then return end
        selfRoot.AssemblyLinearVelocity = Vector3.zero
        selfRoot.AssemblyAngularVelocity = Vector3.zero
        selfRoot.CFrame = CFrame.new(ut.Position + Vector3.new(0, StompHeight or 1.2, 0))
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
        end
        if MainEvent then
            for _ = 1, 3 do
                pcall(function() MainEvent:FireServer("Stomp") end)
            end
        end
    end)
end
function F.StopContinuousAutostomp()
    if AutoStompConnection then AutoStompConnection:Disconnect() AutoStompConnection = nil end
end

-- Fast kill cycle (pure CFrame - glue fully off):
-- 1) Snap BEHIND target (stable look - does not break if target stops walking)
-- 2) Approach at FastKillMoveSpeed; triggerbot at FastKillHitDist
-- 3) Fly FRONT at FastKillMoveSpeed
-- 4) Repeat until dead
-- Top-down camera lock on target. Obstacles cleared on start.
FastKillPhase = "behind" -- behind | hit | front
FastKillFrontCF = nil
FastKillTweening = false
FastKillTweenStart = 0
FastKillTweenFrom = nil
FastKillLastStep = 0
FastKillLastTrigger = 0

-- Client visual spoof: real kill on Heartbeat, RenderStepped shows orbit around target
KillVisualSpoof = true
KillSpoofConn = nil
LastRealKillCF = nil
OrbitVisualAngle = 0

function F.GetKillOffset(tRoot, posName, dist)
    if not tRoot then return Vector3.zero end
    local look = F.getFastKillStableLook(tRoot)
    local right = Vector3.new(-look.Z, 0, look.X)
    if right.Magnitude < 0.05 then right = Vector3.new(1, 0, 0) else right = right.Unit end
    local d = dist or KillDistance or 8
    local n = (posName or KillPosition or "Back"):lower()
    if n == "front" then return look * d
    elseif n == "left" then return -right * d
    elseif n == "right" then return right * d
    elseif n == "top" then return Vector3.new(0, d, 0)
    elseif n == "bottom" then return Vector3.new(0, -d, 0)
    else return -look * d -- Back
    end
end

function F.GetKillVisualCF(target)
    if not target or not target.Character then return nil end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        or target.Character:FindFirstChild("UpperTorso")
        or target.Character:FindFirstChild("Head")
    if not tRoot then return nil end
    -- smooth orbit visual around target (client only)
    OrbitVisualAngle = OrbitVisualAngle + (OrbitSpeed or 30) * 0.016
    local dist = KillDistance or 8
    local h = (OrbitHeight or 1) + 1.5
    local x = math.cos(OrbitVisualAngle) * dist
    local z = math.sin(OrbitVisualAngle) * dist
    local pos = tRoot.Position + Vector3.new(x, h, z)
    return CFrame.lookAt(pos, tRoot.Position)
end

function F.StartKillVisualSpoof()
    F.StopKillVisualSpoof()
    if not KillVisualSpoof then return end
    -- Camera orbits target so SCREEN looks like orbit; body keeps real kill CFrame
    KillSpoofConn = RunService.RenderStepped:Connect(function()
        if not KillVisualSpoof then return end
        if CurrentAction ~= "kill" and CurrentAction ~= "autokill" then return end
        if KillPhase ~= "attack" and KillPhase ~= "waitff" then return end
        local t = TargetPlayer
        if not t or not F.inGame(t) or not t.Character then return end
        local tRoot = t.Character:FindFirstChild("HumanoidRootPart")
            or t.Character:FindFirstChild("UpperTorso")
            or t.Character:FindFirstChild("Head")
        if not tRoot then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        OrbitVisualAngle = OrbitVisualAngle + (OrbitSpeed or 30) * 0.016
        local dist = (KillDistance or 8) + 6
        local h = (OrbitHeight or 1) + 4
        local x = math.cos(OrbitVisualAngle) * dist
        local z = math.sin(OrbitVisualAngle) * dist
        local camPos = tRoot.Position + Vector3.new(x, h, z)
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = CFrame.lookAt(camPos, tRoot.Position)
    end)
end

function F.StopKillVisualSpoof()
    if KillSpoofConn then
        KillSpoofConn:Disconnect()
        KillSpoofConn = nil
    end
    LastRealKillCF = nil
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then cam.CameraType = Enum.CameraType.Custom end
    end)
end

function F.ForceGlueOff()
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
            if not NoclipEnabled then a.CanCollide = true end
            F.SetPhysicsRepRootPart(a, a)
        end
        GlueTargetPlayer = nil
        CustomGlueCF = nil
    end
end

-- Stable horizontal facing: move dir → LookVector → last good (won't collapse when target stops)
function F.getFastKillStableLook(tRoot)
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

function F.FastKillTriggerBot(target)
    if tick() - FastKillLastTrigger < FastKillTriggerRate then return end
    FastKillLastTrigger = tick()
    local method = F.GetKillMethod and F.GetKillMethod() or KillMethod
    if method == "tween" or KnifeTweenEnabled then
        UseGun = false
        local char = LocalPlayer.Character
        local knife = char and (char:FindFirstChild("[Knife]") or char:FindFirstChild("Knife"))
        if not knife then
            local bag = LocalPlayer:FindFirstChild("Backpack")
            knife = bag and (bag:FindFirstChild("[Knife]") or bag:FindFirstChild("Knife"))
            if knife then pcall(function() knife.Parent = char end) end
        end
        if knife then
            F.applyKnifeHitbox()
            pcall(function() knife:Activate() end)
        end
        return
    end
    local tool = F.EquipBestWeapon()
    if not tool then return end
    if tool.Name:lower():find("knife") then
        F.applyKnifeHitbox()
        pcall(function() tool:Activate() end)
    else
        F.FireForceHit(target)
        F.TryReload()
    end
end

-- Tween path by TweenPath setting (not KillPosition)
function F.getTweenKillPath(tRoot)
    local look = F.getFastKillStableLook(tRoot)
    local right = Vector3.new(-look.Z, 0, look.X)
    if right.Magnitude < 0.05 then right = Vector3.new(1, 0, 0) else right = right.Unit end
    local up = Vector3.new(0, 1, 0)
    local origin = tRoot.Position + Vector3.new(0, 1.5, 0)
    local d0 = FastKillBehindDist or 18
    local d1 = FastKillHitDist or 6
    local d2 = FastKillFrontDist or 22
    local path = (TweenPath or "backfront"):lower()
    local startPos, hitPos, endPos

    if path == "topbottom" then
        startPos = origin + up * d0
        hitPos = origin + up * math.max(d1 * 0.35, 2)
        endPos = origin - up * d2
    elseif path == "leftright" then
        startPos = origin - right * d0
        hitPos = origin - right * (d1 * 0.5)
        endPos = origin + right * d2
    elseif path == "diag_tlbr" then
        local a = (-right + up).Unit
        local b = (right - up).Unit
        startPos = origin + a * d0
        hitPos = origin
        endPos = origin + b * d2
    elseif path == "diag_trbl" then
        local a = (right + up).Unit
        local b = (-right - up).Unit
        startPos = origin + a * d0
        hitPos = origin
        endPos = origin + b * d2
    elseif path == "diag_bltr" then
        local a = (-right - up).Unit
        local b = (right + up).Unit
        startPos = origin + a * d0
        hitPos = origin
        endPos = origin + b * d2
    elseif path == "diag_brtl" then
        local a = (right - up).Unit
        local b = (-right + up).Unit
        startPos = origin + a * d0
        hitPos = origin
        endPos = origin + b * d2
    else
        -- backfront (default)
        startPos = origin - look * d0
        hitPos = origin - look * d1
        endPos = origin + look * d2
    end
    return startPos, hitPos, endPos, path
end

function F.FastKillStep(target)
    local tChar = target and target.Character
    if not tChar then return false end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("UpperTorso")
    local r = getgenv().get_root_part()
    if not tRoot or not r then return false end

    local hum = tChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or F.isKnocked(tChar) then
        FastKillPhase = "behind"
        FastKillTweenStart = 0
        return true
    end

    local now = tick()
    local dt = FastKillLastStep > 0 and math.clamp(now - FastKillLastStep, 0, 0.05) or 0.016
    FastKillLastStep = now

    local startPos, hitPos, endPos = F.getTweenKillPath(tRoot)
    local speed = math.max(FastKillMoveSpeed or 2500, 200)

    -- pure CFrame tween (no PhysicsRep fight during path)
    pcall(function() workspace.FallenPartsDestroyHeight = -50000 end)
    r.CanCollide = false
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    F.SetPhysicsRepRootPart(r, r)

    local function snapOrStep(goal)
        local dist = (r.Position - goal).Magnitude
        if dist <= 4 then
            r.CFrame = CFrame.lookAt(goal, tRoot.Position)
            return true
        end
        -- long range: snap halfway then finish so it actually reaches
        if dist > 80 then
            local dir = (goal - r.Position).Unit
            r.CFrame = CFrame.lookAt(r.Position + dir * math.min(dist * 0.85, speed * dt * 3), tRoot.Position)
            dist = (r.Position - goal).Magnitude
            if dist <= 6 then
                r.CFrame = CFrame.lookAt(goal, tRoot.Position)
                return true
            end
            return false
        end
        local dir = goal - r.Position
        local step = math.min(speed * math.max(dt, 1/60), dir.Magnitude)
        r.CFrame = CFrame.lookAt(r.Position + dir.Unit * step, tRoot.Position)
        return (r.Position - goal).Magnitude < 4
    end

    if FastKillPhase ~= "behind" and FastKillPhase ~= "hit" and FastKillPhase ~= "front" then
        FastKillPhase = "behind"
    end

    if FastKillPhase == "behind" then
        if snapOrStep(startPos) then
            r.CFrame = CFrame.lookAt(startPos, tRoot.Position)
            FastKillPhase = "hit"
            FastKillTweenStart = 0
            F.AimMouseAtTarget(target)
            F.FastKillTriggerBot(target)
        end
        return false
    end

    if FastKillPhase == "hit" then
        if not snapOrStep(hitPos) then
            return false
        end
        r.CFrame = CFrame.lookAt(hitPos, tRoot.Position)
        F.AimMouseAtTarget(target)
        F.FastKillTriggerBot(target)
        if FastKillTweenStart == 0 then FastKillTweenStart = now end
        if (now - FastKillTweenStart) >= (FastKillHitHold or 0.05) then
            FastKillPhase = "front"
            FastKillTweenStart = 0
        end
        return false
    end

    if snapOrStep(endPos) then
        r.CFrame = CFrame.lookAt(endPos, tRoot.Position)
        FastKillPhase = "behind"
        FastKillTweenStart = 0
    end
    return false
end

-- Heartbeat driver for fast kill / normal kill attack (smooth on bot's screen)
-- Orbit kill: stick in orbit CF and shoot (no tween path)
function F.OrbitKillStep(target)
    local tChar = target and target.Character
    if not tChar then return true end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("UpperTorso")
    local r = getgenv().get_root_part()
    if not tRoot or not r then return false end
    if F.isKnocked(tChar) then return true end
    local hum = tChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    if tChar:FindFirstChildOfClass("ForceField") then return false end
    local off = F.GetKillOffset(tRoot, KillPosition, KillDistance)
    local dest = CFrame.lookAt(tRoot.Position + off, tRoot.Position)
    F.SetPhysicsRepRootPart(r, tRoot)
    r.CanCollide = false
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    r.CFrame = dest
    F.ForceLocalVisibility()
    F.AimMouseAtTarget(target)
    F.FastKillTriggerBot(target)
    return false
end

-- Real void dive: hard teleport, else tween at SpamVoidTweenSpeed (100000)
function F.GoToVoid(r, surfaceCF)
    if not r then return false end
    pcall(function() workspace.FallenPartsDestroyHeight = -50000 end)
    -- break PhysicsRep so we are not glued to the target while voiding
    F.SetPhysicsRepRootPart(r, r)
    r.CanCollide = false
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero

    local base = surfaceCF or r.CFrame
    local depth = SpamVoidDepth or 500
    local voidPos = Vector3.new(base.Position.X, base.Position.Y - depth, base.Position.Z)
    -- also allow absolute deep void
    local absVoid = Vector3.new(base.Position.X, (VoidY or -500), base.Position.Z)
    if absVoid.Y < voidPos.Y then voidPos = absVoid end

    -- 1) hard teleport
    r.CFrame = CFrame.new(voidPos)
    r.AssemblyLinearVelocity = Vector3.zero

    -- 2) if still not deep enough, tween dive at 100000 studs/s
    if r.Position.Y > (base.Position.Y - depth * 0.6) then
        local goal = Vector3.new(base.Position.X, base.Position.Y - depth, base.Position.Z)
        local dir = goal - r.Position
        local dist = dir.Magnitude
        if dist > 1 then
            local step = math.min((SpamVoidTweenSpeed or 100000) * 0.016, dist)
            r.CFrame = CFrame.new(r.Position + dir.Unit * step)
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end
    return r.Position.Y < (base.Position.Y - 50)
end

-- Spamvoid kill: surface shoot → REAL void → surface (timings customisable)
function F.SpamVoidKillStep(target)
    local tChar = target and target.Character
    if not tChar then return true end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("UpperTorso")
    local r = getgenv().get_root_part()
    if not tRoot or not r then return false end
    if F.isKnocked(tChar) then return true end
    local hum = tChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    -- never shoot while forcefield is up
    if tChar:FindFirstChildOfClass("ForceField") then
        F.GoToVoid(r, SpamVoidSurfaceCF or r.CFrame)
        return false
    end

    local now = tick()
    local off = F.GetKillOffset(tRoot, KillPosition, KillDistance or FastKillHitDist or 6)
    local surfacePos = tRoot.Position + off + Vector3.new(0, 1.0, 0)

    r.CanCollide = false
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero

    local inT, outT
    if UseGun then
        inT = GunSpamVoidIn or 4
        outT = GunSpamVoidOut or 2
    else
        inT = KnifeSpamVoidIn or 2
        outT = KnifeSpamVoidOut or 1
    end

    if SpamVoidPhase == "surface" then
        F.SetPhysicsRepRootPart(r, tRoot)
        r.CFrame = CFrame.lookAt(surfacePos, tRoot.Position)
        SpamVoidSurfaceCF = CFrame.new(surfacePos)
        F.AimMouseAtTarget(target)
        F.FastKillTriggerBot(target)
        SpamVoidPhase = "void"
        SpamVoidUntil = now + inT
        SpamVoidHitDone = true
        F.GoToVoid(r, SpamVoidSurfaceCF)
        return false
    end

    if SpamVoidPhase == "void" then
        F.GoToVoid(r, SpamVoidSurfaceCF)
        if now >= SpamVoidUntil then
            F.SetPhysicsRepRootPart(r, tRoot)
            r.CFrame = CFrame.lookAt(surfacePos, tRoot.Position)
            if now >= SpamVoidUntil + outT then
                SpamVoidPhase = "surface"
                SpamVoidHitDone = false
            end
        end
        return false
    end

    SpamVoidPhase = "surface"
    return false
end

KillAttackConn = nil
function F.StopKillAttackLoop()
    if KillAttackConn then KillAttackConn:Disconnect() KillAttackConn = nil end
    F.StopKillVisualSpoof()
    SpamVoidPhase = "surface"
    SpamVoidUntil = 0
    SpamVoidSurfaceCF = nil
    SpamVoidHitDone = false
end
function F.StartKillAttackLoop()
    F.StopKillAttackLoop()
    FastKillPhase = "behind"
    FastKillTweenStart = 0
    FastKillTweenFrom = nil
    FastKillLastStep = 0
    SpamVoidPhase = "surface"
    SpamVoidUntil = 0
    SpamVoidSurfaceCF = nil
    SpamVoidHitDone = false
    -- Heartbeat = real kill path; RenderStepped visual = orbit spoof
    F.StartKillVisualSpoof()
    KillAttackConn = RunService.Heartbeat:Connect(function()
        if CurrentAction ~= "kill" and CurrentAction ~= "autokill" then return end
        if KillPhase ~= "attack" then return end
        local t = TargetPlayer
        if not t or not F.inGame(t) then return end
        local tChar = t.Character
        if not tChar or F.isKnocked(tChar) then return end
        local hum = tChar:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if tChar:FindFirstChildOfClass("ForceField") then return end
        F.EquipBestWeapon()
        local m = F.GetKillMethod()
        if m == "spamvoid" then
            F.SpamVoidKillStep(t)
        elseif m == "orbit" then
            F.OrbitKillStep(t)
        else
            F.FastKillStep(t)
        end
        if UseGun and tick() - LastReload > 1.8 then F.TryReload() end
    end)
end

-- forward funcs on F: F.StartKill, F.StartFollow, F.OnChatted, F.RunSilent
F.RunSilent = function(cmdLine)
    getgenv()._StandGuiSilent = true
    pcall(function() F.OnChatted(LocalPlayer, PREFIX .. cmdLine) end)
    getgenv()._StandGuiSilent = false
end

-- GUI commands: always chat; if sync bots on, also run locally on controller
F.GuiCommand = function(cmdLine)
    F.ChatCommand(cmdLine)
    if SyncBotsEnabled then
        F.RunSilent(cmdLine)
    end
end

-- Send real chat so bots on other devices hear the command
F.ChatCommand = function(cmdLine)
    local msg = (PREFIX or "NAMELESS.HVH | !") .. tostring(cmdLine or "")
    local sent = false
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS and TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TCS:FindFirstChild("TextChannels")
            local ch = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("RBXSystem"))
            if ch and ch.SendAsync then
                ch:SendAsync(msg)
                sent = true
            end
        end
    end)
    if not sent then
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
            local say = ev and ev:FindFirstChild("SayMessageRequest")
            if say then say:FireServer(msg, "All") sent = true end
        end)
    end
    -- also run locally for controller-side silent tools
    pcall(function() F.RunSilent(cmdLine) end)
end

-- Black screen for stands/bots
BlackScreenGui = nil
function F.CreateBlackScreen()
    if BlackScreenGui then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if not pg then return end
    local g = Instance.new("ScreenGui")
    g.Name = "NAMELESS_BLACK"
    g.IgnoreGuiInset = true
    g.ResetOnSpawn = false
    g.DisplayOrder = 999
    g.Parent = pg
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.new(0, 0, 0)
    f.BorderSizePixel = 0
    f.Parent = g
    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, -40, 0, 40)
    t1.Position = UDim2.new(0, 20, 0.45, 0)
    t1.BackgroundTransparency = 1
    t1.Font = Enum.Font.GothamBold
    t1.TextSize = 18
    t1.TextColor3 = Color3.fromRGB(220, 220, 230)
    t1.Text = "Stand script enabled - control via chat on main account"
    t1.Parent = f
    local t2 = Instance.new("TextLabel")
    t2.Size = UDim2.new(1, -40, 0, 28)
    t2.Position = UDim2.new(0, 20, 0.45, 36)
    t2.BackgroundTransparency = 1
    t2.Font = Enum.Font.Gotham
    t2.TextSize = 14
    t2.TextColor3 = Color3.fromRGB(160, 160, 170)
    t2.Text = "Made by AI - expect bugs | slot " .. tostring(MySlot)
    t2.Parent = f
    BlackScreenGui = g
end
function F.DestroyBlackScreen()
    if BlackScreenGui then pcall(function() BlackScreenGui:Destroy() end) BlackScreenGui = nil end
end

function F.Notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "NAMELESS",
            Text = tostring(text),
            Duration = 5,
        })
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "[NAMELESS] " .. tostring(text),
            Color = Color3.fromRGB(120, 220, 160),
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
        })
    end)
end

-- Controller-only username ESP for bots in BotList
BotEspFolder = nil
local BotEspConns = {}
function F.ClearBotEsp()
    for _, c in pairs(BotEspConns) do pcall(function() c:Disconnect() end) end
    BotEspConns = {}
    if BotEspFolder then pcall(function() BotEspFolder:Destroy() end) BotEspFolder = nil end
end
function F.MakeBotEsp(plr)
    if not BotEspEnabled then return end
    if not F.IsControllerClient() then return end
    if not plr or plr == LocalPlayer then return end
    if not F.IsListedBot(plr.Name) then return end
    if not BotEspFolder then
        local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pg then return end
        BotEspFolder = Instance.new("Folder")
        BotEspFolder.Name = "NAMELESS_BOT_ESP"
        BotEspFolder.Parent = pg
    end
    local existing = BotEspFolder:FindFirstChild("esp_" .. plr.Name)
    if existing then existing:Destroy() end
    if BotEspConns[plr.Name .. "_hb"] then
        pcall(function() BotEspConns[plr.Name .. "_hb"]:Disconnect() end)
        BotEspConns[plr.Name .. "_hb"] = nil
    end
    local function attach(char)
        if not char or not BotEspEnabled then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        local old = BotEspFolder:FindFirstChild("esp_" .. plr.Name)
        if old then old:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "esp_" .. plr.Name
        bb.Adornee = head
        bb.Size = UDim2.new(0, 200, 0, 54)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = BotEspFolder
        local lab = Instance.new("TextLabel")
        lab.Name = "Lab"
        lab.Size = UDim2.new(1, 0, 1, 0)
        lab.BackgroundTransparency = 1
        lab.Font = Enum.Font.GothamBold
        lab.TextSize = 12
        lab.TextColor3 = Color3.fromRGB(80, 255, 140)
        lab.TextStrokeTransparency = 0.35
        lab.TextYAlignment = Enum.TextYAlignment.Top
        lab.Text = plr.Name
        lab.Parent = bb
        if BotEspConns[plr.Name .. "_hb"] then
            pcall(function() BotEspConns[plr.Name .. "_hb"]:Disconnect() end)
        end
        BotEspConns[plr.Name .. "_hb"] = RunService.Heartbeat:Connect(function()
            if not BotEspEnabled or not lab.Parent then return end
            local c = plr.Character
            if not c then
                lab.Text = plr.Name .. "\n[no char]"
                return
            end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local tool = c:FindFirstChildOfClass("Tool")
            local hp = hum and math.floor(hum.Health + 0.5) or 0
            local max = hum and math.floor(hum.MaxHealth + 0.5) or 100
            local toolName = tool and tool.Name or "none"
            lab.Text = string.format("%s\nHP %d/%d\n%s", plr.Name, hp, max, toolName)
            local h = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if h and bb.Adornee ~= h then bb.Adornee = h end
        end)
    end
    if plr.Character then attach(plr.Character) end
    if BotEspConns[plr.Name] then pcall(function() BotEspConns[plr.Name]:Disconnect() end) end
    BotEspConns[plr.Name] = plr.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        attach(c)
    end)
end
function F.RefreshBotEsp()
    if not F.IsControllerClient() then F.ClearBotEsp() return end
    if not BotEspEnabled then F.ClearBotEsp() return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if F.IsListedBot(plr.Name) then F.MakeBotEsp(plr) end
    end
end
function F.OnBotJoined(plr)
    if not plr or plr == LocalPlayer then return end
    if not F.IsListedBot(plr.Name) then return end
    if F.IsControllerClient() then
        F.Notify("Bot joined: " .. plr.Name)
        F.MakeBotEsp(plr)
    end
end


function F.DestroyBotGui()
    if BotGui then pcall(function() BotGui:Destroy() end) BotGui = nil end
    MenuOpen = false
end


-- NeverLarp-style FakePos: keep a frozen server-side position while client moves
function F.SetFakePos(on)
    getgenv().FakePosToggleEnabled = on and true or false
    if getgenv()._FakePosConn then
        pcall(function() getgenv()._FakePosConn:Disconnect() end)
        getgenv()._FakePosConn = nil
    end
    if not on then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then getgenv().FakePosServerPos = hrp.Position end
    getgenv()._FakePosConn = RunService.Heartbeat:Connect(function()
        if not getgenv().FakePosToggleEnabled then return end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        if not getgenv().FakePosServerPos then
            getgenv().FakePosServerPos = r.Position
            return
        end
        -- NeverLarp-style: hold server pos snapshot on respawn; pulse old CF
        local real = r.CFrame
        pcall(function()
            r.CFrame = CFrame.new(getgenv().FakePosServerPos)
        end)
        RunService.RenderStepped:Wait()
        pcall(function()
            r.CFrame = real
        end)
    end)
end

-- Network desync (FFlags + bandwidth starvation, NeverLarp-like)
function F.SetNetDesync(on)
    getgenv().PhysicsRepDesyncEnabled = on and true or false
    pcall(function()
        if setfflag then
            if on then
                setfflag("GameNetCompressionLodByteBudgetThresholdPct", "0")
                setfflag("PhysicsSenderMaxBandwidthBps", "0")
                setfflag("NextGenReplicatorEnabledWrite4", "1")
            else
                setfflag("GameNetCompressionLodByteBudgetThresholdPct", "1")
                setfflag("PhysicsSenderMaxBandwidthBps", "1000")
                setfflag("NextGenReplicatorEnabledWrite4", "1")
            end
        end
    end)
    if getgenv()._NetDesyncConn then
        pcall(function() getgenv()._NetDesyncConn:Disconnect() end)
        getgenv()._NetDesyncConn = nil
    end
    if not on then return end
    getgenv()._NetDesyncConn = RunService.Heartbeat:Connect(function()
        if not getgenv().PhysicsRepDesyncEnabled then return end
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not r then return end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(r, "NetworkIsSleeping", true)
            end
        end)
    end)
end

function F.StartVoidSpam()
    if getgenv()._VoidSpamConn then return end
    getgenv()._VoidSpamConn = true
    task.spawn(function()
        local DS = getgenv().NamelessDesync or {}
        while getgenv()._VoidSpamConn do
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local origin = r.CFrame
                local dist = DS.VoidDist or 200
                local goal = origin + Vector3.new(0, -dist, 0)
                local speed = 1000
                local t0 = tick()
                while tick() - t0 < (DS.VoidIn or 0.15) and getgenv()._VoidSpamConn do
                    local alpha = math.min(1, (tick() - t0) / math.max(0.01, (DS.VoidIn or 0.15)))
                    pcall(function() r.CFrame = origin:Lerp(CFrame.new(goal), alpha) end)
                    RunService.Heartbeat:Wait()
                end
                t0 = tick()
                while tick() - t0 < (DS.VoidOut or 0.1) and getgenv()._VoidSpamConn do
                    local alpha = math.min(1, (tick() - t0) / math.max(0.01, (DS.VoidOut or 0.1)))
                    pcall(function() r.CFrame = CFrame.new(goal):Lerp(origin, alpha) end)
                    RunService.Heartbeat:Wait()
                end
            else
                task.wait(0.1)
            end
        end
    end)
end

function F.StopVoidSpam()
    getgenv()._VoidSpamConn = nil
end

function F.ApplyVisuals()
    local VS = getgenv().NamelessVisual or {}
    local Lighting = game:GetService("Lighting")
    pcall(function()
        if VS.Fullbright then
            Lighting.Brightness = VS.Brightness or 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        end
        if VS.NoFog then
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 0
        end
        if VS.NoShadows then
            Lighting.GlobalShadows = false
        end
    end)
    if VS.MuteAll then
        pcall(function()
            for _, s in ipairs(game:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0 end
            end
        end)
    end
    if VS.NoParticles then
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("ParticleEmitter") or s:IsA("Trail") or s:IsA("Beam") then
                    s.Enabled = false
                end
            end
        end)
    end
    if VS.GreyCharacters then
        pcall(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                local c = plr.Character
                if c then
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Color = Color3.fromRGB(140, 140, 140)
                            p.Material = Enum.Material.SmoothPlastic
                        elseif p:IsA("Decal") or p:IsA("Clothing") or p:IsA("Shirt") or p:IsA("Pants") then
                            p:Destroy()
                        end
                    end
                end
            end
        end)
    end
end

function F.CreateNamelessGui()
    if not (F.IsControllerClient and F.IsControllerClient()) then return end
    F.DestroyBotGui()
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local ACCENT = Color3.fromRGB(220, 35, 35)
    local BG = Color3.fromRGB(16, 16, 20)
    local PANEL = Color3.fromRGB(28, 28, 34)
    local TEXT = Color3.fromRGB(230, 230, 235)

    -- state
    getgenv().NamelessDesync = getgenv().NamelessDesync or {
        VoidSpam = false,
        VoidSpamKey = Enum.KeyCode.V,
        FakePos = false,
        FakePosKey = Enum.KeyCode.F,
        NetDesync = false,
        NetDesyncKey = Enum.KeyCode.N,
        VoidIn = 0.15,
        VoidOut = 0.10,
        VoidDist = 200,
    }
    local DS = getgenv().NamelessDesync
    getgenv().NamelessVisual = getgenv().NamelessVisual or {
        Fullbright = false,
        NoFog = false,
        NoShadows = false,
        MuteAll = false,
        NoParticles = false,
        GreyCharacters = false,
        Brightness = 2,
    }
    local VS = getgenv().NamelessVisual

    BotGui = Instance.new("ScreenGui")
    BotGui.Name = "Nameless.HVH"
    BotGui.ResetOnSpawn = false
    BotGui.IgnoreGuiInset = true
    BotGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BotGui.Parent = pg

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 560, 0, 480)
    win.Position = UDim2.new(0, 12, 0.5, -240)
    win.BackgroundColor3 = BG
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.Parent = BotGui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", win)
    stroke.Color = ACCENT
    stroke.Thickness = 1.2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = ACCENT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Nameless.HVH"
    title.Parent = win

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -16, 0, 28)
    tabBar.Position = UDim2.new(0, 8, 0, 32)
    tabBar.BackgroundColor3 = PANEL
    tabBar.BorderSizePixel = 0
    tabBar.Parent = win
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 4)
    local tabLay = Instance.new("UIListLayout", tabBar)
    tabLay.FillDirection = Enum.FillDirection.Horizontal
    tabLay.Padding = UDim.new(0, 4)
    tabLay.VerticalAlignment = Enum.VerticalAlignment.Center

    local pages = {}
    local function makePage(name)
        local sc = Instance.new("ScrollingFrame")
        sc.Name = name
        sc.Size = UDim2.new(1, -16, 1, -72)
        sc.Position = UDim2.new(0, 8, 0, 66)
        sc.BackgroundColor3 = PANEL
        sc.BorderSizePixel = 0
        sc.ScrollBarThickness = 4
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.Visible = false
        sc.Parent = win
        Instance.new("UICorner", sc).CornerRadius = UDim.new(0, 6)
        local lay = Instance.new("UIListLayout", sc)
        lay.Padding = UDim.new(0, 4)
        local pad = Instance.new("UIPadding", sc)
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pages[name] = sc
        return sc
    end

    local function openTab(name)
        for n, pg in pairs(pages) do pg.Visible = (n == name) end
        for _, b in ipairs(tabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b.Name == name) and ACCENT or Color3.fromRGB(40, 40, 48)
            end
        end
    end

    local function addTab(name)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0, 100, 1, -6)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = TEXT
        b.Text = name
        b.Parent = tabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function() openTab(name) end)
        makePage(name)
    end

    local function addLabel(parent, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = ACCENT
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.Parent = parent
    end

    local function addBtn(parent, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = TEXT
        b.Text = text
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local function addBox(parent, placeholder)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 26)
        box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextColor3 = TEXT
        box.PlaceholderText = placeholder or "username"
        box.Text = ""
        box.ClearTextOnFocus = false
        box.Parent = parent
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        return box
    end

    local function addToggle(parent, label, get, set)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -40, 1, 0)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        t.TextColor3 = TEXT
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = label
        t.Parent = row
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 16)
        b.Position = UDim2.new(1, -32, 0.5, -8)
        b.Text = ""
        b.BackgroundColor3 = get() and ACCENT or Color3.fromRGB(50, 50, 58)
        b.BorderSizePixel = 0
        b.Parent = row
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        b.MouseButton1Click:Connect(function()
            set(not get())
            b.BackgroundColor3 = get() and ACCENT or Color3.fromRGB(50, 50, 58)
        end)
        return b
    end

    local function addKeyBtn(parent, label, getKey, setKey)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = TEXT
        local function refresh()
            local k = getKey()
            b.Text = label .. ": " .. (typeof(k) == "EnumItem" and k.Name or tostring(k))
        end
        refresh()
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            b.Text = label .. ": press key..."
            local c
            c = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    setKey(input.KeyCode)
                    refresh()
                    c:Disconnect()
                end
            end)
        end)
        return b
    end

    local function runCmd(line)
        if F.ChatCommand then F.ChatCommand(line) end
        if SyncBotsEnabled and F.RunSilent then F.RunSilent(line) end
    end

    -- Tab order: Main, Ragebot, Desync, Visual, Commands
    for _, n in ipairs({"Main", "Ragebot", "Desync", "Visual", "Commands"}) do
        addTab(n)
    end

    local main, rage, desync, visual, cmd = pages.Main, pages.Ragebot, pages.Desync, pages.Visual, pages.Commands

    -- MAIN
    addLabel(main, "forcehit")
    addToggle(main, "forcehit fov", function() return ForceHitFOVEnabled end, function(v) ForceHitFOVEnabled = v end)
    addToggle(main, "stomp-target", function() return StompSelectedTarget end, function(v)
        StompSelectedTarget = v
        ForceHitStompTarget = ForceHitKeybindTarget or ForceHitCmdTarget
    end)
    addBtn(main, "clear forcehit target", function()
        ForceHitKeybindTarget = nil
        ForceHitCmdTarget = nil
    end)
    addLabel(main, "toggles")
    addToggle(main, "opt mode", function() return OptMode end, function(v) if F.SetOptMode then F.SetOptMode(v) end end)
    addToggle(main, "rapid fire", function() return RapidFireEnabled end, function(v) RapidFireEnabled = v end)
    addToggle(main, "spinbot", function() return SpinbotEnabled end, function(v) SpinbotEnabled = v end)
    addToggle(main, "killaura", function() return KillAuraEnabled end, function(v)
        if v and F.StartKillAura then F.StartKillAura() elseif F.StopKillAura then F.StopKillAura() end
    end)
    addToggle(main, "sync bots", function() return SyncBotsEnabled end, function(v) SyncBotsEnabled = v end)

    -- RAGEBOT (controller local — no chat)
    addLabel(rage, "controller kill (you — silent)")
    local rageBox = addBox(rage, "target username")
    addBtn(rage, "autokill (controller)", function()
        local x = rageBox.Text
        if x == "" then return end
        if F.ControllerKill then F.ControllerKill(x, true) end
    end)
    addBtn(rage, "kill (controller)", function()
        local x = rageBox.Text
        if x == "" then return end
        if F.ControllerKill then F.ControllerKill(x, false) end
    end)
    addBtn(rage, "stop (controller)", function()
        CurrentAction = "idle"
        TargetPlayer = nil
        getgenv()._CTRL_KILL_GEN = (getgenv()._CTRL_KILL_GEN or 0) + 1
        if F.StopAll then pcall(F.StopAll) end
    end)
    addLabel(rage, "whitelist")
    local wlBox = addBox(rage, "whitelist username")
    addBtn(rage, "whitelist", function()
        local n = wlBox.Text
        if n == "" then return end
        if F.addWhitelistName then F.addWhitelistName(n) end
    end)
    addBtn(rage, "unwhitelist", function()
        local n = wlBox.Text
        if n == "" then return end
        if F.removeWhitelistName then F.removeWhitelistName(n) end
    end)

    -- DESYNC
    addLabel(desync, "void spam")
    addToggle(desync, "void spam", function() return DS.VoidSpam end, function(v)
        DS.VoidSpam = v
        if v then
            if F.StartVoidSpam then F.StartVoidSpam() end
        else
            if F.StopVoidSpam then F.StopVoidSpam() end
        end
    end)
    addKeyBtn(desync, "voidspam key", function() return DS.VoidSpamKey end, function(k) DS.VoidSpamKey = k end)
    addLabel(desync, "fake pos (neverlarp-style)")
    addToggle(desync, "fake pos", function() return DS.FakePos end, function(v)
        DS.FakePos = v
        if F.SetFakePos then F.SetFakePos(v) end
    end)
    addKeyBtn(desync, "fakepos key", function() return DS.FakePosKey end, function(k) DS.FakePosKey = k end)
    addLabel(desync, "network desync")
    addToggle(desync, "network desync", function() return DS.NetDesync end, function(v)
        DS.NetDesync = v
        if F.SetNetDesync then F.SetNetDesync(v) end
    end)
    addKeyBtn(desync, "netdesync key", function() return DS.NetDesyncKey end, function(k) DS.NetDesyncKey = k end)

    -- VISUAL
    addLabel(visual, "visual & audio")
    addToggle(visual, "fullbright", function() return VS.Fullbright end, function(v)
        VS.Fullbright = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)
    addToggle(visual, "no fog", function() return VS.NoFog end, function(v)
        VS.NoFog = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)
    addToggle(visual, "no shadows", function() return VS.NoShadows end, function(v)
        VS.NoShadows = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)
    addToggle(visual, "mute all sounds", function() return VS.MuteAll end, function(v)
        VS.MuteAll = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)
    addToggle(visual, "no particles", function() return VS.NoParticles end, function(v)
        VS.NoParticles = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)
    addToggle(visual, "grey characters", function() return VS.GreyCharacters end, function(v)
        VS.GreyCharacters = v
        if F.ApplyVisuals then F.ApplyVisuals() end
    end)

    -- COMMANDS (bots via chat)
    addLabel(cmd, "bot commands")
    local cmdBox = addBox(cmd, "target username")
    addBtn(cmd, "autokill", function() if cmdBox.Text ~= "" then runCmd("autokill " .. cmdBox.Text) end end)
    addBtn(cmd, "kill", function() if cmdBox.Text ~= "" then runCmd("kill " .. cmdBox.Text) end end)
    addBtn(cmd, "stop", function() runCmd("stop") end)
    addBtn(cmd, "forcehit once", function() if cmdBox.Text ~= "" then runCmd("forcehit " .. cmdBox.Text) end end)
    addBtn(cmd, "forcehit2 loop", function() if cmdBox.Text ~= "" then runCmd("forcehit2 " .. cmdBox.Text) end end)
    addLabel(cmd, "formations")
    for _, cname in ipairs({"summon", "return", "around", "back", "bline", "pole", "line", "orbit", "safe", "teleport"}) do
        addBtn(cmd, cname, function() runCmd(cname) end)
    end
    addLabel(cmd, "combat")
    for _, cname in ipairs({"gun", "knife", "ka", "ka off", "gsk", "ksk", "rapid on", "rapid off", "db", "uzi", "rev"}) do
        addBtn(cmd, cname, function() runCmd(cname) end)
    end

    -- keybinds for desync
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == DS.VoidSpamKey then
            DS.VoidSpam = not DS.VoidSpam
            if DS.VoidSpam and F.StartVoidSpam then F.StartVoidSpam()
            elseif F.StopVoidSpam then F.StopVoidSpam() end
        elseif input.KeyCode == DS.FakePosKey then
            DS.FakePos = not DS.FakePos
            if F.SetFakePos then F.SetFakePos(DS.FakePos) end
        elseif input.KeyCode == DS.NetDesyncKey then
            DS.NetDesync = not DS.NetDesync
            if F.SetNetDesync then F.SetNetDesync(DS.NetDesync) end
        end
    end)

    openTab("Main")
    MenuOpen = true
end

function F.ToggleLoadGui()
    if BotGui and MenuOpen then
        F.DestroyBotGui()
    else
        local ok, err = pcall(F.CreateNamelessGui)
        if not ok then
            warn("[NAMELESS] GUI failed: " .. tostring(err))
        end
    end
end

-- Client-sided Joao Chiken look (only this client's view)
function F.ApplyChickenClient(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    task.spawn(function()
        task.wait(0.4)
        if not char.Parent then return end
        pcall(function()
            local AssetService = game:GetService("AssetService")
            if AssetService and AssetService.GetBundleDetailsAsync then
                local details = AssetService:GetBundleDetailsAsync(CHICKEN_BUNDLE_ID)
                if details and details.Items then
                    local desc = hum:GetAppliedDescription()
                    for _, item in ipairs(details.Items) do
                        local id = tonumber(item.Id or item.id)
                        local typ = tostring(item.Type or item.type or item.Name or ""):lower()
                        if id then
                            if typ:find("leftarm") then desc.LeftArm = id
                            elseif typ:find("rightarm") then desc.RightArm = id
                            elseif typ:find("leftleg") then desc.LeftLeg = id
                            elseif typ:find("rightleg") then desc.RightLeg = id
                            elseif typ:find("torso") then desc.Torso = id
                            elseif typ:find("head") or typ:find("dynamic") then desc.Head = id
                            end
                        end
                    end
                    desc.HatAccessory = ""
                    desc.HairAccessory = ""
                    desc.FaceAccessory = ""
                    pcall(function() hum:ApplyDescription(desc) end)
                end
            end
        end)
        pcall(function()
            local InsertService = game:GetService("InsertService")
            if InsertService and InsertService.LoadAsset then
                local model = InsertService:LoadAsset(CHICKEN_BUNDLE_ID)
                if model then
                    for _, obj in ipairs(model:GetDescendants()) do
                        if obj:IsA("CharacterMesh") or obj:IsA("SpecialMesh") then
                            pcall(function() obj:Clone().Parent = char end)
                        end
                    end
                    model:Destroy()
                end
            end
        end)
        local chicken = Color3.fromRGB(255, 214, 90)
        local white = Color3.fromRGB(255, 255, 255)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function()
                    part.LocalTransparencyModifier = 0
                    local n = part.Name:lower()
                    part.Color = n:find("head") and white or chicken
                    if part:IsA("MeshPart") then part.TextureID = "" end
                end)
            elseif part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") then
                pcall(function() part:Destroy() end)
            elseif part:IsA("BodyColors") then
                pcall(function()
                    part.HeadColor3 = white
                    part.TorsoColor3 = chicken
                    part.LeftArmColor3 = chicken
                    part.RightArmColor3 = chicken
                    part.LeftLegColor3 = chicken
                    part.RightLegColor3 = chicken
                end)
            end
        end
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") or acc:IsA("Hat") then
                pcall(function() acc:Destroy() end)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    F.refreshChar(char)
    F.StopGlue()
    F.StopCameraLock()
    F.StopSlotSpam()
    F.stopFlyAnims()
    F.HookKO(char) -- antistomp for stands + controller
    if F.IsControllerClient and F.IsControllerClient() then
        pcall(function()
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        end)
        return -- no chicken / stand emotes on controller
    end
    task.defer(function() F.ApplyChickenClient(char) end)
    DancePersistent = true
    if not LastDanceId then LastDanceId = DefaultEmoteId end
    task.delay(0.4, function() F.EnsureDancePlaying() end)
    if PendingAutokill and SavedKillTargets then
        task.delay(0.55, function()
            if PendingAutokill and SavedKillTargets then F.StartKill(SavedKillTargets, true) end
        end)
    elseif AutoSummonAfterReset or F.CanSummon() then
        AutoSummonAfterReset = false
        task.delay(0.6, function()
            if F.CanSummon() and not FrozenByPrivilege then
                F.StartFollow()
            end
        end)
    end
end)
-- Apply once on current character
if LocalPlayer.Character and not (F.IsControllerClient and F.IsControllerClient()) then
    task.defer(function() F.ApplyChickenClient(LocalPlayer.Character) end)
end
-- Client view of marked bots
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if BotList[p.Name:lower()] then
            task.defer(function() F.ApplyChickenClient(char) end)
        end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            if BotList[p.Name:lower()] then
                task.defer(function() F.ApplyChickenClient(char) end)
            end
        end)
    end
end

F.StartFollow = function()
    if FrozenByPrivilege then return end
    if not F.CanSummon() then return end
    local ctrl = F.GetController()
    if not ctrl then return end
    local keepA, keepT = PendingAutokill, SavedKillTargets
    F.StopAll()
    PendingAutokill, SavedKillTargets = keepA, keepT
    CurrentAction = "follow"
    F.StartGlue("follow", ctrl)
    F.loadFlyAnims()
    F.updateFlyAnim()
end

function F.StartControllerOrbit(mode)
    if FrozenByPrivilege then return end
    if not F.CanSummon() then return end
    F.StopAll()
    CtrlOrbitMode = tonumber(mode) or 1
    CurrentAction = "formation"
    FormationType = "corbit"
    FormationTarget = F.GetController()
    F.StartGlue("formation", FormationTarget)
    F.loadFlyAnims()
end

function F.StartFormation(ft, name)
    if FrozenByPrivilege then return end
    if not name and not F.CanSummon() then return end
    local t = name and F.FindPlayer(name) or F.GetController()
    if not t then return end
    PendingAutokill, SavedKillTargets = nil, nil
    F.StopAll()
    CurrentAction = "formation"
    FormationType, FormationTarget = ft, t
    F.StartGlue("formation", t)
    F.loadFlyAnims()
end

F.StartKill = function(targets, isAuto)
    if FrozenByPrivilege then return end
    if typeof(targets) ~= "table" then targets = { targets } end
    -- Filter whitelist / bots / controller
    local filtered = {}
    for _, t in ipairs(targets) do
        if t and not F.isWhitelisted(t) then filtered[#filtered + 1] = t end
    end
    targets = filtered
    if #targets == 0 then return end
    F.StopAll()
    TargetList, TargetPlayer = targets, targets[1]
    CurrentAction = isAuto and "autokill" or "kill"
    KillPhase, StompDoneForCycle = "attack", false
    FastKillPhase, FastKillFrontCF, FastKillTweening = "behind", nil, false
    FastKillTweenFrom = nil
    if isAuto then PendingAutokill, SavedKillTargets = true, targets else PendingAutokill, SavedKillTargets = nil, nil end
    -- Always run glue loop with PhysicsRep so controller sees the bot
    F.StartGlue(UseGun and "gun" or "knife", TargetPlayer)
    do
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
        SpamVoidPhase = "surface"
        if F.GetKillMethod() == "tween" then
            task.spawn(F.FastKillClearWorldObstacles)
        end
    end
    F.StartCameraLock(TargetPlayer)
    F.StopSlotSpam()
    -- equip first gun once at kill start
    if UseGun then F.EquipBestWeapon() end
    F.StartKillAttackLoop()
    task.spawn(function()
        while CurrentAction == "kill" or CurrentAction == "autokill" do
            local t = TargetPlayer
            if not F.inGame(t) then
                PendingAutokill, SavedKillTargets = nil, nil
                F.StopKillAttackLoop()
                if not F.IsSelfControlled() then F.StartFollow() else F.StopAll() end
                break
            end
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not myHum or myHum.Health <= 0 then
                F.StopKillAttackLoop()
                break
            end
            F.EnsureDancePlaying()
            local tChar = t.Character
            local hum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local ko = tChar and F.isKnocked(tChar)
            local dead = hum and hum.Health <= 0
            if KillPhase == "attack" then
                -- combat is driven by F.StartKillAttackLoop(Heartbeat)
                if not tChar or ko or dead then
                    pcall(function()
                        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h then h:UnequipTools() end
                    end)
                    F.StopKillAttackLoop()
                    F.StopCameraLock()
                    F.StopSlotSpam()
                    F.ForceGlueOff()
                    KillPhase = "stomp"
                    StompDoneForCycle = false
                    WaitFFUntil = nil
                    F.SayKillChat()
                end
            elseif KillPhase == "stomp" then
                if not StompDoneForCycle then F.DoSingleStomp(t) StompDoneForCycle = true end
                if F.IsSelfControlled() then
                    if isAuto then KillPhase = "waitff"
                    else PendingAutokill, SavedKillTargets = nil, nil F.StopAll() break end
                else KillPhase = "summon" end
            elseif KillPhase == "summon" then
                F.StopKillAttackLoop()
                F.StopCameraLock()
                F.StopSlotSpam()
                F.StartFollow()
                CurrentAction = isAuto and "autokill" or "kill"
                task.wait(SummonHold)
                if not isAuto then
                    PendingAutokill, SavedKillTargets = nil, nil
                    CurrentAction = "follow"
                    break
                end
                KillPhase = "waitff"
            elseif KillPhase == "waitff" then
                if not F.inGame(t) then
                    PendingAutokill, SavedKillTargets = nil, nil
                    if not F.IsSelfControlled() then F.StartFollow() else F.StopAll() end
                    break
                end
                -- sit in void while waiting forcefield / respawn
                do
                    local r = getgenv().get_root_part()
                    if r then
                        pcall(function() F.GoToVoid(r, r.CFrame) end)
                    end
                end
                local char = t.Character
                local ff = char and char:FindFirstChildOfClass("ForceField")
                local alive = F.isFullyAlive(t)
                if alive and not ff then
                    -- resume as soon as forcefield is gone (no timed wait)
                    WaitFFUntil = nil
                    StompDoneForCycle = false
                    KillPhase = "attack"
                    FastKillPhase, FastKillFrontCF, FastKillTweening, FastKillTweenFrom = "behind", nil, false, nil
                    FastKillLastStep = 0
                    SpamVoidPhase = "surface"
                    F.StartGlue(UseGun and "gun" or "knife", t)
                    F.StartCameraLock(t)
                    F.StopSlotSpam()
                    CurrentAction = "autokill"
                    F.StartKillAttackLoop()
                else
                    -- still dead or forcefield present: do not shoot
                    WaitFFUntil = nil
                    task.wait(0.05)
                end
            end
            task.wait(KillPhase == "attack" and 0.05 or 0.08)
        end
        F.StopKillAttackLoop()
        F.StopCameraLock()
        F.StopSlotSpam()
    end)
end

function F.StartBring(targets)
    if FrozenByPrivilege then return end
    local target = typeof(targets) == "table" and targets[1] or targets
    if not target then return end
    PendingAutokill, SavedKillTargets = nil, nil
    F.StopAll()
    CurrentAction, TargetPlayer, BringStage, GrabOnceDone = "bring", target, "kill", false
    F.StartGlue(UseGun and "gun" or "knife", target)
    if UseGun then F.StartCameraLock(target) end
    task.spawn(function()
        while CurrentAction == "bring" do
            if not F.inGame(TargetPlayer) then
                if not F.IsSelfControlled() then F.StartFollow() else F.StopAll() end
                break
            end
            local tChar = TargetPlayer.Character
            if BringStage == "kill" then
                if tChar and (F.isKnocked(tChar) or (tChar:FindFirstChildOfClass("Humanoid") and tChar.Humanoid.Health <= 0)) then
                    F.StopCameraLock()
                    F.StopSlotSpam()
                    F.StopGlue()
                    pcall(function()
                        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h then h:UnequipTools() end
                    end)
                    if (MySlot or 1) ~= 1 then CurrentAction = "idle" break end
                    BringStage = "tween"
                else
                    local tool = F.EquipBestWeapon()
                    if tool then
                        if not UseGun or tool.Name:lower():find("knife") then
                            F.applyKnifeHitbox()
                            pcall(function() tool:Activate() end)
                        else
                            if not CameraConnection then F.StartCameraLock(TargetPlayer) end
                            pcall(function() tool:Activate() end)
                            F.forceHitTick(TargetPlayer)
                        end
                    end
                end
            elseif BringStage == "tween" then
                local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local r = getgenv().get_root_part()
                if thrp and r then
                    local goal = thrp.Position + Vector3.new(0, 2.2, 0)
                    local spd = BringMoveSpeed or 80
                    while CurrentAction == "bring" and (r.Position - goal).Magnitude > (BringArriveDist or 4) do
                        thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        r = getgenv().get_root_part()
                        if not thrp or not r then break end
                        goal = thrp.Position + Vector3.new(0, 2.2, 0)
                        local dt = task.wait()
                        local dir = goal - r.Position
                        local step = math.min(spd * dt, dir.Magnitude)
                        if step > 0.05 then
                            r.CanCollide = false
                            r.AssemblyLinearVelocity = Vector3.zero
                            r.CFrame = CFrame.new(r.Position + dir.Unit * step)
                        else
                            break
                        end
                    end
                    if r and thrp then r.CFrame = CFrame.new(thrp.Position + Vector3.new(0, 2.2, 0)) end
                end
                if CurrentAction ~= "bring" then break end
                BringStage = "grab"
            elseif BringStage == "grab" then
                local thrp = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local r = getgenv().get_root_part()
                if thrp and r then r.CFrame = CFrame.new(thrp.Position + Vector3.new(0, 2.2, 0)) end
                F.TryGrabOnce()
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
                if not F.IsSelfControlled() then F.StartFollow() else F.StopAll() end
                break
            end
            task.wait(0.04)
        end
        F.StopCameraLock()
        F.StopSlotSpam()
    end)
end

function F.ParsePrefix(msg)
    local lower = (msg or ""):lower():gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
    -- NAMELESS.HVH | !command  (spaces optional around |)
    local a, b = lower:find("nameless%.hvh%s*|%s*!")
    if a == 1 then
        -- map back onto original length roughly via lower index
        return lower:sub(b + 1):match("^%s*(.-)%s*$")
    end
    if lower:sub(1, 14) == "nameless.hvh|!" then
        return lower:sub(15):match("^%s*(.-)%s*$")
    end
    if lower:sub(1, 15) == "nameless.hvh |!" then
        return lower:sub(16):match("^%s*(.-)%s*$")
    end
    -- legacy
    if lower:sub(1, 11) == "nameless:!" or lower:sub(1, 10) == "nameless:!" then
        return lower:sub(11):match("^%s*(.-)%s*$") or lower:sub(12):match("^%s*(.-)%s*$")
    end
    if lower:sub(1, 9) == "nameless:" then
        local rest = lower:sub(10)
        if rest:sub(1,1) == "!" then rest = rest:sub(2) end
        return rest:match("^%s*(.-)%s*$")
    end
    if lower:sub(1,1) == "!" then
        return lower:sub(2):match("^%s*(.-)%s*$")
    end
    return nil
end

F.OnChatted = function(player, message)
    message = message:gsub("%s+", " "):match("^%s*(.-)%s*$") or message
    local raw = message:lower()
    if player == LocalPlayer and (raw == "!load" or raw == "load" or raw:find("nameless") and raw:find("load")) then
        if F.IsControllerClient() then F.ToggleLoadGui() end
        return
    end
    local body = F.ParsePrefix(message)
    if not body then return end
    local args = {}
    for w in body:gmatch("%S+") do args[#args+1] = w:lower() end
    local cmd = args[1]
    if not cmd then return end
    local fromGui = (player == LocalPlayer and getgenv()._StandGuiSilent == true)
    -- Controller never runs bot actions unless SyncBotsEnabled
    if F.IsControllerClient() then
        if cmd == "load" and player == LocalPlayer then F.ToggleLoadGui() return end
        if not SyncBotsEnabled and not fromGui then return end
        if not SyncBotsEnabled and fromGui then return end
        -- if sync on, fall through and execute like a stand
    end
    -- Stand clients only obey controller / owners
    if F.IsStandClient() and not fromGui and not F.IsOwner(player) and not F.IsPrivileged(player) then
        return
    end
    if cmd == "load" then
        if player == LocalPlayer and F.IsControllerClient() then F.ToggleLoadGui() end
        return
    end
    if cmd == "slot" and args[2] then
        local n = tonumber(args[2])
        if n and n >= 1 and (F.IsOwner(player) or player == LocalPlayer or fromGui) then MySlot = math.floor(n) end
    elseif cmd == "rows" and args[2] then
        local n = tonumber(args[2])
        if n and n >= 1 and (F.IsOwner(player) or player == LocalPlayer or fromGui) then FormationRows = math.floor(n) end
    elseif cmd == "perrow" and args[2] then
        local n = tonumber(args[2])
        if n and n >= 1 and (F.IsOwner(player) or player == LocalPlayer or fromGui) then FormationPerRow = math.floor(n) end
        return
    end
    if cmd == "controller" then
        if not (F.IsOwner(player) or player == LocalPlayer or fromGui or not ControllerName) then return end
        ShowBotsTab = true
        if not ControllerName then ControllerName = player.Name end
pcall(function()
            F.DestroyBotGui()
            F.CreateNamelessGui()
        end)
        return
    end
    -- Original controller only: whitelist / unwhitelist (killaura + targeting)
    if cmd == "whitelist" or cmd == "wl" then
        if not F.IsOriginalController(player) and not fromGui then return end
        if not args[2] or args[2] == "list" then
            local list = F.ListWhitelistNames()
return
        end
        local t = F.FindPlayerAny(args[2])
        local name = t and t.Name or args[2]
        if F.isProtectedWhitelistName(name) then
return
        end
        F.addWhitelistName(name)
return
    end
    if cmd == "unwhitelist" or cmd == "unwl" then
        if not F.IsOriginalController(player) and not fromGui then return end
        if not args[2] then return end
        local t = F.FindPlayerAny(args[2])
        local name = t and t.Name or args[2]
        local ok, reason = F.removeWhitelistName(name)
        return
    end
    -- Transfer ownership (current owner) / reclaim (original only)
    if cmd == "transfer" and args[2] then
        local can = F.IsOwner(player) or F.IsSuperOwner(player) or F.IsOriginalController(player) or fromGui
        if not can then return end
        if args[2] == "me" or args[2] == "self" then
            -- only original can reclaim this way unless already owner
            if F.IsOriginalController(player) or F.IsOwner(player) then
                ControllerName = player.Name
                ExtraOwners = {}
                FrozenByPrivilege = false
end
            return
        end
        if args[2] == "reclaim" or args[2] == "revert" or args[2] == "back" then
            if not F.IsOriginalController(player) then
return
            end
            ControllerName = OriginalControllerName or player.Name
            ExtraOwners = {}
            FrozenByPrivilege = false
return
        end
        local t = F.FindPlayerAny(args[2])
        local newName = t and t.Name or args[2]
        -- Remember original if not set
        if not OriginalControllerName or OriginalControllerName == "" then
            OriginalControllerName = ControllerName or player.Name
        end
        ControllerName = newName
        FrozenByPrivilege = false
return
    end
    if cmd == "reclaim" or cmd == "revert" then
        if not F.IsOriginalController(player) then return end
        ControllerName = OriginalControllerName or player.Name
        ExtraOwners = {}
        FrozenByPrivilege = false
return
    end
    if F.IsPrivileged(player) then
        if cmd == "freeze" then F.StopAll() FrozenByPrivilege = true local r=getgenv().get_root_part() if r then r.Anchored=true end return end
        if cmd == "kick" then pcall(function() LocalPlayer:Kick("kicked") end) return end
        if cmd == "steal" or cmd == "take" then ControllerName=player.Name ExtraOwners={} FrozenByPrivilege=false F.StopAll() return end
        if cmd == "reset" or cmd == "r" then F.ForceReset() return end
    end
    if not F.IsOwner(player) and not fromGui then return end
    F.EnsureController(player)
    if FrozenByPrivilege then return end
    local function withBots(i, fn)
        local targets, should = F.ParseTargetsAndBots(args, i)
        if should then fn(targets) end
    end
    
        if cmd == "unforcehit" or cmd == "ufh" then
        ForceHitCmdTarget = nil
        ForceHit1Active = false
        ForceHit2Active = false
        return
    end
    if cmd == "forcehit" or cmd == "fh" then
        -- ONCE: follow 7 studs behind, DB, shoot, stomp, return to owner
        local name = args[2]
        if not name then
            ForceHitCmdTarget = nil
            ForceHit1Active = false
            return
        end
        local p = F.FindPlayer and F.FindPlayer(name)
        if not p then return end
        ForceHit2Active = false
        ForceHit1Active = true
        ForceHitCmdTarget = p
        UseGun = true
        if F.SelectGun then
            if not F.SelectGun("db") then
                local guns = F.CollectGuns and F.CollectGuns() or {}
                if guns[1] and F.EquipOnlyTool then F.EquipOnlyTool(guns[1]) end
            end
        end
        CurrentAction = "forcehit1"
        getgenv()._FH1_GEN = (getgenv()._FH1_GEN or 0) + 1
        local gen = getgenv()._FH1_GEN
        task.spawn(function()
            local followDist = 7
            while ForceHit1Active and gen == getgenv()._FH1_GEN and ForceHitCmdTarget and ForceHitCmdTarget.Parent do
                local t = ForceHitCmdTarget
                local tChar = t.Character
                if not tChar then
                    task.wait(0.1)
                else
                    local knocked = F.isKnocked and F.isKnocked(tChar)
                    if knocked or (F.isFullyAlive and not F.isFullyAlive(t)) then
                        break
                    end
                    local tr = tChar:FindFirstChild("HumanoidRootPart")
                    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if tr and r then
                        r.CFrame = tr.CFrame * CFrame.new(0, 0, followDist)
                    end
                    pcall(function() if F.FireForceHit then F.FireForceHit(t) end end)
                    task.wait(0.05)
                end
            end
            if gen ~= getgenv()._FH1_GEN then return end
            local t = ForceHitCmdTarget
            if t and t.Character and F.DoStomp then
                pcall(F.DoStomp, t)
                task.wait(0.4)
            end
            ForceHit1Active = false
            ForceHitCmdTarget = nil
            CurrentAction = "idle"
            if F.StartFollow then pcall(F.StartFollow) end
        end)
        return
    end
    if cmd == "forcehit2" or cmd == "fh2" then
        -- CONTINUOUS: follow 7 studs, DB, shoot, stomp, wait respawn, repeat
        local name = args[2]
        if not name then return end
        local p = F.FindPlayer and F.FindPlayer(name)
        if not p then return end
        ForceHit1Active = false
        ForceHit2Active = false
        task.wait()
        ForceHitCmdTarget = p
        ForceHit2Active = true
        UseGun = true
        CurrentAction = "forcehit2"
        getgenv()._FH2_GEN = (getgenv()._FH2_GEN or 0) + 1
        local gen = getgenv()._FH2_GEN
        task.spawn(function()
            local followDist = 7
            while ForceHit2Active and gen == getgenv()._FH2_GEN do
                local t = ForceHitCmdTarget
                if not t or not t.Parent then
                    -- try re-find by name
                    t = F.FindPlayer and F.FindPlayer(name)
                    ForceHitCmdTarget = t
                end
                if not t or not t.Parent then
                    task.wait(0.5)
                else
                    if F.SelectGun then
                        pcall(function()
                            if not F.SelectGun("db") then
                                local guns = F.CollectGuns and F.CollectGuns() or {}
                                if guns[1] and F.EquipOnlyTool then F.EquipOnlyTool(guns[1]) end
                            end
                        end)
                    end
                    -- attack until KO
                    while ForceHit2Active and gen == getgenv()._FH2_GEN and t.Parent do
                        local tChar = t.Character
                        if not tChar then task.wait(0.15) break end
                        local knocked = F.isKnocked and F.isKnocked(tChar)
                        if knocked or (F.isFullyAlive and not F.isFullyAlive(t)) then
                            if F.DoStomp then pcall(F.DoStomp, t) end
                            task.wait(0.5)
                            break
                        end
                        local tr = tChar:FindFirstChild("HumanoidRootPart")
                        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tr and r then
                            r.CFrame = tr.CFrame * CFrame.new(0, 0, followDist)
                        end
                        pcall(function() if F.FireForceHit then F.FireForceHit(t) end end)
                        task.wait(0.05)
                    end
                    -- wait for respawn / FF gone then continue
                    if not ForceHit2Active or gen ~= getgenv()._FH2_GEN then break end
                    task.wait(2.0)
                end
            end
            if gen == getgenv()._FH2_GEN then
                ForceHit2Active = false
                ForceHitCmdTarget = nil
                CurrentAction = "idle"
                if F.StartFollow then pcall(F.StartFollow) end
            end
        end)
        return
    end


    if cmd == "safe" then
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then
            pcall(function() r.CFrame = CFrame.new(322.43, 34.99, -604.27) end)
        end
        return
    end
    if cmd == "teleport" or cmd == "tpbots" then
        -- teleport to controller in spread positions, no follow glue
        local ctrl = F.GetController and F.GetController()
        local cr = ctrl and ctrl.Character and ctrl.Character:FindFirstChild("HumanoidRootPart")
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if cr and r then
            local slot = MySlot or 1
            local ang = (slot - 1) * (math.pi * 2 / math.max(MaxBots or 20, 1))
            local off = Vector3.new(math.cos(ang) * 4, 0, math.sin(ang) * 4)
            pcall(function()
                if FollowConnection then FollowConnection:Disconnect() FollowConnection = nil end
                CurrentAction = "idle"
                r.CFrame = CFrame.new(cr.Position + off)
            end)
        end
        return
    end

if cmd == "stop" or cmd == "idle" then
        ForceHitCmdTarget = nil
        ForceHit1Active = false
        ForceHit2Active = false
        StompSelectedTarget = false
        PendingAutokill, SavedKillTargets = nil, nil
        DancePersistent, LastDanceId = false, nil
        if CurrentDance then pcall(function() CurrentDance:Stop() end) CurrentDance = nil end
        F.StopAll()
        VoidSpamEnabled = false
        KnifeTweenEnabled = false
        if F.StopKillAura then F.StopKillAura() end
        if F.StopProtectOwner then F.StopProtectOwner() end
    elseif cmd == "return" or cmd == "summon" or cmd == "follow" or cmd == "come" then
        PendingAutokill, SavedKillTargets = nil, nil
        if F.StopProtectOwner then F.StopProtectOwner() end
        F.StartFollow()
    elseif cmd == "stomp" then
        if args[2] == "on" then StompOnKill = true
        elseif args[2] == "off" then StompOnKill = false
        else StompOnKill = not StompOnKill end
    elseif cmd == "gun" then UseGun = true
    elseif cmd == "knife" and not args[2] then UseGun = false
    elseif cmd == "kill" or cmd == "k" or cmd == "kc" or (cmd == "knife" and args[2]) then
        -- multi: !k user1 user2  or  !k user1,user2,user3
        withBots(2, function(t) if #t > 0 then F.StartKill(t, false) end end)
    elseif cmd == "autokill" or cmd == "ak" or cmd == "a" then
        withBots(2, function(t) if #t > 0 then F.StartKill(t, true) end end)
    elseif cmd == "atween" then
        KnifeTweenEnabled = true
        UseGun = false
        F.SetKillMethod("tween")
        withBots(2, function(t) if #t > 0 then F.StartKill(t, true) end end)
    elseif cmd == "aorbit" then
        F.SetKillMethod("orbit")
        withBots(2, function(t) if #t > 0 then F.StartKill(t, true) end end)
    elseif cmd == "aksk" then
        UseGun = false
        SpamVoidWeapon = "knife"
        F.SetKillMethod("spamvoid")
        withBots(2, function(t) if #t > 0 then F.StartKill(t, true) end end)
    elseif cmd == "agsk" then
        UseGun = true
        SpamVoidWeapon = "gun"
        F.SetKillMethod("spamvoid")
        withBots(2, function(t) if #t > 0 then F.StartKill(t, true) end end)
    elseif cmd == "powner" or cmd == "protectowner" then
        F.StartProtectOwner()
    elseif cmd == "unpowner" or cmd == "unprotectowner" then
        F.StopProtectOwner()
    elseif cmd == "bring" or cmd == "get" or cmd == "b" then
        withBots(2, function(t) if #t > 0 then F.StartBring(t) end end)
    elseif cmd == "void" then
        F.StopAll()
        CurrentAction = "void"
        F.StartGlue("custom", nil)
        task.spawn(function()
            while CurrentAction == "void" do CustomGlueCF = CFrame.new(0, VoidY, 0) task.wait(0.1) end
        end)
    -- formations (relative to controller unless a player name is given)
    elseif cmd == "back" then F.StartFormation("back", args[2])
    elseif cmd == "bline" then F.StartFormation("bline", args[2])
    elseif cmd == "pole" or cmd == "stackon" then F.StartFormation("pole", args[2])
    elseif cmd == "around" then F.StartFormation("around", args[2])
    elseif cmd == "line" then F.StartFormation("line", args[2])
    elseif cmd == "rline" then F.StartFormation("rline", args[2])
    elseif cmd == "lline" then F.StartFormation("lline", args[2])
    elseif cmd == "circle" then F.StartFormation("circle", args[2])
    elseif cmd == "dance" then
        if args[2] == "off" or args[2] == "stop" then
            -- resume default execute emote (do not leave idle)
            pcall(function() if F.StartDefaultEmote then F.StartDefaultEmote() end end)
        elseif args[2] then
            local key = args[2]
            local found = false
            if VAULT_EMOTES and VAULT_EMOTES[key] then
                F.PlayEmote(VAULT_EMOTES[key])
                found = true
            end
            if not found and EmoteOrder then
                for _, e in ipairs(EmoteOrder) do
                    if e.key == key then F.PlayEmote(e.id) found = true break end
                end
            end
            if not found then
                -- try rbxassetid number
                if tonumber(key) then F.PlayEmote("rbxassetid://" .. key) found = true end
            end
            if not found and DefaultEmoteId then F.PlayEmote(DefaultEmoteId) end
        else
            F.PlayEmote(EmoteOrder[math.random(1, #EmoteOrder)].id)
        end
    elseif cmd == "floss" then F.PlayEmote(Emotes.Floss)
    elseif cmd == "happier" or cmd == "jump" then F.PlayEmote(Emotes["Yungblud Happier Jump"])
    elseif cmd == "takel" or cmd == "l" then F.PlayEmote(Emotes["take the L"])
    elseif cmd == "darktriad" or cmd == "dark" then F.PlayEmote(Emotes.darktriad)
    elseif cmd == "vampire" or cmd == "upsidedown" then F.PlayEmote(Emotes.vampire)
    elseif cmd == "sentry" then
        if args[2] == "on" then
            SentryEnabled = true
            if SentryConnection then SentryConnection:Disconnect() end
            SentryConnection = RunService.Heartbeat:Connect(function()
                if not SentryEnabled then return end
                local c = F.GetController()
                if not c or not c.Character then return end
                local h = c.Character:FindFirstChildOfClass("Humanoid")
                local hr = c.Character:FindFirstChild("HumanoidRootPart")
                if not h or not hr then return end
                if h.Health < LastControllerHealth and h.Health > 0 then
                    local best, bd = nil, 40
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and not F.IsOwner(p) and p.Character then
                            local pr = p.Character:FindFirstChild("HumanoidRootPart")
                            if pr then
                                local d = (pr.Position - hr.Position).Magnitude
                                if d < bd then bd, best = d, p end
                            end
                        end
                    end
                    if best then F.StartKill({ best }, true) end
                end
                LastControllerHealth = h.Health
            end)
        elseif args[2] == "off" then
            SentryEnabled = false
            if SentryConnection then SentryConnection:Disconnect() SentryConnection = nil end
        end

    elseif cmd == "orbit" then
        local a2 = args[2] and args[2]:lower() or ""
        local n = tonumber(args[2])
        if n == 1 or a2 == "1" or a2 == "" then
            F.StartControllerOrbit(1)
        elseif n == 2 or a2 == "2" then
            F.StartControllerOrbit(2)
        elseif n == 3 or a2 == "3" then
            F.StartControllerOrbit(3)
        elseif a2 == "on" then OrbitEnabled = true
        elseif a2 == "off" then OrbitEnabled = false
        elseif a2 == "top" or a2 == "bottom" or a2 == "back" or a2 == "front" or a2 == "left" or a2 == "right" then
            KillPosition = a2:sub(1,1):upper() .. a2:sub(2)
            OrbitEnabled = true
            F.SetKillMethod("orbit")
        else
            F.StartControllerOrbit(1)
        end
    elseif cmd == "spinbot" or cmd == "spin" then
        local n = tonumber(args[2])
        if args[2] == "off" then
            SpinbotEnabled = false
        elseif n then
            SpinbotSpeed = math.clamp(n, 1, 200)
            SpinbotEnabled = true
        else
            SpinbotEnabled = not SpinbotEnabled
        end
    elseif cmd == "knifetween" or cmd == "kt" then
        if args[2] == "off" then
            KnifeTweenEnabled = false
        else
            KnifeTweenEnabled = true
            UseGun = false
            FastKillBehindDist = BadExecutor and 50 or 100
            FastKillFrontDist = BadExecutor and 50 or 100
            FastKillMoveSpeed = BadExecutor and 100 or 1000
            F.SetKillMethod("tween")
        end
    elseif cmd == "gunspamkill" or cmd == "gsk" then
        if args[2] ~= "off" then
            UseGun = true
            SpamVoidWeapon = "gun"
            F.SetKillMethod("spamvoid")
        end
    elseif cmd == "knifespamkill" or cmd == "ksk" then
        if args[2] ~= "off" then
            UseGun = false
            SpamVoidWeapon = "knife"
            F.SetKillMethod("spamvoid")
        end
    elseif cmd == "fastkill" or cmd == "tweenkill" or cmd == "tween" then
        KnifeTweenEnabled = true
        UseGun = false
        F.SetKillMethod("tween")
    elseif cmd == "orbitkill" then
        F.SetKillMethod("orbit")
    elseif cmd == "spamvoidkill" or cmd == "svkill" then
        UseGun = true
        F.SetKillMethod("spamvoid")
    elseif cmd == "killmethod" and args[2] then
        local m = args[2]
        if m == "tween" or m == "fast" or m == "fastkill" then
            F.SetKillMethod("tween")
        elseif m == "orbit" then
            F.SetKillMethod("orbit")
        elseif m == "spamvoid" or m == "void" or m == "sv" then
            F.SetKillMethod("spamvoid")
        end
    elseif cmd == "killpos" or cmd == "position" then
        local p = args[2] and args[2]:lower() or ""
        local map = { back="Back", front="Front", left="Left", right="Right", top="Top", bottom="Bottom" }
        if map[p] then KillPosition = map[p] warn("[NAMELESS] Kill pos: " .. KillPosition) end
    elseif cmd == "killdist" or cmd == "distance" then
        local n = tonumber(args[2])
        if n then KillDistance = math.clamp(n, 2, 40) end
    elseif cmd == "tweenpath" or cmd == "path" then
        local p = args[2] and args[2]:lower() or ""
        local ok = { backfront=1, leftright=1, topbottom=1, diag_tlbr=1, diag_trbl=1, diag_bltr=1, diag_brtl=1 }
        if ok[p] then TweenPath = p warn("[NAMELESS] Tween path: " .. p) end
    elseif cmd == "voidin" then
        local n = tonumber(args[2]); if n then SpamVoidInTime = math.clamp(n, 0.05, 5) end
    elseif cmd == "voidout" then
        local n = tonumber(args[2]); if n then SpamVoidOutTime = math.clamp(n, 0.05, 5) end
    elseif cmd == "antilag" then
        if args[2] == "off" then F.SetAntiLag(false)
        elseif args[2] == "on" then F.SetAntiLag(true)
        else F.SetAntiLag(not AntiLagEnabled) end
    elseif cmd == "botesp" then
        if args[2] == "off" then F.SetBotEsp(false)
        elseif args[2] == "on" then F.SetBotEsp(true)
        else F.SetBotEsp(not BotEspEnabled) end
    elseif cmd == "rapid" or cmd == "rapidfire" then
        if args[2] == "off" then F.SetRapidFire(false)
        elseif args[2] == "on" then F.SetRapidFire(true)
        else F.SetRapidFire(not RapidFireEnabled) end
    elseif cmd == "killaura" or cmd == "aura" or cmd == "ka" then
        local a2 = args[2] and args[2]:lower() or ""
        local n = tonumber(args[2])
        if n then
            KillAuraRange = math.clamp(n, 5, 300)
            if getgenv().KillAura then getgenv().KillAura.Range = KillAuraRange end
if not KillAuraEnabled then F.StartKillAura() end
        elseif a2 == "off" then F.StopKillAura()
        elseif a2 == "on" or a2 == "" then F.StartKillAura()
        else
            if KillAuraEnabled or (getgenv().KillAura and getgenv().KillAura.Enabled) then
                F.StopKillAura()
            else
                F.StartKillAura()
            end
        end
    elseif cmd == "pingspoof" or cmd == "pspoof" then
        PingSpoofValue = 30
        F.SetPingSpoof(true)
    elseif cmd == "unpspoof" or cmd == "unpingspoof" or cmd == "unpingspoofer" then
        F.SetPingSpoof(false)
    elseif cmd == "visualstrip" or cmd == "vstrip" or cmd == "grey" then
        if args[2] == "off" then F.SetVisualStrip(false)
        elseif args[2] == "on" then F.SetVisualStrip(true)
        else F.SetVisualStrip(not VisualStripEnabled) end
    elseif cmd == "culldist" or cmd == "cull" then
        local n = tonumber(args[2])
        if n then OptCullRange = math.clamp(n, 10, 500) warn("[NAMELESS] cull distance = " .. OptCullRange) end
    elseif cmd == "opt" or cmd == "optimize" or cmd == "optimisation" then
        if args[2] == "off" then F.SetOptMode(false)
        elseif args[2] == "on" then F.SetOptMode(true)
        else F.SetOptMode(not OptMode) end
    elseif cmd == "uzi" or cmd == "rev" or cmd == "db" or cmd == "sg"
        or cmd == "tacticalsg" or cmd == "silencer" then
        F.SelectGun(cmd)
    elseif cmd == "aurarange" then
        local n = tonumber(args[2])
        if n and getgenv().KillAura then
            getgenv().KillAura.Range = math.clamp(n, 5, 200)
            KillAuraRange = getgenv().KillAura.Range
        end
    elseif cmd == "autostomp" then
        if args[2] == "on" then AutoStompEnabled = true F.StartContinuousAutostomp()
        elseif args[2] == "off" then AutoStompEnabled = false F.StopContinuousAutostomp()
        else AutoStompEnabled = not AutoStompEnabled if AutoStompEnabled then F.StartContinuousAutostomp() else F.StopContinuousAutostomp() end end
    elseif cmd == "whitelist" and args[2] then
        F.addWhitelistName(args[2])
        local p = F.FindPlayerAny(args[2])
        if p then F.addWhitelistName(p.Name) end
    elseif cmd == "unwhitelist" and args[2] then
        F.removeWhitelistName(args[2])
        local p = F.FindPlayerAny(args[2])
        if p then F.removeWhitelistName(p.Name) end
    elseif cmd == "bot" and args[2] then
        F.addBotName(args[2])
        local p = F.FindPlayerAny(args[2])
        if p then
            F.addBotName(p.Name)
            if p.Character then task.defer(function() F.ApplyChickenClient(p.Character) end) end
        end
    elseif cmd == "unbot" and args[2] then
        F.removeBotName(args[2])
        local p = F.FindPlayerAny(args[2])
        if p then F.removeBotName(p.Name) end
    elseif cmd == "khold" then
        HoldMode = "knife"
        UseGun = false
    elseif cmd == "ghold" then
        HoldMode = "gun"
        UseGun = true
    elseif cmd == "hold" then
        HoldMode = "both"
    elseif cmd == "unhold" then
        HoldMode = nil
    elseif cmd == "norender" then
        if args[2] == "on" then F.SetNoRender(true)
        elseif args[2] == "off" then F.SetNoRender(false)
        else F.SetNoRender(not NoRenderEnabled) end
    elseif cmd == "autoheal" then
        if args[2] == "on" then AutoHealEnabled = true
        elseif args[2] == "off" then AutoHealEnabled = false
        else AutoHealEnabled = not AutoHealEnabled end
    elseif cmd == "hide" then
        F.StartHide()
    elseif cmd == "unhide" then
        HideAtShop = false
        if CurrentAction == "hide" then
            if F.CanSummon() then F.StartFollow() else F.StopAll() end
        end
    elseif cmd == "pole" then
        F.StartPole(args[2])
    elseif cmd == "chat" then
        if args[2] == "on" then AutoChatEnabled = true
        elseif args[2] == "off" then AutoChatEnabled = false
        else AutoChatEnabled = not AutoChatEnabled end
    elseif cmd == "reset" or cmd == "r" then F.ForceReset()
    elseif cmd == "leave" and F.IsSuperOwner(player) then
        DancePersistent, LastDanceId = false, nil
        if CurrentDance then pcall(function() CurrentDance:Stop() end) CurrentDance = nil end
        pcall(function() LocalPlayer:Kick("left") end)
    elseif cmd == "addowner" and args[2] then ExtraOwners[#ExtraOwners+1] = args[2]
    elseif cmd == "removeowner" and args[2] then
        for i = #ExtraOwners, 1, -1 do if ExtraOwners[i]:lower() == args[2] then table.remove(ExtraOwners, i) end end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(m) F.OnChatted(p, m) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(m) F.OnChatted(p, m) end)
end)
Players.PlayerRemoving:Connect(function(p)
    if TargetPlayer == p and (CurrentAction == "kill" or CurrentAction == "autokill" or CurrentAction == "bring") then
        PendingAutokill, SavedKillTargets = nil, nil
        if not F.IsSelfControlled() then task.defer(F.StartFollow) else task.defer(F.StopAll) end
    end
end)


getgenv().StandAccess = getgenv().StandAccess or {
    PrivilegeList = { "HackerUser1" },
    ImmuneList = { "verceyy" },
    SuperOwners = { "verceyy" },
}
getgenv().StandRunSilent = F.RunSilent
getgenv().StandStartKill = F.StartKill
getgenv().StandStartFollow = F.StartFollow

CtrlBotEnabled = CtrlBotEnabled or {}
CtrlBotSlot = CtrlBotSlot or {}
CtrlFormationRows = CtrlFormationRows or 1
CtrlPerRow = CtrlPerRow or 50

-- Remote multi-bot control (scoped function = own register pool, avoids 200-local limit)
function F.InitRemoteSystem()
    local NPOINT_URL = "https://api.npoint.io/e356beb5fcba0b07d042"
    RemoteLastId = nil
    RemotePollSeconds = 1.0
    RemoteCmdId = tonumber(getgenv().NamelessRemoteId) or 0
    CtrlBotEnabled = CtrlBotEnabled or {}
    CtrlBotSlot = CtrlBotSlot or {}
    CtrlFormationRows = CtrlFormationRows or 1
    CtrlPerRow = CtrlPerRow or 50

    local function httpRequest(opts)
        local res = nil
        pcall(function()
            if syn and syn.request then res = syn.request(opts)
            elseif request then res = request(opts)
            elseif http_request then res = http_request(opts)
            elseif fluxus and fluxus.request then res = fluxus.request(opts)
            end
        end)
        return res
    end

    local function httpGet(url)
        local body = nil
        local r = httpRequest({ Url = url, Method = "GET" })
        if r then body = r.Body or r.body end
        if not body then
            pcall(function()
                if game.HttpGet then body = game:HttpGet(url)
                else body = game:GetService("HttpService"):GetAsync(url) end
            end)
        end
        return body
    end

    local function httpPutJson(url, tbl)
        local Hs = game:GetService("HttpService")
        local body = Hs:JSONEncode(tbl)
        local r = httpRequest({
            Url = url,
            Method = "PUT",
            Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
            Body = body,
        })
        if r and (r.Success or r.StatusCode == 200 or r.StatusCode == 201) then return true end
        r = httpRequest({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
            Body = body,
        })
        if r and (r.Success or r.StatusCode == 200 or r.StatusCode == 201) then return true end
        return false
    end

    local function parseRemoteJson(raw)
        if not raw or raw == "" then return nil end
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if ok and type(data) == "table" then return data end
        return nil
    end

    function F.RemoteShouldRun(data)
        if not data then return false end
        local bots = data.bots
        if bots == nil then return true end
        if type(bots) == "string" then
            if bots == "" then return true end
            return bots:lower() == LocalPlayer.Name:lower()
                or bots:lower() == (LocalPlayer.DisplayName or ""):lower()
        end
        if type(bots) == "table" then
            if #bots == 0 then return true end
            local myN = LocalPlayer.Name:lower()
            local myD = (LocalPlayer.DisplayName or ""):lower()
            for _, b in ipairs(bots) do
                local s = tostring(b):lower()
                if s == myN or s == myD or s == "all" then return true end
            end
            return false
        end
        return true
    end

    function F.RemoteApplyMeta(data)
        if not data then return end
        if data.controller and tostring(data.controller) ~= "" then
            ControllerName = tostring(data.controller)
        end
        if type(data.slots) == "table" then
            local n = data.slots[LocalPlayer.Name] or data.slots[LocalPlayer.Name:lower()]
                or data.slots[LocalPlayer.DisplayName or ""]
            if n then MySlot = math.max(1, math.floor(tonumber(n) or MySlot or 1)) end
        end
        if data.rows then FormationRows = math.max(1, math.floor(tonumber(data.rows) or 1)) end
        if data.perRow then FormationPerRow = math.max(1, math.floor(tonumber(data.perRow) or 50)) end
    end

    function F.RemotePublish(cmd, target, botsList, slotsMap, rows, perRow)
        RemoteCmdId = RemoteCmdId + 1
        getgenv().NamelessRemoteId = RemoteCmdId
        local payload = {
            id = RemoteCmdId,
            cmd = tostring(cmd or ""),
            target = tostring(target or ""),
            bots = botsList or {},
            slots = slotsMap or {},
            rows = rows or CtrlFormationRows,
            perRow = perRow or CtrlPerRow,
            controller = ControllerName or LocalPlayer.Name,
        }
        local ok = httpPutJson(NPOINT_URL, payload)
        return ok
    end

    function F.RemotePublishLine(line, target, bots, slots)
        return F.RemotePublish(line, target, bots, slots, CtrlFormationRows, CtrlPerRow)
    end

    task.spawn(function()
        while true do
            task.wait(RemotePollSeconds)
            local data = parseRemoteJson(httpGet(NPOINT_URL))
            if data then
                local id = data.id
                local cmd = data.cmd
                if cmd and tostring(cmd) ~= "" and id ~= nil and RemoteLastId ~= id then
                    RemoteLastId = id
                    if F.RemoteShouldRun(data) then
                        F.RemoteApplyMeta(data)
                        local line = tostring(cmd)
                        if data.target and tostring(data.target) ~= "" then
                            line = line .. " " .. tostring(data.target)
                        end
                        if line ~= "" and line ~= "a simple JSON data store" then
pcall(function() F.RunSilent(line) end)
                        end
                    end
                end
            end
        end
    end)
end

pcall(function() F.InitRemoteSystem() end)

task.spawn(function()
    task.wait(0.35)
    -- Role boot
    if F.IsStandClient() then
        -- Bot / stand: black screen, no controller GUI
        pcall(F.CreateBlackScreen)
        pcall(F.SyncBotWhitelist)
        if LiteMode or OptMode then
            pcall(function() F.SetOptMode(true) end)
        end
        if AntiLagEnabled then
            pcall(F.CreateBlackScreen)
            pcall(function() F.SetNoRender(true) end)
        end
        if not LiteMode then pcall(F.StartDefaultEmote) end
        local msg = "Stand ready | slot " .. tostring(MySlot) .. " | controller: " .. tostring(ControllerName)
pcall(function()
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = msg, Color = Color3.fromRGB(180, 220, 255), Font = Enum.Font.SourceSansBold, TextSize = 16,
            })
        end)
    else
        -- Controller: GUI + bot ESP + join notifies
        if not ControllerName or ControllerName == "" then
            ControllerName = LocalPlayer.Name
        end
        if not OriginalControllerName or OriginalControllerName == "" then
            OriginalControllerName = ControllerName
        end
        ShowBotsTab = true
        pcall(function()
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        end)
        -- clear any stand KO hooks if re-executed on controller
        if koConn then pcall(function() koConn:Disconnect() end) koConn = nil end
        pcall(F.SyncBotWhitelist)
        local ok, err = pcall(F.CreateNamelessGui)
        if not ok then warn("[NAMELESS] GUI failed: " .. tostring(err)) end
        if BotEspEnabled then pcall(F.RefreshBotEsp) end
        local msg = "Controller ready - " .. LocalPlayer.Name .. " | bots listed: " .. tostring(#BotListOrdered)
pcall(function()
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = msg, Color = Color3.fromRGB(180, 220, 255), Font = Enum.Font.SourceSansBold, TextSize = 16,
            })
        end)
        -- Notify for bots already in game
        for _, plr in ipairs(Players:GetPlayers()) do
            if F.IsListedBot(plr.Name) then
                F.Notify("Bot online: " .. plr.Name)
            end
        end
    end
end)

-- Bot join notifications + ESP (controller only)
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    pcall(function() F.OnBotJoined(plr) end)
end)
Players.PlayerRemoving:Connect(function(plr)
    if F.IsControllerClient() and F.IsListedBot(plr.Name) then
        F.Notify("Bot left: " .. plr.Name)
    end
end)

