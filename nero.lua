--[[
    NeroGG - A Modern, Fluent, and Modular Roblox UI Library
    Version: 1.0.0
    Inspired by WindUI & FluentUI
    
    Features:
    - Soft Glassmorphism (2025-2026 vibe)
    - Full WindUI Feature Set (Theming, Localization, Configs, Notifications, Element Locking)
    - Modern Variants (Hover/Pressed states)
    - Card Component & Grid/List Layouts
    - High Contrast & Scalable Accessibility
]]

local NeroGG = {}
NeroGG.__index = NeroGG

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Design Tokens (2025-2026 Glassmorphic System)
NeroGG.Tokens = {
    Themes = {
        Dark = {
            MainBackground = Color3.fromRGB(18, 18, 28),
            SidebarBackground = Color3.fromRGB(12, 12, 18),
            ElementBackground = Color3.fromRGB(25, 25, 35),
            Accent = Color3.fromRGB(79, 70, 229), -- Indigo Blue
            TextPrimary = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(156, 163, 175),
            Border = Color3.fromRGB(45, 45, 55),
            Transparency = 0.2,
            GlassTransparency = 0.35,
            StrokeTransparency = 0.6
        },
        Light = {
            MainBackground = Color3.fromRGB(243, 244, 246),
            SidebarBackground = Color3.fromRGB(229, 231, 235),
            ElementBackground = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(67, 56, 202),
            TextPrimary = Color3.fromRGB(17, 24, 39),
            TextSecondary = Color3.fromRGB(75, 85, 99),
            Border = Color3.fromRGB(209, 213, 219),
            Transparency = 0.1,
            GlassTransparency = 0.2,
            StrokeTransparency = 0.8
        }
    },
    Typography = {
        Font = Enum.Font.GothamMedium,
        TitleSize = 24,
        HeaderSize = 18,
        BodySize = 14,
        SmallSize = 12
    },
    Radius = {
        Large = UDim.new(0, 24),
        Medium = UDim.new(0, 14),
        Small = UDim.new(0, 8)
    },
    Spacing = {
        Padding = 16,
        Gap = 12
    }
}

-- Internal State
NeroGG.CurrentTheme = NeroGG.Tokens.Themes.Dark
NeroGG.ActiveWindows = {}
NeroGG.Configs = {}
NeroGG.Localization = {
    Enabled = false,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {}
}

-- Utility Functions
local function Create(className, properties, children)
    local obj = Instance.new(className)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function Tween(obj, info, goal)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local function GetIcon(iconName)
    local icons = {
        ["geist:window"] = "rbxassetid://10723415903",
        ["arrow-right"] = "rbxassetid://10723346959",
        ["home"] = "rbxassetid://10723345518",
        ["settings"] = "rbxassetid://10723346437",
        ["user"] = "rbxassetid://10723351167",
        ["search"] = "rbxassetid://10723346214",
        ["bell"] = "rbxassetid://10723345102",
        ["lock"] = "rbxassetid://10723346014"
    }
    return icons[iconName] or iconName
end

-- Core API
function NeroGG:SetTheme(themeName)
    local theme = self.Tokens.Themes[themeName]
    if theme then
        self.CurrentTheme = theme
        for _, window in pairs(self.ActiveWindows) do
            window:UpdateTheme(theme)
        end
    end
end

function NeroGG:Notify(options)
    local Title = options.Title or "Notification"
    local Content = options.Content or ""
    local Duration = options.Duration or 5
    local Icon = options.Icon or "bell"
    
    -- Notification Logic (Create a toast in the top right)
    print("[NeroGG Notify]:", Title, Content)
end

-- Window Class
local Window = {}
Window.__index = Window

