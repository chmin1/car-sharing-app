//
//  PickCollegeViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

protocol PickCollegeViewControllerDelegate {
    func selectCollege(_ selectCollege: PickCollegeViewController, didSelectCollege college: String?)
}

class PickCollegeViewController: UITableViewController {

    
    var schools: [String]!
    var filteredSchools: [String]!
    let searchController = UISearchController(searchResultsController: nil)
    
    var delegate: PickCollegeViewControllerDelegate? //this is the protocol (not the vc)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        schools = Array(CollegesDict.collegeDict.keys)
        
        setupSearchController()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Search Controller Setup
    func setupSearchController () {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    
    func filterContentForSearchText(_ searchText: String) {
        
        filteredSchools = schools.filter { school in
            return school.lowercased().contains(searchText.lowercased()) || searchText == ""
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredSchools.count
        }
        return schools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let school: String
        if searchController.isActive {
            school = filteredSchools[(indexPath as NSIndexPath).row]
        } else {
            school = schools[(indexPath as NSIndexPath).row]
        }
        cell.textLabel!.text = school
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath)")
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let school: String
            if searchController.isActive {
                school = filteredSchools[(indexPath as NSIndexPath).row]
            } else {
                school = schools[(indexPath as NSIndexPath).row]
            }
            print("😆school is: \(school)")
            
            // Alert the delegate
            delegate?.selectCollege(self, didSelectCollege: school) //sending the school string to the delegate
            self.dismiss(animated: true, completion: { //dismisses first vc
                self.dismiss(animated: true, completion: nil) //dismisses second vc (for when in search mode)
            })
            
        }
        
    }
    
   
    

    
}//close class


