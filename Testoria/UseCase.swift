
import Foundation

enum UseCaseError: Error, Equatable {
    case recurringSuiteName(String)
    case recurringScenarioName(suiteName: String, scenarioName: String)
    case suiteNotFound(Suite.Id)
}

final class UseCase {
    
    private var suites: [Suite] = []
    private let generateId: () -> String
    
    init(
        generateId: @escaping () -> String = { UUID().uuidString }
    ) {
        self.generateId = generateId
    }
    
    func addSuite(with name: String) throws -> Suite.Id {
        if suites.contains(where: { $0.name == name }) {
            throw UseCaseError.recurringSuiteName(name)
        }
        
        let id: Suite.Id = .id(generateId())
        let newSuite = Suite(id, name: name)
        suites.append(newSuite)
        return id
    }
    
    func addScenario(with name: String, for suiteId: Suite.Id) throws -> Scenario.Id {
        guard let suiteIndex = suites.firstIndex(where: { $0.id == suiteId }) else {
            throw UseCaseError.suiteNotFound(suiteId)
        }
        var suite = suites[suiteIndex]
        if suite.scenario.contains(where: { $0.name == name }) {
            throw UseCaseError.recurringScenarioName(suiteName: suite.name, scenarioName: name)
        }
        let id: Scenario.Id = .id(suite.id.value, generateId())
        suite.scenario.append(Scenario(id, name: name))
        suites[suiteIndex] = suite
        return id
    }
    
    func buildSuites() -> [Suite] {
        suites
    }
}

struct Suite: Equatable {
    struct Id: Equatable {
        let value: String
        
        static func id(
            _ value: String
        ) -> Id {
            Id(value: value)
        }
    }
    
    var id: Id
    var name: String
    var scenario: [Scenario]
    
    init(
        _ id: Id,
        name: String,
        scenario: [Scenario] = []
    ) {
        self.id = id
        self.name = name
        self.scenario = scenario
    }
}

struct Scenario: Equatable {
    struct Id: Equatable {
        let suiteId: String
        let value: String
        
        static func id(
            _ suiteId: String,
            _ value: String
        ) -> Id {
            Id(suiteId: suiteId, value: value)
        }
    }
    
    var id: Id
    var name: String
    
    init(
        _ id: Id,
        name: String
    ) {
        self.id = id
        self.name = name
    }
}
