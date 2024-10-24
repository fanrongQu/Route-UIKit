//
//  RouteOptions.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// 外部参数关联属性
private struct Route_associatedKeys {
    static var acceptBackpass = "route_backpass"
    static var acceptRedirect = "route_redirect"
}

internal extension UIViewController {
    /// 路由扩展闭包回调
    var routeBackpass: ClosureAny? {
        set {
            objc_setAssociatedObject(self, &Route_associatedKeys.acceptBackpass, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let options = objc_getAssociatedObject(self, &Route_associatedKeys.acceptBackpass) as? ClosureAny {
                return options
            }
            return nil
        }
    }
    /// 重定向执行闭包
    var routeRedirect: ClosureVoid? {
        set {
            objc_setAssociatedObject(self, &Route_associatedKeys.acceptRedirect, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let options = objc_getAssociatedObject(self, &Route_associatedKeys.acceptRedirect) as? ClosureVoid {
                return options
            }
            return nil
        }
    }
}
