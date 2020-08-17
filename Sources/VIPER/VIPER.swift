import Combine
import Foundation
import ObjectiveC

private struct Key {
    static var interaction = "VIPER.interaction"
    static var presentation = "VIPER.presentation"
    static var navigation = "VIPER.navigation"
    static var view = "VIPER.view"
}

/**
 A VIPER View represents the UI logic of your screen.

 Views receive view models to update their view state information, and notify the interactor of any user
 interaction.
 
 Examples of Views include View Controllers, Windows and other UI-interface components.
 */
public protocol VIPERView {
    
    associatedtype Input
    associatedtype UserInteraction
    
    var interactor: PassthroughSubject<UserInteraction, Never> { get }
    
    /**
     Initialise a view with a view model.
     
     - Parameters:
        - viewModel: An object that conveys view state information.
     */
    init(input: Input)
    
    /**
     Updates the view with a view model.
     
     - Parameters:
        - viewModel:An object that conveys view state information.
     */
    func receive(input: Input)

}

/**
 A VIPER Interactor represents the business logic of your screen module.
 
 Interactors respond to user interaction events and communicate with entities to determine the state of the
 module. They broadcast state information to Presenters to consume, and notify routers when it's time to
 navigate.
 */
public protocol VIPERInteractor {
    
    associatedtype Entities
    associatedtype Navigation
    associatedtype Presentation
    associatedtype UserInteraction
    
    /// Used to broadcast presentation information for Presenters to consume.
    var presenter: CurrentValueSubject<Presentation, Never> { get }
    /// Used to broadcast navigation information for Routers to consume.
    var router: PassthroughSubject<Navigation, Never> { get }
    
    /**
     - Parameters:
        - Entities: Services and repositories for the Interactor to depend on.
     */
    init(entities: Entities)
    
    func receive(userInteraction: UserInteraction)
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 Presenters take business logic processed by the Interactor and map it into presentation logic for the view.
 */
public protocol VIPERPresenter {

    associatedtype Input
    associatedtype Output
    
    /**
     Maps presentation logic from the Interactor into display logic for the View to consume.
     
     - Parameters:
        - presentation: an object that conveys presentation logic information.
     - Returns: An object that conveys display logic information.
     */
    static func map(input: Input) -> Output
    
}

/**
 A VIPER Router handles the navigation logic of your screen module.

 As the Router lives in the same realm as the View, it is empowered to configure the view if needed. It also
 uses the view as a context to present new modules.
 */
public protocol VIPERRouter {

    /**
     An object that can construct dependencies on behalf of the Router. The builder is
     used by the router to instantiate other modules; typically a dependency injection
     container.
     */
    associatedtype Builder
    associatedtype Navigation
    associatedtype View

    var builder: Builder { get }
    
    /**
     Initialises the Router with a Builder.
     
     - Parameters:
        - builder:  An object that can construct dependencies on behalf of the Router. The builder is
                    used by the router to instantiate other modules; typically a dependency injection
                    container.
     */
    init(builder: Builder)
    
    /**
     Invoked when the view is assembled. Override this to configure the view.
    */
    func viewDidLoad(view: View)

    /**
     Invoked when the router receives a navigation instruction.
    */
    func receive(navigation: Navigation, for view: View)
}

public extension VIPERRouter {
    
    func viewDidLoad(view: View) {}
    
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
public final class VIPERModule<View: VIPERView & NSObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router: VIPERRouter>
    where
    Interactor.Presentation == Presenter.Input,
    Interactor.Navigation == Router.Navigation,
    Interactor.UserInteraction == View.UserInteraction,
    Presenter.Output == View.Input,
    View == Router.View
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
    internal static func components(entities: Interactor.Entities, builder: Router.Builder) -> (view: View, interactor: Interactor, router: Router) {
        let router = Router(builder: builder)
        let interactor = Interactor(entities: entities)
        let view = View(input: Presenter.map(input: interactor.presenter.value))

        view.interactionSubscription = view.interactor.sink { [interactor] userInteraction in
            interactor.receive(userInteraction: userInteraction)
        }
        
        view.presentationSubscription = interactor.presenter.sink { [weak view] presentation in
            view?.receive(input: Presenter.map(input: presentation))
        }
        
        view.navigationSubscription = interactor.router.sink { [router, weak view] navigation in
            guard let view = view else { return }
            router.receive(navigation: navigation, for: view)
        }

        router.viewDidLoad(view: view)
        
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
    public static func assemble(entities: Interactor.Entities, builder: Router.Builder) -> View {
        return components(entities: entities, builder: builder).view
    }

}

internal extension NSObject {

    var interactionSubscription: AnyCancellable? {
        get {
            objc_getAssociatedObject(self, &Key.interaction) as? AnyCancellable
        }
        set {
            objc_setAssociatedObject(self, &Key.interaction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var presentationSubscription: AnyCancellable? {
        get {
            objc_getAssociatedObject(self, &Key.presentation) as? AnyCancellable
        }
        set {
            objc_setAssociatedObject(self, &Key.presentation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var navigationSubscription: AnyCancellable? {
        get {
            objc_getAssociatedObject(self, &Key.navigation) as? AnyCancellable
        }
        set {
            objc_setAssociatedObject(self, &Key.navigation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
