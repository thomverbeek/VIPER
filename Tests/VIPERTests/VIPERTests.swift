import XCTest

import Combine
@testable import VIPER

class VIPERTests: XCTestCase {
    
    struct Services {}
    
    struct Dependencies {
        var values: [String] = ["one", "two", "three"]
    }
    
    struct PresenterModel {
        var count: Int
    }
    
    struct ViewModel {
        var title: String
    }
    
    class View: NSObject, VIPERView {

        let presenter: Presenter<Router>
        var viewModel: ViewModel
        
        required init(presenter: Presenter<Router>, viewModel: ViewModel) {
            self.presenter = presenter
            self.viewModel = viewModel
        }
        
        func update(with viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
    }
    
    class Presenter<Router>: VIPERPresenter {
        
        let interactor: Interactor
        let router: Router
        
        required init(interactor: Interactor, router: Router) {
            self.interactor = interactor
            self.router = router
        }

        func selected(string: String) {
            interactor.add(value: string)
        }

        static func map(presenterModel: PresenterModel) -> ViewModel {
            return ViewModel(title: "\(presenterModel.count)")
        }
        
    }
    
    class Interactor: VIPERInteractor {
        
        var output: CurrentValueSubject<PresenterModel, Never>
        private var values: [String] {
            didSet {
                output.send(Self.generatePresenterModel(values: values))
            }
        }

        required init(services: Services, dependencies: Dependencies) {
            values = dependencies.values
            output = CurrentValueSubject(Self.generatePresenterModel(values: values))
        }

        private static func generatePresenterModel(values: [String]) -> PresenterModel {
            return PresenterModel(count: values.count)
        }

        func add(value: String) {
            values.append(value)
        }
        
    }
    
    class Router: VIPERRouter<Services, View> {
        
        var expectation: XCTestExpectation?
        
        override func viewDidChange() {
            super.viewDidChange()
            
            DispatchQueue.main.async {
                self.expectation?.fulfill()
            }
        }
        
    }

    class Module: VIPERModule {

        typealias Dependencies = VIPERTests.Dependencies
        typealias Services = VIPERTests.Services
        typealias View = VIPERTests.View

    }

}

extension VIPERTests {

    func testAssembly() {
        // arrange
        typealias Builder = VIPERBuilder<View, Interactor, Presenter<Router>, Router>
        var components: (view: View, presenter: Presenter, interactor: Interactor, router: Router)? = Builder.components(services: .init(), dependencies: .init())
        
        weak var view = components?.view
        weak var interactor = components?.interactor
        weak var presenter = components?.presenter
        weak var router = components?.router
        weak var subscription = router?.subscription

        XCTAssert(view === components?.router.view)
        XCTAssert(presenter === components?.view.presenter)
        XCTAssert(interactor === components?.presenter.interactor)
        XCTAssert(router === components?.presenter.router)

        XCTAssertNotNil(view)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(router)
        XCTAssertNotNil(subscription)
        
        // act
        router?.expectation = expectation(description: "View changed")
        components = nil

        // assert
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNil(view)
            XCTAssertNil(interactor)
            XCTAssertNil(presenter)
            XCTAssertNil(router)
            XCTAssertNil(subscription)
        }
    }

    func testDataFlow() {
        // arrange
        let view = Module.assemble(services: .init(), dependencies: .init())
        XCTAssertEqual(view.viewModel.title, "3")

        view.presenter.selected(string: "four")
        XCTAssertEqual(view.viewModel.title, "4")
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
