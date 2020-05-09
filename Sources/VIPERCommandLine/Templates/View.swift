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

import VIPER
        
extension \(moduleName) {

    class View: \(view), VIPERView {
        
        private let interactor: Interactor<Router>
        private var viewModel: ViewModel
        
        required init(interactor: Interactor<Router>, viewModel: ViewModel) {
            self.interactor = interactor
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            DispatchQueue.main.async { [unowned self] in
                self.update(with: self.viewModel)
            }
        }
        
        func update(with viewModel: ViewModel) {
            defer {
                self.viewModel = viewModel
            }
            guard isViewLoaded else { return }
        }
            
    }

}
"""
    }
    
    
}
