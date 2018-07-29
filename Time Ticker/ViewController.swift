//
//  ViewController.swift
//  Time Ticker
//
//  Created by fangwiehsu on 2018/7/27.
//  Copyright © 2018年 fangwiehsu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - IBoutlet
    
    @IBOutlet weak var remainingLabel: NSTextField!
    @IBOutlet weak var goalProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var goalLabel: NSTextField!
    @IBOutlet weak var goalTimePopUpButton: NSPopUpButton!
    @IBOutlet weak var inOutButton: NSButton!
    @IBOutlet weak var currentlyLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    // MARK: - Properities
    
    var currentPeriod: Period?
    var timer: Timer?
    var periods = [Period]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        goalTimePopUpButton.removeAllItems()
        goalTimePopUpButton.addItems(withTitles: titles())
        getPeriods()
    }
    
    // MARK: -Functions
    fileprivate func updateView(){
        let goalTime = goalTimePopUpButton.indexOfSelectedItem + 1
        
        if goalTime == 1{
            goalLabel.stringValue = "Goal: 1 Hour"
        }else{
            goalLabel.stringValue = "Goal: \(goalTime) Hours"
        }
        
        if currentPeriod == nil {
            
            inOutButton.image = NSImage(named: NSImage.Name(rawValue: "IN"))
            currentlyLabel.isHidden = true
            
        }else{
            inOutButton.image = NSImage(named: NSImage.Name(rawValue: "OUT"))
            currentlyLabel.isHidden = false
            currentlyLabel.stringValue = "Currently: \(currentPeriod!.currentlyString())"
        }
        
        remainingLabel.stringValue = remainingTimeAsString()
        let ratio = totalTimeInterval() / goalTimeInterval()
        goalProgressIndicator.doubleValue = ratio
        
    }
    
    fileprivate func remainingTimeAsString() -> String {
        let remainingTime = goalTimeInterval() - totalTimeInterval()
        if remainingTime <= 0 {
            return "Finished! \(Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: totalTimeInterval())))"
        }else{
            return "Remaining: \(Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: remainingTime)))"
        }
        
    }
    
    fileprivate func getPeriods() {
        
        // Get the core data context
        if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext{
            
            // Fetch request
            if let name = Period.entity().name {
                
                let fetchRequest = NSFetchRequest<Period>(entityName: name)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "outDate", ascending: false)]
                
                if var periods = try? context.fetch(fetchRequest){
                    
                    // Check to see if current clocked in. If the device crash, keep the inDate for user.
                    for x in 0..<periods.count{
                        let period = periods[x]
                        if period.outDate == nil{
                            currentPeriod = period
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                                self.updateView()
                            })
                            
                            periods.remove(at: x)
                            break
                        }
                    }
                    
                    self.periods = periods
                    
                    
                }
                
            }
            
        }
        tableView.reloadData()
        updateView()
    }
    
    fileprivate func totalTimeInterval() -> TimeInterval{
        
        var time = 0.0
        
        for period in periods {
            time += period.time()
        }
        
        if let currentPeriod = self.currentPeriod {
            time += currentPeriod.time()
        }
        
        return time 
    }
    
    fileprivate func goalTimeInterval() -> TimeInterval {
        // time interval calculate second
        return Double(goalTimePopUpButton.indexOfSelectedItem + 1) * 60.0 * 60.0
    }
    
    // MARK: - IBAction
    @IBAction func resetClicked(_ sender: Any) {
        if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext {
            for period in periods{
                context.delete(period)
            }
            
            if let currentPeriod = self.currentPeriod{
                context.delete(currentPeriod)
                self.currentPeriod = nil
            }
            
            getPeriods()
            
        }
        
    }
    
    @IBAction func goalTimeChanged(_ sender: Any) {
        
        updateView()
        
    }
    
    @IBAction func inOutTapped(_ sender: Any) {
        
        if currentPeriod == nil{
            
            // Using the core data  clocking in..
            if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                currentPeriod = Period(context: context)
                currentPeriod?.inDate = Date()
                //currentPeriod?.inDate = Date(timeIntervalSinceNow: -1404)
            }
            // Update currentlyLabel
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.updateView()
            })
            
        }else{
            //Clocking out...
            currentPeriod!.outDate = Date()
            (NSApp.delegate as? AppDelegate)?.saveAction(nil)
            currentPeriod = nil
            timer?.invalidate() //stop the timer
            timer = nil
            getPeriods()
        }
        updateView()
        (NSApp.delegate as? AppDelegate)?.saveAction(nil)
        
    }
    
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    fileprivate func titles() -> [String] {
        
        var titles = [String]()
        for number in 1...100 {
            titles.append("\(number)h")
        }
        return titles
    }
    
    // MARK: - TableView functions
    func numberOfRows(in tableView: NSTableView) -> Int {
        return periods.count
    }
    
    // iOS --> cellForIndexPath
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PeriodCell"), owner: self) as? PeriodCell
        
        let period = periods[row]
        cell?.timeTotalTextField.stringValue = Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: period.time()))
        cell?.timeRangeTextField.stringValue = "\(period.perttyInDate()) - \(period.perttyOutDate())"
        
        return cell
    }

}

