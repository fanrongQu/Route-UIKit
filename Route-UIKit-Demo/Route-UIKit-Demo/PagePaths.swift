//
//  PagePaths.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import Foundation
import Route_UIKit

enum PagePaths {
    case none
    case first
    case second
    case push
    case present
    case login
    case order
    case http(String)
}
// 路由协议
extension PagePaths: RoutePathable {
    
    var baseURL: String {
        switch self {
        case .http(_):
            return ""
        default:
            return "routeUIKitDemo://"
        }
    }
    
    var path: (String, Bool) {
        switch self {
        case .first:
            return ("Root/FirstViewController", false)
        case .second:
            return ("SecondViewController", false)
        case .push:
            return ("Push", false)
        case .present:
            return ("PresentViewController", false)
        case .login:
            return ("LoginViewController", false)
        case .order:
            return ("OrderViewController", true)
        case .http(let url):
            return (url, false)
        default:
            return ("AKGo404Scene", false)
        }
    }
    
    var authState: Bool {
        return AuthState.shared.didAuthed
    }
    
    func enterOAuth() -> RouteResponse? {
        return PagePaths.login.response()
    }
}

