import Foundation

struct View: Template {
        
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
import Combine

import VIPER
        
extension \(moduleName) {

    class View: \(view), VIPERView {
        
        let presenter = PassthroughSubject<UserInteraction, Never>()
        var subscriptions = Set<AnyCancellable>()

        private let viewModel: ViewModel
        
        required init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // add subscriptions to viewModel here
        }

    }

}
"""
    }
    
    
}
