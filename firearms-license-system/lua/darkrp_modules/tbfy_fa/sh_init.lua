
//I suggest creating this job in your darkrp modification or whatever you use instead
TEAM_FA_INSTRUCTOR = DarkRP.createJob("Firearms Instructor", {
    color = Color(50, 120, 20, 255),
    model = {
        "models/player/Group01/Female_01.mdl",
        "models/player/Group01/Female_02.mdl",
        "models/player/Group01/Female_03.mdl",
        "models/player/Group01/Female_04.mdl",
        "models/player/Group01/Female_06.mdl",
        "models/player/group01/male_01.mdl",
        "models/player/Group01/Male_02.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/Male_04.mdl",
        "models/player/Group01/Male_05.mdl",
        "models/player/Group01/Male_06.mdl",
        "models/player/Group01/Male_07.mdl",
        "models/player/Group01/Male_08.mdl",
        "models/player/Group01/Male_09.mdl"
    },
    description = [[Teach players how to properly use a firearm, both theory and practical.]],
    weapons = {},
    command = "fainstructor",
    max = 2,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Citizens",
    customCheck = function(Player)
        if TBFY_FAConfig.InstructorWhitelist then
            return Player:FA_IsInstructor()
        else
            return true
        end
    end,
    CustomCheckFailMsg = "You require to be whitelisted in order to be a firearms instructor.",
})
