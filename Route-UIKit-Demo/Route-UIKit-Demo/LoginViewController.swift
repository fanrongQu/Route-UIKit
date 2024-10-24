//
//  LoginViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        addSubViews()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(loginAction)),
                                                   UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logoutAction))]
    }
    
    @objc func loginAction() {
        AuthState.shared.didAuthed = true
        back(["name": "哈哈哈", "age": 10])
    }
    @objc func logoutAction() {
        AuthState.shared.didAuthed = false
        back()
    }
}


extension LoginViewController: UIRoute {
    /// 默认不唯一
    static var __uniqueType: RouteUniqueType {
        return .global
    }
}
