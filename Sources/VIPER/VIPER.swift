import Combine
import Foundation

/// A VIPER View represents the UI logic of your screen module.
///
/// It must define:
///
/// - a Presenter (which handles all user interaction logic on its behalf);
/// - a View Model (which contains its view state information).
///
/// Messages are passed between VIPER components via entities. A View Model is used  by a Presenter to
/// communicate view state information to the View.
///
public protocol VIPERView {
    
    associatedtype Presenter
    associatedtype ViewModel
    
    init(presenter: Presenter, viewModel: ViewModel)
    func update(with viewModel: ViewModel)

}

/// A VIPER Interactor represents the business logic of your screen module.
///
/// It must define:
///
/// - Services it requires (micro-services, typically vended by a dependency injection container);
/// - Dependencies it relies on (which give the screen its configuration);
/// - a Presenter Model (which contains presentation state information).
///
public protocol VIPERInteractor {
    
    associatedtype Services
    associatedtype Dependencies
    associatedtype PresenterModel
    
    var output: CurrentValueSubject<PresenterModel, Never> { get }
    
    init(services: Services, dependencies: Dependencies)
    
}

/// A VIPER Presenter represents the presentation logic of your screen module.
///
/// It must define:
///
/// - An Interactor (which handles all business logic on its behalf);
/// - A Router (which handles all navigation logic on its behalf).
///
public protocol VIPERPresenter {
        
    associatedtype Interactor
    associatedtype Router
    associatedtype PresenterModel
    associatedtype ViewModel
    
    init(interactor: Interactor, router: Router)
    
    static func map(presenterModel: PresenterModel) -> ViewModel
    
}

/// A VIPER Router handles the navigation logic of your screen module.
///
/// It must define:
///
/// - Services (which are used to instantiate other modules);
/// - A View (that is weakly held by the router for configuration and navigation).
///
open class VIPERRouter<Services, View: AnyObject>: NSObject {
    
    public weak var view: View? {
        didSet {
            viewDidChange()
        }
    }
    
    internal var subscription: AnyCancellable?
    public let services: Services

    required public init(services: Services) {
        self.services = services
    }
        
    deinit {
        subscription = nil
    }
    
    open func viewDidChange() {
        
    }

}

/// A VIPER Builder handles the assembly logic of your screen module.
///
/// A VIPER Builder is a composable assembler that specifies constraints for constructing VIPER
/// components. It defines the strict guidelines that VIPER configurations must meet and ensures that
/// communication between components is set up. This guarantees that any assembled VIPER configuration
/// will communicate in a consistent manner, regardless of wherher the assembly is for production or testing..
///
/// The builder defines:
///
/// - A View (which strongly retains the VIPER components);
/// - An Interactor (which must match the Presenter's Interactor);
/// - A Presenter (which must match the View's Presenter);
/// - A Router (which retains the subscription of the communication loop between components.
///
public class VIPERBuilder<View: VIPERView & AnyObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router: VIPERRouter<Interactor.Services, View>>
where
    Presenter == View.Presenter,
    Presenter.ViewModel == View.ViewModel,
    Presenter.Interactor == Interactor,
    Presenter.PresenterModel == Interactor.PresenterModel,
    Presenter.Router == Router
{
        
    internal static func components(services: Interactor.Services, dependencies: Interactor.Dependencies) -> (view: View, interactor: Interactor, presenter: Presenter, router: Router) {
        let router = Router(services: services)
        let interactor = Interactor(services: services, dependencies: dependencies)
        let presenter = Presenter(interactor: interactor, router: router)
        let view = View(presenter: presenter, viewModel: Presenter.map(presenterModel: interactor.output.value))

        router.subscription = interactor.output.sink { [weak view] presenterModel in
            view?.update(with: Presenter.map(presenterModel: presenterModel))
        }
        router.view = view

        return (view: view, interactor: interactor, presenter: presenter, router: router)
    }
    
    public static func assemble(services: Interactor.Services, dependencies: Interactor.Dependencies) -> View {
        return components(services: services, dependencies: dependencies).view
    }

}

/// A VIPER Module defines the minimal requirements needed to construct a VIPER screen.
///
/// It must define:
///
/// - Dependencies (used to configure the module);
/// - Services (micro-services shared throughout your application for interactors to consume);
/// - View (the assembled screen expected to be constructed).
///
/// In concept, a VIPER Module is an abstraction of a screen assembly. In practice, a typical implementation
/// will make use of a VIPER Builder to construct and return the screen. When working across framework
/// boundaries, you'll likely define a module that type-erases the View to some UI-specific component.
///
public protocol VIPERModule {

    associatedtype Dependencies
    associatedtype Services
    associatedtype View

    static func assemble(services: Services, dependencies: Dependencies) -> View

}
