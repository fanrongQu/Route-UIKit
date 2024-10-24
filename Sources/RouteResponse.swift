//
//  RouteResponse.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// 路由响应(得到Profile或者重定向URL)
public final class RouteResponse {
    public private(set) var from: UIViewController?
    public private(set) var obj: AnyObject?
    /// 转场方式
    public private(set) var transition: RouteTransition = .push
    /// 路由类型
    public private(set) var uniqueType: RouteUniqueType = .none
    /// 转场目标类型（uniqueType为root/global时查找目标使用）
    public private(set) var classType: UIViewController.Type?
    
    public private(set) var options: Any?
    
    /// 重定向路由响应对象
    public private(set) var redirectResponse: RouteResponse?
    /// 重定向后是否还返回到原请求 默认true
    public private(set) var needReturn2Origin: Bool = true
    /// 便利构造器
    public convenience init(from: UIViewController?, obj: AnyObject?, transition: RouteTransition = .push, uniqueType: RouteUniqueType = .none, classType: UIViewController.Type? = nil, options: Any? = nil) {
        self.init()
        self.from = from
        self.obj = obj
        self.transition = transition
        self.uniqueType = uniqueType
        self.classType = classType
        self.options = options
    }
    /// 重定向
    public func redirect(_ redirect: RouteResponse?, return2Origin: Bool = true) -> Self {
        self.redirectResponse = redirect
        self.needReturn2Origin = return2Origin
        return self
    }
    /// 数据回调
    @discardableResult
    public func backpass(_ closure: ClosureAny?) -> Self {
        if let scene = from {
            scene.routeBackpass = closure
        }
        return self
    }
}
