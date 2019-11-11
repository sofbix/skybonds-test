#
#  run.sh
#  Script build VAPOR projects, run, restart and has each other function
#  version 1.2
#
#  Created by Sergey Balalaev on 20.05.18.
#  Copyright (c) 2018-2019 ByteriX. All rights reserved.
#

HOST="192.168.1.8:8080"
RUN="Run serve"
PARAMS="--env production"
COMPILE="release"
#COMPILE="debug"

RESULT_DIR=".run"
TEMP_DIR=".run.tmp"
BUILD_DIR=".build"

# Functions
printInfo(){
    echo "\033[0;32m [ INFO ] $1\033[0m"
}
printError(){
    echo "\033[0;31m [ ERROR ] $1\033[0m $1"
}
checkExit(){
    if [ $? != 0 ]; then
        printError "Run failed\n"
        exit 1
    fi
}
resolve(){
    swift package resolve
    swift package generate-xcodeproj
	printInfo "package resolved & project generated"
}
update(){
    swift package update
    swift package generate-xcodeproj
	printInfo "package updated & project generated"
}
create(){
    swift package update
    mkdir -p "Sources"
    mkdir -p "Sources/App"
    mkdir -p "Sources/App/Config"
    mkdir -p "Sources/Run"
    mkdir -p "Tests"
    mkdir -p "Tests/AppTests"

    echo "import Vapor\n\n/// Creates an instance of Application. This is called from main.swift in the run target.\npublic func app(_ env: Environment) throws -> Application {\n    var config = Config.default()\n    var env = env\n    var services = Services.default()\n    try configure(&config, &env, &services)\n    let app = try Application(config: config, environment: env, services: services)\n    try boot(app)\n    return app\n}" > "Sources/App/Config/app.swift"

	echo "import Vapor\n\n/// Called after your application has initialized.\npublic func boot(_ app: Application) throws {\n    // your code here\n}" > "Sources/App/Config/boot.swift"

	echo "import Vapor\n\n/// Called before your application initializes.\npublic func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {\n    /// Register routes to the router\n    let router = EngineRouter.default()\n    try routes(router)\n    services.register(router, as: Router.self)\n\n}" > "Sources/App/Config/configure.swift"

	echo "import Vapor\n\n/// Register your application's routes here.\npublic func routes(_ router: Router) throws {\n    // Basic \"Hello, world!\" example\n    router.get(\"hello\") { req in\n        return \"Hello, world!\"\n    }\n\n}" > "Sources/App/Config/routes.swift"

    echo "import App\n\ntry app(.detect()).run()\n" > "Sources/Run/main.swift"

    mkdir -p "Resources"
    mkdir -p "Resources/Views"

    mkdir -p "Public"

    swift package generate-xcodeproj
	printInfo "package created & project generated"
}
cleanBuild(){
    #vapor clean - I remove all old build fieles from myself, because it requere dialog user
	printInfo "clean build dir"
	rm -f -d -r "${BUILD_DIR}"
	#printInfo "start building ${COMPILE}"
	#vapor build "--${COMPILE}"
	printInfo "start resolving"
	resolve
	printInfo "start building ${COMPILE}"
	swift build -c ${COMPILE}
	checkExit
	printInfo "server builded"

	printInfo "start deploying"
	rm -f -d -r "${TEMP_DIR}"
	mkdir -p "${TEMP_DIR}"
	cp -rf "${BUILD_DIR}/${COMPILE}/." "${TEMP_DIR}"
	checkExit
	printInfo "server deployed"
}
stopServer(){
	local KILL_PARAM=$1
    local RUN_NAME="[${RESULT_DIR}/${RUN}] -b ${HOST}"
	printInfo "searching server ${RUN_NAME}"
	local PID=$(ps aux | grep "${RUN_NAME}" | awk '{print $2}')
	if ! [ "${PID}" = "" ]
	then
		kill ${KILL_PARAM} ${PID}
		printInfo "server stoped"
	fi
	checkExit
}
updateServer(){
	rm -f -d -r "${RESULT_DIR}"
	mv "${TEMP_DIR}" "${RESULT_DIR}"
	checkExit
	printInfo "server updated"
}
runServer(){
    ${RESULT_DIR}/${RUN} -b ${HOST} ${PARAMS}
	printInfo "server finished"
}

if [ "$1" = "resolve" ]
then
	resolve
else
if [ "$1" = "update" ]
then
	update
else
if [ "$1" = "create" ]
then
	create
else
if [ "$1" = "stop" ]
then
	stopServer "-9"
	wait
else
if [ "$1" = "start" ]
then
	runServer
else
if [ "$1" = "restart" ]
then
	#stopServer "-9"
	stopServer "-TERM"
	wait
	runServer
else
	cleanBuild
	stopServer
	updateServer
	runServer
fi
fi
fi
fi
fi
fi


