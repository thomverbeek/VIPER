import Foundation

struct Router: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import VIPER

extension \(moduleName) {
    
    class Router: VIPER.Router {

        typealias View = \(moduleName).View

        let builder: Builder
        
        required init(builder: Builder) {
            self.builder = builder
        }
        
        func receive(navigation: Navigation) {
            
        }
        
    }

}
"""
    }
    
}
