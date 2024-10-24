//
//  PresentViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class PresentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Present"
        view.backgroundColor = .white
        addSubViews()
    }
}

extension PresentViewController: UIRouteable {
    /// 默认转场
    static var __presenting: RouteTransition {
        return .present
    }
}
