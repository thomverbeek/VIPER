import Foundation

struct Router: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Foundation

import VIPER

extension \(moduleName) {
    
    class Router: NSObject, VIPERRouter {

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
