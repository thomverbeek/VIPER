import VIPER

extension Example {
    
    class Router: VIPER.Router {
        
        typealias View = Example.View
        
        var presentedSomething = false
        
        required init(builder: Builder) {

        }
        
        func receive(navigation: Navigation) {
            switch navigation {
            case .presentSomething:
                presentedSomething = true
            }
        }
                
    }

}
