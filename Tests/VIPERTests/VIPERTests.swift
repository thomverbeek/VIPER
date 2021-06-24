import XCTest

import Combine
@testable import VIPER

class VIPERTests: XCTestCase {
        
    struct Builder {}
    
    struct Entities {
        var values: [String] = ["one", "two", "three"]
    }
    
    struct PresenterModel {
        var count: Int
    }
    
    enum UserInteraction {
        case select(String)
    }
    
    enum Navigation {
        case presentSomething
    }
    
    struct ViewModel {
        var title: String
    }
    
    class View: NSObject, VIPERView {
        
        let interactor = PassthroughSubject<UserInteraction, Never>()
        var viewModel: ViewModel

        required init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        func receive(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
                
    }
    
    class Presenter: VIPERPresenter {
        
        static func map(presenterModel: PresenterModel) -> ViewModel {
            return ViewModel(title: "\(presenterModel.count)")
        }
        
    }
    
    class Interactor: VIPERInteractor {
        
        private var values: [String] {
            didSet {
                presenter.send(Self.generatePresenterModel(values: values))
            }
        }

        let presenter: CurrentValueSubject<PresenterModel, Never>
        let router = PassthroughSubject<Navigation, Never>()
        
        required init(entities: Entities) {
            values = entities.values
            presenter = .init(Self.generatePresenterModel(values: values))
        }
        
        private static func generatePresenterModel(values: [String]) -> PresenterModel {
            return PresenterModel(count: values.count)
        }

        func receive(userInteraction: UserInteraction) {
            switch userInteraction {
            case let .select(string):
                values.append(string)
            }
        }
                
    }
    
    class Router: VIPERRouter {
        
        let builder: Builder
        
        required init(builder: Builder) {
            self.builder = builder
        }
        
        func receive(navigation: Navigation, for view: View) {
            
        }
                
    }

}

extension VIPERTests {

    func testAssembly() {
        // arrange
        var components = Optional(VIPERModule<View, Interactor, Presenter, Router>.components(entities: .init(), builder: .init()))

        var view = components?.view // view keeps entire module alive
        weak var interactor = components?.interactor
        weak var router = components?.router

        components = nil

        XCTAssertNotNil(view)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(router)

        // act
        view = nil

        // assert
        XCTAssertNil(view)
        XCTAssertNil(interactor)
        XCTAssertNil(router)
    }

    func testDataFlow() {
        // arrange
        let view = VIPERModule<View, Interactor, Presenter, Router>.assemble(entities: .init(), builder: .init())
        XCTAssertEqual(view.viewModel.title, "3")

        view.interactor.send(.select("four"))
        XCTAssertEqual(view.viewModel.title, "4")
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
