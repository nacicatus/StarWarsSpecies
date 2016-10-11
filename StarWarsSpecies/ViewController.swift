//
//  ViewController.swift
//  StarWarsSpecies
//
//  Created by Saurabh Sikka on 11/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var species: Array<StarWarsSpecies>? //  To hold all of the species we’ve loaded (which might be from multiple API calls due to pagination)
    
    var speciesWrapper: SpeciesWrapper? // To access the next field if we need to load more species and to access the count field to see whether we need to load more species
    
    var isLoadingSpecies = false // Since our API wrappers are asynchronous, we want to make sure we don’t fire off a second request to load more species after we’ve already done so. There are more sophisticated ways of handling this requirement but a simple boolean value works for our simple example.
    
    @IBOutlet weak var speciesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speciesTableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.loadFirstSpecies()
    }
    
    
    
    // MARK: - Getting data
    func loadFirstSpecies() {
        isLoadingSpecies = true
        StarWarsSpecies.getSpecies { wrapper, error in
            guard error == nil else {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error",
                    message: "Could not load first species \(error?.localizedDescription)",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            self.addSpeciesFromWrapper(wrapper)
            self.isLoadingSpecies = false
            self.speciesTableView?.reloadData()
        }
    }
    
    func loadMoreSpecies()
    {
        self.isLoadingSpecies = true
        guard let species = self.species, let wrapper = self.speciesWrapper where species.count < wrapper.count else {
            // no more species to fetch
            return
        }
        // there are more species out there!
        StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { (moreWrapper, error) in
            guard error == nil else {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error",
                    message: "Could not load more species \(error?.localizedDescription)",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            print("got more!")
            self.addSpeciesFromWrapper(moreWrapper)
            self.isLoadingSpecies = false
            self.speciesTableView?.reloadData()
        })
    }
    
    func addSpeciesFromWrapper(wrapper: SpeciesWrapper?) {
        self.speciesWrapper = wrapper
        if self.species == nil {
            self.species = self.speciesWrapper?.species
        } else if let newSpecies = self.speciesWrapper?.species, let currentSpecies = self.species {
            self.species = currentSpecies + newSpecies
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Table View Boilerplate
    
    // datasource functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let species = self.species else {
            return 0
        }
        return species.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpeciesCell", forIndexPath: indexPath)
        
        if let numberOfSpecies = self.species?.count where numberOfSpecies >= indexPath.row {
            if let species = self.species?[indexPath.row] {
                cell.textLabel?.text = species.name
                cell.detailTextLabel?.text = species.classification
            }
            
            // See if we need to load more species
            let rowsToLoadFromBottom = 5;
            if !self.isLoadingSpecies && indexPath.row >= (numberOfSpecies - rowsToLoadFromBottom) {
                if let totalSpeciesCount = self.speciesWrapper?.count where totalSpeciesCount - numberOfSpecies > 0 {
                    self.loadMoreSpecies()
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    
    
    
    
}

