--[[
    ███╗   ██╗██╗██╗  ██╗███████╗    ██╗  ██╗ █████╗ ████████╗     ██████╗ ██████╗ ██████╗ ██╗████████╗
    ████╗  ██║██║██║ ██╔╝██╔════╝    ██║  ██║██╔══██╗╚══██╔══╝    ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝
    ██╔██╗ ██║██║█████╔╝ ███████╗    ███████║███████║   ██║       ██║   ██║██████╔╝██████╔╝██║   ██║   
    ██║╚██╗██║██║██╔═██╗ ╚════██║    ██╔══██║██╔══██║   ██║       ██║   ██║██╔══██╗██╔══██╗██║   ██║   
    ██║ ╚████║██║██║  ██╗███████║    ██║  ██║██║  ██║   ██║       ╚██████╔╝██║  ██║██████╔╝██║   ██║   
    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝   
    
    QUANTUM EDITION V9.5 - ADVANCED UI WITH MUSIC
    1 QUINTILLION FORCE + BEAUTIFUL INTERFACE
    
    Created by: Enhanced by AI
    Original Concept: Niks Hat Orbit
]]

if _G.NiksOrbitLoaded then return end
_G.NiksOrbitLoaded = true

local NiksOrbitVersion = "9.5 QUANTUM UI"

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
cloneref = cloneref or function(o) return o end

local Debris = cloneref(game:GetService("Debris"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))

local Player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local Util = {}

Util.RandomString = function(length)
    length = length or math.random(32, 256)
    local str = ""
    for _=1, length do
        str ..= string.char(math.random(32, 126))
    end
    return str
end

Util.Notify = function(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Niks Orbit",
        Text = text,
        Duration = 5
    })
end

Util.Instance = function(cl, p)
    local i = Instance.new(cl)
    i.Name = Util.RandomString()
    i.Parent = p
    return i
end

Util.LinkDestroyI2I = function(a, b)
    a.Destroying:Once(function()
        b:Destroy()
    end)
end

Util.LinkDestroyI2C = function(a, b)
    a.Destroying:Once(function()
        b:Disconnect()
    end)
end

Util.LoopedHSV = function(h, s, v)
    h %= 1
    s = math.clamp(s, 0, 1)
    v = math.clamp(v, 0, 1)
    return Color3.fromHSV(h, s, v)
end

Util.GetScreenSize = function()
    if workspace.CurrentCamera then
        return workspace.CurrentCamera.ViewportSize
    end
    return Vector2.new(1920, 1080)
end

Util.UDim2ToVector2Offset = function(x)
    return Vector2.new(x.X.Offset, x.Y.Offset)
end

Util.Vector2ToUDim2Offset = function(x)
    return UDim2.fromOffset(x.X, x.Y)
end

Util.UDim2ToVector2Scale = function(x)
    return Vector2.new(x.X.Scale, x.Y.Scale)
end

Util.Vector2ToUDim2Scale = function(x)
    return UDim2.fromScale(x.X, x.Y)
end

-- ═══════════════════════════════════════════════════════════
-- GLOBAL VARIABLES
-- ═══════════════════════════════════════════════════════════
local chr = nil
local hum = nil
local hrp = nil
local camera = workspace.CurrentCamera

-- Hat system
local accessories = {}
local orbitAttachments = {}
local angularVelocities = {}
local orbitParts = {}
local totalAccessories = 0

-- System state
local isInitialized = false
local isReanimated = false
local connections = {}
local respawnInProgress = false

-- Position tracking
local lastSafePosition = Vector3.new(0, 10, 0)
local lastSafeCFrame = CFrame.new(0, 10, 0)
local savedCameraCFrame = nil
local savedCameraType = nil

-- Animation
local angleCounter = 0
local timeCounter = 0

-- Player modifications
local flyEnabled = false
local noClipEnabled = false
local invisibleEnabled = false
local godModeEnabled = false
local frozenEnabled = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local originalGravity = 196.2

-- 1 QUINTILLION FORCE
local QUINTILLION = 1000000000000000000

-- Configuration
local config = {
    offset = 13,
    speed = 1,
    mode = 1,
    angular = Vector3.new(0, 10, 0),
    hatFallThreshold = 20,
    hatYThreshold = -15,
}

-- MODE CONFIGURATIONS
local MODE_CONFIGS = {
    [1] = {name = "Fast Circle", description = "Classic smooth circle orbit"},
    [2] = {name = "Speed Crown", description = "Elevated crown formation"},
    [3] = {name = "Dual Rings", description = "Two counter-rotating rings"},
    [4] = {name = "Rapid Helix", description = "DNA-like spiral pattern"},
    [5] = {name = "Galaxy Spiral", description = "Expanding spiral galaxy"},
    [6] = {name = "Quantum Wave", description = "Oscillating wave pattern"},
    [7] = {name = "Star Formation", description = "Five-pointed star"},
    [8] = {name = "Tornado", description = "Spinning vortex"},
    [9] = {name = "DNA Helix", description = "Double helix structure"},
    [10] = {name = "Phoenix Rising", description = "Ascending spiral"},
    [11] = {name = "Infinity Loop", description = "Figure-8 pattern"},
    [12] = {name = "Chaos Storm", description = "Random chaotic movement"}
}

-- ═══════════════════════════════════════════════════════════
-- UI VARIABLES
-- ═══════════════════════════════════════════════════════════
local SCREENGUI = Util.Instance("ScreenGui")
SCREENGUI.IgnoreGuiInset = true
SCREENGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SCREENGUI.ClipToDeviceSafeArea = false
SCREENGUI.ResetOnSpawn = false
SCREENGUI.ScreenInsets = Enum.ScreenInsets.None
SCREENGUI.DisplayOrder = 2147483647
SCREENGUI.Parent = CoreGui

local UIMainFrame = Util.Instance("Frame", SCREENGUI)
UIMainFrame.AnchorPoint = Vector2.new(0, 0)
UIMainFrame.Position = UDim2.new(0, 0, 0, 0)
UIMainFrame.Size = UDim2.new(1, 0, 1, 0)
UIMainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
UIMainFrame.BackgroundTransparency = 1
UIMainFrame.BorderSizePixel = 0
UIMainFrame.ZIndex = 2147483647

-- Save Data
local SaveData = {
    UITheme = 1,
    SkipIntro = false,
    MuteUISound = false,
    MuteMusic = false,
    CurrentTrack = 1,
}

-- Stylized Objects
local StylizedObjs = {}
local function Stylize(obj, options)
    options = options or {}
    Util.Instance("UICorner", obj).CornerRadius = UDim.new(0, 5)
    local Out = Util.Instance("UIStroke", obj)
    Out.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Out.Color = Color3.new(1, 1, 1)
    Out.LineJoinMode = Enum.LineJoinMode.Round
    Out.Thickness = 1
    Out.Transparency = 0
    Out.Enabled = true
    obj.BackgroundColor3 = Color3.new(0, 0, 0)
    table.insert(StylizedObjs, {
        obj = obj,
        Out = Out,
        options = options,
    })
end

local ForceUIColor = nil
local ForceUIBGColor = nil
local UITextColor = Util.Instance("Color3Value")
UITextColor.Value = Color3.new(1, 1, 1)

local function GetUIColor(t)
    if ForceUIColor then
        local si = math.sin(math.pi * 2 * t / 10)
        local h, s, v = ForceUIColor:ToHSV()
        if s < 0.2 then
            v *= 0.8 + si * 0.2
        else
            h += si * 0.01
        end
        return Util.LoopedHSV(h, s, v)
    end
    return Util.LoopedHSV(t / 10, 0.8, 1)
end

local function GetUIBGColor(t)
    if ForceUIBGColor then
        return ForceUIBGColor
    end
    return Color3.new(0, 0, 0)
end

