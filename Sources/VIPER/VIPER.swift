import Foundation
import ObjectiveC

public typealias VIPERModule = Module
public typealias VIPERView = View
public typealias VIPERInteractor = Interactor
public typealias VIPERPresenter = Presenter
public typealias VIPERRouter = Router

/**
 A VIPER View represents the UI logic of your screen.
 
 Views bind to view models to update their view state information, and notify the presenter of any user
 interaction.
 
 Examples of Views include View Controllers, Windows and other UI-interface components.
 */
public protocol View: AnyObject {
    
    associatedtype ViewModel
    associatedtype UserInteraction
        
    /**
     Initialises a View with a ViewModel.
     
     Use this entrypoint to bind to the `viewModel` to be notified of view state changes.
     - Parameter viewModel: A model that conveys view state information.
     */
    init(viewModel: ViewModel)

    /**
     Used to notify the presenter that a user interaction occurred.
     
     - Parameter userInteraction: A user interaction message
     */
    func send(_ userInteraction: UserInteraction)
    
}

public extension View {
    
    func send(_ userInteraction: UserInteraction) {
        (objc_getAssociatedObject(self, &presenterKey) as? (UserInteraction) -> Void)?(userInteraction)
    }
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 Whenever user interactions take place, the Presenter can decide to send a use case request to the Interactor
 or notify a Router when it's time to navigate. Presenters take business logic processed by the Interactor and
 map it into presentation logic for the view.
 */
public protocol Presenter: AnyObject {

    associatedtype ViewModel
    associatedtype PresenterModel
    associatedtype UseCase
    associatedtype UserInteraction
    associatedtype Navigation
    
    /// A model that conveys view state information. This is consumed by the View.
    var viewModel: ViewModel { get }
    
    /**
     Initialises a Presenter with a PresenterModel.
     
     Use this entrypoint to bind to the `presenterModel` to be notified of state changes.
     
     - Parameter presenterModel: A model that conveys state information.
     */
    init(presenterModel: PresenterModel)
    
    /**
     Sends a message to perform a use case. This is relayed to the Interactor.
     
     - Parameter useCase: A message to perform a use case.
     */
    func send(_ useCase: UseCase)
    
    /**
     Sends a message to perform a navigation action. This is relayed to the Router.
     
     - Parameter navigation: A message to perform a navigation action.
     */
    func send(_ navigation: Navigation)

    /**
     Used to notify the Presenter that a user interaction took place in the View.
     
     - Parameter userInteraction: A user interaction message, emitted by the View.
     */
    func receive(userInteraction: UserInteraction)
        
}

public extension Presenter {
    
    func send(_ useCase: UseCase) {
        (objc_getAssociatedObject(self, &interactorKey) as? (UseCase) -> Void)?(useCase)
    }
    
    func send(_ navigation: Navigation) {
        (objc_getAssociatedObject(self, &routerKey) as? (Navigation) -> Void)?(navigation)
    }
    
}

public extension Presenter where UserInteraction == Void {
    
    func receive(userInteraction: UserInteraction) {}

}


/**
 A VIPER Interactor represents the business logic of your screen module.
 
 Interactors respond to use case requests and communicate with the entity layer (via services and
 repositories) to determine the state of the module, which is relayed to Presenters via the PresenterModel.
 */
public protocol Interactor: AnyObject {
    
    associatedtype Entities
    associatedtype PresenterModel
    associatedtype UseCase
    
    /// A model that conveys business logic information. This is consumed by the Presenter.
    var presenterModel: PresenterModel { get }
    
    /**
     Initialises an Interactor with entities (services and repositories).
     
     - Parameter entities: Services and repositories for the Interactor to depend on.
     */
    init(entities: Entities)
    
    /// Invoked when the interactor receives a use case request.
    /// - Parameter useCase: A use case request for the Interactor to interpret and process.
    func receive(useCase: UseCase)
    
}

public extension Interactor where UseCase == Void {
    
    func receive(useCase: UseCase) {}

}

/**
 A VIPER Router handles the navigation logic of your screen module.
 
 When a Router receives a request to navigate, it uses the View as a context to present new modules. As
 the Router lives in the same realm as the View, it is empowered to configure the view if needed. Routers
 depend on a Builder to construct dependencies (e.g., services or entire VIPER modules) on their behalf.
 */
public protocol Router: AnyObject {

    associatedtype Builder
    associatedtype Navigation
    associatedtype View
    
