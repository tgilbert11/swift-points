//
//  ViewController.swift
//  SwiftPoints
//
//  Created by Taylor H. Gilbert on 6/16/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//



// 71.116.69.230
import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var tPoints: UILabel
    @IBOutlet var mPoints: UILabel
    @IBOutlet var collectionView: UICollectionView
    @IBOutlet var segControl: UISegmentedControl
    
    let items: (itemName: String, itemID: Int, imageName: String, score: Int)[] = [
        ("Woke up early",   0, "BedMornEmpty.png",    10),
        ("Woke up late",    1, "BedMornEmpty.png",    -5),
        ("To bed early",    2, "BedNightEmpty.png",   10),
        ("To bed late",     3, "BedNightEmpty.png",   -5),
        ("Exercise",        4, "Exercise30.png",      20),
        ("Alcohol",         5, "Drink.png",           -5),
        ("Laundry",         6, "Laundry.png",         15),
        ("Fatty meal",      7, "Fries.png",           -10),
        ("Watered plants",  8, "Plants.png",          5),
        ("Vacuum",          9, "Vacuum.png",          5),
        ("Was a D.D.",     10, "DD.png",              35),
        ("Cooked at home", 11, "Cooking.png",         10),
        ("Cleaned house",  12, "Cleaning.png",        5),
        ("Did dishes",     13, "Dishes.png",          5),
        ("Saw Friends",    14, "Friends.png",         10),
    ]
    
    let images: (imageName: String, score: Int)[] = [
        ("BedMornEmpty.png",    10),
        ("BedMornEmpty.png",   -5),
        ("BedNightEmpty.png", 10),
        ("BedNightEmpty.png",  -5),
        ("Exercise30.png",      20),
        ("Drink.png",           -5),
        ("Laundry.png",         15),
        ("Fries.png",           -10),
        ("Plants.png",          5),
        ("Vacuum.png",          5),
        ("DD.png",              35),
        ("Cooking.png",         10),
        ("Cleaning.png",        5),
        ("Dishes.png",          5),
        ("Friends.png",         10),
    ]
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshValues() {
        let incomingString:NSString = NSString.stringWithContentsOfURL(NSURL(string: "http://192.168.1.100/data/read")) as NSString
        
        let entries: String[] = incomingString.componentsSeparatedByString(";") as String[]
        
        var mTotal: Int = 0, tTotal: Int = 0;
        for thisString:String in entries {
            var theseEntries: String[] = thisString.componentsSeparatedByString("/")
            if theseEntries.count == 3 {
                var tempAmt: Int = theseEntries[1].toInt()!
                if theseEntries[0] == "Morgan" || theseEntries[0] == "morgan" {
                    mTotal += tempAmt
                }
                else {
                    tTotal += tempAmt
                }
            }
        }
        tPoints.text = "\(tTotal)"
        mPoints.text = "\(mTotal)"
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
         as MyCollectionViewCell
        
        cell.imageView.image = UIImage(named: images[indexPath.row].imageName)
        cell.pointsLabel.text = "\(images[indexPath.row].score)"
        return cell;
        
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        println("Section: \(indexPath.section), Row: \(indexPath.row), Image Name: \(images[indexPath.row].imageName), Score: \(images[indexPath.row].score)")
        
        let name: NSString = segControl.selectedSegmentIndex == 0 ? "Taylor" : "Morgan"
        let eventID: Int = indexPath.row
        let output: NSString = NSString.stringWithContentsOfURL(NSURL(string: "http://192.168.1.100/data/write/\(name)/\(eventID)")) as NSString
        refreshValues()
        
    }
    
    
}

