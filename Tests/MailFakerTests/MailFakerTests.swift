import XCTest
@testable import MailFaker

/// This test class contains only rudimentary test cases because the testing of random returns is only partially possible.
final class MailFakerTests: XCTestCase {
    
    /// Tests if the initializers work correctly.
    func testInitMailFaker() {
        
        let fakerEN = MailFaker(withExplicitLanguageCode: "en")
        let fakerDE = MailFaker(withExplicitLanguageCode: "de")
        let fakerFR = MailFaker(withExplicitLanguageCode: "fr")
        let fakerFALLBACK = MailFaker(withExplicitLanguageCode: "zh")
        let fakerDEFAULT = MailFaker()
        
        XCTAssertTrue(femaleFirstNames["en"]!.contains(fakerEN.firstName(.female)))
        XCTAssertTrue(lastNames["en"]!.contains(fakerFALLBACK.lastName()))
        
        XCTAssertTrue(
            lastNames["en"]!.contains(fakerDEFAULT.lastName()) ||
            lastNames["de"]!.contains(fakerDEFAULT.lastName()) ||
            lastNames["fr"]!.contains(fakerDEFAULT.lastName())
        )
        
        XCTAssertTrue(maleFirstNames["de"]!.contains(fakerDE.firstName(.male)))
        XCTAssertTrue(maleFirstNames["fr"]!.contains(fakerFR.firstName(.male)))
        
    }
    
    /// Tests if the replacement of bad characters works correctly.
    func testBadCharacters() {
        
        let faker = MailFaker(withExplicitLanguageCode: "fr")
        var localParts = [String]()
        let badChars: Set = ["'","Ä","ä","Ü","ü","Ö","ö","ß","À","à","Â","â","Æ","æ","Ç","ç","È","è","É","é","Ê","ê","Ë","ë","Î","î","Ï","ï","Ô","ô","Œ","œ","Ù","ù","Û","û","Ÿ","ÿ"]
        
        for _ in 0...300 {
            localParts.append(faker.localPart())
        }
        
        XCTAssertTrue(badChars.isDisjoint(with: localParts))
        
    }

    static var allTests = [
        ("testInitMailFaker", testInitMailFaker),
        ("testBadCharacters", testBadCharacters)
    ]
    
}
