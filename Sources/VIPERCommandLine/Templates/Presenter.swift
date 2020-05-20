import Foundation

struct Presenter: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import VIPER

extension \(moduleName) {

    class Presenter: VIPERPresenter {
            
        static func map(input presenterModel: PresenterModel) -> ViewModel {
            return ViewModel()
        }
        
    }

}
"""
    }
    
}
