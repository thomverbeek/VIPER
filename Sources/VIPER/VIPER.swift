import Combine
import Foundation

/**
 A VIPER View represents the UI logic of your screen module.

 It must define:

 - an Interactor (which handles all user interaction logic on its behalf);
 - a View Model (which contains its view state information).

 Messages are passed between VIPER components via entities. Views receive View Models to update their
 view state information.
 */
public protocol VIPERView {
    
    associatedtype Interactor
    associatedtype ViewModel
    
    init(interactor: Interactor, viewModel: ViewModel)
    func update(with viewModel: ViewModel)

}

/**
 A VIPER Interactor represents the business logic of your screen module.

 It must define:

 - Dependencies it relies on (micro-services and other information used to configure the screen);
 - a Router (which handles navigation logic on its behalf);
 - a Presenter Model (which contains presentation state information).
 */
public protocol VIPERInteractor {
    
    associatedtype Dependencies
    associatedtype Router
    associatedtype PresenterModel
    
    var output: CurrentValueSubject<PresenterModel, Never> { get }
    
    init(dependencies: Dependencies, router: Router)
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 It must define:

 - A PresenterModel (which contains state information received from the Interactor);
 - A ViewModel (which is a mapping of state information suitable to be displayed in the view).
 */
public protocol VIPERPresenter {

    associatedtype PresenterModel
    associatedtype ViewModel
    
    static func map(presenterModel: PresenterModel) -> ViewModel
    
}

/**
 A VIPER Router handles the navigation logic of your screen module.

 The Router defines:

 - Modules (which is used to instantiate other modules);
 - A View (that is weakly held by the router, a context for configuration and navigation).

 As Routers hold a weak reference to the view, they're also designated to hold the reference to the cancellable
 subscription.
 */
open class VIPERRouter<Components, View: AnyObject>: NSObject {
    
    public weak var view: View? {
        didSet {
            viewDidChange()
        }
    }
    
    fileprivate var subscription: AnyCancellable?
    public let components: Components

    required public init(components: Components) {
        self.components = components
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
 - An Interactor (which communicates with the specified Router);
 - A Presenter (which maps the Interactor's PresenterModel into the View's ViewModel);
 - A Router (which retains the subscription of the communication loop between components).
 */
public final class VIPERBuilder<View: VIPERView & AnyObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router>
    where
    Interactor == View.Interactor,
    Interactor.Router == Router,
    Presenter.ViewModel == View.ViewModel,
    Presenter.PresenterModel == Interactor.PresenterModel
{

    /// For testing purposes, you can use this method to both assemble and access components.
    internal static func components<Components>(dependencies: Interactor.Dependencies, components: Components) -> (view: View, interactor: Interactor, router: Router) where Router: VIPERRouter<Components, View> {
        let router = Router(components: components)
        let interactor = Interactor(dependencies: dependencies, router: router)
        let view = View(interactor: interactor, viewModel: Presenter.map(presenterModel: interactor.output.value))

        router.subscription = interactor.output.sink { [weak view] presenterModel in
            view?.update(with: Presenter.map(presenterModel: presenterModel))
        }
        router.view = view

        return (view: view, interactor: interactor, router: router)
    }
    
    public static func assemble<Components>(dependencies: Interactor.Dependencies, components: Components) -> View where Router: VIPERRouter<Components, View> {
        return self.components(dependencies: dependencies, components: components).view
    }

}
