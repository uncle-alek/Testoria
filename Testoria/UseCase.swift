
import Foundation

enum UseCaseError: Error, Equatable {
    case recurringSuiteName(String)
    case recurringScenarioName(suiteName: String, scenarioName: String)
    case suiteNotFound(Suite.Id)
    case scenarioNotFound(Scenario.Id)
}

final class UseCase {
    
    private var suites: [Suite] = []
    private let generateId: () -> String
    
    init(
        generateId: @escaping () -> String = { UUID().uuidString }
    ) {
        self.generateId = generateId
    }
    
    @discardableResult
    func addSuite(
        with name: String
    ) throws -> Suite.Id {
        if isSuiteExist(with: name) {
            throw UseCaseError.recurringSuiteName(name)
        }
        let id: Suite.Id = .id(generateId())
        let newSuite = Suite(id, name: name)
        suites.append(newSuite)
        return id
    }
    
    @discardableResult
    func addScenario(
        with name: String,
        for suiteId: Suite.Id
    ) throws -> Scenario.Id {
        guard let suiteIndex = suiteIndex(for: suiteId) else {
            throw UseCaseError.suiteNotFound(suiteId)
        }
        let suite = suites[suiteIndex]
        if isScenarioExist(with: name, for: suite) {
            throw UseCaseError.recurringScenarioName(suiteName: suite.name, scenarioName: name)
        }
        let id: Scenario.Id = .id(suite.id.value, generateId())
        suites[suiteIndex].scenarios.append(Scenario(id, name: name))
        return id
    }
    
    func renameSuite(
        with newName: String,
        for suiteId: Suite.Id
    ) throws {
        guard let index = suiteIndex(for: suiteId) else {
            throw UseCaseError.suiteNotFound(suiteId)
        }
        suites[index].name = newName
    }
    
    func renameScenario(
        with newName: String,
        for scenarioId: Scenario.Id
    ) throws {
        guard let index = scenarioIndex(for: scenarioId) else {
            throw UseCaseError.scenarioNotFound(scenarioId)
        }
        suites[index.suiteIndex].scenarios[index.scenarioIndex].name = newName
    }
    
    func deleteSuite(
        for suiteId: Suite.Id
    ) throws {
        guard let index = suiteIndex(for: suiteId) else {
            throw UseCaseError.suiteNotFound(suiteId)
        }
        suites.remove(at: index)
    }
    
    func deleteScenario(
        for scenarioId: Scenario.Id
    ) throws {
        guard let index = scenarioIndex(for: scenarioId) else {
            throw UseCaseError.scenarioNotFound(scenarioId)
        }
        suites[index.suiteIndex].scenarios.remove(at: index.scenarioIndex)
    }
    
    func buildSuites() -> [Suite] {
        suites
    }
}

private extension UseCase {
    
    func isSuiteExist(
        with name: String
    ) -> Bool {
        return suites.contains(where: { $0.name == name })
    }
    
    func suiteIndex(
        for suiteId: Suite.Id
    ) -> Int? {
        return suites.firstIndex(where: { $0.id == suiteId })
    }
    
    func isScenarioExist(
        with name: String,
        for suite: Suite
    ) -> Bool {
        return suite.scenarios.contains(where: { $0.name == name })
    }
    
    func scenarioIndex(
        for scenarioId: Scenario.Id
    ) -> (suiteIndex: Int, scenarioIndex: Int)? {
        guard let suiteIndex = suiteIndex(for: .id(scenarioId.suiteId)),
           let scenarioIndex = suites[suiteIndex].scenarios.firstIndex(where: { $0.id == scenarioId }) else {
            return nil
        }
        return (suiteIndex, scenarioIndex)
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
    var scenarios: [Scenario]
    
    init(
        _ id: Id,
        name: String,
        scenarios: [Scenario] = []
    ) {
        self.id = id
        self.name = name
        self.scenarios = scenarios
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
