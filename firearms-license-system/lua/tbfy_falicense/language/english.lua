
TBFY_SH:AddLanguage("Practical", "Practical")
TBFY_SH:AddLanguage("Instructor", "Instructor")
TBFY_SH:AddLanguage("Job", "Job")
TBFY_SH:AddLanguage("Theory", "Theory")
TBFY_SH:AddLanguage("Carry", "Carry")
TBFY_SH:AddLanguage("Sell", "Sell")
TBFY_SH:AddLanguage("CanCarry", "CanCarry")
TBFY_SH:AddLanguage("CanSell", "CanSell")
TBFY_SH:AddLanguage("License", "License")
TBFY_SH:AddLanguage("AdminManageMenu", "Admin Management")
TBFY_SH:AddLanguage("InstructorManageMenu", "Instructor Management")
TBFY_SH:AddLanguage("FirearmTab", "Firearms Licenses")
TBFY_SH:AddLanguage("PracticalTestChooseTest", "Choose Practical Test")
TBFY_SH:AddLanguage("SomeoneDoingPracticalTest", "Currently someone is doing the practical test for this license, please try again later.")
TBFY_SH:AddLanguage("PracticalTestFinish", "Congratulations! You have successfully finished the practical test for license: ")
TBFY_SH:AddLanguage("PracticalTestFail", "You have failed the practical firearms test for license: ")
TBFY_SH:AddLanguage("ApplicationHeadline", "Firearms License Application")
TBFY_SH:AddLanguage("AppName", "Name:")
TBFY_SH:AddLanguage("AppOccupation", "Occupation:")
TBFY_SH:AddLanguage("YourSignature", "Your Signature:")
TBFY_SH:AddLanguage("Signature", "Signature:")
TBFY_SH:AddLanguage("SignApp", "Sign Application")
TBFY_SH:AddLanguage("ApplyLicense", "Applying for license:")
TBFY_SH:AddLanguage("ApplicationRequestSent", "Application was successfully sent.")
TBFY_SH:AddLanguage("ApplicationRequestArrived", "A firearms license application was just received.")
TBFY_SH:AddLanguage("AppExaminePList", "Firearms  License Application List")
TBFY_SH:AddLanguage("AppApprove", "Approve")
TBFY_SH:AddLanguage("AppDisapprove", "Disapprove")
TBFY_SH:AddLanguage("ApplicationAlreadyPending", "You already have a firearms license application pending!")
TBFY_SH:AddLanguage("AppApprover", "Successfully approved %s %s license application.")
TBFY_SH:AddLanguage("AppApproved", "%s has approved your %s license application.")
TBFY_SH:AddLanguage("AppDisapprover" , "Successfully disapproved %s %s license application.")
TBFY_SH:AddLanguage("AppDisapproved" , "%s has disapproved your %s license application.")
TBFY_SH:AddLanguage("InstructorRevoked" , "%s has revoked your instructor status.")
TBFY_SH:AddLanguage("InstructorGranter" , "Successfully granted %s instructor status.")
TBFY_SH:AddLanguage("InstructorGranted" , "%s has granted you instructor status.")
TBFY_SH:AddLanguage("TheoryTestRevoker" , "Successfully revoked %s %s theory test.")
TBFY_SH:AddLanguage("TheoryTestRevoked" , "%s has revoked your %s theory test.")
TBFY_SH:AddLanguage("TheoryTestGranter" , "Successfully granted %s %s theory test.")
TBFY_SH:AddLanguage("TheoryTestGranted" , "%s has granted you %s theory test.")
TBFY_SH:AddLanguage("PracticalTestRevoker" , "Successfully revoked %s %s practical test.")
TBFY_SH:AddLanguage("PracticalTestRevoked" , "%s has revoked your %s practical test.")
TBFY_SH:AddLanguage("PracticalTestGranter" , "Successfully granted %s %s practical test.")
TBFY_SH:AddLanguage("PracticalTestGranted" , "%s has granted you %s practical test.")
TBFY_SH:AddLanguage("CarryLicenseRevoker" , "Successfully revoked %s %s carry license.")
TBFY_SH:AddLanguage("CarryLicenseRevoked" , "%s has revoked your %s carry license.")
TBFY_SH:AddLanguage("CarryLicenseGranter" , "Successfully granted %s %s carry license.")
TBFY_SH:AddLanguage("CarryLicenseGranted" , "%s has granted you %s carry license.")
TBFY_SH:AddLanguage("SellLicenseRevoker" , "Successfully revoked %s %s sell license.")
TBFY_SH:AddLanguage("SellLicenseRevoked" , "%s has revoked your %s sell license.")
TBFY_SH:AddLanguage("SellLicenseGranter" , "Successfully granted %s %s sell license.")
TBFY_SH:AddLanguage("SellLicenseGranted" , "%s has granted you %s sell license.")
TBFY_SH:AddLanguage("NoTheory" , "%s hasn't passed the %s theory test.")
TBFY_SH:AddLanguage("NoPractical" , "%s hasn't passed the %s practical test.")
TBFY_SH:AddLanguage("CantAffordTest" , "You can't afford this test!")
TBFY_SH:AddLanguage("ReqLicense" , "This weapon require the %s carry license.")
TBFY_SH:AddLanguage("PracticalCantSwitchJob" , "You can't change job during the practical test.")

//ID, Name
TBFY_SH:RegisterTheoryTest("fa_theory", "Firearms License")

local Question = {
  Question = "If a gun has a safe switch, when should it be used?",
  Options = {
    "Only when holstered.",
    "During usage of the weapon.",
    "Never as it might malfunction.",
    "Always, but don't depend on it.",
  },
  CorrectAnswer = 4,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Which of these statements is true?",
  Options = {
    "Rifles can be semi and automatic, shotguns can't.",
    "Scopes are more common on rifles than shotguns.",
    "Shotguns requires you to reload after each shot."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)


local Question = {
  Question = "How should you always treat a gun?",
  Options = {
    "Like a toy.",
    "Like it's always loaded, even if it isn't.",
    "Playing around with it is fine, as long as the safety is on.",
    "Like you don't care."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Why should you never fire at water?",
  Options = {
    "It can riochet off the water and go in an unsafe direction.",
    "You might hit a rock.",
    "It could hit a fish.",
    "The bullet can explode upon impact with water."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Which is the safest way to check if a firearm is loaded?",
  Options = {
    "Aim at a safe direction and squeeze the trigger.",
    "Set to safe mode and attempt to squeeze the trigger, if it works it isn't loaded.",
    "Aim at a safe direction and check the chamber and the magazine."
  },
  CorrectAnswer = 3,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "What should the firearms be used for?",
  Options = {
    "Primarily hobbies, such as hunting and at shooting ranges. But can be used in self-defense if required.",
    "Wear it in public to seem intimating and hence making your daily life more secure.",
    "Extra security at home, you are legally allowed to shoot trespassers at sight."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "At shooting ranges you may keep your firearms loaded at all times.",
  Options = {
    "True",
    "False"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "You should never keep your finger on the trigger unless you are just about to fire.",
  Options = {
    "True",
    "False"
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Aiming at people is fine as long as the safety is on, even if it's loaded or not.",
  Options = {
    "True",
    "False"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Even if you don't have a firearms license, you are still allowed to own a firearm and use it at home for self-defense.",
  Options = {
    "True",
    "False"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)
