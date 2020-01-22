import XCTest

import Combine
@testable import VIPER

final class VIPERTests: XCTestCase {
    
    struct Services {}
    
    struct Dependencies {}
    
    struct PresenterModel {}
    
    struct ViewModel {}
    
    class View: VIPERView {

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
        
        static func map(presenterModel: PresenterModel) -> ViewModel {
            return ViewModel()
        }
        
    }
    
    class Interactor: VIPERInteractor {
        
        var output: CurrentValueSubject<PresenterModel, Never>
        
        required init(services: Services, dependencies: Dependencies) {
            output = CurrentValueSubject(PresenterModel())
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
    
    func testAssembly() {
        // arrange
        typealias Builder = VIPERBuilder<View, Interactor, Presenter<Router>, Router>
        
        // act
        let components = Builder.components(services: .init(), dependencies: .init())
        
        // assert
        XCTAssert(components.view === components.router.view)
        XCTAssert(components.presenter === components.view.presenter)
        XCTAssert(components.interactor === components.presenter.interactor)
        XCTAssert(components.router === components.presenter.router)
    }
        
    func testDisassembly() {
        // arrange
        typealias Builder = VIPERBuilder<View, Interactor, Presenter<Router>, Router>
        var components: (view: View, presenter: Presenter, interactor: Interactor, router: Router)? = Builder.components(services: .init(), dependencies: .init())
        
        weak var view = components?.view
        weak var interactor = components?.interactor
        weak var presenter = components?.presenter
        weak var router = components?.router
        router?.expectation = expectation(description: "View deallocated, VIPER stack disassembled")
        XCTAssertNotNil(router?.subscription)
        
        // act
        components = nil

        // assert
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNil(view)
            XCTAssertNil(interactor)
            XCTAssertNil(presenter)
            XCTAssertNil(router)
        }
    }

    static var allTests = [
        ("testAssembly", testAssembly),
    ]
    
}
