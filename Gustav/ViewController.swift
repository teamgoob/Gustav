//
//  ViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import UIKit

class ViewController: UIViewController {

    private let loginView = LoginView()
    
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        LoginView.load()
    }
    
}

