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
        
public protocol Dependencies {
    
}

public enum \(moduleName) {

    public func assemble(entities: Entities, resolver: Resolver) -> \(view) {
        return VIPERModule<View, Interactor<Router>, Presenter, Router>.assemble(entities: entities, resolver: Resolver)
    }

    public struct Entities {
        
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
