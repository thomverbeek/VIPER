import XCTest

import Combine
@testable import VIPER

class VIPERTests: XCTestCase {
        
    struct Modules {}
    
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

        required init(dependencies: Dependencies) {
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
    
    class Router: VIPERRouter<Modules, View> {
        
        var expectation: XCTestExpectation?
        
        override func viewDidChange() {
            super.viewDidChange()
            
            DispatchQueue.main.async {
                self.expectation?.fulfill()
            }
        }
        
    }

    class Module: VIPERModule {

        static func assemble(dependencies: Dependencies, modules: Modules) -> View {
            return VIPERBuilder<View, Interactor, Presenter, Router>.assemble(dependencies: dependencies, modules: modules)
        }

    }

}

extension VIPERTests {

    func testAssembly() {
        // arrange
        var components = Optional(VIPERBuilder<View, Interactor, Presenter, Router>.components(dependencies: .init(), modules: .init()))

        weak var view = components?.view
        weak var interactor = components?.interactor
        weak var presenter = components?.presenter
        weak var router = components?.router

        XCTAssert(view === components?.router.view)
        XCTAssert(presenter === components?.view.presenter)
        XCTAssert(interactor === components?.presenter.interactor)
        XCTAssert(router === components?.presenter.router)

        XCTAssertNotNil(view)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(router)
        
        // act
        router?.expectation = expectation(description: "View changed")
        components = nil

        // assert
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNil(view)
            XCTAssertNil(interactor)
            XCTAssertNil(presenter)
            XCTAssertNil(router)
        }
    }

    func testDataFlow() {
        // arrange
        let view = Module.assemble(dependencies: .init(), modules: .init())
        XCTAssertEqual(view.viewModel.title, "3")

        view.presenter.selected(string: "four")
        XCTAssertEqual(view.viewModel.title, "4")
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
