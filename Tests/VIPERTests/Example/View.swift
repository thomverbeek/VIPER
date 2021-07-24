#if os(macOS)
import AppKit
#else
import UIKit
#endif

import VIPER
        
extension Example {

    class View: VIPER.View, ViewModelDelegate {
        
        typealias UserInteraction = Example.UserInteraction
        
        let viewModel: ViewModel

        var title: String
        var rows: [String]
        
        required init(viewModel: ViewModel) {
            self.viewModel = viewModel
            
            title = viewModel.title
            rows = viewModel.rows
            
            viewModel.delegate = self
        }
        
        func titleDidUpdate(title: String) {}
        func rowsDidUpdate(rows: [String]) {}
        
    }

}
