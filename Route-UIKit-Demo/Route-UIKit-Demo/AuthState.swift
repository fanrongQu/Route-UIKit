//
//  AuthState.swift
//  Route-UIKit-Demo
//
//  Created by Rain on 2024/10/23.
//

import UIKit

class AuthState: NSObject {
    public static let shared = AuthState()
    var didAuthed: Bool = false
}
