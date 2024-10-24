//
//  RouteRequest.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// 路由请求(每一次路由都包装为一个request)
public final class RouteRequest {
    public private(set) var url: URL
    public var from: UIViewController?
    public var options: Any?
    /// 便利构造器
    public init(_ url: URL, from: UIViewController?, options: Any? = nil) {
        self.url = url
        self.from = from
        self.options = options
    }
}
