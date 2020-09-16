import XCTest

import MailFaker

var tests = [XCTestCaseEntry]()
tests += MailFaker.allTests()
XCTMain(tests)
