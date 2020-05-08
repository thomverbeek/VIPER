import Foundation

struct Module: Template {
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String {
        let framework: String = {
            switch operatingSystem {
            case .iOS, .tvOS:
                return "UIKit"
            case .macOS:
                return "AppKit"
            }
        }()
        let view: String = {
            switch operatingSystem {
            case .iOS, .tvOS:
                return "UIViewController"
            case .macOS:
                return "NSViewController"
            }
        }()

        return
"""
import \(framework)

import VIPER
        
public protocol Components {
    
}

public enum \(moduleName) {

    public func assemble(dependencies: Dependencies, components: Components) -> \(view) {
        return VIPERBuilder<View, Interactor<Router>, Presenter, Router>.assemble(dependencies: dependencies, components: components)
    }

    public struct Dependencies {
        
        public init() {
            
        }
    }
        
    struct PresenterModel {
        
    }

    struct ViewModel {
        
    }

}
"""
    }
    
}
