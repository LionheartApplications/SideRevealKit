//
//  ViewController.swift
//  ExampleStoryboards
//
//  Created by Stoyan Stoyanov on 05/04/2019.
//  Copyright © 2019 Stoyan Stoyanov. All rights reserved.
//

import UIKit
import SideRevealKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SideRevealViewController.shared?.frontContainer.layer.shadowOpacity = 1
    }

    @IBAction private func bookmarksButtonTapped(_ sender: UIBarButtonItem) {
        SideRevealViewController.shared?.toggleReveal()
    }
}
