import VIPER

extension Example {

    class Presenter: VIPER.Presenter, PresenterModelDelegate {
        
        typealias UseCase = Example.UseCase
        typealias Navigation = Example.Navigation
        
        let viewModel: ViewModel
                
        required init(presenterModel: PresenterModel) {
            viewModel = ViewModel(title: String(presenterModel.values.count), rows: presenterModel.values)
            
            presenterModel.delegate = self
        }
        
        func receive(userInteraction: UserInteraction) {
            switch userInteraction {
            case .selectThis:
                send(.loadValues)
            case .selectThat:
                send(.presentSomething)
            }
        }
        
        func valuesDidUpdate(values: [String]) {
            viewModel.title = String(values.count)
            viewModel.rows = values
        }
        
    }

}
