import Combine
import Foundation

/**
 A VIPER View represents the UI logic of your screen module.

 It must define:

 - a Presenter (which handles all user interaction logic on its behalf);
 - a View Model (which contains its view state information).

 Messages are passed between VIPER components via entities. A View Model is used  by a Presenter to
 communicate view state information to the View.
 */
public protocol VIPERView {
    
    associatedtype Presenter
    associatedtype ViewModel
    
    init(presenter: Presenter, viewModel: ViewModel)
    func update(with viewModel: ViewModel)

}

/**
 A VIPER Interactor represents the business logic of your screen module.

 It must define:

 - Services it requires (micro-services, typically vended by a dependency injection container);
 - Dependencies it relies on (which give the screen its configuration);
 - a Presenter Model (which contains presentation state information).
 */
public protocol VIPERInteractor {
    
    associatedtype Dependencies
    associatedtype PresenterModel
    
    var output: CurrentValueSubject<PresenterModel, Never> { get }
    
    init(dependencies: Dependencies)
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 It must define:

 - An Interactor (which handles all business logic on its behalf);
 - A Router (which handles all navigation logic on its behalf).
 */
public protocol VIPERPresenter {

    associatedtype Interactor
    associatedtype Router
    associatedtype PresenterModel
    associatedtype ViewModel
    
    init(interactor: Interactor, router: Router)
    
    static func map(presenterModel: PresenterModel) -> ViewModel
    
}

/**
 A VIPER Router handles the navigation logic of your screen module.

 The Router defines:

 - Modules (which is used to instantiate other modules);
 - A View (that is weakly held by the router, a context for configuration and navigation).

 As Routers hold a weak reference to the view, they're also designated to hold the reference to the cancellable subscription.
 */
open class VIPERRouter<Modules, View: AnyObject>: NSObject {
    
    public weak var view: View? {
        didSet {
            viewDidChange()
        }
    }
    
    fileprivate var subscription: AnyCancellable?
    public let modules: Modules

    required public init(modules: Modules) {
        self.modules = modules
    }

    /**
     Called after the view has changed.

     This method is invoked when a view is assigned to this Router or when said weakly-referenced
     view is deallocated. Routers override this method to configure their view.

     The default implementation does nothing.
     */
    open func viewDidChange() {}

}

/**
 A VIPER Builder handles the assembly logic of your screen module.

 A VIPER Builder is a composable assembler that specifies constraints for constructing VIPER components. It
 defines the strict guidelines that VIPER configurations must meet and ensures that communication between
 components is set up. This guarantees that any vended VIPER assembly will communicate in identical
 manner, regardless of whether the assembly is for production or testing.

 The Builder defines:

 - A View (which strongly retains the VIPER components);
 - An Interactor (which must match the Presenter's Interactor);
 - A Presenter (which must match the View's Presenter);
 - A Router (which retains the subscription of the communication loop between components).
 */
public final class VIPERBuilder<View: VIPERView & AnyObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router>
    where
    Presenter == View.Presenter,
    Presenter.ViewModel == View.ViewModel,
    Presenter.Interactor == Interactor,
    Presenter.PresenterModel == Interactor.PresenterModel,
    Presenter.Router == Router
{

    /// For testing purposes, you can use this method to both assemble and access components.
    internal static func components<Modules>(dependencies: Interactor.Dependencies, modules: Modules) -> (view: View, interactor: Interactor, presenter: Presenter, router: Router) where Router: VIPERRouter<Modules, View> {
        let router = Router(modules: modules)
        let interactor = Interactor(dependencies: dependencies)
        let presenter = Presenter(interactor: interactor, router: router)
        let view = View(presenter: presenter, viewModel: Presenter.map(presenterModel: interactor.output.value))

        router.subscription = interactor.output.sink { [weak view] presenterModel in
            view?.update(with: Presenter.map(presenterModel: presenterModel))
        }
        router.view = view

        return (view: view, interactor: interactor, presenter: presenter, router: router)
    }
    
    public static func assemble<Modules>(dependencies: Interactor.Dependencies, modules: Modules) -> View where Router: VIPERRouter<Modules, View> {
        return components(dependencies: dependencies, modules: modules).view
    }

}
