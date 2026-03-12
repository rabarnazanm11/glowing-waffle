--[[
╔══════════════════════════════════════════════════════════════════╗
║                    🔥 REDZLIB UI LIBRARY v1.5 🔥                ║
║                    Modern, Animated, Flag‑Ready                  ║
╚══════════════════════════════════════════════════════════════════╝
]]

--=============================================================================
-- 📦 BOOTSTRAP – Load the library
--=============================================================================
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/rabarnazanm11/glowing-waffle/refs/heads/main/NewReDd"))()

--=============================================================================
-- 🪟 WINDOW – The main container for your entire UI
--=============================================================================
local Window = redzlib:MakeWindow({
    "Window Title",          -- [1]  Main title at the top
    "Subtitle",              -- [2]  Smaller text below the title
    "save_filename.json"     -- [3]  (optional) Auto‑save flags to this file
})

--=============================================================================
-- 🧲 FLOATING BUTTON – A draggable icon that toggles the window
--=============================================================================
Window:MakeFloatButton("home")   -- Lucide icon name (e.g. "home", "settings", "sword")

--=============================================================================
-- 📂 TABS – Organise your UI into separate pages
--=============================================================================
local Tab = Window:MakeTab({
    "Tab Name",          -- [1]  Label shown in the sidebar
    "home"               -- [2]  Icon name or full rbxassetid:// (optional)
})

--=============================================================================
-- 🧩 SECTION – A simple header to group related elements
--=============================================================================
Tab:AddSection("Section Title")
-- OR with a table (allows extra options)
Tab:AddSection({ Name = "Section Title" })

--[[
    📌 Section methods:
    · :Set(newTitle)   – change the section text
    · :Visible(bool)   – show / hide this section
    · :Destroy()       – remove it completely
]]

--=============================================================================
─── A thin horizontal line to visually separate content
--=============================================================================
Tab:AddSeparator()

--[[
    📌 Separator methods:
    · :Visible(bool)   – show / hide
    · :Destroy()       – remove
]]

--=============================================================================
-- 📝 PARAGRAPH – Static text block with title and optional description
--=============================================================================
Tab:AddParagraph({
    Title = "Info",
    Text  = "This is a paragraph with longer description."
})

