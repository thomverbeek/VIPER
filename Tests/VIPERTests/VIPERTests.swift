import XCTest

import Combine
@testable import VIPER

class VIPERTests: XCTestCase {
        
    struct Dependencies {}
    
    struct Entities {
        var values: [String] = ["one", "two", "three"]
    }
    
    struct PresenterModel {
        var count: Int
    }
    
    struct ViewModel {
        var title: String
    }
    
    class View: NSObject, VIPERView {

        let interactor: Interactor<Router>
        var viewModel: ViewModel
        
        required init(interactor: Interactor<Router>, viewModel: ViewModel) {
            self.interactor = interactor
            self.viewModel = viewModel
        }
        
        func update(with viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
    }
    
    class Presenter: VIPERPresenter {
        
        static func map(presenterModel: PresenterModel) -> ViewModel {
            return ViewModel(title: "\(presenterModel.count)")
        }
        
    }
    
    class Interactor<Router>: VIPERInteractor {
        
        private var values: [String] {
            didSet {
                output.send(Self.generatePresenterModel(values: values))
            }
        }

        let router: Router
        var output: CurrentValueSubject<PresenterModel, Never>

        required init(entities: Entities, router: Router) {
            values = entities.values
            self.router = router
            output = CurrentValueSubject(Self.generatePresenterModel(values: values))
        }

        private static func generatePresenterModel(values: [String]) -> PresenterModel {
            return PresenterModel(count: values.count)
        }

        func select(string: String) {
            values.append(string)
        }
        
    }
    
    class Router: VIPERRouter<Dependencies, View> {
        
        var expectation: XCTestExpectation?
        
        override func viewDidChange() {
            super.viewDidChange()
            
            DispatchQueue.main.async {
                self.expectation?.fulfill()
            }
        }
        
    }

}

extension VIPERTests {

    func testAssembly() {
        // arrange
        var components = Optional(VIPERModule<View, Interactor, Presenter, Router>.components(entities: .init(), dependencies: .init()))

        weak var view = components?.view
        weak var interactor = components?.interactor
        weak var router = components?.router

        XCTAssert(view === components?.router.view)
        XCTAssert(interactor === components?.view.interactor)
        XCTAssert(router === components?.interactor.router)

        XCTAssertNotNil(view)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(router)
        
        // act
        router?.expectation = expectation(description: "View changed")
        components = nil

        // assert
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNil(view)
            XCTAssertNil(interactor)
            XCTAssertNil(router)
        }
    }

    func testDataFlow() {
        // arrange
        let view = VIPERModule<View, Interactor, Presenter, Router>.assemble(entities: .init(), dependencies: .init())
        XCTAssertEqual(view.viewModel.title, "3")

        view.interactor.select(string: "four")
        XCTAssertEqual(view.viewModel.title, "4")
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
