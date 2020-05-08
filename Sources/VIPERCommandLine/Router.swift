import Foundation

struct Router: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        return
"""
import Foundation

import VIPER

extension \(moduleName) {
    
    class Router: VIPERRouter<Components, View> {
            
    }

}
"""
    }
    
}
