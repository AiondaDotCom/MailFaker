//
//  MailFaker.swift
//  
//
//  Created by Jonas Sannewald on 14.09.20.
//

import Foundation


/// Provides functions to create random names and email addresses.
public final class MailFaker {
    
    // MARK: - Properties
    
    /// The current language code, set in `init(...)`.
    private let languageCode: String
    
    
    // MARK: - Initializer
    
    /**
    Creates a new instance of MailFaker with a specific language code.
    
    If no language code is specified as parameter, the language code of the current locale is used.
    
        let mailFaker = MailFaker() // => e.g. "de" on a german Mac.
    
    Fallback is always "en" and is used if the given language code is not supported.
    
         let mailFaker = MailFaker(withExplicitLocale: "ar") // => "en" because "ar" is not supported.
    
    This can also happen if no language code is set as parameter because then the current language code of locale is used.
     
         let mailFaker = MailFaker() // => "en" on an arabic Mac.
     
    The language code cannot be changed after the initializer has been called.
    
    - Parameter code: ISO 639-1 language code ([specification](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)).
    */
    public init(withExplicitLanguageCode code: String = Locale.current.languageCode ?? "en") {
        let supportedLanguageCodes = Array(lastNames.keys)
        self.languageCode = supportedLanguageCodes.contains(code) ? code : "en"
    }
    
    
    // MARK: - Public MailFaker functions
    
    /**
    Creates a first name based on the `gender` parameter.
    
    If no parameter is specified, a random first name will be generated.
     
        let femaleFirstName = mailFaker.firstName(.female)
        let maleFirstName = mailFaker.firstName(.male)
        let randomFirstName = mailFaker.firstName() // or mailFaker.firstName(.random)
     
    - Parameter gender: Specifies whether a male, female or random first name should be created.
    - Returns: A first name based on the `gender` parameter.
    */
    public func firstName(_ gender:Gender = .random) -> String {
        switch gender {
            case .female:
                return femaleFirstNames[languageCode]!.randomElement()!
            case .male:
                return maleFirstNames[languageCode]!.randomElement()!
            case .random:
                return Bool.random() ? femaleFirstNames[languageCode]!.randomElement()! :
maleFirstNames[languageCode]!.randomElement()!
        }
    }
    
    /// Creates a last name, the gender does not matter.
    public func lastName() -> String {
        return lastNames[languageCode]!.randomElement()!
    }
    
    /**
    Creates a full name based on the `gender` parameter.
     
    If no parameter is specified, a random full name will be generated.
     
        let femaleFullName = mailFaker.fullName(.female)
        let maleFullName = mailFaker.fullName(.male)
        let randomFullName = mailFaker.fullName() // or mailFaker.fullName(.random)
     
    - Parameter gender: Specifies whether a male, female or random full name should be created.
    - Returns: A full name based on the `gender` parameter.
    */
    public func fullName(_ gender:Gender = .random) -> String {
        switch gender {
            case .female:
                return self.firstName(.female) + " " + self.lastName()
            case .male:
                return self.firstName(.male) + " " + self.lastName()
            case .random:
                return self.firstName(.random) + " " + self.lastName()
        }
    }
    
    /**
    Creates the local-part of an email address based on the `gender` parameter.
     
    If no parameter is specified, a random local-part will be generated.
     
        let femaleLocalPart = mailFaker.localPart(.female)
        let maleLocalPart = mailFaker.localPart(.male)
        let randomLocalPart = mailFaker.localPart() // or mailFaker.localPart(.random)
     
    - Parameter gender: Specifies whether a male, female or random local-part should be created.
    - Returns: A local-part based on the `gender` parameter.
    */
    public func localPart(_ gender:Gender = .random) -> String {
        var fakeName: (firstName: String, lastName: String) {
            switch gender {
            case .female:
                let firstName = self.replaceAllBadCharacters(from: self.firstName(.female))
                let lastName = self.replaceAllBadCharacters(from: self.lastName())
                return (firstName, lastName)
            case .male:
                let firstName = self.replaceAllBadCharacters(from: self.firstName(.male))
                let lastName = self.replaceAllBadCharacters(from: self.lastName())
                return (firstName, lastName)
            case .random:
                let firstName = self.replaceAllBadCharacters(from: self.firstName(.random))
                let lastName = self.replaceAllBadCharacters(from: self.lastName())
                return (firstName, lastName)
            }
        }
        let delimiters = ["_", ".", "-"]
        let randomNumber = Int.random(in: 0..<9999)
        var namePart = [fakeName.firstName, fakeName.lastName].shuffled()
        namePart.insert(delimiters.randomElement()!, at: 1)
        let combinedEmail = Bool.random() ? [namePart.joined(), delimiters.randomElement()! + String(randomNumber)] : [String(randomNumber) + delimiters.randomElement()!, namePart.joined()]
        return combinedEmail.joined().lowercased()
    }
    
    /**
    Creates the domain-part of an email address.
     
    "Lorem Ipsum" words are used to minimize the possibility that the domain exists.
    Also, a high combination is achieved, because all current (15.09.2020) top-level domains are used.
    */
    public func domainPart() -> String {
        let sld = loremWords.randomElement()!
        let tld = topLevelDomains.randomElement()!
        return (sld + "." + tld).lowercased()
    }
    
    /**
    Creates a full email address based on the `gender` parameter.
     
    If no parameter is specified, a random full email address will be generated.
     
        let femaleFullAddress = mailFaker.fullAddress(.female)
        let maleFullAddress = mailFaker.fullAddress(.male)
        let randomFullAddress = mailFaker.fullAddress() // or mailFaker.fullAddress(.random)
     
    - Parameter gender: Specifies whether a male, female or random full email address should be created.
    - Returns: A full email address based on the `gender` parameter.
    */
    public func fullAddress(_ gender:Gender = .random) -> String {
        let localPart = self.localPart(gender)
        let domainPart = self.domainPart()
        return localPart + "@" + domainPart
    }
    
    
    // MARK: - Private helper functions
    
    /**
    Removes special characters from a string.
     
    The languages supported by MailFaker contain special characters that should not be included in email addresses.
    For this reason, these special characters must be replaced by [A-Za-z] characters.
     
        let name = "Günther Müller"
        let emailName = replaceAllBadCharacters(from: name)
        print(emailName) // => Guenther Mueller
     
    - Parameter from: The string that contains the special characters.
    - Returns: The cleaned string without special characters.
    */
    private func replaceAllBadCharacters(from:String) -> String {
        var cleanString = from
        
        let replaceDict = [
            "'":"", // en
            "Ä":"Ae","ä":"ae","Ü":"Ue","ü":"ue","Ö":"Oe","ö":"oe","ß":"ss", // de
            "À":"A","à":"a","Â":"A","â":"a","Æ":"AE","æ":"ae","Ç":"C","ç":"c","È":"E","è":"e","É":"E","é":"e","Ê":"E","ê":"e","Ë":"E","ë":"e","Î":"I","î":"i","Ï":"I","ï":"i","Ô":"O","ô":"o","Œ":"OE","œ":"oe","Ù":"U","ù":"u","Û":"U","û":"u","Ÿ":"Y","ÿ":"y" // fr
        ]
        
        // Unfortunately, Swift 5 does not support replacingOccurrences(...) with arrays
        // For this reason, this workaround is necessary
        for badChar in replaceDict {
            cleanString = cleanString.replacingOccurrences(of: badChar.key, with: badChar.value)
        }
        
        return cleanString
    }

}
