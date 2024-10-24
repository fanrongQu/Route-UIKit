//
//  SecondViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second"
        view.backgroundColor = .white
        addSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension SecondViewController: UIRouteable {
    /// 默认转场
    static var __presenting: RouteTransition {
        return .none
    }
    /// 默认不唯一
    static var __uniqueType: RouteUniqueType {
        return .root
    }
    
    func __routeOptions(data: Any?) {
        print("路由参数：\(data)")
    }
}