local function RegisterTextLabel(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.TextColor3 = UITextColor.Value
        Util.LinkDestroyI2C(obj, UITextColor.Changed:Connect(function(val)
            obj.TextColor3 = val
        end))
    end
    if obj:IsA("TextBox") then
        local h, s, v = UITextColor.Value:ToHSV()
        obj.TextColor3 = UITextColor.Value
        obj.PlaceholderColor3 = Color3.fromHSV(h, s, 0.5 + (v - 0.5) * 0.4)
        Util.LinkDestroyI2C(obj, UITextColor.Changed:Connect(function(val)
            h, s, v = val:ToHSV()
            obj.TextColor3 = val
            obj.PlaceholderColor3 = Color3.fromHSV(h, s, 0.5 + (v - 0.5) * 0.4)
        end))
    end
end

local function UpdateGrads(t)
    local c = GetUIColor(t)
    local bgc = GetUIBGColor(t)
    local h, s, v = bgc:ToHSV()
    local bgcd = Color3.fromHSV(h, s, v * 0.9)
    for _,grad in StylizedObjs do
        local obj, Out, options = grad.obj, grad.Out, grad.options
        Out.Color = c
        if options.Depthed then
            obj.BackgroundColor3 = bgcd
        else
            obj.BackgroundColor3 = bgc
        end
    end
end

local function SetUITheme(index)
    local UIThemes = {
        {nil, nil, Color3.new(1, 1, 1)},                                            -- RGB/Default
        {Color3.new(1, 1, 1), nil, Color3.new(1, 1, 1)},                           -- ALONE
        {Color3.fromRGB(49, 203, 233), Color3.fromRGB(38, 38, 38), Color3.fromRGB(49, 203, 233)}, -- Oxide
        {Color3.new(0.0941177, 0.317647, 0.878431), nil, Color3.new(0.560784, 0.560784, 0.560784)}, -- Patchma
        {Color3.fromHex("7733FF"), Color3.fromHex("161330"), Color3.new(1, 1, 1)}, -- Genesis
        {Color3.new(0.9, 0, 0), Color3.new(0.05, 0, 0), Color3.new(1, 1, 1)},     -- Crimson
        {Color3.new(0, 1, 0), nil, Color3.new(0, 1, 0)},                           -- Matrix
        {Color3.new(0, 0, 0), Color3.new(1, 0.95, 0), Color3.new(0, 0, 0)},       -- Homer
        {Color3.new(0.1, 0.1, 0.1), nil, Color3.new(1, 1, 1)},                     -- Dark
        {nil, Color3.new(1, 1, 1), Color3.new(0, 0, 0)},                           -- Light
        {Color3.fromHex("333780"), Color3.fromHex("666EFF"), Color3.new(1, 1, 1)}, -- FT2 Blue
        {Color3.fromHex("75284B"), Color3.fromHex("F7ABE8"), Color3.fromHex("75284B")}, -- Cherry
    }
    local theme = UIThemes[index]
    if theme then
        ForceUIColor = theme[1]
        ForceUIBGColor = theme[2]
        UITextColor.Value = theme[3]
    end
end
SetUITheme(SaveData.UITheme)

-- UI Sound
local UISound = {}
UISound.Click = Util.Instance("Sound", UIMainFrame)
UISound.Click.SoundId = "rbxassetid://6324790483"
UISound.Click.Volume = SaveData.MuteUISound and 0 or 1
UISound.Click.PlaybackSpeed = 2

-- ═══════════════════════════════════════════════════════════
-- BACKGROUND MUSIC SYSTEM
-- ═══════════════════════════════════════════════════════════
local BackgroundMusic = {}
BackgroundMusic.Tracks = {
    {
        Name = "Robot Adventure",
        Url = "https://github.com/user-attachments/files/18390293/Dubmood_-_Zabutoms_Robot_Adventure__Dubmood_2004_Remix_.mp3"
    },
    {
        Name = "Afterburner",
        Url = "https://github.com/user-attachments/files/18390294/Dubmood_-_Afterburner__2003_.mp3"
    }
}

BackgroundMusic.CurrentSound = nil
BackgroundMusic.CurrentTrackIndex = SaveData.CurrentTrack
BackgroundMusic.IsPlaying = false

function BackgroundMusic.DownloadAndPlay(index)
    local track = BackgroundMusic.Tracks[index]
    if not track then return end
    
    Util.Notify("Downloading: " .. track.Name .. "...")
    
    local success, soundData = pcall(function()
        return game:HttpGet(track.Url, true)
    end)
    
    if not success or not soundData then
        Util.Notify("Failed to download: " .. track.Name)
        return
    end
    
    -- Stop current sound if playing
    if BackgroundMusic.CurrentSound then
        BackgroundMusic.CurrentSound:Stop()
        BackgroundMusic.CurrentSound:Destroy()
    end
    
    -- Try to use writefile if available (for executors that support it)
    local soundId = nil
    if writefile and isfolder and makefolder then
        pcall(function()
            if not isfolder("NiksOrbitMusic") then
                makefolder("NiksOrbitMusic")
            end
            local fileName = "NiksOrbitMusic/" .. track.Name .. ".mp3"
            writefile(fileName, soundData)
            soundId = getcustomasset(fileName)
        end)
    end
    
    -- If file writing failed, try direct sound creation
    if not soundId then
        Util.Notify("Direct streaming: " .. track.Name)
        soundId = track.Url
    end
    
    BackgroundMusic.CurrentSound = Util.Instance("Sound", UIMainFrame)
    BackgroundMusic.CurrentSound.Name = "BGMusic"
    BackgroundMusic.CurrentSound.SoundId = soundId
    BackgroundMusic.CurrentSound.Volume = SaveData.MuteMusic and 0 or 0.3
    BackgroundMusic.CurrentSound.Looped = true
    BackgroundMusic.CurrentSound.PlaybackSpeed = 1
    
    BackgroundMusic.CurrentTrackIndex = index
    SaveData.CurrentTrack = index
    
    BackgroundMusic.CurrentSound:Play()
    BackgroundMusic.IsPlaying = true
    Util.Notify("♫ Now Playing: " .. track.Name)
end

function BackgroundMusic.Play()
    if BackgroundMusic.CurrentSound and not BackgroundMusic.IsPlaying then
        BackgroundMusic.CurrentSound:Play()
        BackgroundMusic.IsPlaying = true
    elseif not BackgroundMusic.CurrentSound then
        BackgroundMusic.DownloadAndPlay(BackgroundMusic.CurrentTrackIndex)
    end
end

function BackgroundMusic.Pause()
    if BackgroundMusic.CurrentSound and BackgroundMusic.IsPlaying then
        BackgroundMusic.CurrentSound:Pause()
        BackgroundMusic.IsPlaying = false
    end
end

function BackgroundMusic.Stop()
    if BackgroundMusic.CurrentSound then
        BackgroundMusic.CurrentSound:Stop()
        BackgroundMusic.IsPlaying = false
    end
end

function BackgroundMusic.NextTrack()
    local nextIndex = BackgroundMusic.CurrentTrackIndex + 1
    if nextIndex > #BackgroundMusic.Tracks then
        nextIndex = 1
    end
    BackgroundMusic.DownloadAndPlay(nextIndex)
end

function BackgroundMusic.PreviousTrack()
    local prevIndex = BackgroundMusic.CurrentTrackIndex - 1
    if prevIndex < 1 then
        prevIndex = #BackgroundMusic.Tracks
    end
    BackgroundMusic.DownloadAndPlay(prevIndex)
end

function BackgroundMusic.SetVolume(volume)
    if BackgroundMusic.CurrentSound then
        BackgroundMusic.CurrentSound.Volume = SaveData.MuteMusic and 0 or volume
    end
end

-- ═══════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════
local UIMainWindow, WindowContent

UIMainWindow = Util.Instance("Frame", UIMainFrame)
UIMainWindow.Active = true
UIMainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
UIMainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
UIMainWindow.Size = UDim2.new(0, 420, 0, 380)
UIMainWindow.BackgroundTransparency = 0
UIMainWindow.BackgroundColor3 = Color3.new(1, 1, 1)
UIMainWindow.BorderSizePixel = 0
Stylize(UIMainWindow, {Glow = true})

-- Click sound handler
local _clicksndclicked = false
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        _clicksndclicked = false
    end
end)

local function _registerclicksnd(v)
    if v:GetAttribute("ClickSnd") then return end
    v:SetAttribute("ClickSnd", true)
    v.InputBegan:Connect(function(input)
        if _clicksndclicked then return end
        if input.UserInputState ~= Enum.UserInputState.Begin then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UISound.Click:Play()
            _clicksndclicked = true
        end
    end)
