local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local gui = Library:create{
    Theme = Library.Themes.Serika
}

local tab = gui:tab{
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot"
}

tab:button({
    Name = "Show Prompt",
    Callback = function()
        tab:prompt{
            Title = "Baby",
            Text = "Shark doo doo doo doo... I'm blank, lmao.",
            Buttons = {
                Ok = function()
                    tab:prompt{
                        Followup = true,
                        Title = "Really?",
                        Text = "You sure about this?",
                        Buttons = {
                            Yes = function()
                                tab:prompt{
                                    Followup = true,
                                    Title = "XD",
                                    Text = "Sus!",
                                    Buttons = {
                                        Balls = function()
                                            gui:set_status("github")
                                        end,
                                        Anal = function()
                                            gui:set_status("money")
                                        end
                                    }
                                }
                            end
                        }
                    }
                end
            }
        }
    end
})

tab:keybind({
    Callback = function()
        gui:prompt()
    end
})

tab:dropdown({
    Name = "Dropdown",
    Description = "Yeeeeeeeeeeboi!",
    StartingText = "Bodypart",
    Items = {
        "Head",
        "Torso",
        "Random"
    }
})

tab:dropdown({
    Name = "Number Dropdown",
    StartingText = "Choose a number",
    Items = {
        {"One", 1},
        {"Two", 2},
        {"Three", 3}
    },
    Description = "Among us reference",
    Callback = function(v)
        print(v, "clicked")
    end
})

local cum = tab:slider({
    Callback = function(v)
        gui:set_status(v)
    end
})

tab:textbox({
    Callback = function(v)
        gui:prompt{Text = v}
    end
})

tab:color_picker({
    Name = "Your mom's color",
    Style = Library.ColorPickerStyles.Legacy,
    Description = "Click to adjust color...",
    Callback = function(color)
        print(color)
    end
})
