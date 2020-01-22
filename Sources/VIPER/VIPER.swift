import Combine
import Foundation

public protocol VIPERView {
    
    associatedtype Presenter
    associatedtype ViewModel
    
    init(presenter: Presenter, viewModel: ViewModel)
    func update(with viewModel: ViewModel)

}

public protocol VIPERInteractor {
    
    associatedtype Services
    associatedtype Dependencies
    associatedtype PresenterModel
    
    var output: CurrentValueSubject<PresenterModel, Never> { get }
    
    init(services: Services, dependencies: Dependencies)
    
}

public protocol VIPERPresenter {
        
    associatedtype Interactor
    associatedtype Router
    associatedtype PresenterModel
    associatedtype ViewModel
    
    init(interactor: Interactor, router: Router)
    
    static func map(presenterModel: PresenterModel) -> ViewModel
    
}
    
open class VIPERRouter<Services, View: AnyObject> {
    
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
