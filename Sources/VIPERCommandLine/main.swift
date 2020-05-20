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
    
    private var destination: URL {
        var url = URL(fileURLWithPath: output)
        if !excludeDirectory {
            url.appendPathComponent(moduleName)
        }
        return url
    }
    
    private var moduleName: String {
        return name.prefix(1).capitalized + name.dropFirst()
    }
    
    @Argument(help: "The name of the module to generate.")
    private var name: String

    @Argument(help: "The output path of the module.")
    private var output: String
    
    @Option(default: .iOS, help: "The OS for the generated module. [iOS,macOS,tvOS]")
    private var os: OperatingSystem

    @Flag(help: "Don't create a new directory for generated files.")
    private var excludeDirectory: Bool

    @Flag(name: .shortAndLong, help: "Show extra logging for debugging purposes.")
    private var verbose: Bool

    func run() throws {
        guard !moduleName.isEmpty else { throw Error.invalidModuleName }
        
        if verbose {
            print("Generating module \"\(moduleName)\"…")
        }
        
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        
        if verbose {
            print("Generated directory at \(destination.path)")
        }
        
        try generateFile(from: Module.self)
        try generateFile(from: View.self)
        try generateFile(from: Interactor.self)
        try generateFile(from: Presenter.self)
        try generateFile(from: Router.self)

        print("Finished generating module \"\(moduleName)\" at \"\(destination.path)\".")
    }
    
    private func generateFile<T: Template>(from template: T.Type) throws {
        let url = destination.appendingPathComponent(T.filename).appendingPathExtension("swift")
        let contents = T.contents(moduleName: moduleName, operatingSystem: os)

        if verbose {
            print("Generating \(url.path)…")
        }
        
        if !fileManager.createFile(atPath: url.path, contents: contents.data(using: .utf8), attributes: nil) {
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
