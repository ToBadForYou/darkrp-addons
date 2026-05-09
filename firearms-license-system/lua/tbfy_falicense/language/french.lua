
//Translated by [TG-of-TN]walkka (https://steamcommunity.com/profiles/76561198034333249 )
TBFY_SH:AddLanguage("Practical" , "Pratique")
TBFY_SH:AddLanguage("Theory" , "Theorie")
TBFY_SH:AddLanguage("Instructor" , "Instructeur")
TBFY_SH:AddLanguage("Job" , "Job")
TBFY_SH:AddLanguage("Carry" , "Port")
TBFY_SH:AddLanguage("Sell" , "Vend")
TBFY_SH:AddLanguage("CanCarry" , "Port ok")
TBFY_SH:AddLanguage("CanSell" , "Vend ok")
TBFY_SH:AddLanguage("License" , "License")
TBFY_SH:AddLanguage("AdminManageMenu" , "Gestion des administrateurs")
TBFY_SH:AddLanguage("InstructorManageMenu" , "Gestion des Instructeurs")
TBFY_SH:AddLanguage("FirearmTab" , "Permis d'armes à feu")
TBFY_SH:AddLanguage("PracticalTestChooseTest" , "Choisir un test pratique")
TBFY_SH:AddLanguage("SomeoneDoingPracticalTest" , "Actuellement, quelqu'un effectue le test pratique de cette licence, réessayez plus tard.")
TBFY_SH:AddLanguage("PracticalTestFinish" , "Toutes nos félicitations! Vous avez terminé avec succès le test pratique de licence: ")
TBFY_SH:AddLanguage("PracticalTestFail" , "Vous avez échoué au test pratique d'armes à feu pour la licence: ")
TBFY_SH:AddLanguage("ApplicationHeadline" , "Demande de permis d'armes à feu")
TBFY_SH:AddLanguage("AppName" , "Nom:")
TBFY_SH:AddLanguage("AppOccupation" , "Emploi:")
TBFY_SH:AddLanguage("YourSignature" , "Votre signature:")
TBFY_SH:AddLanguage("Signature" , "Signature:")
TBFY_SH:AddLanguage("SignApp" , "Signer")
TBFY_SH:AddLanguage("ApplyLicense" , "Demande de licence:")
TBFY_SH:AddLanguage("ApplicationRequestSent" , "La demande à été envoyée avec succès.")
TBFY_SH:AddLanguage("ApplicationRequestArrived" , "Une demande de permis d'armes à feu vient d'être reçue.")
TBFY_SH:AddLanguage("AppExaminePList" , "Liste des demandes de licence d'armes à feu")
TBFY_SH:AddLanguage("AppApprove" , "Approuver")
TBFY_SH:AddLanguage("AppDisapprove" , "Désapprouver")
TBFY_SH:AddLanguage("ApplicationAlreadyPending" , "Vous avez déjà une demande de licence d'armes à feu en attente!")
TBFY_SH:AddLanguage("AppApprover" , "Approuvé avec succès %s %s Demande de licence.")
TBFY_SH:AddLanguage("AppApproved" , "%s A approuvé votre %s Demande de licence.")
TBFY_SH:AddLanguage("AppDisapprover" , "Accepté avec succès %s %s Demande de licence.")
TBFY_SH:AddLanguage("AppDisapproved" , "%s Avez désapprouvé votre %s Demande de licence.")
TBFY_SH:AddLanguage("InstructorRevoker" , "Révoqué avec succès %s Statut de l'instructeur.")
TBFY_SH:AddLanguage("InstructorRevoked" , "%s A annulé votre statut d'instructeur.")
TBFY_SH:AddLanguage("InstructorGranter" , "Réussite %s Statut de l'instructeur.")
TBFY_SH:AddLanguage("InstructorGranted" , "%s Vous a accordé le statut d'instructeur.")
TBFY_SH:AddLanguage("TheoryTestRevoker" , "Révoqué avec succès %s %s Test théorique.")
TBFY_SH:AddLanguage("TheoryTestGranter" , "Réussite %s %s Test théorique.")
TBFY_SH:AddLanguage("TheoryTestRevoked" , "%s A révoqué votre %s Test théorique.")
TBFY_SH:AddLanguage("TheoryTestGranted" , "%s Vous a accordé %s Test théorique.")
TBFY_SH:AddLanguage("PracticalTestRevoker" , "Révoqué avec succès %s %s test pratique.")
TBFY_SH:AddLanguage("PracticalTestRevoked" , "%s A révoqué votre %s test pratique.")
TBFY_SH:AddLanguage("PracticalTestGranter" , "Successfully granted %s %s test pratique.")
TBFY_SH:AddLanguage("PracticalTestGranted" , "%s Vous a accordé %s test pratique.")
TBFY_SH:AddLanguage("CarryLicenseRevoker" , "Révoqué avec succès %s %s License de port d'arme.")
TBFY_SH:AddLanguage("CarryLicenseRevoked" , "%s A révoqué votre %s License de port d'arme.")
TBFY_SH:AddLanguage("CarryLicenseGranter" , "Réussite %s %s License de port d'arme.")
TBFY_SH:AddLanguage("CarryLicenseGranted" , "%s Vous a accordé %s License de port d'arme.")
TBFY_SH:AddLanguage("SellLicenseRevoker" , "Révoqué avec succès %s %s License de vendeur.")
TBFY_SH:AddLanguage("SellLicenseRevoked" , "%s A révoqué votre %s License de vendeur.")
TBFY_SH:AddLanguage("SellLicenseGranter" , "Réussite %s %s License de vendeur.")
TBFY_SH:AddLanguage("SellLicenseGranted" , "%s Vous a accordé %s License de vendeur.")
TBFY_SH:AddLanguage("NoTheory" , "%s N'a pas dépassé le %s Test théorique.")
TBFY_SH:AddLanguage("NoPractical" , "%s N'a pas dépassé le %s épreuve pratique.")
TBFY_SH:AddLanguage("CantAffordTest" , "Vous ne pouvez pas vous permettre ce test!")
TBFY_SH:AddLanguage("ReqLicense" , "Cette arme exige la %s license de port d'arme.")
TBFY_SH:AddLanguage("PracticalCantSwitchJob" , "Vous ne pouvez pas changer de métier durant le test de pratique.")

