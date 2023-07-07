import CustomDump
import XCTest
@testable import Testoria

final class UseCaseTests: XCTestCase {
    
    func test_add_multiple_suites() throws {
        let sut = makeSUT()
        let suiteId_1 = try sut.addSuite(with: "Home screen")
        let suiteId_2 = try sut.addSuite(with: "Log in screen")
        XCTAssertNoDifference(
            suiteId_1,
            .id("uniqueId_1")
        )
        XCTAssertNoDifference(
            suiteId_2,
            .id("uniqueId_2")
        )
        XCTAssertNoDifference(
            sut.buildSuites(),
            [
                Suite(
                    .id("uniqueId_1"),
                    name: "Home screen"
                ),
                Suite(
                    .id("uniqueId_2"),
                    name: "Log in screen"
                )
            ]
        )
    }
    
    func test_add_suite_with_recurring_name() throws {
        let sut = makeSUT()
        try sut.addSuite(with: "Home screen")
        XCTAssertThrowsError(try sut.addSuite(with: "Home screen")) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .recurringSuiteName("Home screen"))
            
        }
    }
    
    func test_add_mutliple_scenarios_for_same_suite() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        let scenarioId_1 = try sut.addScenario(with: "Show welcome message", for: suiteId)
        let scenarioId_2 = try sut.addScenario(with: "Show discount message", for: suiteId)
        XCTAssertNoDifference(
            scenarioId_1,
            .id("uniqueId_1", "uniqueId_2")
        )
        XCTAssertNoDifference(
            scenarioId_2,
            .id("uniqueId_1", "uniqueId_3")
        )
        XCTAssertNoDifference(
            sut.buildSuites()[0].scenario,
            [
                Scenario(
                    .id("uniqueId_1", "uniqueId_2"),
                    name: "Show welcome message"
                ),
                Scenario(
                    .id("uniqueId_1", "uniqueId_3"),
                    name: "Show discount message"
                )
            ]
        )
    }
    
    func test_add_scenario_with_recurring_name_for_same_suite() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        try sut.addScenario(with: "Show welcome message", for: suiteId)
        XCTAssertThrowsError(_ = try sut.addScenario(with: "Show welcome message" , for: suiteId)) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .recurringScenarioName(suiteName: "Home screen", scenarioName: "Show welcome message"))
            
        }
    }
    
    func test_add_scenarios_for_different_suite() throws {
        let sut = makeSUT()
        let suiteId_1 = try sut.addSuite(with: "Home screen")
        let suiteId_2 = try sut.addSuite(with: "Log in screen")
        let scenarioId_1 = try sut.addScenario(with: "Show welcome message", for: suiteId_1)
        let scenarioId_2 = try sut.addScenario(with: "Show discount message", for: suiteId_2)
        XCTAssertNoDifference(
            scenarioId_1,
            .id("uniqueId_1", "uniqueId_3")
        )
        XCTAssertNoDifference(
            scenarioId_2,
            .id("uniqueId_2", "uniqueId_4")
        )
        XCTAssertNoDifference(
            sut.buildSuites()[0].scenario,
            [
                Scenario(
                    .id("uniqueId_1", "uniqueId_3"),
                    name: "Show welcome message"
                )
            ]
        )
        XCTAssertNoDifference(
            sut.buildSuites()[1].scenario,
            [
                Scenario(
                    .id("uniqueId_2", "uniqueId_4"),
                    name: "Show discount message"
                )
            ]
        )
    }
    
    func test_add_scenario_with_wrong_suiteId() throws {
        let sut = makeSUT()
        try sut.addSuite(with: "Home screen")
        XCTAssertThrowsError(try sut.addScenario(with: "Show welcome message", for: .id("wrongId"))) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .suiteNotFound(.id("wrongId"))
            )
        }
    }
    
    func test_rename_suite() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        try sut.renameSuite(with: "New Home screen", for: suiteId)
        XCTAssertNoDifference(
            sut.buildSuites(),
            [
                Suite(
                    .id("uniqueId_1"),
                    name: "New Home screen"
                )
            ]
        )
    }
    
    func test_rename_suite_with_wrong_suiteId() throws {
        let sut = makeSUT()
        try sut.addSuite(with: "Home screen")
        XCTAssertThrowsError(try sut.renameSuite(with: "New Home screen", for: .id("wrongId"))) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .suiteNotFound(.id("wrongId"))
            )
        }
    }
    
    func test_rename_scenario() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        let scenarioID = try sut.addScenario(with: "Show welcome message", for: suiteId)
        try sut.renameScenario(with: "New Show welcome message", for: scenarioID)
        XCTAssertNoDifference(
            sut.buildSuites()[0].scenario,
            [
                Scenario(
                    .id("uniqueId_1", "uniqueId_2"),
                    name: "New Show welcome message"
                )
            ]
        )
    }
    
    func test_rename_scenario_with_wrong_suiteId() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        let scenarioID = try sut.addScenario(with: "Show welcome message", for: suiteId)
        XCTAssertThrowsError(try sut.renameScenario(with: "New Show welcome message", for: .id("wrongSuiteId", scenarioID.value))) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .scenarioNotFound(.id("wrongSuiteId", "uniqueId_2"))
            )
        }
    }
    
    func test_rename_scenario_with_wrong_scenarioId() throws {
        let sut = makeSUT()
        let suiteId = try sut.addSuite(with: "Home screen")
        let scenarioID = try sut.addScenario(with: "Show welcome message", for: suiteId)
        XCTAssertThrowsError(try sut.renameScenario(with: "New Show welcome message", for: .id(scenarioID.suiteId , "wrongScenarioId"))) {
            XCTAssertNoDifference(
                $0 as? UseCaseError,
                .scenarioNotFound(.id("uniqueId_1", "wrongScenarioId"))
            )
        }
    }
}

extension UseCaseTests {
    
    func makeSUT() -> UseCase {
        var counter = 0
        return UseCase {
            counter += 1
            return "uniqueId_\(counter)"
        }
    }
}
