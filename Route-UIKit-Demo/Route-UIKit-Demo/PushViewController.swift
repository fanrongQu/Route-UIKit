//
//  PushViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit
import Route_UIKit

class PushViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Push"
        view.backgroundColor = .white
        addSubViews()
    }
}

extension PushViewController: UIRouteable {
    static var __pathName: String {
        return "Push"
    }
}
