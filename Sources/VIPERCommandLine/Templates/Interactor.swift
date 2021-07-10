import Foundation

struct Interactor: Template {
        
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Combine

import VIPER

extension \(moduleName) {

    class Interactor: VIPERInteractor {
        
        let presenterModel: Example.PresenterModel
        
        required init(entities: Entities) {
            self.presenterModel = PresenterModel()
        }
        
        func receive(useCase: UseCase) {
            
        }
        
    }

}
"""
    }
    
}
