
TBFY_SH:AddLanguage("Practical", "Uygulamali")
TBFY_SH:AddLanguage("Instructor", "Egitmen")
TBFY_SH:AddLanguage("Job", "Meslek")
TBFY_SH:AddLanguage("Theory", "Teori")
TBFY_SH:AddLanguage("Carry", "Tasimak")
TBFY_SH:AddLanguage("Sell", "Satmak")
TBFY_SH:AddLanguage("CanCarry", "Tasiyabilir")
TBFY_SH:AddLanguage("CanSell", "Satabilir")
TBFY_SH:AddLanguage("License", "Lisans")
TBFY_SH:AddLanguage("AdminManageMenu", "Yonetici Idare Menusu")
TBFY_SH:AddLanguage("InstructorManageMenu", "Egitmen Idare Menusu")
TBFY_SH:AddLanguage("FirearmTab", "Silah Lisansi")
TBFY_SH:AddLanguage("PracticalTestChooseTest", "Pratik Testi Sec")
TBFY_SH:AddLanguage("SomeoneDoingPracticalTest", "Su an baska biri bu lisans icin uygulamali test aliyor, lutfen daha sonra tekrar deneyiniz.")
TBFY_SH:AddLanguage("PracticalTestFinish", "Tebrikler! Su lisans icin yaptiginiz testi basariyla gectiniz: ")
TBFY_SH:AddLanguage("PracticalTestFail", "Su lisans icin yaptiginiz uygulamali testi gecemediniz: ")
TBFY_SH:AddLanguage("ApplicationHeadline", "Silah Lisansi Basvurusu")
TBFY_SH:AddLanguage("AppName", "Isim:")
TBFY_SH:AddLanguage("AppOccupation", "Meslek:")
TBFY_SH:AddLanguage("YourSignature", "Imzaniz:")
TBFY_SH:AddLanguage("Signature", "Imza:")
TBFY_SH:AddLanguage("SignApp", "Imza Basvurusu")
TBFY_SH:AddLanguage("ApplyLicense", "Lisans Basvurusu:")
TBFY_SH:AddLanguage("ApplicationRequestSent", "Basvurunuz basariyla gonderildi.")
TBFY_SH:AddLanguage("ApplicationRequestArrived", "Silah lisansi basvurusu geldi.")
TBFY_SH:AddLanguage("AppExaminePList", "Silah Lisansi Uygulamasi Listesi")
TBFY_SH:AddLanguage("AppApprove", "Onayla")
TBFY_SH:AddLanguage("AppDisapprove", "Reddet")
TBFY_SH:AddLanguage("ApplicationAlreadyPending", "Zaten gecerli bir silah lisansi basvurunuz bulunmakta!")
TBFY_SH:AddLanguage("AppApprover", "%s'nin %s lisans basvurusu onaylandi.")
TBFY_SH:AddLanguage("AppApproved", "%s sizin %s lisans basvurunuzu onayladi.")
TBFY_SH:AddLanguage("AppDisapprover" , "%s'nin %s lisans basvurusu reddedildi.")
TBFY_SH:AddLanguage("AppDisapproved" , "%s sizin %s lisans basvurunuzu reddetti.")
TBFY_SH:AddLanguage("InstructorRevoked" , "%s sizin lisans egitmenliginizi aldi.")
TBFY_SH:AddLanguage("InstructorGranter" , "%s'ya egitmen rolu verildi.")
TBFY_SH:AddLanguage("InstructorGranted" , "%s sana egitmen rolu verdi.")
TBFY_SH:AddLanguage("TheoryTestRevoker" , "%s'nin %s teori testi alindi.")
TBFY_SH:AddLanguage("TheoryTestRevoked" , "%s senin %s teori testini aldi.")
TBFY_SH:AddLanguage("TheoryTestGranter" , "%s'ya %s teori testi verildi.")
TBFY_SH:AddLanguage("TheoryTestGranted" , "%s sana %s teori testi verdi.")
TBFY_SH:AddLanguage("PracticalTestRevoker" , "%s'nin %s uygulamali testi alindi.")
TBFY_SH:AddLanguage("PracticalTestRevoked" , "%s senin %s uygulamali testini aldi.")
TBFY_SH:AddLanguage("PracticalTestGranter" , "%s'ya %s uygulamali test verildi.")
TBFY_SH:AddLanguage("PracticalTestGranted" , "%s sana %s uygulamali test verdi.")
TBFY_SH:AddLanguage("CarryLicenseRevoker" , "%s'nin %s tasima lisansi alindi.")
TBFY_SH:AddLanguage("CarryLicenseRevoked" , "%s senin %s tasima lisansini aldi.")
TBFY_SH:AddLanguage("CarryLicenseGranter" , "%s'ya %s tasima lisansi verildi.")
TBFY_SH:AddLanguage("CarryLicenseGranted" , "%s sana %s tasima lisansi verdi.")
TBFY_SH:AddLanguage("SellLicenseRevoker" , "%s'nin %s satma lisansi aldindi.")
TBFY_SH:AddLanguage("SellLicenseRevoked" , "%s senin %s satma lisansini aldi.")
TBFY_SH:AddLanguage("SellLicenseGranter" , "%s'ya %s satma lisansi verildi.")
TBFY_SH:AddLanguage("SellLicenseGranted" , "%s sana %s satma lisansi verdi.")
TBFY_SH:AddLanguage("NoTheory" , "%s %s teori testini gecmedi.")
TBFY_SH:AddLanguage("NoPractical" , "%s %s uygulamali testi gecmedi.")
TBFY_SH:AddLanguage("CantAffordTest" , "Bu testi karsilayacak paran yok!")
TBFY_SH:AddLanguage("ReqLicense" , "Bu silah %s tasima lisansi gerektiriyor.")
TBFY_SH:AddLanguage("PracticalCantSwitchJob" , "Uygulamali test sirasindayken meslek degistiremezsiniz.")

