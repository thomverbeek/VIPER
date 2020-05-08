import Foundation

struct Presenter: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Foundation

import VIPER

extension \(moduleName) {

    class Presenter: VIPERPresenter {
            
        static func map(presenterModel: PresenterModel) -> ViewModel {
            return ViewModel()
        }
        
    }

}
"""
    }
    
}
