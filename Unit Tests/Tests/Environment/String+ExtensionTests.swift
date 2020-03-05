import XCTest
@testable import Environment

class EnvironmentStringExtensionTests: XCTestCase {
    
    func test_camelcased() {
        XCTAssertEqual("missingseparator".camelcased(separator: "_"), "Missingseparator")
        XCTAssertEqual("missingSeparator".camelcased(separator: "_"), "Missingseparator")
        XCTAssertEqual("MissingSeparator".camelcased(separator: "_"), "Missingseparator")
        XCTAssertEqual("MISSINGSEPARATOR".camelcased(separator: "_"), "Missingseparator")
        
        XCTAssertEqual("includes_separator".camelcased(separator: "_"), "IncludesSeparator")
        XCTAssertEqual("includes_Separator".camelcased(separator: "_"), "IncludesSeparator")
        XCTAssertEqual("Includes_Separator".camelcased(separator: "_"), "IncludesSeparator")
        XCTAssertEqual("INCLUDES_SEPARATOR".camelcased(separator: "_"), "IncludesSeparator")
        
        XCTAssertEqual("more_than_one_separator".camelcased(separator: "_"), "MoreThanOneSeparator")
        XCTAssertEqual("more_Than_One_Separator".camelcased(separator: "_"), "MoreThanOneSeparator")
        XCTAssertEqual("More_Than_One_Separator".camelcased(separator: "_"), "MoreThanOneSeparator")
        XCTAssertEqual("MORE_THAN_ONE_SEPARATOR".camelcased(separator: "_"), "MoreThanOneSeparator")
    }
    
    func test_hungarianCased() {
        XCTAssertEqual("missingseparator".hungarianCased(separator: "_"), "missingseparator")
        XCTAssertEqual("missingSeparator".hungarianCased(separator: "_"), "missingseparator")
        XCTAssertEqual("MissingSeparator".hungarianCased(separator: "_"), "missingseparator")
        XCTAssertEqual("MISSINGSEPARATOR".hungarianCased(separator: "_"), "missingseparator")
        
        XCTAssertEqual("includes_separator".hungarianCased(separator: "_"), "includesSeparator")
        XCTAssertEqual("includes_Separator".hungarianCased(separator: "_"), "includesSeparator")
        XCTAssertEqual("Includes_Separator".hungarianCased(separator: "_"), "includesSeparator")
        XCTAssertEqual("INCLUDES_SEPARATOR".hungarianCased(separator: "_"), "includesSeparator")
        
        XCTAssertEqual("more_than_one_separator".hungarianCased(separator: "_"), "moreThanOneSeparator")
        XCTAssertEqual("more_Than_One_Separator".hungarianCased(separator: "_"), "moreThanOneSeparator")
        XCTAssertEqual("More_Than_One_Separator".hungarianCased(separator: "_"), "moreThanOneSeparator")
        XCTAssertEqual("MORE_THAN_ONE_SEPARATOR".hungarianCased(separator: "_"), "moreThanOneSeparator")
    }
}