//ID, Name
TBFY_SH:RegisterTheoryTest("fa_theory", "Silah Lisansi")

local Question = {
  Question = "Silahin guvenli modu varsa, ne zaman kullanilmali?",
  Options = {
    "Sadece kilifindayken.",
    "Silah kullanilirken.",
    "Asla, her an arizalanabilir diye.",
    "Her zaman, ancak buna sirtinizi yaslamayin.",
  },
  CorrectAnswer = 4,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Asagidakilerden hangisi dogrudur?",
  Options = {
    "Silahlar yari otomatik ve otomatik modlara ayrilabilir, pompali tufekler ayrilamaz.",
    "Durbunler pompalidan cok tufeklerde kullaniliyor.",
    "Pompali tufekler her ateslendikten sonra mermi doldurmanizi gerektiriyor."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)


local Question = {
  Question = "Bir salaha nasil davranmalisiniz?",
  Options = {
    "Oyuncak gibi.",
    "Her zaman dolu gibi davranilmasi lazim, dolu olmasa bile.",
    "Guvenli moddaysa istedigin gibi oynayabilirsin.",
    "Soguk yapmalisin."
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Neden suya ates etmemelisin?",
  Options = {
    "Sudan sekebilir ve herhangi bir yere gidebilir.",
    "Bir tasa isabet edebilir.",
    "Bir baliga isabet edebilir.",
    "Mermi suyla temas edince patlayabilir."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Silahin dolu olup olmadigi en guvenli bir sekilde nasil kontrol edilir?",
  Options = {
    "Guvenli bir noktaya bakip ates ederek.",
    "Guvenli moda alip ates edilmeye calisilmalidir, eger sikmaya calisiyorsa ici doludur.",
    "Guvenli bir noktaya nisan alip sarjore ve ates cemberine bakilmasi lazim."
  },
  CorrectAnswer = 3,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Silah hangi amacla kullanilmalidir?",
  Options = {
    "Hobiler icin kullanilabilir (avcilik, poligon) ancak kendini savunmak icin de kullanabilirsiniz.",
    "Gunluk hayatini daha guvenli hale getirmek icin toplu bolgelerde cebinde tutarak.",
    "Evde kendini daha da guvende hisset diye, evine girenleri sorgusuz sualsiz vurabilirsin."
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Poligonda silahin sarjoru hep dolu olmalidir.",
  Options = {
    "Dogru",
    "Yanlis"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Ates etme durumunda olmadigin surece elin tetikte olmamalidir.",
  Options = {
    "Dogru",
    "Yanlis"
  },
  CorrectAnswer = 1,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Silah bos ya da dolu olsa dahi guvenli modda oldugu takdirde istediginize nisan alabilirsiniz.",
  Options = {
    "Dogru",
    "Yanlis"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)

local Question = {
  Question = "Silah lisansin olmasa bile bir silaha evinde tutma sartiyla sahip olabilirsin.",
  Options = {
    "Dogru",
    "Yanlis"
  },
  CorrectAnswer = 2,
  Imgur = nil,
}
TBFY_SH:AddTheoryQuestion(Question)