--[[
    📌 Paragraph methods:
    · :SetTitle(val)   – update the title
    · :SetDesc(val)    – update the description
    · :Set(title, desc)– update both at once
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 🔘 BUTTON – Clickable action button
--=============================================================================
Tab:AddButton({
    Name = "Click Me",
    Desc = "Optional description",   -- (optional) secondary text
    Callback = function()
        print("Button pressed")
    end
})

--[[
    ⚡ Positional shortcut: Tab:AddButton({ "Button Name", function() ... end })

    📌 Button methods:
    · :Callback(func)  – add another callback (runs alongside existing ones)
    · :Set(title, desc)– change label and/or description
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 🔄 TOGGLE – On/off switch with optional flag saving
--=============================================================================
Tab:AddToggle({
    Name = "Enable Feature",
    Desc = "Turns on the feature",
    Default = true,               -- initial state
    Flag = "feature_enabled",      -- (optional) saved flag key
    Callback = function(value)
        print("Toggle is now", value)
    end
})

--[[
    ⚡ Positional: { "Toggle Name", Default, Callback, Flag? }

    📌 Toggle methods:
    · :Set(value)      – set state (boolean) OR update label (string)
    · :Callback(func)  – add callback
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 📋 DROPDOWN – Single or multi‑select list
--=============================================================================
Tab:AddDropdown({
    Name = "Choose Option",
    Desc = "Select one or more",
    Options = { "Option1", "Option2", "Option3" },
    Default = "Option1",           -- single select, or table for multi
    MultiSelect = true,            -- enable multi‑select
    Flag = "dropdown_choice",
    Callback = function(selected)
        print("Selected:", selected)  -- string (single) or table (multi)
    end
})

--[[
    ⚡ Positional: { "Name", Options, Default, Callback, Flag? }

    📌 Dropdown methods:
    · :Refresh(newOptionsTable)          – replace all options
    · :Add(optionName) or :Add({...})    – add one or more options
    · :Remove(optionName)                – remove an option
    · :Set(selected)                     – programmatically set selection
    · :GetSelected()                      – get current selection
    · :Callback(func)                     – add callback
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 🎚️ SLIDER – Numeric slider with min, max, step
--=============================================================================
Tab:AddSlider({
    Name = "Volume",
    Desc = "Adjust volume",
    Min = 0,
    Max = 100,
    Increase = 1,                  -- step size
    Default = 50,
    Flag = "volume",
    Callback = function(value)
        print("Volume:", value)
    end
})

--[[
    ⚡ Positional: { "Name", Min, Max, Increase, Default, Callback, Flag? }

    📌 Slider methods:
    · :Set(value)      – set slider position (number) or update label (string)
    · :GetValue()      – get current numeric value
    · :Callback(func)  – add callback
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- ⌨️ TEXTBOX – Single‑line text input
--=============================================================================
Tab:AddTextBox({
    Name = "Username",
    Desc = "Enter your name",
    Default = "Player",
    PlaceholderText = "Type here...",
    ClearTextOnFocus = false,
    Callback = function(text)
        print("Entered:", text)
    end
})

--[[
    ⚡ Positional: { "Name", Default, ClearTextOnFocus?, Callback?, PlaceholderText? }

    🔧 Extra feature:
    · You can set an `OnChanging` function to modify input before commit:
        local box = Tab:AddTextBox({...})
        box.OnChanging = function(raw) return raw:upper() end

    📌 TextBox methods:
    · :Set(newText)    – change the displayed text
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- ⌨️ KEYBIND – Capture a keyboard key
--=============================================================================
Tab:AddKeybind({
    Name = "Activate",
    Desc = "Press a key",
    Default = Enum.KeyCode.F,
    Flag = "keybind",
    Callback = function(key)
        print("Key set to", key.Name)
    end
})

--[[
    ⚡ Positional: { "Name", Default, Callback, Flag? }

    📌 Keybind methods:
    · :Set(key)        – set key (Enum.KeyCode or string name)
    · :GetKey()        – get current Enum.KeyCode
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 🎨 COLORPICKER – Full HSV colour selection
--=============================================================================
Tab:AddColorPicker({
    Name = "Highlight Color",
    Desc = "Pick a colour",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "highlight_color",
    Callback = function(color)
        print("New color:", color)
    end
})

--[[
    ⚡ Positional: { "Name", Default, Callback, Flag? }

    📌 ColorPicker methods:
    · :Set(Color3)     – set colour (animates cursor)
    · :GetColor()      – get current Color3
    · :Callback(func)  – add callback
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 💬 DISCORD INVITE – Stylish card with “Join” button (copies invite)
--=============================================================================
Tab:AddDiscordInvite({
    Name = "Our Discord",
    Desc = "Join for updates",
    Logo = "rbxassetid://123456",   -- (optional) custom icon
    Invite = "discord.gg/example"
})

--[[
    ⚡ Positional: { "Name", Logo, Invite }

    📌 DiscordInvite methods:
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 🧩 HORIZONTAL PANELS – Two collapsible panels side by side
--=============================================================================
local leftPanel, rightPanel = Tab:AddHorizontalPanels("Left Panel", "Right Panel")

leftPanel:AddButton({ Name = "Left Button", Callback = function() ... end })
rightPanel:AddToggle({ Name = "Right Toggle", Default = true })

--[[
    Each panel has ALL the same element‑adding methods as a Tab:
    · :AddSection, :AddSeparator, :AddParagraph, :AddButton, :AddToggle,
      :AddDropdown, :AddSlider, :AddTextBox, :AddKeybind, :AddColorPicker,
      :AddDiscordInvite

    📌 Panel control methods:
    · :Collapse() / :Expand() / :Toggle()   – open/close the panel
    · :SetTitle(newTitle)                   – change panel header
    · :Visible(bool)
    · :Destroy()
]]

--=============================================================================
-- 💾 FLAGS & PERSISTENCE – Save/load values automatically
--=============================================================================
--[[
    Any element with a `Flag` will have its value saved to the file provided
    in :MakeWindow() (if the executor supports file I/O).

    You can also access flags directly:
]]
redzlib.Flags:SetFlag("flag_name", value)
local val = redzlib.Flags:GetFlag("flag_name")

--[[
    The library fires a "FlagsChanged" event whenever a flag is modified.
]]

--=============================================================================
-- 🎨 THEMES – Switch between built‑in colour schemes
--=============================================================================
-- Available themes: "Darker", "Dark", "Purple"
redzlib:SetTheme("Purple")

-- Check if a theme exists:
if redzlib:VerifyTheme("Dark") then
    print("Theme exists!")
end

--=============================================================================
-- 🔔 NOTIFICATION – Temporary pop‑up that slides in from the right
--=============================================================================
redzlib:Notify({
    Title = "Hello",
    Text = "This is a notification",
    Duration = 3   -- seconds (default = 3)
})

--=============================================================================
-- 💬 DIALOG – Modal confirmation box
--=============================================================================
Window:Dialog({
    Title = "Confirm",
    Text = "Are you sure?",
    Options = {
        { "Yes", function() print("Confirmed") end },
        { "No" }
    }
})

--=============================================================================
-- 🎉 THAT'S IT! Happy coding with redzlib!
--=============================================================================