end
_registerclicksnd(UIMainWindow)
UIMainWindow.DescendantAdded:Connect(function(v)
    if v:IsA("GuiObject") then
        _registerclicksnd(v)
    end
end)

-- Top Bar
local TopBarFrame = Util.Instance("Frame", UIMainWindow)
TopBarFrame.Position = UDim2.new(0, 0, 0, 0)
TopBarFrame.Size = UDim2.new(1, 0, 0, 35)
TopBarFrame.BackgroundTransparency = 0
TopBarFrame.BackgroundColor3 = Color3.new(1, 1, 1)
TopBarFrame.BorderSizePixel = 0
TopBarFrame.ClipsDescendants = true
TopBarFrame.ZIndex = 1
Stylize(TopBarFrame)

local TopBarText = Util.Instance("TextLabel", TopBarFrame)
TopBarText.AnchorPoint = Vector2.new(0, 0.5)
TopBarText.Position = UDim2.new(0, 10, 0.5, 0)
TopBarText.Size = UDim2.new(1, -45, 1, 0)
TopBarText.BackgroundTransparency = 1
TopBarText.ClipsDescendants = true
TopBarText.Font = Enum.Font.Code
TopBarText.TextColor3 = Color3.new(1, 1, 1)
TopBarText.TextSize = 18
TopBarText.TextXAlignment = Enum.TextXAlignment.Left
TopBarText.Text = "Niks Orbit Quantum | v" .. NiksOrbitVersion
TopBarText.RichText = true
RegisterTextLabel(TopBarText)

local TopBarClose = Util.Instance("TextButton", TopBarFrame)
TopBarClose.AnchorPoint = Vector2.new(1, 0)
TopBarClose.Position = UDim2.new(1, 0, 0, 0)
TopBarClose.Size = UDim2.new(0, 35, 1, 0)
TopBarClose.BackgroundTransparency = 1
TopBarClose.Text = ""

do
    local A = Util.Instance("Frame", TopBarClose)
    A.AnchorPoint = Vector2.new(0.5, 0.5)
    A.Position = UDim2.new(0.5, 0, 0.5, 0)
    A.Size = UDim2.new(0, 16, 0, 2)
    A.Rotation = 0
    A.BackgroundTransparency = 0
    A.BackgroundColor3 = UITextColor.Value
    A.BorderSizePixel = 0
    A.Name = "A"
    A = Util.Instance("Frame", A)
    A.AnchorPoint = Vector2.new(0.5, 0.5)
    A.Position = UDim2.new(0.5, 0, 0.5, 0)
    A.Size = UDim2.new(0, 2, 0, 0)
    A.Rotation = 0
    A.BackgroundTransparency = 0
    A.BackgroundColor3 = UITextColor.Value
    A.BorderSizePixel = 0
    A.Name = "B"
    UITextColor.Changed:Connect(function(val)
        TopBarClose.A.BackgroundColor3 = val
        TopBarClose.A.B.BackgroundColor3 = val
    end)
end

WindowContent = Util.Instance("Frame", UIMainWindow)
WindowContent.Position = UDim2.new(0, 0, 0, 35)
WindowContent.Size = UDim2.new(1, 0, 1, -35)
WindowContent.BackgroundTransparency = 1
WindowContent.ClipsDescendants = true
WindowContent.ZIndex = 0

-- Window drag functionality
local MainWindowClosed = false
local MainWindowTweening = false
local MainWindowPosOpen = UIMainWindow.Position
local MainWindowPosClose = UDim2.new(1, -120, 0, 10)

TopBarClose.Activated:Connect(function()
    if MainWindowTweening then return end
    MainWindowTweening = true
    MainWindowClosed = not MainWindowClosed
    if MainWindowClosed then
        MainWindowPosOpen = UIMainWindow.Position
        TweenService:Create(UIMainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = MainWindowPosClose,
            Size = UDim2.fromOffset(120, 35)
        }):Play()
        TweenService:Create(TopBarClose.A, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Rotation = 180
        }):Play()
        TweenService:Create(TopBarClose.A.B, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 2, 0, 16)
        }):Play()
        task.delay(0.6, function()
            WindowContent.Visible = false
            MainWindowTweening = false
        end)
    else
        WindowContent.Visible = true
        MainWindowPosClose = UIMainWindow.Position
        TweenService:Create(UIMainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = MainWindowPosOpen,
            Size = UDim2.fromOffset(420, 380)
        }):Play()
        TweenService:Create(TopBarClose.A, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Rotation = 0
        }):Play()
        TweenService:Create(TopBarClose.A.B, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 2, 0, 0)
        }):Play()
        task.delay(0.6, function()
            MainWindowTweening = false
        end)
    end
    WindowContent.Active = not MainWindowClosed
    WindowContent.Interactable = not MainWindowClosed
end)

-- Drag functionality
local dragref = nil
local offset = Vector2.new(0, 0)
TopBarFrame.InputBegan:Connect(function(input)
    if dragref then return end
    if input.UserInputState ~= Enum.UserInputState.Begin then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        WindowContent.Interactable = false
        local screen = Util.GetScreenSize()
        local ch = (Vector2.new(input.Position.X, input.Position.Y) + SCREENGUI.AbsolutePosition) / screen
        offset = Util.UDim2ToVector2Scale(UIMainWindow.Position) - ch
        dragref = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragref then
        if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and dragref == input) then
            local screen = Util.GetScreenSize()
            local ch = (Vector2.new(input.Position.X, input.Position.Y) + SCREENGUI.AbsolutePosition) / screen
            local pos = ch + offset
            UIMainWindow.Position = Util.Vector2ToUDim2Scale(pos)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragref and dragref == input then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            WindowContent.Interactable = true
            dragref = nil
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════
local UI = {}

function UI.CreatePage()
    local Frame = Util.Instance("ScrollingFrame", WindowContent)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Visible = false
    Frame.ZIndex = 0
    Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Frame.ScrollingDirection = Enum.ScrollingDirection.Y
    Frame.ScrollBarThickness = 4
    Frame.ClipsDescendants = true
    local Padding = Util.Instance("UIPadding", Frame)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)
    Padding.PaddingLeft = UDim.new(0, 5)
    Padding.PaddingRight = UDim.new(0, 5)
    local UIList = Util.Instance("UIListLayout", Frame)
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.VerticalAlignment = Enum.VerticalAlignment.Top
    UIList.Padding = UDim.new(0, 5)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    return Frame
end

function UI.CreateText(parent, text, size, alignment)
    local margin = 5
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 65536)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Text = Util.Instance("TextLabel", Container)
    Text.Position = UDim2.new(0, margin, 0, 0)
    Text.Size = UDim2.new(1, margin * -2, 1, -margin)
    Text.BackgroundTransparency = 1
    Text.RichText = true
    Text.Font = Enum.Font.Code
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextTransparency = 0
    Text.TextXAlignment = alignment or Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Top
    Text.TextWrapped = true
    Text.TextSize = size
    RegisterTextLabel(Text)
    local function update()
        local x = parent.AbsoluteSize.X
        local size = TextService:GetTextSize(Text.ContentText, Text.TextSize, Text.Font, Vector2.new(x - margin * 2, math.huge))
        Container.Size = UDim2.new(1, 0, 0, size.Y + margin)
    end
    Text.Text = text
    update()
    Text.Changed:Connect(update)
    return Text
end

