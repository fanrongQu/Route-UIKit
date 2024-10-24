//
//  RouteDefs.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// any-closure回调闭包定义
public typealias ClosureAny = (Any?)->Void
/// void-closure回调闭包定义
public typealias ClosureVoid = () -> Void
/// response-closure重定向执行闭包
public typealias ClosureBackResponse = () -> RouteResponse?

/// 页面路由优先级
public enum RoutePriority: Int, CaseIterable {
    case def = 10           // scheme://host/path 默认
    case high = 20          // 自定义协议 http/https/sdk
    case require = 30       // 覆盖协议 如临时降级方案(降级就是更高优先级协议响应)
}

/// 页面实例化类型
public enum RouteInstanceType {
    case code               //  代码化
    case xib                //  xib化
    case sb(String, String?)//  sb构建<sb文件名, sb标识符>
}

/// 页面路由转场
public enum RouteTransition: Int {
    case none               //  root根控制器
    case push               //  压栈
    case present            //  模态
}

/// 页面路由唯一类型
public enum RouteUniqueType {
    case none               //  不唯一
    case root               //  根视图
    case global             //  全局唯一
}