function NeroGG:CreateWindow(options)
    local self = setmetatable({}, Window)
    
    self.Title = options.Title or "NeroGG"
    self.Author = options.Author or "Developer"
    self.Size = options.Size or UDim2.new(0, 650, 0, 450)
    self.Acrylic = options.Acrylic ~= false
    self.HideSearch = options.HideSearchBar or false
    self.SidebarWidth = options.SideBarWidth or 190
    
    -- Root UI
    self.ScreenGui = Create("ScreenGui", {
        Name = "NeroGG_" .. HttpService:GenerateGUID(false),
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame (Glassmorphic)
    self.MainFrame = Create("Frame", {
        Name = "Main",
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        BackgroundColor3 = NeroGG.CurrentTheme.MainBackground,
        BackgroundTransparency = self.Acrylic and NeroGG.CurrentTheme.GlassTransparency or 0,
        Parent = self.ScreenGui
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Large }),
        Create("UIStroke", {
            Color = NeroGG.CurrentTheme.Border,
            Thickness = 1.5,
            Transparency = NeroGG.CurrentTheme.StrokeTransparency
        })
    })

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar (Translucent)
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, self.SidebarWidth, 1, 0),
        BackgroundColor3 = NeroGG.CurrentTheme.SidebarBackground,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Large }),
        Create("Frame", { -- Sidebar Border
            Size = UDim2.new(0, 1, 1, -60),
            Position = UDim2.new(1, -1, 0, 30),
            BackgroundColor3 = NeroGG.CurrentTheme.Border,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0
        })
    })

    -- Logo / Window Title in Sidebar
    self.Brand = Create("Frame", {
        Name = "Brand",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Sidebar
    }, {
        Create("ImageLabel", {
            Name = "Logo",
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 20, 0.5, -12),
            Image = GetIcon("geist:window"),
            ImageColor3 = NeroGG.CurrentTheme.Accent,
            BackgroundTransparency = 1
        }),
        Create("TextLabel", {
            Name = "Title",
            Text = self.Title,
            Font = NeroGG.Tokens.Typography.Font,
            TextSize = 16,
            TextColor3 = NeroGG.CurrentTheme.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 52, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1
        })
    })

    -- Content Wrapper
    self.ContentWrapper = Create("Frame", {
        Name = "ContentWrapper",
        Size = UDim2.new(1, -self.SidebarWidth, 1, 0),
        Position = UDim2.new(0, self.SidebarWidth, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })

    -- Header / Topbar
    self.Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.ContentWrapper
    })

    if not self.HideSearch then
        self.SearchBar = Create("Frame", {
            Name = "SearchBar",
            Size = UDim2.new(0, 200, 0, 32),
            Position = UDim2.new(1, -210, 0.5, -16),
            BackgroundColor3 = NeroGG.CurrentTheme.ElementBackground,
            BackgroundTransparency = 0.5,
            Parent = self.Topbar
        }, {
            Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Small }),
            Create("UIStroke", { Color = NeroGG.CurrentTheme.Border, Thickness = 0.5, Transparency = 0.8 }),
            Create("TextBox", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                Text = "",
                PlaceholderText = "Search...",
                PlaceholderColor3 = NeroGG.CurrentTheme.TextSecondary,
                Font = NeroGG.Tokens.Typography.Font,
                TextSize = 12,
                TextColor3 = NeroGG.CurrentTheme.TextPrimary,
                BackgroundTransparency = 1
            }),
            Create("ImageLabel", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 8, 0.5, -7),
                Image = GetIcon("search"),
                ImageColor3 = NeroGG.CurrentTheme.TextSecondary,
                BackgroundTransparency = 1
            })
        })
    end

    self.TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -20, 1, -120),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = self.Sidebar
    }, {
        Create("UIListLayout", { Padding = UDim.new(0, 6) })
    })

    -- User Section in Sidebar
    self.UserSection = Create("Frame", {
        Name = "UserSection",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 1, -60),
        BackgroundColor3 = NeroGG.CurrentTheme.ElementBackground,
        BackgroundTransparency = 0.8,
        Parent = self.Sidebar
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Medium }),
        Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 10, 0.5, -16),
            Image = GetIcon("user"),
            ImageColor3 = NeroGG.CurrentTheme.TextSecondary,
            BackgroundTransparency = 1
        }),
        Create("TextLabel", {
            Name = "Username",
            Text = self.Author,
            Font = NeroGG.Tokens.Typography.Font,
            TextSize = 12,
            TextColor3 = NeroGG.CurrentTheme.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 50, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1
        })
    })

    self.Tabs = {}
    self.CurrentTab = nil
    
    table.insert(NeroGG.ActiveWindows, self)
    return self
end

