import Combine
import Foundation

/**
 A VIPER View represents the UI logic of your screen.

 Views receive view models to update their view state information, and notify the interactor of any user
 interaction.
 
 Examples of Views include View Controllers, Windows and other UI-interface components.
 */
public protocol VIPERView {
    
    associatedtype ViewModel
    associatedtype UserInteraction
    
    var presenter: PassthroughSubject<UserInteraction, Never> { get }
    var subscriptions: Set<AnyCancellable> { get set }
    
    /**
     Initialise a view with a view model.
     
     - Parameters:
        - viewModel: An object that conveys view state information.
     */
    init(viewModel: ViewModel)
    
}

/**
 A VIPER Presenter represents the presentation logic of your screen module.

 Presenters take business logic processed by the Interactor and map it into presentation logic for the view.
 */
public protocol VIPERPresenter {

    associatedtype ViewModel
    associatedtype PresenterModel
    associatedtype UseCase
    associatedtype UserInteraction
    associatedtype Navigation

    var viewModel: ViewModel { get }
    var interactor: PassthroughSubject<UseCase, Never> { get }
    var router: PassthroughSubject<Navigation, Never> { get }

    init(presenterModel: PresenterModel)
    
    func receive(userInteraction: UserInteraction)
        
}

/**
 A VIPER Interactor represents the business logic of your screen module.
 
 Interactors respond to user interaction events and communicate with entities to determine the state of the
 module. They broadcast state information to Presenters to consume, and notify routers when it's time to
 navigate.
 */
public protocol VIPERInteractor {
    
    associatedtype Entities
    associatedtype PresenterModel
    associatedtype UseCase
    
    var presenterModel: PresenterModel { get }
        
    /**
     - Parameters:
        - Entities: Services and repositories for the Interactor to depend on.
     */
    init(entities: Entities)
    
    func receive(useCase: UseCase)
    
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
    
    /**
     A navigation message that the router receives when instructed to navigate.
     */
    associatedtype Navigation
    
    /**
     The view associated with this Router.
     */
    associatedtype View
    
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
     - Parameters:
        - view:     The view to configure.
    */
    func configure(view: View)

    /**
     Invoked when the router receives a navigation instruction.
     - Parameters:
        - navigation: A navigation instruction for the Router to interpret and process.
        - view: The view provided as a presentation context.
    */
    func receive(navigation: Navigation, for view: View)
}

public extension VIPERRouter {
    
    func configure(view: View) {}
    
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
public final class VIPERModule<View: VIPERView & AnyObject, Interactor: VIPERInteractor, Presenter: VIPERPresenter, Router: VIPERRouter>
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
        var view = View(viewModel: presenter.viewModel)
        
        view.presenter.sink { [presenter] userInteraction in
            presenter.receive(userInteraction: userInteraction)
        }.store(in: &view.subscriptions)
        
        presenter.interactor.sink { [interactor] useCase in
            interactor.receive(useCase: useCase)
        }.store(in: &view.subscriptions)
        
        presenter.router.sink { [router, weak view] navigation in
            guard let view = view else { return }
            router.receive(navigation: navigation, for: view)
        }.store(in: &view.subscriptions)
        
        router.configure(view: view)
        
        return (view: view, interactor: interactor, presenter, router: router)
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
