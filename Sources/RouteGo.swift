//
//  RouteGo.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

// MARK: - go2路由协议
/// 跳转执行路由协议
public protocol RouteGo {
    /// 是否可以处理此URL
    func canOpen(_ url: URL?, options: [String: Any]?) -> Bool
    
    /// scheme/universal-link/弹窗链接等方式打开url
    /// - Parameters:
    ///   - url: 链接url
    ///   - options: 参数信息
    ///   - authGoResponse: 授权操作
    ///   - backpass: 数据回调
    func open(_ url: URL?, options: [String: Any]?, authGoResponse: ClosureBackResponse?, backpass: ClosureAny?)
    
    /// 场景直接调用方式(第三方SDK生成的VC)
    func go2(_ resp: RouteResponse?)
    
    /// UI层级最顶层控制器
    func paramountVC() -> UIViewController?
}

/// 跳转执行路由协议默认实现
public extension RouteGo {
    /// 是否可以处理此URL
    func canOpen(_ url: URL?, options: [String: Any]? = nil) -> Bool {
        return Route.shared.canOpen(url, options: options)
    }
    /// scheme/universal-link/弹窗链接等方式打开url
    /// - Parameters:
    ///   - url: 链接url
    ///   - options: 参数信息
    ///   - authGoResponse: 授权操作
    ///   - backpass: 数据回调
    func open(_ url: URL?, options: [String: Any]? = nil, authGoResponse: ClosureBackResponse? = nil, backpass: ClosureAny? = nil) {
        Route.shared.open(url, options: options, authGoResponse: authGoResponse, backpass: backpass)
    }
    /// 场景直接调用方式(第三方SDK生成的VC)
    func go2(_ resp: RouteResponse?) {
        Route.shared.go2(resp)
    }
    /// UI层级最顶层控制器
    func paramountVC() -> UIViewController? {
        return Route.shared.paramountVC()
    }
}

// MARK: - PopDisimiss执行路由协议
/// PopDisimiss路由协议
public protocol PopDismissRoute {
    /// 模态消失(dismiss navi)导航栈最顶层模态视图
    /// - Parameters:
    ///   - values: 反向传值
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    func dismiss(_ values: Any?, goHookPath: Bool, animated: Bool) -> UIViewController?
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部path
    /// - Parameters:
    ///   - values: 反向传值
    ///   - path: RoutePathable路径
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    func back(_ values: Any?, path: RoutePathable, goHookPath: Bool, animated: Bool) -> UIViewController?
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部url
    /// - Parameters:
    ///   - values: 反向传值
    ///   - url: 目标对象url链接
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    func back(_ values: [String: Any]?, url: URL?, goHookPath: Bool, animated: Bool) -> UIViewController?
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部vcType
    /// - Parameters:
    ///   - values: 反向传值
    ///   - vcType: 目标控制器类型
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    func back(_ values: Any?, vcType: UIViewController.Type, goHookPath: Bool, animated: Bool) -> UIViewController?
    /// 销毁(pop/dismiss)导航栈内控制器到目标控制器
    /// - Parameters:
    ///   - values: 反向传值
    ///   - targetVC: 目标控制器
    ///   - goHookPath: 执行拦截路由(默认执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    func back(_ values: Any?, targetVC: UIViewController?, goHookPath: Bool, animated: Bool) -> UIViewController?
}

/// PopDisimiss执行路由默认实现
public extension PopDismissRoute where Self: NSObject {
    @discardableResult
    func dismiss(_ values: Any? = nil, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        return Route.shared.dismiss(values, goHookPath: goHookPath, animated: animated)
    }
    @discardableResult
    func back(_ values: Any? = nil, path: RoutePathable, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        return Route.shared.back(values, path: path, goHookPath: goHookPath, animated: animated)
    }
    @discardableResult
    func back(_ values: [String: Any]? = nil, url: URL?, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        return Route.shared.back(values, url: url, goHookPath: goHookPath, animated: animated)
    }
    @discardableResult
    func back(_ values: Any? = nil, vcType: UIViewController.Type, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        return Route.shared.back(values, vcType: vcType, goHookPath: goHookPath, animated: animated)
    }
    
    @discardableResult
    func back(_ values: Any? = nil, targetVC: UIViewController? = nil, goHookPath: Bool = true, animated: Bool = true) -> UIViewController? {
        return Route.shared.back(values, targetVC: targetVC, goHookPath: goHookPath, animated: animated)
    }
}

//MARK: - 页面协议集合
/// 页面路由集合(UIRouteable, PopDismissRoute)
public protocol UIRoute: UIRouteable, PopDismissRoute {}
