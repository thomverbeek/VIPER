import VIPER

extension Example {

    class Interactor: VIPER.Interactor {
        
        var presenterModel: PresenterModel
        
        private let increment: Int
        
        required init(entities: Entities) {
            increment = entities.increment
            let values = (0..<increment).map{ String($0) }
            presenterModel = .init(values: values)
        }
        
        func receive(useCase: UseCase) {
            switch useCase {
            case .loadValues:
                let values = (presenterModel.values.count..<presenterModel.values.count + increment).map{ String($0) }
                presenterModel.values = presenterModel.values + values
            }
        }
                
    }

}
