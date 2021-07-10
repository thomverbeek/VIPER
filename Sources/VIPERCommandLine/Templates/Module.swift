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
        
public protocol Builder {
    
}

public enum \(moduleName) {

    public func assemble(entities: Entities, builder: Builder) -> \(view) {
        return VIPERModule<View, Interactor, Presenter, Router>.assemble(entities: entities, builder: builder)
    }

    public struct Entities {
        
        public init() {
            
        }
        
    }
    
    enum UserInteraction {
        
    }

    enum UseCase {
        
    }
    
    enum Navigation {
        
    }
        
    struct PresenterModel {
        
    }

    struct ViewModel {
        
    }

}
"""
    }
    
}
