import VIPER
        
protocol Builder {
    
}

protocol PresenterModelDelegate: AnyObject {
    func valuesDidUpdate(values: [String])
}

protocol ViewModelDelegate: AnyObject {
    func titleDidUpdate(title: String)
    func rowsDidUpdate(rows: [String])
}

enum Example {
    
    struct Entities {
        
        var increment: Int

        public init(increment: Int) {
            self.increment = increment
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
        
    class PresenterModel {
        
        weak var delegate: PresenterModelDelegate?
        
        var values: [String] {
            didSet {
                delegate?.valuesDidUpdate(values: values)
            }
        }
        
        init(values: [String]) {
            self.values = values
        }
        
    }

    class ViewModel {
        
        weak var delegate: ViewModelDelegate?

        var title: String {
            didSet {
                delegate?.titleDidUpdate(title: title)
            }
        }
        var rows: [String] {
            didSet {
                delegate?.rowsDidUpdate(rows: rows)
            }
        }
        
        init(title: String, rows: [String]) {
            self.title = title
            self.rows = rows
        }
        
    }

}