function UI.CreateButton(parent, text, size)
    local margin = 5
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 65536)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Button = Util.Instance("TextButton", Container)
    Button.AnchorPoint = Vector2.new(0, 0)
    Button.Position = UDim2.new(0, margin, 0, margin // 2)
    Button.Size = UDim2.new(1, margin * -2, 1, -margin)
    Button.BackgroundTransparency = 0
    Button.BackgroundColor3 = Color3.new(1, 1, 1)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = true
    local ButtonText = Util.Instance("TextLabel", Button)
    ButtonText.AnchorPoint = Vector2.new(0, 0.5)
    ButtonText.Position = UDim2.new(0, 0, 0.5, 0)
    ButtonText.Size = UDim2.new(1, 0, 1, -margin)
    ButtonText.BackgroundTransparency = 1
    ButtonText.RichText = true
    ButtonText.Font = Enum.Font.Code
    ButtonText.TextColor3 = Color3.new(1, 1, 1)
    ButtonText.TextTransparency = 0
    ButtonText.TextXAlignment = Enum.TextXAlignment.Center
    ButtonText.TextYAlignment = Enum.TextYAlignment.Center
    ButtonText.TextWrapped = true
    ButtonText.TextSize = size
    RegisterTextLabel(ButtonText)
    Stylize(Button)
    local function update()
        local x = parent.AbsoluteSize.X
        local size = TextService:GetTextSize(ButtonText.ContentText, ButtonText.TextSize, ButtonText.Font, Vector2.new(x - margin * 2, math.huge))
        Container.Size = UDim2.new(1, 0, 0, size.Y + margin * 2)
    end
    ButtonText.Text = text
    update()
    ButtonText.Changed:Connect(update)
    return Button, ButtonText
end

function UI.CreateSwitch(parent, text, value)
    local margin = 5
    local switchsize = 50
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Button = Util.Instance("TextButton", Container)
    Button.AnchorPoint = Vector2.new(0, 0)
    Button.Position = UDim2.new(0, 0, 0, 0)
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    local ButtonText = Util.Instance("TextLabel", Button)
    ButtonText.AnchorPoint = Vector2.new(0, 0)
    ButtonText.Position = UDim2.new(0, margin, 0, 0)
    ButtonText.Size = UDim2.new(1, margin * -3 - switchsize, 1, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.RichText = true
    ButtonText.Font = Enum.Font.Code
    ButtonText.TextColor3 = Color3.new(1, 1, 1)
    ButtonText.TextTransparency = 0
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.TextYAlignment = Enum.TextYAlignment.Center
    ButtonText.TextWrapped = true
    ButtonText.TextSize = 16
    ButtonText.Text = text
    RegisterTextLabel(ButtonText)
    local Switch = Util.Instance("Frame", Container)
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -margin, 0.5, 0)
    Switch.Size = UDim2.new(0, 25, 0, 25)
    Switch.BackgroundTransparency = 0
    Switch.BackgroundColor3 = Color3.new(0, 0, 0)
    Switch.BorderSizePixel = 0
    Util.Instance("UICorner", Switch).CornerRadius = UDim.new(0, 5)
    Stylize(Switch)
    local SwitchDot = Util.Instance("Frame", Switch)
    SwitchDot.AnchorPoint = Vector2.new(0.5, 0.5)
    SwitchDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    SwitchDot.Size = UDim2.new(0, 19, 0, 19)
    SwitchDot.BackgroundTransparency = 0.2
    SwitchDot.BackgroundColor3 = UITextColor.Value
    SwitchDot.BorderSizePixel = 0
    Util.LinkDestroyI2C(SwitchDot, UITextColor.Changed:Connect(function(val)
        SwitchDot.BackgroundColor3 = val
    end))
    Util.Instance("UICorner", SwitchDot).CornerRadius = UDim.new(0, 2)
    local Lever = Util.Instance("BoolValue")
    Lever.Value = value
    local function updatesw()
        SwitchDot.Visible = Lever.Value
    end
    Lever.Changed:Connect(updatesw)
    updatesw()
    Button.Activated:Connect(function()
        Lever.Value = not Lever.Value
    end)
    return Lever, ButtonText
end

function UI.CreateSlider(parent, text, value, min, max, step)
    min = min or 1
    max = max or 10
    step = math.abs(step or 0)
    assert(max > min)
    local margin = 5
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 65)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Text = Util.Instance("TextLabel", Container)
    Text.AnchorPoint = Vector2.new(0, 0)
    Text.Position = UDim2.new(0, margin, 0, 0)
    Text.Size = UDim2.new(1, margin * -2, 0, 30)
    Text.BackgroundTransparency = 1
    Text.RichText = true
    Text.Font = Enum.Font.Code
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextTransparency = 0
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Center
    Text.TextWrapped = true
    Text.TextSize = 16
    Text.Text = text
    RegisterTextLabel(Text)
    local Box = Util.Instance("Frame", Container)
    Box.AnchorPoint = Vector2.new(1, 0)
    Box.Position = UDim2.new(1, -margin, 0, margin)
    Box.Size = UDim2.new(0, 60, 0, 30 - margin * 2)
    Box.BackgroundTransparency = 0
    Box.BackgroundColor3 = Color3.new(1, 1, 1)
    Box.BorderSizePixel = 0
    local BoxText = Util.Instance("TextBox", Box)
    BoxText.AnchorPoint = Vector2.new(0, 0.5)
    BoxText.Position = UDim2.new(0, 0, 0.5, 0)
    BoxText.Size = UDim2.new(1, 0, 1, -margin)
    BoxText.BackgroundTransparency = 1
    BoxText.Font = Enum.Font.Code
    BoxText.TextColor3 = Color3.new(1, 1, 1)
    BoxText.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
    BoxText.TextTransparency = 0
    BoxText.TextXAlignment = Enum.TextXAlignment.Center
    BoxText.TextYAlignment = Enum.TextYAlignment.Center
    BoxText.TextWrapped = true
    BoxText.TextSize = 14
    BoxText.ClearTextOnFocus = false
    RegisterTextLabel(BoxText)
    BoxText.Focused:Connect(function()
        UISound.Click:Play()
    end)
    Stylize(Box, {Depthed = true})
    local SliderC = Util.Instance("TextButton", Container)
    SliderC.AnchorPoint = Vector2.new(0, 0)
    SliderC.Position = UDim2.new(0, 0, 0, 35)
    SliderC.Size = UDim2.new(1, 0, 0, 25)
    SliderC.BackgroundTransparency = 1
    SliderC.Text = ""
    SliderC.AutoButtonColor = true
    local SliderR = Util.Instance("Frame", SliderC)
    SliderR.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderR.Position = UDim2.new(0.5, 0, 0.5, 0)
    SliderR.Size = UDim2.new(1, margin * -2 - 18, 0, 5)
    SliderR.BackgroundTransparency = 0
    SliderR.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderR.BorderSizePixel = 0
    local SliderB = Util.Instance("Frame", SliderR)
    SliderB.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderB.Position = UDim2.new(0, 0, 0.5, 0)
    SliderB.Size = UDim2.new(0, 18, 0, 18)
    SliderB.BackgroundTransparency = 0
    SliderB.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderB.BorderSizePixel = 0
    SliderB.ZIndex = 2
    Stylize(SliderR, {Depthed = true})
    Stylize(SliderB)
    local range = max - min
    local Select = Util.Instance("NumberValue")
    local function update()
        local str = string.format("%.1f", Select.Value)
        BoxText.Text = str
        SliderB.Position = UDim2.new(math.clamp((Select.Value - min) / (max - min), 0, 1), 0, 0.5, 0)
    end
    Select.Value = value
    Select.Changed:Connect(update)
    update()
    BoxText.FocusLost:Connect(function()
        Select.Value = tonumber(BoxText.Text) or Select.Value
        update()
    end)
    local function ondrag(x)
        local val = range * math.clamp((x - SliderR.AbsolutePosition.X) / SliderR.AbsoluteSize.X, 0, 1)
        if step > 0 then
            val = math.round(val / step) * step
        end
        val += min
        Select.Value = val
    end
    local dragref = nil
    local start = nil
    SliderC.InputBegan:Connect(function(input)
        if input.UserInputState ~= Enum.UserInputState.Begin then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragref = input
            start = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragref then
            if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and dragref == input) then
                if start then
                    local delta = input.Position - start
                    if delta.Magnitude > 10 then
                        start = nil
                    end
                else
                    ondrag(input.Position.X)
                end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragref and dragref == input then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ondrag(input.Position.X)
                dragref = nil
            end
        end
    end)
    return Select
end