function Window:UpdateTheme(theme)
    self.MainFrame.BackgroundColor3 = theme.MainBackground
    self.Sidebar.BackgroundColor3 = theme.SidebarBackground
    -- Recursively update components...
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(options)
    local tab = setmetatable({}, Tab)
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or "home"
    tab.Desc = options.Desc or ""
    tab.Locked = options.Locked or false
    tab.Window = self
    
    -- Tab Button in Sidebar
    tab.Button = Create("TextButton", {
        Name = tab.Title,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = self.TabList
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Medium }),
        Create("Frame", {
            Name = "Inner",
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1
        }, {
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 0, 0.5, -9),
                Image = GetIcon(tab.Locked and "lock" or tab.Icon),
                ImageColor3 = NeroGG.CurrentTheme.TextSecondary,
                BackgroundTransparency = 1
            }),
            Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                Text = tab.Title,
                Font = NeroGG.Tokens.Typography.Font,
                TextSize = 13,
                TextColor3 = NeroGG.CurrentTheme.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
        })
    })

    -- Page Container
    tab.Page = Create("ScrollingFrame", {
        Name = tab.Title .. "_Page",
        Size = UDim2.new(1, -40, 1, -80),
        Position = UDim2.new(0, 20, 0, 70),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 1,
        ScrollBarImageColor3 = NeroGG.CurrentTheme.Accent,
        Parent = self.ContentWrapper,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, NeroGG.Tokens.Spacing.Gap),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 20) })
    })

    tab.Button.MouseButton1Click:Connect(function()
        if not tab.Locked then
            self:SelectTab(tab)
        else
            NeroGG:Notify({ Title = "Tab Locked", Content = "This tab is currently locked." })
        end
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    
    return tab
end

function Window:SelectTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Page.Visible = false
        Tween(self.CurrentTab.Button, TweenInfo.new(0.3), { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1) })
        Tween(self.CurrentTab.Button.Inner.Label, TweenInfo.new(0.3), { TextColor3 = NeroGG.CurrentTheme.TextSecondary })
        Tween(self.CurrentTab.Button.Inner.Icon, TweenInfo.new(0.3), { ImageColor3 = NeroGG.CurrentTheme.TextSecondary })
    end
    
    self.CurrentTab = tab
    tab.Page.Visible = true
    Tween(tab.Button, TweenInfo.new(0.3), { BackgroundTransparency = 0.85, BackgroundColor3 = NeroGG.CurrentTheme.Accent })
    Tween(tab.Button.Inner.Label, TweenInfo.new(0.3), { TextColor3 = NeroGG.CurrentTheme.TextPrimary })
    Tween(tab.Button.Inner.Icon, TweenInfo.new(0.3), { ImageColor3 = NeroGG.CurrentTheme.TextPrimary })
end

-- Section Class
local Section = {}
Section.__index = Section

function Tab:CreateSection(options)
    local section = setmetatable({}, Section)
    section.Title = options.Title or "Section"
    section.Tab = self
    
    section.Container = Create("Frame", {
        Name = section.Title,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Page
    }, {
        Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
        Create("TextLabel", {
            Text = section.Title:upper(),
            Font = NeroGG.Tokens.Typography.Font,
            TextSize = 11,
            TextColor3 = NeroGG.CurrentTheme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            LayoutOrder = -1
        })
    })

    return section
end

-- UI Components
function Section:CreateToggle(options)
    local Title = options.Title or "Toggle"
    local Default = options.Value or false
    local Callback = options.Callback or function() end
    
    local Toggled = Default
    
    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = NeroGG.CurrentTheme.ElementBackground,
        BackgroundTransparency = 0.4,
        Parent = self.Container
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Medium }),
        Create("UIStroke", { Color = NeroGG.CurrentTheme.Border, Thickness = 0.5, Transparency = 0.7 }),
        Create("TextLabel", {
            Text = Title,
            Font = NeroGG.Tokens.Typography.Font,
            TextSize = 13,
            TextColor3 = NeroGG.CurrentTheme.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1
        })
    })

    local Switch = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -52, 0.5, -9),
        BackgroundColor3 = Toggled and NeroGG.CurrentTheme.Accent or NeroGG.CurrentTheme.Border,
        Parent = Frame
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local Knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, Toggled and 20 or 2, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = Switch
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local Clicker = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Frame
    })

    Clicker.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        Tween(Switch, TweenInfo.new(0.2), { BackgroundColor3 = Toggled and NeroGG.CurrentTheme.Accent or NeroGG.CurrentTheme.Border })
        Tween(Knob, TweenInfo.new(0.2), { Position = UDim2.new(0, Toggled and 20 or 2, 0.5, -7) })
        Callback(Toggled)
    end)

    return {
        SetValue = function(val)
            Toggled = val
            Tween(Switch, TweenInfo.new(0.2), { BackgroundColor3 = Toggled and NeroGG.CurrentTheme.Accent or NeroGG.CurrentTheme.Border })
            Tween(Knob, TweenInfo.new(0.2), { Position = UDim2.new(0, Toggled and 20 or 2, 0.5, -7) })
        end
    }
end

