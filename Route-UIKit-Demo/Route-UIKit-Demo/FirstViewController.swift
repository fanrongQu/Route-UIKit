//
//  FirstViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        view.backgroundColor = .white
        addSubViews()
    }
}


extension FirstViewController: UIRouteable {
    /// 默认转场
    static var __presenting: RouteTransition {
        return .none
    }
    /// 默认不唯一
    static var __uniqueType: RouteUniqueType {
        return .root
    }
    
    static var __pathName: String {
        PagePaths.first.path.0
    }
    
    static var __schemes: Set<String> {
        ["routeUIKitDemo", "http"]
    }
}
