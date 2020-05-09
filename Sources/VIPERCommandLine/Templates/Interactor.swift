import Foundation

struct Interactor: Template {
        
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Combine
import Foundation

import VIPER

extension \(moduleName) {

    class Interactor<Router>: VIPERInteractor {
        
        private let router: Router
        private(set) var output: CurrentValueSubject<PresenterModel, Never>
        
        required init(entities: Entities, router: Router) {
            self.router = router
            output = .init(Self.generatePresenterModel())
        }
        
        private static func generatePresenterModel() -> PresenterModel {
            return PresenterModel()
        }
        
    }

}
"""
    }
    
}
