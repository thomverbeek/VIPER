import Foundation

struct Interactor: Template {
        
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Combine

import VIPER

extension \(moduleName) {

    class Interactor<Router>: VIPERInteractor {
        
        let presenter: CurrentValueSubject<PresenterModel, Never>
        let router = PassthroughSubject<Navigation, Never>()
        
        required init(entities: Entities) {
            presenter = .init(Self.generatePresenterModel())
        }
        
        private static func generatePresenterModel() -> PresenterModel {
            return PresenterModel()
        }
        
        func receive(userInteraction: UserInteraction) {
            
        }
        
    }

}
"""
    }
    
}