function UI.CreateDropdown(parent, text, array, value)
    value = value and math.clamp(value, 1, #array) or 1
    local margin = 5
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Text = Util.Instance("TextLabel", Container)
    Text.AnchorPoint = Vector2.new(0, 0)
    Text.Position = UDim2.new(0, margin, 0, 0)
    Text.Size = UDim2.new(0.4, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.RichText = true
    Text.Font = Enum.Font.Code
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextTransparency = 0
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Center
    Text.TextWrapped = true
    Text.TextSize = 16
    Text.Text = text
    RegisterTextLabel(Text)
    local Dropdown = Util.Instance("TextButton", Container)
    Dropdown.AnchorPoint = Vector2.new(1, 0.5)
    Dropdown.Position = UDim2.new(1, -margin, 0.5, 0)
    Dropdown.Size = UDim2.new(0.55, 0, 1, -margin)
    Dropdown.BackgroundTransparency = 0
    Dropdown.BackgroundColor3 = Color3.new(1, 1, 1)
    Dropdown.BorderSizePixel = 0
    Dropdown.Text = ""
    Dropdown.AutoButtonColor = true
    local DropdownText = Util.Instance("TextLabel", Dropdown)
    DropdownText.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownText.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownText.Size = UDim2.new(1, -margin * 2, 1, -margin)
    DropdownText.BackgroundTransparency = 1
    DropdownText.RichText = true
    DropdownText.Font = Enum.Font.Code
    DropdownText.TextColor3 = Color3.new(1, 1, 1)
    DropdownText.TextTransparency = 0
    DropdownText.TextXAlignment = Enum.TextXAlignment.Center
    DropdownText.TextYAlignment = Enum.TextYAlignment.Center
    DropdownText.TextWrapped = true
    DropdownText.TextSize = 14
    DropdownText.Text = array[value]
    RegisterTextLabel(DropdownText)
    Stylize(Dropdown)
    local Select = Util.Instance("IntValue")
    Select.Value = value
    Select.Changed:Connect(function()
        DropdownText.Text = array[Select.Value]
    end)
    local Droplist = Util.Instance("ScrollingFrame", UIMainFrame)
    Droplist.AnchorPoint = Vector2.new(0, 0)
    Droplist.Position = UDim2.new(0, 0, 0, 0)
    Droplist.Size = UDim2.new(0, 0, 0, 0)
    Droplist.BackgroundTransparency = 0
    Droplist.BackgroundColor3 = Color3.new(1, 1, 1)
    Droplist.BorderSizePixel = 0
    Droplist.Visible = false
    Droplist.CanvasSize = UDim2.new(0, 0, 0, 0)
    Droplist.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Droplist.ScrollBarThickness = 0
    Droplist.ScrollingDirection = Enum.ScrollingDirection.Y
    local Padding = Util.Instance("UIPadding", Droplist)
    Padding.PaddingLeft = UDim.new(0, 5)
    Padding.PaddingRight = UDim.new(0, 5)
    Padding.PaddingTop = UDim.new(0, 0)
    Padding.PaddingBottom = UDim.new(0, 0)
    local UIList = Util.Instance("UIListLayout", Droplist)
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.VerticalAlignment = Enum.VerticalAlignment.Top
    UIList.Padding = UDim.new(0, 0)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    Stylize(Droplist, {Glow = true})
    local items = {}
    local sizex = 60
    local interact = false
    local opened = false
    Util.LinkDestroyI2I(Dropdown, Droplist)
    for i,itemname in array do
        local Item = Util.Instance("TextButton", Droplist)
        Item.Size = UDim2.new(1, 0, 0, 25)
        Item.BackgroundTransparency = 0
        Item.BackgroundColor3 = Color3.new(0, 0, 0)
        Item.BorderSizePixel = 0
        Item.AutoButtonColor = true
        Item.LayoutOrder = i
        Item.Text = itemname
        Item.TextSize = 14
        Item.Font = Enum.Font.Code
        Item.TextColor3 = Color3.new(1, 1, 1)
        Item.TextXAlignment = Enum.TextXAlignment.Left
        Item.TextYAlignment = Enum.TextYAlignment.Center
        Item.TextWrapped = false
        RegisterTextLabel(Item)
        table.insert(items, Item)
        local size = TextService:GetTextSize(itemname, Item.TextSize, Item.Font, Vector2.new(math.huge, math.huge))
        sizex = math.max(sizex, size.X + 12)
        Item.Activated:Connect(function()
            Select.Value = i
            opened = false
            interact = true
        end)
        Item.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                interact = true
                UISound.Click:Play()
            end
        end)
    end
    Dropdown.Activated:Connect(function()
        opened = not opened
        interact = true
    end)
    local conn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            task.wait()
            if not interact then
                opened = false
            end
            interact = false
        end
    end)
    Util.LinkDestroyI2C(Dropdown, conn)
    local opentween = 0
    local _funcrefreshes = {}
    local function AddToRenderStep(func, linkto)
        table.insert(_funcrefreshes, func)
        if linkto then
            linkto.Destroying:Connect(function()
                local i = table.find(_funcrefreshes, func)
                if i then
                    table.remove(_funcrefreshes, i)
                end
            end)
        end
        return func
    end
    AddToRenderStep(function(t, dt)
        if opened then
            opentween = 1 + (opentween - 1) * math.exp(-32 * dt)
            Droplist.ZIndex = 4
            Droplist.Interactable = true
        else
            opentween *= math.exp(-32 * dt)
            Droplist.ZIndex = 3
            Droplist.Interactable = false
        end
        local ysize = math.round(math.min(120, #items * 25) * opentween)
        if ysize >= 1 then
            Droplist.Position = Util.Vector2ToUDim2Offset((Dropdown.AbsolutePosition + Vector2.new(0, Dropdown.AbsoluteSize.Y)) - UIMainFrame.AbsolutePosition)
            Droplist.Size = UDim2.new(0, math.max(Dropdown.Size.X.Offset, sizex), 0, ysize)
            Droplist.Visible = true
        else
            Droplist.Visible = false
        end
        local i1 = GetUIBGColor(t)
        local i2 = i1:Lerp(Color3.new(1, 1, 1), 0.1)
        for i,v in items do
            if i == Select.Value then
                v.BackgroundColor3 = i2
            else
                v.BackgroundColor3 = i1
            end
        end
    end, Droplist)
    Util.LinkDestroyI2I(Dropdown, Select)
    return Select, Text
end

function UI.CreateSeparator(parent)
    local Container = Util.Instance("Frame", parent)
    Container.AnchorPoint = Vector2.new(0.5, 0)
    Container.Size = UDim2.new(1, 0, 0, 7)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = #parent:GetChildren()
    local Sep = Util.Instance("Frame", Container)
    Sep.AnchorPoint = Vector2.new(0.5, 0.5)
    Sep.Position = UDim2.new(0.5, 0, 0.5, 0)
    Sep.Size = UDim2.new(1, -10, 0, 1)
    Sep.BackgroundColor3 = UITextColor.Value
    Sep.BackgroundTransparency = 0.8
    Sep.BorderSizePixel = 0
    Util.LinkDestroyI2C(Sep, UITextColor.Changed:Connect(function(val)
        Sep.BackgroundColor3 = val
    end))
end

-- ═══════════════════════════════════════════════════════════
-- CREATE PAGES
-- ═══════════════════════════════════════════════════════════
local MainPage = UI.CreatePage()
local OrbitPage = UI.CreatePage()
local PlayerPage = UI.CreatePage()
local MusicPage = UI.CreatePage()
local SettingsPage = UI.CreatePage()

-- Store UI references
local reanimateBtn, reanimateBtnText
local currentTrackText
local flySwitch, noClipSwitch, invisSwitch, godSwitch
local walkSlider, jumpSlider
local speedSlider, sizeSlider, modeDropdown

-- MAIN PAGE
UI.CreateText(MainPage, "NIKS HAT ORBIT - QUANTUM EDITION", 20, Enum.TextXAlignment.Center)
UI.CreateText(MainPage, "1 Quintillion Force System", 14, Enum.TextXAlignment.Center)
UI.CreateSeparator(MainPage)

-- REANIMATE BUTTON (MAIN FEATURE)
reanimateBtn, reanimateBtnText = UI.CreateButton(MainPage, "🔥 ACTIVATE ORBIT SYSTEM 🔥", 18)
reanimateBtn.Activated:Connect(function()
    if not isReanimated then
        isReanimated = true
        reanimateBtnText.Text = "⚡ ORBIT ACTIVE ⚡"
        if initialize() then
            Util.Notify("Orbit system activated! 1 Quintillion Force!")
            BackgroundMusic.DownloadAndPlay(BackgroundMusic.CurrentTrackIndex)
        else
            Util.Notify("Failed - No accessories found")
            isReanimated = false
            reanimateBtnText.Text = "🔥 ACTIVATE ORBIT SYSTEM 🔥"
        end
    else
        Util.Notify("Orbit already active!")
    end
end)

UI.CreateSeparator(MainPage)
UI.CreateText(MainPage, "Features:", 14, Enum.TextXAlignment.Left)
UI.CreateText(MainPage, "• 1,000,000,000,000,000,000 P-Force\n• 12 Cinematic Orbit Modes\n• Advanced Hat Fall Detection\n• Player Control System\n• Background Music Player\n• Beautiful Customizable UI", 12, Enum.TextXAlignment.Left)
UI.CreateSeparator(MainPage)

local function CreatePageButton(parent, text, page)
    local btn = UI.CreateButton(parent, text, 16)
    btn.Activated:Connect(function()
        MainPage.Visible = false
        OrbitPage.Visible = false
        PlayerPage.Visible = false
        MusicPage.Visible = false
        SettingsPage.Visible = false
        page.Visible = true
    end)
end

CreatePageButton(MainPage, "⚡ Orbit Controls", OrbitPage)
CreatePageButton(MainPage, "👤 Player Controls", PlayerPage)
CreatePageButton(MainPage, "♫ Music Player", MusicPage)
CreatePageButton(MainPage, "⚙️ Settings & Themes", SettingsPage)

-- ORBIT PAGE
UI.CreateText(OrbitPage, "⚡ ORBIT CONTROLS", 18, Enum.TextXAlignment.Center)
UI.CreateSeparator(OrbitPage)

local modeNames = {}
for i = 1, 12 do
    table.insert(modeNames, i .. ". " .. MODE_CONFIGS[i].name)
end
modeDropdown = UI.CreateDropdown(OrbitPage, "Orbit Mode", modeNames, config.mode)
modeDropdown.Changed:Connect(function()
    config.mode = modeDropdown.Value
    Util.Notify("Mode: " .. MODE_CONFIGS[config.mode].name)
end)

speedSlider = UI.CreateSlider(OrbitPage, "Orbit Speed", config.speed, 0.1, 20, 0.1)
speedSlider.Changed:Connect(function()
    config.speed = speedSlider.Value
end)

sizeSlider = UI.CreateSlider(OrbitPage, "Orbit Size", config.offset, 5, 50, 1)
sizeSlider.Changed:Connect(function()
    config.offset = sizeSlider.Value
end)

UI.CreateSeparator(OrbitPage)
local backBtn1 = UI.CreateButton(OrbitPage, "← Back to Main", 16)
backBtn1.Activated:Connect(function()
    OrbitPage.Visible = false
    MainPage.Visible = true
end)

-- PLAYER PAGE
UI.CreateText(PlayerPage, "👤 PLAYER CONTROLS", 18, Enum.TextXAlignment.Center)
UI.CreateSeparator(PlayerPage)

flySwitch = UI.CreateSwitch(PlayerPage, "Fly Mode", false)
noClipSwitch = UI.CreateSwitch(PlayerPage, "NoClip", false)
invisSwitch = UI.CreateSwitch(PlayerPage, "Invisible", false)
godSwitch = UI.CreateSwitch(PlayerPage, "God Mode", false)

UI.CreateSeparator(PlayerPage)

walkSlider = UI.CreateSlider(PlayerPage, "Walk Speed", 16, 16, 200, 1)
jumpSlider = UI.CreateSlider(PlayerPage, "Jump Power", 50, 50, 300, 1)

UI.CreateSeparator(PlayerPage)
local backBtn2 = UI.CreateButton(PlayerPage, "← Back to Main", 16)
backBtn2.Activated:Connect(function()
    PlayerPage.Visible = false
    MainPage.Visible = true
end)

-- MUSIC PAGE
UI.CreateText(MusicPage, "♫ MUSIC PLAYER", 18, Enum.TextXAlignment.Center)
UI.CreateSeparator(MusicPage)

currentTrackText = UI.CreateText(MusicPage, "♫ Now Playing: " .. BackgroundMusic.Tracks[1].Name, 14, Enum.TextXAlignment.Center)

local prevTrackBtn = UI.CreateButton(MusicPage, "⏮ Previous Track", 16)
prevTrackBtn.Activated:Connect(function()
    BackgroundMusic.PreviousTrack()
    currentTrackText.Text = "♫ Now Playing: " .. BackgroundMusic.Tracks[BackgroundMusic.CurrentTrackIndex].Name
end)

local nextTrackBtn = UI.CreateButton(MusicPage, "Next Track ⏭", 16)
nextTrackBtn.Activated:Connect(function()
    BackgroundMusic.NextTrack()
    currentTrackText.Text = "♫ Now Playing: " .. BackgroundMusic.Tracks[BackgroundMusic.CurrentTrackIndex].Name
end)

UI.CreateSeparator(MusicPage)

local musicVolSlider = UI.CreateSlider(MusicPage, "Music Volume", 0.3, 0, 1, 0.01)
musicVolSlider.Changed:Connect(function()
    BackgroundMusic.SetVolume(musicVolSlider.Value)
end)

UI.CreateSeparator(MusicPage)

UI.CreateText(MusicPage, "Available Tracks:", 14, Enum.TextXAlignment.Left)
for i, track in ipairs(BackgroundMusic.Tracks) do
    UI.CreateText(MusicPage, i .. ". " .. track.Name, 12, Enum.TextXAlignment.Left)
end

UI.CreateSeparator(MusicPage)
local backBtn4 = UI.CreateButton(MusicPage, "← Back to Main", 16)
backBtn4.Activated:Connect(function()
    MusicPage.Visible = false
    MainPage.Visible = true
end)

-- SETTINGS PAGE
UI.CreateText(SettingsPage, "⚙️ SETTINGS", 18, Enum.TextXAlignment.Center)
UI.CreateSeparator(SettingsPage)

local themeNames = {
    "RGB Default", "Monochrome", "Oxide Blue", "Patchma",
    "Genesis Purple", "Crimson Red", "Matrix Green", "Homer Yellow",
    "Dark Mode", "Light Mode", "FT2 Blue", "Cherry Blossom"
}
local themeDropdown = UI.CreateDropdown(SettingsPage, "UI Theme", themeNames, SaveData.UITheme)
themeDropdown.Changed:Connect(function()
    SaveData.UITheme = themeDropdown.Value
    SetUITheme(SaveData.UITheme)
    Util.Notify("Theme: " .. themeNames[SaveData.UITheme])
end)

local soundSwitch = UI.CreateSwitch(SettingsPage, "UI Sounds", not SaveData.MuteUISound)
soundSwitch.Changed:Connect(function()
    SaveData.MuteUISound = not soundSwitch.Value
    UISound.Click.Volume = soundSwitch.Value and 1 or 0
end)

local musicSwitch = UI.CreateSwitch(SettingsPage, "Background Music", not SaveData.MuteMusic)
musicSwitch.Changed:Connect(function()
    SaveData.MuteMusic = not musicSwitch.Value
    if SaveData.MuteMusic then
        BackgroundMusic.Pause()
    else
        BackgroundMusic.Play()
    end
    BackgroundMusic.SetVolume(musicVolSlider.Value)
end)

UI.CreateSeparator(SettingsPage)

local respawnBtn = UI.CreateButton(SettingsPage, "🔄 Respawn Character", 16)
respawnBtn.Activated:Connect(function()
    if instantRespawn and isReanimated then
        instantRespawn()
        Util.Notify("Respawning...")
    else
        Util.Notify("Orbit must be active to respawn")
    end
end)

local cleanupBtn = UI.CreateButton(SettingsPage, "🧹 Cleanup & Reset", 16)
cleanupBtn.Activated:Connect(function()
    if cleanup then
        cleanup()
        isReanimated = false
        reanimateBtnText.Text = "🔥 ACTIVATE ORBIT SYSTEM 🔥"
        BackgroundMusic.Stop()
        Util.Notify("Cleaned up all systems")
    end
end)

UI.CreateSeparator(SettingsPage)
local backBtn3 = UI.CreateButton(SettingsPage, "← Back to Main", 16)
backBtn3.Activated:Connect(function()
    SettingsPage.Visible = false
    MainPage.Visible = true
end)

-- Show main page by default
MainPage.Visible = true

-- ═══════════════════════════════════════════════════════════
-- RENDER LOOP
-- ═══════════════════════════════════════════════════════════
local _totalrendertime = 0
local _funcrefreshes = {}

local function AddToRenderStep(func, linkto)
    table.insert(_funcrefreshes, func)
    if linkto then
        linkto.Destroying:Connect(function()
            local i = table.find(_funcrefreshes, func)
            if i then
                table.remove(_funcrefreshes, i)
            end
        end)
    end
    return func
end

RunService:BindToRenderStep("NiksOrbit_Render" .. Util.RandomString(), Enum.RenderPriority.Last.Value - 69, function(dt)
    _totalrendertime += dt
    UpdateGrads(_totalrendertime)
    WindowContent.Visible = UIMainWindow.Size.Y.Offset > 40
    for _,func in _funcrefreshes do
        local s, e = pcall(func, _totalrendertime, dt)
        if not s then warn(e) end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- CORE ORBIT FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local function safeCall(func, context)
    local success, err = pcall(func)
    return success
end

local function loadNetBypass1()
    safeCall(function()
        local success, result = pcall(function()
            return game:HttpGet("https://gist.githubusercontent.com/MoroccanfromRED/66df89a007fe80b80d6321cbcc3eb0cd/raw/a7a3d042e217d905b932eae7dc189953340c29ae/NET%2520bypass", true)
        end)
        if success and result then
            local executeFunc = loadstring(result)
            if executeFunc then executeFunc() end
        end
    end, "Net Bypass 1")
end

local function setupTripleNetBypass()
    loadNetBypass1()
    task.wait(0.1)
    safeCall(function()
        settings().Physics.AllowSleep = false
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        settings().Physics.ThrottleAdjustTime = 0
    end, "Physics Settings")
    task.spawn(function()
        while task.wait(0.05) do
            safeCall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Player then
                        player.MaximumSimulationRadius = 0.001
                        player.SimulationRadius = 0
                    else
                        player.MaximumSimulationRadius = math.huge
                        player.SimulationRadius = math.huge
                    end
                end
            end, "Network Priority")
        end
    end)
end

local function saveCamera()
    safeCall(function()
        if camera then
            savedCameraCFrame = camera.CFrame
            savedCameraType = camera.CameraType
        end
    end, "Save Camera")
end

local function lockCamera()
    safeCall(function()
        if camera and savedCameraCFrame then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = savedCameraCFrame
        end
    end, "Lock Camera")
end

local function unlockCamera()
    safeCall(function()
        if camera and savedCameraType then
            camera.CameraType = savedCameraType
        end
    end, "Unlock Camera")
end

local function updateSafePosition()
    if not hrp or not hrp.Parent then return end
    safeCall(function()
        if hrp.Position.Y > -100 then
            lastSafePosition = hrp.Position
            lastSafeCFrame = hrp.CFrame
            saveCamera()
        end
    end, "Position Update")
end

local function restorePosition()
    if not hrp or not hrp.Parent then return end
    safeCall(function()
        lockCamera()
        hrp.CFrame = lastSafeCFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.05)
        unlockCamera()
    end, "Position Restore")
end

local function checkIfAnyHatFell()
    if not chr or not hrp or not hrp.Parent then return false end
    local hatFell = false
    for i, acc in ipairs(accessories) do
        safeCall(function()
            local handle = acc.handle
            local orbitPart = orbitParts[i]
            if handle and handle.Parent and orbitPart and orbitPart.Parent then
                local distance = (handle.Position - orbitPart.Position).Magnitude
                if distance > config.hatFallThreshold then
                    hatFell = true
                end
                if handle.AssemblyLinearVelocity.Y < config.hatYThreshold then
                    hatFell = true
                end
                if handle.Position.Y < -50 then
                    hatFell = true
                end
            else
                hatFell = true
            end
        end, "Hat Check")
    end
    return hatFell
end

function instantRespawn()
    if respawnInProgress or not chr or not hum then return end
    respawnInProgress = true
    safeCall(function()
        updateSafePosition()
        saveCamera()
        lockCamera()
        hum.Health = 0
        task.spawn(function()
            for _, part in ipairs(chr:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    safeCall(function() part:Destroy() end, "Limb")
                end
            end
        end)
        task.wait(0.01)
        if hrp and hrp.Parent then
            safeCall(function() hrp:Destroy() end, "HRP")
        end
    end, "Instant Respawn")
end

local function setupAccessories()
    if not chr or not hum then return false end
    local accessoryList = hum:GetAccessories()
    totalAccessories = #accessoryList
    if totalAccessories == 0 then return false end
    for _, accessory in ipairs(accessoryList) do
        safeCall(function()
            local handle = accessory:FindFirstChild("Handle")
            if not handle then return end
            for _, obj in ipairs(handle:GetDescendants()) do
                if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") or 
                   (obj:IsA("Constraint") and not obj.Name:find("Orbit")) then
                    obj:Destroy()
                end
            end
            handle:BreakJoints()
            handle.CustomPhysicalProperties = PhysicalProperties.new(0.00000001, 0, 0, 0, 0)
            handle.CanCollide = false
            handle.Massless = true
            handle.CanTouch = false
            handle.CanQuery = false
            local accessoryWeld = handle:FindFirstChild("AccessoryWeld")
            if accessoryWeld then accessoryWeld:Destroy() end
            local bodyPos = Instance.new("BodyPosition")
            bodyPos.Name = "OrbitBodyPos"
            bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyPos.P = QUINTILLION
            bodyPos.D = 10000000
            bodyPos.Position = handle.Position
            bodyPos.Parent = handle
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "OrbitBodyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.zero
            bodyVel.P = QUINTILLION / 2
            bodyVel.Parent = handle
            local angularVel = Instance.new("BodyAngularVelocity")
            angularVel.Name = "OrbitAngularVel"
            angularVel.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            angularVel.AngularVelocity = config.angular
            angularVel.P = QUINTILLION / 2
            angularVel.Parent = handle
            local att0 = Instance.new("Attachment", handle)
            att0.Name = "OrbitAtt0"
            local att1 = Instance.new("Attachment", chr.Head)
            att1.Name = "OrbitAtt1"
            local alignPos = Instance.new("AlignPosition")
            alignPos.Name = "OrbitAlign"
            alignPos.MaxForce = math.huge
            alignPos.MaxVelocity = math.huge
            alignPos.Responsiveness = 200
            alignPos.RigidityEnabled = true
            alignPos.ApplyAtCenterOfMass = true
            alignPos.Attachment0 = att0
            alignPos.Attachment1 = att1
            alignPos.Parent = handle
            table.insert(accessories, {
                handle = handle,
                bodyPos = bodyPos,
                bodyVel = bodyVel,
                angular = angularVel,
                attachment = att1
            })
            table.insert(orbitAttachments, att1)
            table.insert(angularVelocities, angularVel)
        end, "Accessory Setup")
    end
    return #accessories > 0
end

local function createOrbitParts()
    for i = 1, #orbitAttachments do
        safeCall(function()
            local part = Instance.new("Part")
            part.Name = "OrbitPoint_" .. i
            part.Anchored = true
            part.Size = Vector3.new(0.1, 0.1, 0.1)
            part.Transparency = 1
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Parent = workspace
            table.insert(orbitParts, part)
        end, "Orbit")
    end
end

local function updateAnimation()
    if not chr or not hrp or not hrp.Parent then return end
    angleCounter = angleCounter + config.speed
    if angleCounter > 360 then angleCounter = angleCounter - 360 end
    timeCounter = timeCounter + 0.016
    local mode = config.mode
    local offset = config.offset
    
    for i, part in ipairs(orbitParts) do
        safeCall(function()
            if part and part.Parent then
                local angle = math.rad(angleCounter + (360 / #orbitParts) * (i - 1))
                local x = math.cos(angle) * offset
                local z = math.sin(angle) * offset
                local y = 0
                
                -- Apply mode-specific patterns
                if mode == 2 then
                    y = 3 + math.sin(timeCounter * 2) * 0.5
                elseif mode == 3 then
                    local ring = (i % 2 == 0) and 1 or -1
                    y = math.sin(timeCounter + i) * 1.5
                elseif mode == 4 then
                    y = math.sin((timeCounter + i * 30) / 10) * 3
                elseif mode == 5 then
                    local spiralRadius = offset + math.sin(angle + timeCounter) * 3
                    x = math.cos(angle) * spiralRadius
                    z = math.sin(angle) * spiralRadius
                    y = math.sin(angle * 2) * 2
                end
                
                part.CFrame = CFrame.new(hrp.Position + Vector3.new(x, y, z))
            end
        end, "Animation")
    end
    
    for i, att in ipairs(orbitAttachments) do
        safeCall(function()
            if att and att.Parent and orbitParts[i] and orbitParts[i].Parent then
                local rel = hrp.CFrame:ToObjectSpace(CFrame.new(orbitParts[i].Position))
                att.Position = Vector3.new(rel.X, rel.Y, rel.Z)
            end
        end, "Attachment")
    end
    
    for _, angularVel in ipairs(angularVelocities) do
        safeCall(function()
            if angularVel and angularVel.Parent then
                angularVel.AngularVelocity = config.angular
            end
        end, "Angular")
    end
end

function cleanup()
    safeCall(function()
        for _, conn in pairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        for _, part in ipairs(orbitParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        table.clear(accessories)
        table.clear(orbitAttachments)
        table.clear(angularVelocities)
        table.clear(orbitParts)
        table.clear(connections)
        isInitialized = false
    end, "Cleanup")
end

function initialize()
    chr = Player.Character
    if not chr then return false end
    hum = chr:FindFirstChild("Humanoid")
    hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    
    if hum then
        originalWalkSpeed = hum.WalkSpeed
        originalJumpPower = hum.JumpPower
    end
    originalGravity = workspace.Gravity
    
    lastSafePosition = hrp.Position
    lastSafeCFrame = hrp.CFrame
    saveCamera()
    
    if not setupAccessories() then return false end
    createOrbitParts()
    
    connections.force = RunService.RenderStepped:Connect(function()
        if not chr or not hrp or not hrp.Parent or not isReanimated then return end
        for i, acc in ipairs(accessories) do
            safeCall(function()
                local handle = acc.handle
                local bodyPos = acc.bodyPos
                local orbitPart = orbitParts[i]
                if handle and handle.Parent and bodyPos and orbitPart and orbitPart.Parent then
                    bodyPos.Position = orbitPart.Position
                    local distance = (handle.Position - orbitPart.Position).Magnitude
                    if distance > 0.1 then
                        handle.CFrame = CFrame.new(orbitPart.Position)
                        handle.AssemblyLinearVelocity = Vector3.zero
                        handle.AssemblyAngularVelocity = Vector3.zero
                    end
                    handle.AssemblyLinearVelocity = Vector3.new(
                        handle.AssemblyLinearVelocity.X * 0.99,
                        0,
                        handle.AssemblyLinearVelocity.Z * 0.99
                    )
                    handle.CanCollide = false
                    handle.Massless = true
                    handle.CanTouch = false
                    handle.CanQuery = false
                end
            end, "1Q Force")
        end
    end)
    
    connections.antiDrop = RunService.Heartbeat:Connect(function()
        if not chr or not hrp or not hrp.Parent or not isReanimated then return end
        for i, acc in ipairs(accessories) do
            safeCall(function()
                local handle = acc.handle
                local bodyPos = acc.bodyPos
                local bodyVel = acc.bodyVel
                local orbitPart = orbitParts[i]
                if handle and handle.Parent and bodyPos and orbitPart and orbitPart.Parent then
                    bodyPos.Position = orbitPart.Position
                    if bodyVel then
                        bodyVel.Velocity = Vector3.zero
                    end
                    if math.abs(handle.AssemblyLinearVelocity.Y) > 0.001 then
                        handle.AssemblyLinearVelocity = Vector3.new(
                            handle.AssemblyLinearVelocity.X,
                            0,
                            handle.AssemblyLinearVelocity.Z
                        )
                    end
                    local distance = (handle.Position - orbitPart.Position).Magnitude
                    if distance > 0.5 then
                        handle.CFrame = CFrame.new(orbitPart.Position)
                        handle.AssemblyLinearVelocity = Vector3.zero
                        handle.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end, "Quantum Anti-Drop")
        end
    end)
    
    connections.hatDetect = RunService.Heartbeat:Connect(function()
        if not isReanimated then return end
        if checkIfAnyHatFell() and not respawnInProgress then
            instantRespawn()
        end
    end)
    
    task.spawn(function()
        while task.wait(0.1) do
            if not isReanimated then break end
            updateSafePosition()
        end
    end)
    
    connections.main = RunService.RenderStepped:Connect(function()
        if not isReanimated then return end
        safeCall(updateAnimation, "Animation")
    end)
    
    isInitialized = true
    return true
end

-- Player controls
walkSlider.Changed:Connect(function()
    if hum then
        hum.WalkSpeed = walkSlider.Value
    end
end)

jumpSlider.Changed:Connect(function()
    if hum then
        hum.JumpPower = jumpSlider.Value
    end
end)

flySwitch.Changed:Connect(function()
    flyEnabled = flySwitch.Value
    if flyEnabled then
        if not chr or not hrp then 
            Util.Notify("Character not found!")
            flySwitch.Value = false
            return 
        end
        if not connections.fly then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(0, 0, 0)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.Parent = hrp
            connections.fly = RunService.Heartbeat:Connect(function()
                if not hrp or not hrp.Parent then return end
                local moveDirection = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Velocity = moveDirection.Unit * 50
            end)
            Util.Notify("Fly Mode: Enabled")
        end
    else
        if connections.fly then
            connections.fly:Disconnect()
            connections.fly = nil
            if hrp then
                local bodyVel = hrp:FindFirstChild("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
            Util.Notify("Fly Mode: Disabled")
        end
    end
end)

noClipSwitch.Changed:Connect(function()
    noClipEnabled = noClipSwitch.Value
    if noClipEnabled then
        if not chr then 
            Util.Notify("Character not found!")
            noClipSwitch.Value = false
            return 
        end
        connections.noclip = RunService.Stepped:Connect(function()
            if not chr then return end
            for _, part in pairs(chr:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        Util.Notify("NoClip: Enabled")
    else
        if connections.noclip then
            connections.noclip:Disconnect()
            connections.noclip = nil
            Util.Notify("NoClip: Disabled")
        end
    end
end)

invisSwitch.Changed:Connect(function()
    invisibleEnabled = invisSwitch.Value
    if not chr then 
        Util.Notify("Character not found!")
        invisSwitch.Value = false
        return 
    end
    if invisibleEnabled then
        for _, part in pairs(chr:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 1
            end
        end
        Util.Notify("Invisible: Enabled")
    else
        for _, part in pairs(chr:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name == "HumanoidRootPart" then
                    part.Transparency = 1
                else
                    part.Transparency = 0
                end
            elseif part:IsA("Decal") then
                part.Transparency = 0
            end
        end
        Util.Notify("Invisible: Disabled")
    end
end)

godSwitch.Changed:Connect(function()
    godModeEnabled = godSwitch.Value
    if godModeEnabled then
        if not hum then 
            Util.Notify("Humanoid not found!")
            godSwitch.Value = false
            return 
        end
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        connections.godmode = hum.HealthChanged:Connect(function()
            if godModeEnabled then
                hum.Health = math.huge
            end
        end)
        Util.Notify("God Mode: Enabled")
    else
        if connections.godmode then
            connections.godmode:Disconnect()
            connections.godmode = nil
            if hum then
                hum.MaxHealth = 100
                hum.Health = 100
            end
            Util.Notify("God Mode: Disabled")
        end
    end
end)

-- Respawn handler
Player.CharacterAdded:Connect(function(newChar)
    respawnInProgress = false
    chr = newChar
    hum = chr:WaitForChild("Humanoid", 5)
    hrp = chr:WaitForChild("HumanoidRootPart", 5)
    
    task.wait(0.1)
    restorePosition()
    cleanup()
    task.wait(0.1)
    if isReanimated and initialize() then
        Util.Notify("System restored!")
    end
end)

-- Initialize network bypass
setupTripleNetBypass()

Util.Notify("Niks Orbit Quantum UI loaded! Press the button to activate!")