    /// The view associated with this Router.
    var view: View? { get }
    
    /**
     Initialises the Router with a Builder.
     
     - Parameter builder:   A Builder constructs dependencies on behalf of the Router. The Builder
                            is used by the Router to instantiate other modules. An example of a
                            Builder could be a dependency injection container.
     */
    init(builder: Builder)
    
    /**
     Invoked when the view is assembled. Override this to configure the view.
     
     - Parameter view: The view to configure.
    */
    func configure(view: View)

    /**
     Invoked when the router receives a navigation instruction.
     
     - Parameter navigation: A navigation instruction for the Router to interpret and process.
    */
    func receive(navigation: Navigation)
    
}

public extension Router {
 
    var view: View? {
        objc_getAssociatedObject(self, &viewKey) as? View
    }
    
    func configure(view: View) {}
    
}

public extension Router where Navigation == Void {
    
    func receive(navigation: Navigation) {}
    
}

/**
 A VIPER Module is responsible for the assembly logic of your screen module.

 A VIPER Module is a composable assembler that constructs VIPER components based on constraints.
 
 Particularly, it assembles the following components:
 
 - View: The user interface component. Its lifetime dictates the lifetime of the module.
 - Interactor: The business logic component. Responsible for processing use cases.
 - Presenter: The presentation logic component. Responsible for processing user interactions.
 - Router: The navigation logic component. Responsible for processing navigation instructions.
 
 The VIPER Module defines strict guidelines that VIPER configurations must adhere to. This ensures that
 communication between VIPER components is set up correctly. Any vended VIPER assembly will
 communicate in identical manner, regardless of whether the assembly is for production or testing. It is
 therefore implemented as a final class.
 */
public final class Module<View: VIPER.View, Interactor: VIPER.Interactor, Presenter: VIPER.Presenter, Router: VIPER.Router>
    where
    Interactor.PresenterModel == Presenter.PresenterModel,
    Interactor.UseCase == Presenter.UseCase,
    Presenter.Navigation == Router.Navigation,
    Presenter.UserInteraction == View.UserInteraction,
    Presenter.ViewModel == View.ViewModel,
    View == Router.View
{
    
    internal typealias Components = (view: View, interactor: Interactor, presenter: Presenter, router: Router)
    
    private init() {}
    
    /**
     Assembles a VIPER module and returns individual components for testing purposes.
               
     - Parameters:
        - entities: Any repositories or services that the Interactor should depend on, defined by the
                    Interactor. These repositories and services should be abstract.
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; it's typically a dependency injection
                    container.
     - Returns:     VIPER components configured according to the VIPER assembly criteria.
     */
    internal static func components(entities: Interactor.Entities, builder: Router.Builder) -> Components {
        let router = Router(builder: builder)
        let interactor = Interactor(entities: entities)
        let presenter = Presenter(presenterModel: interactor.presenterModel)
        let view = View(viewModel: presenter.viewModel)
        
        objc_setAssociatedObject(view, &presenterKey, { [presenter] userInteraction in
            presenter.receive(userInteraction: userInteraction)
        }, .OBJC_ASSOCIATION_RETAIN)
                
        objc_setAssociatedObject(presenter, &interactorKey, { [interactor] useCase in
            interactor.receive(useCase: useCase)
        }, .OBJC_ASSOCIATION_RETAIN)
        
        objc_setAssociatedObject(presenter, &routerKey, { [router] navigation in
            router.receive(navigation: navigation)
        }, .OBJC_ASSOCIATION_RETAIN)
                
        objc_setAssociatedObject(router, &viewKey, view, .OBJC_ASSOCIATION_ASSIGN)

        router.configure(view: view)
        
        return (view: view, interactor: interactor, presenter, router: router)
    }
    
    /**
     Assembles a VIPER module.
          
     - Parameters:
        - entities: Any repositories or services that the Interactor should depend on, defined by the
                    Interactor. These repositories and services should be abstract.
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; typically a dependency injection
                    container.
     - Returns:     A view configured according to the VIPER assembly criteria.
     */
    public static func assemble(entities: Interactor.Entities, builder: Router.Builder) -> View {
        return components(entities: entities, builder: builder).view
    }

}

//------------------------------------------------------------------------------

private var viewKey = "VIPER.View"
private var interactorKey = "VIPER.Interactor"
private var presenterKey = "VIPER.Presenter"
private var routerKey = "VIPER.Router"
