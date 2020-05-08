import Foundation

import ArgumentParser

struct VIPER: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool for VIPER. Use this tool by running `swift run viper-tools` from this package's directory.",
        subcommands: [Generate.self])

    init() { }
    
}

struct Generate: ParsableCommand {
    
    public static let configuration = CommandConfiguration(abstract: "Generate a module of VIPER components at a given file location.")

    private var fileManager: FileManager {
        return .default
    }
    
    private var directory: URL {
        return URL(fileURLWithPath: output).appendingPathComponent(moduleName)
    }
    
    private var moduleName: String {
        return name.prefix(1).capitalized + name.dropFirst()
    }
    
    @Argument(help: "The name of the module to generate.")
    private var name: String

    @Argument(help: "The output path of the module.")
    private var output: String
    
    @Option(default: .iOS, help: "The OS for the generated module. [iOS,macOS,tvOS]")
    private var operatingSystem: OperatingSystem

    @Flag(name: .shortAndLong, help: "Show extra logging for debugging purposes.")
    private var verbose: Bool

    func run() throws {
        guard !moduleName.isEmpty else { throw Error.invalidModuleName }
        
        if verbose {
            print("Generating module \"\(moduleName)\"…")
        }
        
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
        if verbose {
            print("Generated directory at \(directory.path)")
        }
        
        try generateFile(from: Module.self)
        try generateFile(from: View.self)
        try generateFile(from: Interactor.self)
        try generateFile(from: Presenter.self)
        try generateFile(from: Router.self)

        if verbose {
            print("Finished generating module \"\(moduleName)\" at \"\(directory.path)\".")
        }
    }
    
    private func generateFile<T: Template>(from template: T.Type) throws {
        let url = directory.appendingPathComponent(T.filename).appendingPathExtension("swift")
        let contents = T.contents(moduleName: moduleName, operatingSystem: operatingSystem)

        if verbose {
            print("Generating \(url.path)…")
        }
        
        let success = fileManager.createFile(atPath: url.path, contents: contents.data(using: .utf8), attributes: nil)
        if !success {
            throw Error.unableToCreateFile
        }
    }
        
}

extension Generate {
    
    enum Error: Swift.Error {
        case invalidModuleName
        case unableToCreateFile
    }
    
}

VIPER.main()
