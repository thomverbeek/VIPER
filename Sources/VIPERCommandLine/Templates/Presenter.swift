import Foundation

struct Presenter: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import VIPER

extension \(moduleName) {

    class Presenter: VIPER.Presenter {
        
        typealias UseCase = \(moduleName).UseCase
        typealias Navigation = \(moduleName).Navigation

        let viewModel: ViewModel
        
        required init(presenterModel: PresenterModel) {
            self.viewModel = ViewModel()

            // Bind to the presenterModel
        }
        
        func receive(userInteraction: UserInteraction) {
            
        }
                
    }

}
"""
    }
    
}
