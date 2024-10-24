//
//  OrderViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class OrderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order"
        view.backgroundColor = .white
        addSubViews()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "回调信息", style: .plain, target: self, action: #selector(loginAction))
    }
    
    @objc func loginAction() {
        AuthState.shared.didAuthed = true
        
        back(["name": "哈哈哈", "age": 10])
    }
}

extension OrderViewController: UIRoute {
    
    static var __uniqueType: RouteUniqueType {
        return .global
    }
    
    func __routeOptions(data: Any?) {
        print("路由参数：\(data)")
    }
}
