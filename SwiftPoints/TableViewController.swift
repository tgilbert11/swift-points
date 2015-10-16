//
//  TableViewController.swift
//  SwiftPoints
//
//  Created by Taylor H. Gilbert on 7/2/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var theTableView: UITableView
    @IBOutlet var mScoreLabel: UILabel
    @IBOutlet var tScoreLabel: UILabel
    
    @IBOutlet var leftLittleNeedle: UIImageView
    @IBOutlet var rightLittleNeedle: UIImageView
    @IBOutlet var bigNeedle: UIImageView
    var leftLittleNeedleAngle: Float = 0
    var rightLittleNeedleAngle: Float = 0
    var bigNeedleAngle: Float = 0

    @IBOutlet var leftBigCoverWhite: UIImageView
    @IBOutlet var rightBigCoverWhite: UIImageView
    @IBOutlet var bigRedIndicator: UIImageView
    @IBOutlet var bigGreenIndicator: UIImageView
    
    var events: (name: String, itemNumber: Int, date: NSDate)[] = []
    
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
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var displayLink = CADisplayLink(target: self, selector:Selector("redrawNeedles"))
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshLocalModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refreshLocalModel() {
        
        reloadEvents()
        
        theTableView.reloadData()
        
        var tScore = 0
        var mScore = 0
        
        for event in events {
            if event.name == "Morgan" || event.name == "M" {
                mScore += items[event.itemNumber].score
            }
            else {
                tScore += items[event.itemNumber].score
            }
        }
        
        let newLeftNeedleAngle = (mScore > 0 ? 1 : -1)*Float(log10(Double(abs(mScore))/10+1)*145/1.04139)*3.14159/180
        let newRightNeedleAngle = (tScore > 0 ? 1 : -1)*Float(log10(Double(abs(tScore))/10+1)*145/1.04139)*3.14159/180
        let newBigNeedleAngle = (tScore>mScore ? 1 : -1)*Float(log10(Double(abs(tScore-mScore))/10+1)*90/1.04139)*3.14159/180
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.animateNeedles(newBigNeedleAngle, leftAngle: newLeftNeedleAngle, rightAngle: newRightNeedleAngle, duration: 0.6)
        })
        
        mScoreLabel.text = "\(mScore)"
        tScoreLabel.text = "\(tScore)"
        
    }
    func reloadEvents() {
        
        events.removeAll(keepCapacity: false)
        let url = NSURL(string: "http://192.168.1.100/data/read")
        var error: NSError? = nil
        let possibleString:NSString? = NSString.stringWithContentsOfURL(url, encoding: NSUTF8StringEncoding, error: &error)
        if error != nil {
            println(error)
        }
        if let incomingString = possibleString {
            let entries: String[] = incomingString.componentsSeparatedByString(";") as String[]
            for thisString:String in entries {
                var theseEntries: String[] = thisString.componentsSeparatedByString("/")
                if theseEntries.count == 3 {
                    
                    var df: NSDateFormatter = NSDateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let thisDate: NSDate = df.dateFromString(theseEntries[2])
                    let thisItemNumber: Int = (theseEntries[1].toInt()! < 1 ? -1 : 1)*theseEntries[1].toInt()!
                    let thisTuple: (String, Int, NSDate) = (theseEntries[0], thisItemNumber, thisDate)
                    events += thisTuple
                }
            }
        }
    }
    func animateNeedles(bigAngle: Float, leftAngle: Float, rightAngle: Float, duration: Float) {
        
        let startTime: NSDate = NSDate()
        var finished: Bool = false
        
        let startBigAngle = bigNeedleAngle
        let startLeftAngle = leftLittleNeedleAngle
        let startRightAngle = rightLittleNeedleAngle
        
        while !finished {
            
            let timeDelta = Float(NSDate().timeIntervalSinceDate(startTime))
            
            if timeDelta < duration { // go, animation, go!
                let t = timeDelta / (duration/2)
                if t < 1 {
                    bigNeedleAngle = startBigAngle + (bigAngle - startBigAngle)/2*t*t*t
                    leftLittleNeedleAngle = startLeftAngle + (leftAngle - startLeftAngle)/2*t*t*t
                    rightLittleNeedleAngle = startRightAngle + (rightAngle - startRightAngle)/2*t*t*t
                }
                else {
                    bigNeedleAngle = startBigAngle + (bigAngle - startBigAngle)/2*((t-2)*(t-2)*(t-2) + 2)
                    leftLittleNeedleAngle = startLeftAngle + (leftAngle - startLeftAngle)/2*((t-2)*(t-2)*(t-2) + 2)
                    rightLittleNeedleAngle = startRightAngle + (rightAngle - startRightAngle)/2*((t-2)*(t-2)*(t-2) + 2)
                }
            }
            else {  //time has expired
                drawBigNeedle(bigAngle)
                drawLeftNeedle(leftAngle)
                drawRightNeedle(rightAngle)
                finished = true
            }
        }
        
    }
    func redrawNeedles() {
        drawBigNeedle(bigNeedleAngle)
        drawLeftNeedle(leftLittleNeedleAngle)
        drawRightNeedle(rightLittleNeedleAngle)
    }
    
    func drawBigNeedle(angle: Float) {
        bigNeedleAngle = angle
        bigNeedle.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        bigRedIndicator.transform = CGAffineTransformMakeRotation(CGFloat(-3.14159/2 + angle))
        bigGreenIndicator.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        
        if angle < 0 {
            leftBigCoverWhite.transform = CGAffineTransformMakeRotation(CGFloat(-3.14159/2 + angle))
            rightBigCoverWhite.transform = CGAffineTransformMakeRotation(0)
        }
        else {
            leftBigCoverWhite.transform = CGAffineTransformMakeRotation(CGFloat(-3.14159/2))
            rightBigCoverWhite.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        }
    }
    func drawLeftNeedle(angle: Float) {
        leftLittleNeedleAngle = angle
        leftLittleNeedle.transform = CGAffineTransformMakeRotation(CGFloat(angle-3.14159))
    }
    func drawRightNeedle(angle: Float) {
        rightLittleNeedleAngle = angle
        rightLittleNeedle.transform = CGAffineTransformMakeRotation(CGFloat(-angle))
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: RecentEventTableViewCell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as RecentEventTableViewCell
        if events[indexPath.row].name == "Morgan" || events[indexPath.row].name == "morgan" || events[indexPath.row].name == "M" {
            cell.leftScoreLabel.text = "\(items[events[indexPath.row].itemNumber].score)"
            cell.rightScoreLabel.text = ""
            let textColor: UIColor = UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1)
            let backgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
            //mScoreLabel.textColor = textColor
            cell.leftScoreLabel.textColor = textColor
            cell.eventTitleLabel.textColor = textColor
            cell.dateLabel.textColor = textColor
            cell.backgroundColor = backgroundColor
            // color stuff
        }
        else {
            cell.rightScoreLabel.text = "\(items[events[indexPath.row].itemNumber].score)"
            cell.leftScoreLabel.text = ""
            let textColor: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            let backgroundColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            //tScoreLabel.textColor = textColor
            cell.rightScoreLabel.textColor = textColor
            cell.eventTitleLabel.textColor = textColor
            cell.dateLabel.textColor = textColor
            cell.backgroundColor = backgroundColor
            // color stuff
        }
        cell.eventTitleLabel.text = "\(items[events[indexPath.row].itemNumber].itemName)"
        var df: NSDateFormatter = NSDateFormatter()
        df.dateFormat = "MMM dd"
        cell.dateLabel.text = df.stringFromDate(events[indexPath.row].date)
        return cell
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    
}