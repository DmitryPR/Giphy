//
//  SearchViewController.swift
//  GiphyProject
//
//  Created by Dmitry Preobrazhenskiy on 28/06/16.
//  Copyright © 2016 Example. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import XCGLogger

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var logoView: UIImageView!
    
    private var images: [GIF] = [GIF]()
    private var selectedImage: GIF?
    
    // MARK: System Stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialViews()
        setUpInitialData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if searchBar.canBecomeFirstResponder() {
            searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: Initialisation
    
    private func setUpInitialViews() {
        searchBar.text = "Happy!"
    }
    
    private func setUpInitialData() {
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: IBActions
    
    @IBAction func trendingButtonTapped(sender: AnyObject) {
        trending()
    }
    
    // MARK: Private Methods
    
    private func search(query: String?) {
        guard let q = query else {
            return
        }
        
        resignSearchBar()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        APIClient.search(q) {
            result, error in
            PKHUD.sharedHUD.hide(afterDelay: 0, completion: nil)
            
            if let displayError = error {
                UIAlertView.init(title: "Attention", message: displayError.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                
            } else {
                self.handleResult(result)
            }

        }
    }
    
    private func trending() {
        resignSearchBar()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        APIClient.trending() {
            result, error in
            PKHUD.sharedHUD.hide(afterDelay: 0, completion: nil)
            
            if let displayError = error {
                UIAlertView.init(title: "Attention", message: displayError.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                
            } else {
                self.handleResult(result)
            }
            
        }
        
    }
    
    private func handleResult(gifs: [GIF]?) {
        guard let gifs = gifs else {
            XCGLogger.defaultInstance().debug("Could not get the results from the API")
            return
        }
        
        images = gifs
        collectionView.reloadData()
    }
    
    private func resignSearchBar() {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = searchBar.text?.stringByReplacingOccurrencesOfString(" ", withString: "+")
        search(searchString)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignSearchBar()
    }
}

// MARK: UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        resignSearchBar()
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        let item = images[indexPath.row]
        
        selectedImage = item
        
        let alert = UIAlertView.init(title: item.slug, message: item.source, delegate: self, cancelButtonTitle: "Cancel")
        alert.addButtonWithTitle("Show")
        alert.show()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        resignSearchBar()
    }
}

// MARK: UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = images[indexPath.row]
        let imageCell = collectionView .dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! ImageCell
        
        imageCell.updateWithGIF(item)
        return imageCell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        logoView.hidden = (images.count != 0)
        return images.count
    }
}

// MARK: UIAlertViewDelegate

extension SearchViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        guard buttonIndex == 1 else {
            return
        }
        
        let sourceURL = NSURL.init(string: selectedImage!.source!)!
        
        if UIApplication.sharedApplication().canOpenURL(sourceURL) {
            UIApplication.sharedApplication().openURL(sourceURL)
        }
    }
}