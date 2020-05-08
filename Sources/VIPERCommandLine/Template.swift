import Foundation

protocol Template {
    
    static var filename: String { get }
    
    static func contents(moduleName: String, operatingSystem: OperatingSystem) -> String
    
}

extension Template {
    
    static var filename: String {
        return String(describing: self)
    }
    
}
