//
//  RootViewController.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(FirstViewController())
        addChild(SecondViewController())
        view.backgroundColor = .white
    }

}
