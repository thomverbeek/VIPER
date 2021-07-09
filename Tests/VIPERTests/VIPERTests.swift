import XCTest

import Combine
@testable import VIPER

class VIPERTests: XCTestCase {
        
    struct Builder {}
    
    struct Entities {
        var increment: Int
    }
    
    class PresenterModel {
        @Published var values: [String]
        
        init(values: [String]) {
            self.values = values
        }
    }
    
    enum UserInteraction {
        case selectThis
        case selectThat
    }
    
    enum UseCase {
        case loadValues
    }
    
    enum Navigation {
        case presentSomething
    }
    
    class ViewModel {
        @Published var title: String
        @Published var rows: [String]
        
        init(title: String, rows: [String]) {
            self.title = title
            self.rows = rows
        }
    }
    
    class View: VIPERView {
        
        let presenter = PassthroughSubject<UserInteraction, Never>()
        var subscriptions = Set<AnyCancellable>()
        var viewModel: ViewModel

        required init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
                        
    }
    
    class Presenter: VIPERPresenter {
        
        let interactor = PassthroughSubject<UseCase, Never>()
        let router = PassthroughSubject<Navigation, Never>()
        var viewModel: ViewModel
        
        private var subscriptions = Set<AnyCancellable>()
        
        required init(presenterModel: PresenterModel) {
            viewModel = ViewModel(title: String(presenterModel.values.count), rows: presenterModel.values)
            
            presenterModel.$values.sink { [viewModel] values in
                viewModel.title = String(values.count)
                viewModel.rows = values
            }.store(in: &subscriptions)
        }
        
        func receive(userInteraction: UserInteraction) {
            switch userInteraction {
            case .selectThis:
                interactor.send(.loadValues)
            case .selectThat:
                router.send(.presentSomething)
            }
        }
        
    }
    
    class Interactor: VIPERInteractor {
        
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
    
    class Router: VIPERRouter {
        
        var presentedSomething = false
        
        required init(builder: Builder) {

        }
        
        func receive(navigation: Navigation, for view: View) {
            switch navigation {
            case .presentSomething:
                presentedSomething = true
            }
        }
                
    }

}

extension VIPERTests {

    func testAssembly() {
        // arrange
        var components = Optional(VIPERModule<View, Interactor, Presenter, Router>.components(entities: .init(increment: 3), builder: .init()))
        
        var view = components?.view // view keeps entire module alive
        weak var presenter = components?.presenter
        weak var interactor = components?.interactor
        weak var router = components?.router

        components = nil

        XCTAssertNotNil(view)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(router)

        // act
        view = nil

        // assert
        XCTAssertNil(view)
        XCTAssertNil(interactor)
        XCTAssertNil(presenter)
        XCTAssertNil(router)
    }

    func testDataFlow() {
        // arrange
        let components = VIPERModule<View, Interactor, Presenter, Router>.components(entities: .init(increment: 3), builder: .init())
        let view = components.view; let router = components.router
        XCTAssertEqual(view.viewModel.title, "3")
        XCTAssertEqual(view.viewModel.rows, ["0", "1", "2"])
        XCTAssertFalse(router.presentedSomething)

        // act & assert
        view.presenter.send(.selectThis)
        XCTAssertEqual(view.viewModel.title, "6")
        XCTAssertEqual(view.viewModel.rows, ["0", "1", "2", "3", "4", "5"])
        
        // act & assert
        view.presenter.send(.selectThat)
        XCTAssertTrue(router.presentedSomething)
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
