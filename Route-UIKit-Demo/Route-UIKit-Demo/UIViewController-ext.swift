//
//  UIViewController-ext.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

extension UIViewController: RouteGo, PopDismissRoute {
    
    func addSubViews() {
        let pushButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 120, width: 120, height: 44))
            button.setTitle("跳转push", for: .normal)
            button.addTarget(self, action: #selector(goPushView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let presentButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 170, width: 120, height: 44))
            button.setTitle("跳转present", for: .normal)
            button.addTarget(self, action: #selector(goPresentView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let firstButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 220, width: 120, height: 44))
            button.setTitle("跳转first", for: .normal)
            button.addTarget(self, action: #selector(goFirstView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let secondButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 270, width: 120, height: 44))
            button.setTitle("跳转second", for: .normal)
            button.addTarget(self, action: #selector(goSecondView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let loginButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 320, width: 120, height: 44))
            button.setTitle("跳转login", for: .normal)
            button.addTarget(self, action: #selector(goLoginView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let orderButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 370, width: 120, height: 44))
            button.setTitle("order", for: .normal)
            button.addTarget(self, action: #selector(goOrderView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let openUrlButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 60, y: 420, width: 120, height: 44))
            button.setTitle("openUrl", for: .normal)
            button.addTarget(self, action: #selector(openUrlView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let dismissButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 120, width: 120, height: 44))
            button.setTitle("dismiss", for: .normal)
            button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let backFirstButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 170, width: 120, height: 44))
            button.setTitle("back2FirstVC", for: .normal)
            button.addTarget(self, action: #selector(back2FirstVCView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let backFirstPathButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 220, width: 120, height: 44))
            button.setTitle("back2FirstPath", for: .normal)
            button.addTarget(self, action: #selector(back2FirstView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let backFirstUrlButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 270, width: 120, height: 44))
            button.setTitle("back2FirstUrl", for: .normal)
            button.addTarget(self, action: #selector(back2FirstUrlView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        let backVCButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 320, width: 120, height: 44))
            button.setTitle("back2OrderVC", for: .normal)
            button.addTarget(self, action: #selector(backVCView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let backPathButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 370, width: 120, height: 44))
            button.setTitle("back2OrderPath", for: .normal)
            button.addTarget(self, action: #selector(backPathView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        let backUrlButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(x: 240, y: 420, width: 120, height: 44))
            button.setTitle("back2OrderUrl", for: .normal)
            button.addTarget(self, action: #selector(backUrlView), for: .touchUpInside)
            button.backgroundColor = .brown
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        view.addSubview(pushButton)
        view.addSubview(presentButton)
        view.addSubview(firstButton)
        view.addSubview(secondButton)
        view.addSubview(loginButton)
        view.addSubview(orderButton)
        view.addSubview(openUrlButton)
        
        view.addSubview(dismissButton)
        view.addSubview(backFirstButton)
        view.addSubview(backFirstPathButton)
        view.addSubview(backFirstUrlButton)
        view.addSubview(backVCButton)
        view.addSubview(backPathButton)
        view.addSubview(backUrlButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(backItemClick))
    }
    
    @objc func backItemClick() {
        back()
    }
    
    @objc func goPushView() {
        PagePaths.push.go() { data in
            print("订单页回调信息\(String(describing: data))")
        }
    }
    
    @objc func goPresentView() {
        PagePaths.present.go()
    }
    
    @objc func goFirstView() {
        PagePaths.first.go()
    }
    
    @objc func goSecondView() {
        PagePaths.second.go(["data": "测试数据tab切换传递"])
    }
    
    @objc func goLoginView() {
        PagePaths.login.go { data in
            print("登录回调信息\(String(describing: data))")
        }
    }
    @objc func goOrderView() {
        PagePaths.order.go(["orderId": "57687565"]) { data in
            print("订单回调信息\(String(describing: data))")
        }
    }
    @objc func openUrlView() {
        let auth = AuthState.shared.didAuthed ? 0 : 1
        open(URL(string: "routeUIKitDemo://OrderViewController?auth=\(auth)"), options: nil, authGoResponse: {
            PagePaths.login.response()
        }, backpass: { data in
            print("url订单回调信息\(String(describing: data))")
        })
    }
    @objc func dismissView() {
        dismiss()
    }
    @objc func back2FirstVCView() {
        back(vcType: FirstViewController.self)
    }
    @objc func back2FirstView() {
        back(path: PagePaths.first)
    }
    @objc func back2FirstUrlView() {
        back(url: URL(string: "http://Root/FirstViewController"))
    }
    @objc func backVCView() {
        back(["orderName": "通过OrderViewController返回订单页"], vcType: OrderViewController.self)
    }
    @objc func backPathView() {
        back(["orderName": "通过Path返回订单页"], path: PagePaths.order)
    }
    @objc func backUrlView() {
        back(["orderName": "通过url返回订单页"], url: URL(string: "routeUIKitDemo://OrderViewController?orderid=10998"))
    }
}

