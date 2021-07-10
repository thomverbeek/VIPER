import Foundation

struct Presenter: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Combine

import VIPER

extension \(moduleName) {

    class Presenter: VIPERPresenter {
        
        let viewModel: ViewModel
        let interactor = PassthroughSubject<UseCase, Never>()
        let router = PassthroughSubject<Navigation, Never>()
        
        required init(presenterModel: PresenterModel) {
            self.viewModel = ViewModel()
        }
        
        func receive(userInteraction: UserInteraction) {
            
        }
                
    }

}
"""
    }
    
}