//ID, Name
TBFY_SH:RegisterTheoryTest("fa_theory", "Permis d'armes à feu")

local Question = {
  Question = "Si une arme à feu possède une sécurité, quand devrait-etre elle mise?",
  Options = {
    "Seulement quand elle est rangée.",
    "Durant l'utilisation de l'arme.",
    "Jamais car cela pourrait mal fonctionner.",
    "Toujours, mais ne comptez pas dessus."
  },
  CorrectAnswer = 4,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Laquelle de ces affirmations est vraie?",
  Options = {
    "Les fusils peuvent être semi et automatiques, les fusils à pompe ne peuvent pas.",
    "Les viseurs sont plus courants sur les fusils que sur les fusils à pompe.",
    "Les fusils à pompe vous obligent à recharger après chaque tir.",
    "Question piège, aucune n'est vraie."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Quelles sont les 3 règles des armes à feu?",
  Options = {
    "Sécurité, Responsabilité, Instruction",
    "Sécurité, Responsabilité, Visée",
    "Sécurité, Sécurité, Sécurité",
    "Sécurité, Responsabilité, Consiance"
  },
  CorrectAnswer = 3,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Quand avez-vous le droit de sortir votre arme dans la rue?",
  Options = {
    "Quand je veux.",
    "Quand la situation l'oblige.",
    "Seulement quand un policier me l'autorise.",
    "En cas de self-defence.",
    "Jamais."
  },
  CorrectAnswer = 4,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Comment devriez-vous toujours traiter une arme à feu?",
  Options = {
    "Comme un jouet.",
    "Comme si elle était toujours chargée, meme si ce n'est pas le cas.",
    "Jouer avec est OK, tant que la sécurité est activée.",
    "Comme si tu ne t'en souciais pas."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Pourquoi ne devriez-vous jamais tirer sur l'eau?",
  Options = {
    "Il peut ricocher hors de l'eau et aller dans une direction dangereuse.",
    "Vous pourriez toucher un rocher.", "Vous pourriez toucher un poisson.",
    "La balle peut exploser lors d'un impact avec de l'eau.",
    "Question piège, on peut le faire."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Quel est le moyen le plus sûr de vérifier si une arme à feu est chargée?",
  Options = {
    "Viser dans une direction sure et appuyer sur la gachette.",
    "Mettre la sécurité et essayez de presser la gachette, si cela fonctionne, il n'est pas chargé.",
    "Viser dans une direction sure et vérifier la chambre/le canon et le magazine."
  },
  CorrectAnswer = 3,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "À quoi devraient servir les armes à feu?",
  Options = {
    "Principalement des passe-temps, tels que la chasse et les stands de tir. Mais peut etre utilisé en état de légitime défense si nécessaire.",
    "Pour le porter en public pour paraître intimidant et ainsi se faire respecter.",
    "Sécurité supplémentaire à la maison, vous etes légalement autorisé à tirer sur les intrus en vue."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Au champ de tir, vous pouvez garder vos armes à feu chargées en tout temps.",
  Options = {
    "Vrai.",
    "Faux."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Vous ne devez jamais garder votre doigt sur la gâchette, sauf si vous êtes sur le point de tirer.",
  Options = {
    "Vrai.",
    "Faux."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Viser les gens n'est pas interdit tant que la sécurité est activée, même si elle est chargée ou non.",
  Options = {
    "Vrai.",
    "Faux."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Même si vous n'avez pas de permis d'armes à feu, vous pouvez toujours posséder une arme à feu et l'utiliser à la maison pour votre autodéfense.",
  Options = {
    "Vrai.",
    "Faux."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)
