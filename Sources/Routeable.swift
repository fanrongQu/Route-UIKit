//
//  Routeable.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

//MARK: - 路由注册协议(执行特定服务协议 UI无关)
/// 路由协议(执行特定服务协议 UI无关)
public protocol Routeable: NSObjectProtocol {
    /// 优先级 - 默认def
    static var __priority: RoutePriority { get }
    
    /// 路径名 - 默认当前类名
    static var __pathName: String { get }
    
    /// 支持的协议簇
    static var __schemes: Set<String> { get }
    
    /// 路由可达性 - 默认false
    static func __routable(_ req: RouteRequest) -> Bool
    
    /// 正向执行路由节点(核心方法) - 1UI返回scene 2非UI返回nil
    static func __exe(_ req: RouteRequest) -> UIViewController?
    
    /// 路由指向目标的类型
    static func __classType() -> AnyClass
    
    /// 路由传递的参数
    func __routeOptions(data: Any?)
}

/// 路由执行协议默认实现
public extension Routeable where Self: NSObject {
    // 默认优先级
    static var __priority: RoutePriority {
        return .def
    }
    // 默认路径名
    static var __pathName: String {
        return "\(self)"
    }
    /// 默认场景
    static func __exe(_ req: RouteRequest) -> UIViewController? {
        return nil
    }
    
    func __routeOptions(data: Any?) {}
}

//MARK: - UI路由协议(创建UI)
public protocol UIRouteable: Routeable, UIViewController {
    /// 实例化类型 默认代码
    static var __instanceType: RouteInstanceType { get }
    
    /// 转场呈现方式 默认push
    static var __presenting: RouteTransition { get }
    
    /// 唯一类型 eg.登录授权页面全局唯一
    static var __uniqueType: RouteUniqueType { get }
}

/// UI路由默认实现
public extension UIRouteable {
    // 默认协议
    static var __schemes: Set<String> {
        // 协议默认使用小写 大小写不敏感
        let def = Route.shared.ThisNameSpace
        let cls = NSStringFromClass(self)
        let ns = cls.split(separator: ".").first?.filter { $0.isLetter || $0.isNumber }
        guard let ns = ns,
              !ns.isEmpty else {
            return [def]
        }
        return [ns]
    }
    // 默认是否响应
    static func __routable(_ req: RouteRequest) -> Bool {
        // step1 scheme是否匹配
        guard __schemes.contains(req.url.schm) else {
            return false
        }
        // step2 host/path是否匹配
        let dest = req.url.hostPath
        return dest == __pathName
    }
    /// 默认实例化类型
    static var __instanceType: RouteInstanceType {
        return .code
    }
    /// 默认转场
    static var __presenting: RouteTransition {
        return .push
    }
    /// 默认不唯一
    static var __uniqueType: RouteUniqueType {
        return .none
    }
    /// 默认场景
    static func __exe(_ req: RouteRequest) -> UIViewController? {
        var nxt: UIViewController?
        switch __instanceType {
        case .xib:
            nxt = Self.loadFromXib(nib: nil)
        case .sb(let sb, let idf):
            nxt = Self.loadFromSB(sb: sb, and: idf)
        default:
            nxt = Self()
        }
        (nxt as? Routeable)?.__routeOptions(data: req.options)
        return nxt
    }
    /// 当前对象类型
    static func __classType() -> AnyClass {
        return Self.self
    }
}

/// 请求中间件
public protocol RouteReqMiddleware {
    func process(_ req: RouteRequest) -> RouteResponse?
}

/// 响应中间件
public protocol RouteResMiddleware {
    func process(_ resp: RouteResponse?, req: RouteRequest) -> RouteResponse?
}

// MARK: - xib/sb加载 默认实现
fileprivate extension UIViewController {
    /// xib loads
    static func loadFromXib(nib name: String? = nil) -> UIViewController {
        return Self.init(nibName: name ?? "\(self)", bundle: Bundle(for: self.classForCoder()))
    }
    /// sb loads
    static func loadFromSB(sb name: String, and identifier: String?) -> UIViewController? {
        let bundle: Bundle = Bundle(for: self.classForCoder())
        guard let idf = identifier else {
            return UIStoryboard(name: name, bundle: bundle).instantiateInitialViewController()
        }
        return UIStoryboard(name: name, bundle: bundle).instantiateViewController(withIdentifier: idf)
    }
}

//MARK: - 模块注册协议
public protocol RouteRegisterable {
    /// 返回实现路由协议的类集合
    func registerModule() -> [Routeable.Type]
}

