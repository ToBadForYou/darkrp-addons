//Translated by EpicWolf (http://steamcommunity.com/id/Plechovka/ )

TBFY_SH:AddLanguage("Practical" , "Praktické")
TBFY_SH:AddLanguage("Theory" , "Teória")
TBFY_SH:AddLanguage("Instructor" , "Inštruktor")
TBFY_SH:AddLanguage("Carry" , "Nosiť")
TBFY_SH:AddLanguage("Job" , "Práca")
TBFY_SH:AddLanguage("Sell" , "Predať")
TBFY_SH:AddLanguage("CanCarry" , "Môže nosiť")
TBFY_SH:AddLanguage("CanSell" , "Môže predať")
TBFY_SH:AddLanguage("License" , "Licencia")
TBFY_SH:AddLanguage("AdminManageMenu" , "Admin správca")
TBFY_SH:AddLanguage("InstructorManageMenu" , "Vedenie inštruktorov")
TBFY_SH:AddLanguage("FirearmTab" , "Licencie na strelné zbrane")
TBFY_SH:AddLanguage("PracticalTestChooseTest" , "Vyberte praktický test")
TBFY_SH:AddLanguage("SomeoneDoingPracticalTest" , "Momentálne niekto robí praktickú skúšku na túto licenciu, skúste to znova neskôr.")
TBFY_SH:AddLanguage("PracticalTestFinish" , "Blahoželáme! Úspešne ste absolvovali praktickú skúšku na získanie licencie: ")
TBFY_SH:AddLanguage("PracticalTestFail" , "Zlyhal ste praktický test strelnej zbrane pre licenciu: ")
TBFY_SH:AddLanguage("ApplicationHeadline" , "Žiadosť o licenciu na strelné zbrane")
TBFY_SH:AddLanguage("AppName" , "Méno:")
TBFY_SH:AddLanguage("AppOccupation" , "Zamestnanie:")
TBFY_SH:AddLanguage("YourSignature" , "Your Signature:")
TBFY_SH:AddLanguage("Signature" , "Tvoj podpis")
TBFY_SH:AddLanguage("SignApp" , "Prihláste aplikáciu")
TBFY_SH:AddLanguage("ApplyLicense" , "Žiadosť o licenciu:")
TBFY_SH:AddLanguage("ApplicationRequestSent" , "Aplikácia bola úspešne odoslaná.")
TBFY_SH:AddLanguage("ApplicationRequestArrived" , "Aplikácia na získavanie strelných zbraní bola práve prijatá.")
TBFY_SH:AddLanguage("AppExaminePList" , "Zoznam aplikačných licencií na strelné zbrane")
TBFY_SH:AddLanguage("AppApprove" , "Schváliť")
TBFY_SH:AddLanguage("AppDisapprove" , "Zmietnuť")
TBFY_SH:AddLanguage("ApplicationAlreadyPending" , "Už máte žiadosť o licenciu na strelnú zbrane!")
TBFY_SH:AddLanguage("AppApprover" , "Úspešne schválená %s %s žiadosť o licenciu.")
TBFY_SH:AddLanguage("AppApproved" , "%s schválil váš %s žiadosť o licenciu.")
TBFY_SH:AddLanguage("AppDisapprover" , "Úspešne zamietnuté %s %s žiadosť o licenciu.")
TBFY_SH:AddLanguage("AppDisapproved" , "%s vám zamietol %s žiadosť o licenciu.")
TBFY_SH:AddLanguage("InstructorRevoker" , "Úspešné zrušenie %s stav inštruktora.")
TBFY_SH:AddLanguage("InstructorRevoked" , "%s zrušil tvôj instructor status.")
TBFY_SH:AddLanguage("InstructorGranter" , "Úspešne udelil %s stav inštruktora.")
TBFY_SH:AddLanguage("InstructorGranted" , "%s vám udelil stav inštruktora.")
TBFY_SH:AddLanguage("TheoryTestRevoker" , "Úspešné zrušenie %s %s teoretický test.")
TBFY_SH:AddLanguage("TheoryTestRevoked" , "%s zrušil tvôj %s teoretický test.")
TBFY_SH:AddLanguage("TheoryTestGranter" , "Úspešne udelil %s %s teoretický test.")
TBFY_SH:AddLanguage("TheoryTestGranted" , "%s vám udelil %s teoretický test.")
TBFY_SH:AddLanguage("PracticalTestRevoker" , "Úspešné zrušenie %s %s praktický test.")
TBFY_SH:AddLanguage("PracticalTestRevoked" , "%s zrušil tvôj %s praktický test.")
TBFY_SH:AddLanguage("PracticalTestGranter" , "Úspešne udelil %s %s praktický test.")
TBFY_SH:AddLanguage("PracticalTestGranted" , "%s vám udelil %s praktický test.")
TBFY_SH:AddLanguage("CarryLicenseRevoker" , "Úspešné zrušenie %s %s nosenie licencie.")
TBFY_SH:AddLanguage("CarryLicenseRevoked" , "%s zrušil tvôj %s nosenie licencie.")
TBFY_SH:AddLanguage("CarryLicenseGranter" , "Úspešne udelil %s %s nosenie licencie.")
TBFY_SH:AddLanguage("CarryLicenseGranted" , "%s vám udelil %s nosenie licencie.")
TBFY_SH:AddLanguage("SellLicenseRevoker" , "Úspešné zrušenie %s %s predavanie licencie.")
TBFY_SH:AddLanguage("SellLicenseRevoked" , "%s zrušil tvôj %s sell predavanie licencie.")
TBFY_SH:AddLanguage("SellLicenseGranter" , "Úspešne udelil %s %s predavanie licencie.")
TBFY_SH:AddLanguage("SellLicenseGranted" , "%s vám udelil %s predavanie licencie.")
TBFY_SH:AddLanguage("NoTheory" , "%s nebol úspešný %s teoretický test.")
TBFY_SH:AddLanguage("NoPractical" , "%s neprešiel %s praktickým testom.")
TBFY_SH:AddLanguage("CantAffordTest" , "Nemôžete si dovoliť tento test!")
TBFY_SH:AddLanguage("ReqLicense" , "Táto zbraň vyžaduje %s nosenie licencie.")
TBFY_SH:AddLanguage("PracticalCantSwitchJob" , "Počas praktickej skúšky nemôžete zmeniť prácu.")

//ID, Name
TBFY_SH:RegisterTheoryTest("fa_theory", "Licencie na strelné zbrane")

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
