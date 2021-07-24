import Foundation

struct Interactor: Template {
        
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import VIPER

extension \(moduleName) {

    class Interactor: VIPER.Interactor {
        
        let presenterModel: PresenterModel
        
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
