import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

//    app.get(".well-known", "apple-app-site-association") { req -> Response in
//            let appIdentifier = "<YOUR_APP_IDENTIFIER>" // e.g. "ABCDE12345.com.example.app"
//            let responseString =
//                """
//                {
//                    "applinks": {
//                        "details": [
//                            {
//                                "appIDs": [
//                                    "\(appIdentifier)"
//                                ],
//                                "components": [
//                                ]
//                            }
//                        ]
//                    },
//                    "webcredentials": {
//                        "apps": [
//                            "\(appIdentifier)"
//                        ]
//                    }
//                }
//                """
//            let response = try await responseString.encodeResponse(for: req)
//            response.headers.contentType = HTTPMediaType(type: "application", subType: "json")
//            return response
//        }

    try app.register(collection: UserController())
    try app.register(collection: TodoController())
    try app.register(collection: AuthController())
}
