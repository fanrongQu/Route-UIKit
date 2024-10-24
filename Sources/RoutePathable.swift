//
//  RoutePathable.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/**
 * path路径协议中可控制是否需要强制授权(比如配置的路由协议中添加参数动态控制授权-默认false-外部控制)
 * route路由协议中也可以配置是否需要强制授权(即自身设定是否需要强制授权-默认false-自身控制)
 * 外部控制 + 自身控制 = 决定此次路由投递是否需要强制授权
 */

//MARK: - 路由路径协议
public protocol RoutePathable {
    /// 默认前缀
    var baseURL: String { get }
    
    /// 路径/鉴权(路径|是否需要授权-可使用枚举关联属性实现)
    var path: (String, Bool) { get }
    
    /// 用户授权状态(以解藕路由中心与具体业务场景)
    var authState: Bool { get }
    
    /// 引导用户进入授权中心(以解藕路由中心与具体业务场景)
    func enterOAuth() -> RouteResponse?
    
    /// 执行路由
    /// - Parameters:
    ///   - options: 传递的参数
    ///   - backpass: 回调参数
    func go(_ options: Any?, backpass: ClosureAny?)
}
/// 默认实现
public extension RoutePathable {
    var authState: Bool {
        return false
    }
    
    func enterOAuth() -> RouteResponse? {
        return nil
    }
    
    func go(_ options: Any? = nil, backpass: ClosureAny? = nil) {
        Route.shared.go2(self, options: options, backpass: backpass)
    }
    
    func response(_ options: Any? = nil, backpass: ClosureAny? = nil) -> RouteResponse? {
        Route.shared.pathResponse(self, options: options)?.backpass(backpass)
    }
}

