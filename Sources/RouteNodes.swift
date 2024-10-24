//
//  RouteNodes.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// 路由节点 - 执行节点
internal class RouteExecNode {
    /// 路由协议实现者
    internal var handler: Routeable.Type
    /// 初始化
    init(_ handler: Routeable.Type) {
        self.handler = handler
    }
    
    /// 路由查询是否可达
    func reachable(_ req: RouteRequest) -> Bool {
        guard self.handler.__routable(req) else {
            return false
        }
        return true
    }
    
    /// 路由管理器发起实际调用-过渡
    func exe(_ req: RouteRequest) -> RouteResponse {
        guard let result = self.handler.__exe(req) else {
            return RouteResponse(from: req.from, obj: nil)
        }
        var trans: RouteTransition = .push
        if let ui = handler as? UIRouteable.Type {
            trans = ui.__presenting
        }
        return RouteResponse(from: req.from, obj: result, transition:trans)
    }
    
    /// 路由节点目标类型
    func targetType() -> AnyClass {
        return self.handler.__classType()
    }
}

/// 路由导航控制器节点
internal class RouteNaviNode {
    /// 当前节点导航控制器(同一栈内就是自身 根控制器root导航即使自己)
    var this: UINavigationController
    /// 自身呈现方式
    var transform: RouteTransition = .present
    /// 上一节点导航控制器(根控制器为nil)
    var previous: UINavigationController?
    /// 下一跳节点导航控制器(eg present后改变了导航控制器栈的布局)
    var next: UINavigationController?
    
    init(_ this: UINavigationController, previous: UINavigationController?, trans: RouteTransition = .present) {
        self.this = this
        self.previous = previous
        self.transform = trans
    }
    
    internal func update(_ next: UINavigationController?) {
        self.next = next
    }
}

// MARK: 相等协议比较
extension RouteNaviNode: Equatable {
    static func == (lhs: RouteNaviNode, rhs: RouteNaviNode) -> Bool {
        if lhs.this.isEqual(rhs.this), lhs.transform == rhs.transform {
            return true
        }
        return false
    }
}
