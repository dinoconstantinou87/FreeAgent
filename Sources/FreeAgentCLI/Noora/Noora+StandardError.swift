import Noora

extension Noora {
    static func standardError() -> Noora {
        Noora(standardPipelines: StandardPipelines(output: StandardErrorPipeline()))
    }
}
