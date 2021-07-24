import XCTest

@testable import VIPER

private extension Example {
    
    typealias Components = (view: View, interactor: Interactor, presenter: Presenter, router: Router)
    
    static func components(entities: Entities, builder: Builder) -> Components {
        return Module<View, Interactor, Presenter, Router>.components(entities: entities, builder: builder)
    }

}

class VIPERTests: XCTestCase, Builder {
        
    func testAssembly() {
        // arrange
        var components = Optional(Example.components(entities: .init(increment: 3), builder: self))
        
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
        let components = Example.components(entities: .init(increment: 3), builder: self)
        let view = components.view; let router = components.router
        XCTAssertEqual(view.title, "3")
        XCTAssertEqual(view.rows, ["0", "1", "2"])
        XCTAssertFalse(router.presentedSomething)

        // act & assert
        view.send(.selectThis)
        XCTAssertEqual(view.viewModel.title, "6")
        XCTAssertEqual(view.viewModel.rows, ["0", "1", "2", "3", "4", "5"])
        
        // act & assert
        view.send(.selectThat)
        XCTAssertTrue(router.presentedSomething)
    }

    static var allTests = [
        ("testAssembly", testAssembly),
        ("testDataFlow", testDataFlow)
    ]
    
}
