import Combine
import Foundation

/**
 A VIPER View represents the UI logic of your screen.

 Views receive view models to update their view state information, and notify the interactor of any user
 interaction.
 
 Examples of Views include View Controllers, Windows and other UI-interface components.
 */
public protocol VIPERView {
    
    associatedtype Interactor
    associatedtype ViewModel
    
    /**
     Initialise a view with an interactor and view model.
     
     - Parameters:
        - interactor: An object to notify regarding any user interaction.
        - viewModel: An object that conveys view state information.
     */
    init(interactor: Interactor, viewModel: ViewModel)
    
    /**
     Updates the view with a view model.
     
     - Parameters:
        - viewModel:An object that conveys view state information.
     */
    func update(with viewModel: ViewModel)

}

/**
 A VIPER Interactor represents the business logic of your screen module.
 
 Interactors respond to user interaction events and communicate with entities to determine the state of the
 module. They broadcast state information to Presenters to consume, and notify routers when it's time to
 navigate.
 */
public protocol VIPERInteractor {
    
    associatedtype Entities
    associatedtype Router
    associatedtype PresenterModel
    
    /// Used to broadcast state information for Presenters to consume.
    var output: CurrentValueSubject<PresenterModel, Never> { get }
    
    /**
     - Parameters:
        - Entities: Services and repositories for the Interactor to depend on.
        - Router: An object to handle navigation logic.
        - PresenterModel: An object that conveys state information.
     */
    init(entities: Entities, router: Router)
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 Presenters take business logic processed by the Interactor and map it into presentation logic for the view.
 */
public protocol VIPERPresenter {

    associatedtype PresenterModel
    associatedtype ViewModel
    
    /**
     Maps business logic from the Interactor into presentation logic for the View to consume.
     
     - Parameters:
        - presenterModel: an object that conveys state information.
     - Returns: A view model that conveys view state information.
     */
    static func map(presenterModel: PresenterModel) -> ViewModel
    
}

/**
 A VIPER Router handles the navigation logic of your screen module.

 As the Router lives in the same realm as the View, it is empowered to configure the view if needed. It also
 uses the view as a context to present new modules.
 
 Routers need to hold a weak reference to the view. They are therefore a class as opposed to a protocol.
 Consequentially, they're also designated to hold the reference to the module's data flow subscription.
 */
open class VIPERRouter<Builder, View: AnyObject>: NSObject {
    
    /// A weak reference to the view of the module. The View provides a UI context for the Router to
    /// configure and navigate from.
    public weak var view: View? {
        didSet {
            viewDidChange()
        }
    }
    
    fileprivate var subscription: AnyCancellable?
    
    /**
     An object that can construct dependencies on behalf of the Router. The builder is
     used by the router to instantiate other modules; typically a dependency injection
     container.
     */
    public let builder: Builder

    /**
     Initialises the Router with a Builder.
     
     - Parameters:
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; typically a dependency injection
                    container.
     */
    required public init(builder: Builder) {
        self.builder = builder
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
 A VIPER Module handles the assembly logic of your screen module.

 `VIPERModule` is a composable assembler that constructs VIPER components based on constraints.
 
 Particularly, it assembles the following components:
 
 - View: Strongly retains the VIPER components.
 - Interactor: Communicates with the specified Router.
 - Presenter: Maps the Interactor's PresenterModel into the View's ViewModel.
 - Router: Retains the subscription of the communication loop between components.
 
 It defines strict guidelines that VIPER configurations must adhere to and ensures that
 communication between components is set up. This guarantees that any vended VIPER assembly will
 communicate in identical manner, regardless of whether the assembly is for production or testing. It is
 therefore a final class.
 */
public final class VIPERModule<View: VIPERView & AnyObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router>
    where
    Interactor == View.Interactor,
    Interactor.Router == Router,
    Presenter.ViewModel == View.ViewModel,
    Presenter.PresenterModel == Interactor.PresenterModel
{

    /**
     Assembles a VIPER module and returns individual components for testing purposes.
          
     A VIPER module can assemble when the Router is a `VIPERRouter` that defines a particular type of
     Builder.
     
     - Parameters:
        - entities: Any repositories or services that the Interactor should depend on, defined by the
                    Interactor. These repositories and services should be abstract.
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; it's typically a dependency injection
                    container.
     - Returns:     VIPER components configured according to the VIPER assembly criteria.
     */
    internal static func components<Builder>(entities: Interactor.Entities, builder: Builder) -> (view: View, interactor: Interactor, router: Router) where Router: VIPERRouter<Builder, View> {
        let router = Router(builder: builder)
        let interactor = Interactor(entities: entities, router: router)
        let view = View(interactor: interactor, viewModel: Presenter.map(presenterModel: interactor.output.value))

        router.view = view
        router.subscription = interactor.output.sink { [weak view] presenterModel in
            view?.update(with: Presenter.map(presenterModel: presenterModel))
        }

        return (view: view, interactor: interactor, router: router)
    }
    
    /**
     Assembles a VIPER module.
     
     A VIPER module can assemble when the Router is a `VIPERRouter` that defines a particular type of
     Builder.
     
     - Parameters:
        - entities: Any repositories or services that the Interactor should depend on, defined by the
                    Interactor. These repositories and services should be abstract.
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; typically a dependency injection
                    container.
     - Returns:     A view configured according to the VIPER assembly criteria.
     */
    public static func assemble<Builder>(entities: Interactor.Entities, builder: Builder) -> View where Router: VIPERRouter<Builder, View> {
        return components(entities: entities, builder: builder).view
    }

}
