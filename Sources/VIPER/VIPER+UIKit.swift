import UIKit

public extension VIPERModule
    where
    View: VIPERView & AnyObject,
    View.Presenter: VIPERPresenter,
    View.Presenter.Interactor: VIPERInteractor,
    View.Presenter.Router: VIPERRouter<Services, View>,
    Services == View.Presenter.Interactor.Services,
    Dependencies == View.Presenter.Interactor.Dependencies,
    View.Presenter.ViewModel == View.ViewModel,
    View.Presenter.PresenterModel == View.Presenter.Interactor.PresenterModel
{

    static func assemble(services: Services, dependencies: Dependencies) -> View {
        return VIPERBuilder.assemble(services: services, dependencies: dependencies)
    }

}
