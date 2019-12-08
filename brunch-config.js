exports.config = {
    files: {
        javascripts: {
            joinTo: {
                "dummy": "dummy"
            }
        }
    },
    paths: {
        watched: [
            "src"
        ],
        public: "static"
    },
    plugins: {
        elmBrunch: {
            mainModules: [
                "src/FlowTime.elm"
            ],
            independentModules: true,
            executablePath: "../node_modules/elm/bin"
        }
    }
}