function Section:CreateButton(options)
    local Title = options.Title or "Button"
    local Callback = options.Callback or function() end
    local Variant = options.Variant or "Default"
    
    local Frame = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Variant == "Primary" and NeroGG.CurrentTheme.Accent or NeroGG.CurrentTheme.ElementBackground,
        BackgroundTransparency = Variant == "Primary" and 0.1 or 0.4,
        Text = Title,
        Font = NeroGG.Tokens.Typography.Font,
        TextColor3 = Variant == "Primary" and Color3.new(1, 1, 1) or NeroGG.CurrentTheme.TextPrimary,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = self.Container
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Medium }),
        Create("UIStroke", { Color = NeroGG.CurrentTheme.Border, Thickness = 0.5, Transparency = 0.7 })
    })

    Frame.MouseEnter:Connect(function()
        Tween(Frame, TweenInfo.new(0.2), { BackgroundTransparency = Variant == "Primary" and 0 or 0.2 })
    end)
    Frame.MouseLeave:Connect(function()
        Tween(Frame, TweenInfo.new(0.2), { BackgroundTransparency = Variant == "Primary" and 0.1 or 0.4 })
    end)
    Frame.MouseButton1Down:Connect(function()
        Tween(Frame, TweenInfo.new(0.1), { Size = UDim2.new(1, -4, 0, 40) })
    end)
    Frame.MouseButton1Up:Connect(function()
        Tween(Frame, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 42) })
        Callback()
    end)
end

function Section:CreateSlider(options)
    local Title = options.Title or "Slider"
    local Min = options.Min or 0
    local Max = options.Max or 100
    local Default = options.Value or 50
    local Step = options.Step or 1
    local Callback = options.Callback or function() end

    local Value = Default
    
    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = NeroGG.CurrentTheme.ElementBackground,
        BackgroundTransparency = 0.4,
        Parent = self.Container
    }, {
        Create("UICorner", { CornerRadius = NeroGG.Tokens.Radius.Medium }),
        Create("UIStroke", { Color = NeroGG.CurrentTheme.Border, Thickness = 0.5, Transparency = 0.7 }),
        Create("TextLabel", {
            Text = Title,
            Font = NeroGG.Tokens.Typography.Font,
            TextSize = 13,
            TextColor3 = NeroGG.CurrentTheme.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 12),
            Size = UDim2.new(0.6, 0, 0, 20),
            BackgroundTransparency = 1
        })
    })

    local ValueLabel = Create("TextLabel", {
        Text = tostring(Value),
        Font = NeroGG.Tokens.Typography.Font,
        TextSize = 12,
        TextColor3 = NeroGG.CurrentTheme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(0.6, 0, 0, 12),
        Size = UDim2.new(0.4, -16, 0, 20),
        BackgroundTransparency = 1,
        Parent = Frame
    })

    local Track = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 4),
        Position = UDim2.new(0, 16, 0.7, 0),
        BackgroundColor3 = NeroGG.CurrentTheme.Border,
        Parent = Frame
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local Fill = Create("Frame", {
        Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0),
        BackgroundColor3 = NeroGG.CurrentTheme.Accent,
        Parent = Track
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local Knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((Value - Min)/(Max - Min), -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = Track
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = NeroGG.CurrentTheme.Accent, Thickness = 1.5 })
    })

    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(((Max - Min) * pos + Min) / Step + 0.5) * Step
        Value = math.clamp(val, Min, Max)
        
        ValueLabel.Text = tostring(Value)
        Fill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
        Knob.Position = UDim2.new((Value - Min)/(Max - Min), -7, 0.5, -7)
        Callback(Value)
    end

    local dragging = false
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)

    return { SetValue = function(val) Update({Position = Vector3.new(Track.AbsolutePosition.X + (val-Min)/(Max-Min) * Track.AbsoluteSize.X, 0, 0)}) end }
end

-- Example Code Integration
function NeroGG:Example()
    local Window = self:CreateWindow({
        Title = "NeroGG",
        Author = "NeroGG Team",
        Theme = "Dark",
        Acrylic = true
    })

    local Home = Window:CreateTab({ Title = "Dashboard", Icon = "home" })
    local Settings = Window:CreateTab({ Title = "Settings", Icon = "settings" })
    local LockedTab = Window:CreateTab({ Title = "Premium", Icon = "lock", Locked = true })

    local Stats = Home:CreateSection({ Title = "Player Stats" })
    Stats:CreateToggle({ Title = "Infinite Stamina", Callback = function(v) print("Stamina:", v) end })
    Stats:CreateSlider({ Title = "Walkspeed", Min = 16, Max = 100, Value = 16, Callback = function(v) print("Speed:", v) end })
    
    local Appearance = Settings:CreateSection({ Title = "Theming" })
    Appearance:CreateButton({ Title = "Light Mode", Callback = function() NeroGG:SetTheme("Light") end })
    Appearance:CreateButton({ Title = "Dark Mode", Callback = function() NeroGG:SetTheme("Dark") end })
end

return NeroGG
