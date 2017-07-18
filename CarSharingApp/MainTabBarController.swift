//
//  MainTabBarController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, CreateViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedViewController = selectedViewController {
            becomeCreateControllerDelegateIfNeeded(selectedViewController)
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        becomeCreateControllerDelegateIfNeeded(viewController)
    }
    
    private func becomeCreateControllerDelegateIfNeeded(_ viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController,
            let createViewController = navigationController.viewControllers.first as? CreateViewController {
            createViewController.delegate = self
        }
    }
    
    private func updateHomeControllerIfNeeded(_ viewController: UIViewController, trip: PFObject) {
        if let navigationController = viewController as? UINavigationController,
            let homeViewController = navigationController.viewControllers.first as? HomeViewController {
            homeViewController.didPostTrip(trip: trip)
        }
    }
    
    func switchToHome(with trip: PFObject) {
        selectedIndex = 0
        if let selectedViewController = selectedViewController {
            updateHomeControllerIfNeeded(selectedViewController, trip: trip)
        }
        
    }
    
    func didPostTrip(trip: PFObject) {
        switchToHome(with: trip)
    }
}

