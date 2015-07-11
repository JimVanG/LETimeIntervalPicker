//
//  LETimeIntervalPicker.swift
//  LETimeIntervalPickerExample
//
//  Created by Ludvig Eriksson on 2015-06-04.
//  Copyright (c) 2015 Ludvig Eriksson. All rights reserved.
//

import UIKit

// MARK: - Public Components Enum

/**
Use the `Components` enum to specify the type of time-interval/duration that you'd like the row to display.

Usage:

    //specifies that componentOne will be in years with 20 rows.
    self.picker.componentOne = .Year(20)
    //specifies that componentTwo will be in minutes and will use the default value (60 rows)
    self.picker.componentTwo = .Minutes(nil)
    //specifies that componentThree will be in hours with 13 rows.
    self.picker.componentThree = .Hours(13)
    //makes it so there will be no componentThree
    self.picker.componentThree = .None

The supported time-interval/duration types are:

- .Hour
- .Minute
- .Second
- .Year
- .Month
- .Week
- .Day
- .None (makes it so no component)
*/
public enum Components: Hashable {
    ///Use to specify no component.
    case None
    ///Set the argument to `nil` to use the default value of 100 rows
    case Year(Int?)
    ///Set the argument to `nil` to use the default value of 12 rows
    case Month(Int?)
    ///Set the argument to `nil` to use the default value of 52 rows
    case Week(Int?)
    ///Set the argument to `nil` to use the default value of 7 rows
    case Day(Int?)
    ///Set the argument to `nil` to use the default value of 24 rows
    case Hour(Int?)
    ///Set the argument to `nil` to use the default value of 60 rows
    case Minute(Int?)
    ///Set the argument to `nil` to use the default value of 60 rows
    case Second(Int?)
    
    ///The hashValue of the `Component` so we can conform to `Hashable` and be sorted.
    public var hashValue : Int {
        return self.toInt()
    }
    
    ///The default row count for the `Component`, if there wasn't one specified.
    public var defaultRowCount : Int {
        switch self {
        case .Year:
            return 100
        case .Month:
            return 12
        case .Week:
            return 52
        case .Day:
            return 7
        case .Hour:
            return 24
        case .Minute:
            return 60
        case .Second:
            return 60
        default:
            return -1
        }
    }
    
    ///Returns the number of rows for the `Component`
    public var rowCount : Int {
        switch self {
        case let .Year(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Month(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Week(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Day(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Hour(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Minute(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        case let .Second(rows) where rows != nil:
            return (rows! > 100) ? 100 : rows!
        default:
            return self.defaultRowCount
        }
    }
    
    /// Return an `Int` value for each `Component` type so `Component` can conform to `Hashable`. Ordered from largest time interval to smallest, must stay in this order.
    private func toInt() -> Int {
        switch self {
        case .None:
            return -1
        case .Year:
            return 0
        case .Month:
            return 1
        case .Week:
            return 2
        case .Day:
            return 3
        case .Hour:
            return 4
        case .Minute:
            return 5
        case .Second:
            return 6
        }
        
    }
    
}

/// Overide equality operator so Components Enum conforms to Hashable
public func == (lhs: Components, rhs: Components) -> Bool {
    return lhs.toInt() == rhs.toInt()
}

/// A class to display: Hour, Minute, Second, Year, Month, Week, and Day durations in a `UIPicker`.
public class LETimeIntervalPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Public API
    
        public var timeInterval: NSTimeInterval {
        get {
            var numberOne = 0
            var numberTwo = 0
            var numberThree = 0
            
            switch self.numberOfComponents {
                
            case 1:
                
                numberOne = self.convertComponentsDurationToSeconds(0)
                return NSTimeInterval(numberOne)
                
            case 2:
                
                numberOne = self.convertComponentsDurationToSeconds(0)
                numberTwo = self.convertComponentsDurationToSeconds(1)
                return NSTimeInterval(numberOne + numberTwo)
                
            case 3:
                
                numberOne = self.convertComponentsDurationToSeconds(0)
                numberTwo = self.convertComponentsDurationToSeconds(1)
                numberThree = self.convertComponentsDurationToSeconds(2)
                return NSTimeInterval(numberOne + numberTwo + numberThree)
                
                
            default:
                return 0
            }
        }
        set {
            setPickerToTimeInterval(newValue, animated: false)
        }
    }
    
    
    public var timeIntervalAsComponentTypes: (valueOne: String, valueTwo: String, valueThree: String) {
        get {
            return self.getTimeIntervalAsComponentTypes()
        }
        
        set {
            self.setPickerComponentsToValues(newValue.valueOne.toInt()!, componentTwoValue: newValue.valueTwo.toInt()!, componentThreeValue: newValue.valueThree.toInt()!, animated: false)
        }
    }
    
    /**
    Returns the pickes selected components in the ISO8601 format
    */
    public var timeIntervalAsISO8601: String? {
        get {
            return self.getTimeIntervalInISO8601()
        }
    }
    
    public func setTimeIntervalAnimated(interval: NSTimeInterval) {
        setPickerToTimeInterval(interval, animated: true)
    }
    
    public func setPickerComponentsToValuesAnimated(componentOneValue: String?, componentTwoValue: String?,
        componentThreeValue: String?) {
            
            self.setPickerComponentsToValues(componentOneValue?.toInt(), componentTwoValue: componentTwoValue?.toInt(), componentThreeValue: componentThreeValue?.toInt(), animated: true)
    }
    
    /**
    Note that setting a font that makes the picker wider than this view can cause layout problems
    */
    public var font = UIFont.systemFontOfSize(17) {
        didSet {
            self.updateLabels()
            self.calculateNumberWidth()
            self.calculateTotalPickerWidth()
            self.pickerView.reloadAllComponents()
        }
    }
    
    // MARK: - UI Components
    
    private let pickerView = UIPickerView()
    
    private let labelOne = UILabel()
    private let labelTwo = UILabel()
    private let labelThree = UILabel()
    
    /// Component type for column one/left (defaults to hour). **Must specify .None to make hidden**.
    public var componentOne: Components = .None
    /// Component type for column two/middle (defaults to minute). **Must specify .None to make hidden**.
    public var componentTwo: Components = .None
    /// Component type for column three/right (defaults to second). **Must specify .None to make hidden**.
    public var componentThree: Components = .None
    
    /// The array that holds the `.Components`. Ignores `.None Compnents` type.
    private var componentsArray: [Components]?
    
    // MARK: - Initialization
    
    required public init(coder aDecoder: NSCoder) {
        self.componentOne = .Hour(24)
        self.componentTwo = .Minute(60)
        self.componentThree = .Second(60)
        super.init(coder: aDecoder)
        self.setup()
        
    }
    
    override public init(frame: CGRect) {
        self.componentOne = .Hour(24)
        self.componentTwo = .Minute(60)
        self.componentThree = .Second(60)
        super.init(frame: frame)
        self.setup()
    }
    
    convenience public init(componentOne: Components) {
        
        self.init()
        self.componentOne = componentOne
        self.componentTwo = .None
        self.componentThree = .None
        self.setup()
    }
    
    convenience public init(componentOne: Components, componentTwo: Components) {
        
        self.init()
        self.componentOne = componentOne
        self.componentTwo = componentTwo
        self.componentThree = .None
        self.setup()
    }
    
    //Use this init() to define a custom component type for each picker column
    
    convenience public init(componentOne: Components, componentTwo: Components,
        componentThree: Components) {
            
            self.init()
            self.componentOne = componentOne
            self.componentTwo = componentTwo
            self.componentThree = componentThree
            self.setup()
    }
    
    public func setup() {
        self.createValidComponentsArray()
        self.setupLocalizations()
        self.setupLabels()
        self.calculateNumberWidth()
        self.calculateTotalPickerWidth()
        self.setupPickerView()
    }
    
    private func setupLabels() {
        
        if let safeComponents = self.componentsArray {
            
            switch safeComponents.count {
                
            case 1:
                self.labelOne.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelOne.text = self.getLabelTextForComponent(safeComponents[0])
                self.addSubview(self.labelOne)
                break
                
            case 2:
                self.labelOne.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelTwo.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelOne.text = self.getLabelTextForComponent(safeComponents[0])
                self.addSubview(self.labelOne)
                self.labelTwo.text = self.getLabelTextForComponent(safeComponents[1])
                self.addSubview(self.labelTwo)
                break
                
            case 3:
                self.labelOne.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelTwo.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelThree.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.labelOne.text = self.getLabelTextForComponent(safeComponents[0])
                self.addSubview(self.labelOne)
                self.labelTwo.text = self.getLabelTextForComponent(safeComponents[1])
                self.addSubview(self.labelTwo)
                self.labelThree.text = self.getLabelTextForComponent(safeComponents[2])
                self.addSubview(self.labelThree)
                break
                
            default:
                break
            }
            
            self.updateLabels()
        }
        
    }
    
    private func updateLabels() {
        self.labelOne.font = self.font
        self.labelOne.sizeToFit()
        self.labelTwo.font = self.font
        self.labelTwo.sizeToFit()
        self.labelThree.font = self.font
        self.labelThree.sizeToFit()
    }
    
    private func calculateNumberWidth() {
        let label = UILabel()
        label.font = font
        self.numberWidth = 0
        for i in 0...59 {
            label.text = "\(i)"
            label.sizeToFit()
            if label.frame.width > self.numberWidth {
                self.numberWidth = label.frame.width
            }
        }
    }
    
    func calculateTotalPickerWidth() {
        // Used to position labels
        
        self.totalPickerWidth = 0
        self.totalPickerWidth += self.labelOne.bounds.width
        self.totalPickerWidth += self.labelTwo.bounds.width
        self.totalPickerWidth += self.labelThree.bounds.width
        self.totalPickerWidth += self.standardComponentSpacing * 2
        self.totalPickerWidth += self.extraComponentSpacing * 3
        self.totalPickerWidth += self.labelSpacing * 3
        self.totalPickerWidth += self.numberWidth * 3
    }
    
    func setupPickerView() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(pickerView)
        
        // Size picker view to fit self
        let top = NSLayoutConstraint(item: self.pickerView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Top,
            multiplier: 1,
            constant: 0)
        
        let bottom = NSLayoutConstraint(item: self.pickerView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0)
        
        let leading = NSLayoutConstraint(item: self.pickerView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Leading,
            multiplier: 1,
            constant: 0)
        
        let trailing = NSLayoutConstraint(item: self.pickerView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0)
        
        self.addConstraints([top, bottom, leading, trailing])
    }
    
    // MARK: - Layout
    
    
    private var totalPickerWidth: CGFloat = 0
    /// Width of UILabel displaying a two digit number with standard font
    private var numberWidth: CGFloat = 20
    /// A UIPickerView has a 5 point space between components
    private let standardComponentSpacing: CGFloat = 5
    /// Add an additional 10 points between the components
    private let extraComponentSpacing: CGFloat = 10
    /// Spacing between picker numbers and labels
    private let labelSpacing: CGFloat = 5
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Reposition labels
        
        switch (self.numberOfComponents) {
        case 1:
            
            self.labelTwo.hidden = true
            self.labelThree.hidden = true
            
            self.addConstraint(NSLayoutConstraint(item: self.labelOne, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint(item: self.labelOne, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: self.extraComponentSpacing))
            
            break
            
        case 2:
            
            self.labelThree.hidden = true
            
            let views: [String : UIView] = ["labelOne" : self.labelOne, "labelTwo" : self.labelTwo]
            
            let labelOneWidth = self.widthOfLabelWithText(self.getPluralTextForPickerComponentPosition(0))
            let labelTwoWidth = self.widthOfLabelWithText(self.getPluralTextForPickerComponentPosition(1))
            
            let pickerMinX = CGRectGetMidX(bounds) - self.totalPickerWidth / 3
            let space = self.standardComponentSpacing + self.extraComponentSpacing + self.numberWidth + self.labelSpacing
            
            let one = pickerMinX + self.numberWidth + self.extraComponentSpacing
            let two = labelOneWidth + space
            
            let metrics: [String : CGFloat] = [
                "componentOneWidth" : one,
                "componentTwoWidth" : two,
                "labelSpacing" : self.labelSpacing,
                "numberWidth" : self.numberWidth,
                "labelAndNumber" : (self.labelSpacing + self.numberWidth),
                "space" : space,
                "labelOneWidth" : labelOneWidth,
                "labelTwoWidth" : labelTwoWidth]
            
            self.addConstraint(NSLayoutConstraint(item: self.labelOne, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint(item: self.labelTwo, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            
            let vflString = "H:|-componentOneWidth-[labelOne(==labelOneWidth@1000)]-space-[labelTwo(==labelTwoWidth@1000)]"
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vflString, options: NSLayoutFormatOptions(0), metrics: metrics, views: views ))
            
            break
            
        case 3:
            
            let views: [String : UIView] = ["labelOne" : self.labelOne, "labelTwo" : self.labelTwo, "labelThree" : self.labelThree]
            
            let labelOneWidth = self.widthOfLabelWithText(self.getPluralTextForPickerComponentPosition(0))
            let labelTwoWidth = self.widthOfLabelWithText(self.getPluralTextForPickerComponentPosition(1))
            let labelThreeWidth = self.widthOfLabelWithText(self.getPluralTextForPickerComponentPosition(2))
            
            let pickerMinX = CGRectGetMidX(bounds) - self.totalPickerWidth / 2
            let space = self.standardComponentSpacing + self.extraComponentSpacing + self.numberWidth + self.labelSpacing
            
            let one = pickerMinX + self.numberWidth + self.labelSpacing
            let two = labelOneWidth + space
            let three = labelTwoWidth + space
            
            let metrics: [String : CGFloat] = [
                "componentOneWidth" : one,
                "componentTwoWidth" : two,
                "componentThreeWidth" : three,
                "labelSpacing" : self.labelSpacing,
                "numberWidth" : self.numberWidth,
                "labelAndNumber" : (self.labelSpacing + self.numberWidth),
                "space" : space,
                "labelOneWidth" : labelOneWidth,
                "labelTwoWidth" : labelTwoWidth,
                "labelThreeWidth" : labelThreeWidth]
            
            self.addConstraint(NSLayoutConstraint(item: self.labelOne, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint(item: self.labelTwo, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint(item: self.labelThree, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            
            
            let vflString = "H:|-componentOneWidth-[labelOne(==labelOneWidth@1000)]-space-[labelTwo(==labelTwoWidth@1000)]-space-[labelThree(==labelThreeWidth@1000)]"
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vflString, options: NSLayoutFormatOptions(0), metrics: metrics, views: views ))

            break
            
        default:
            println("Unhandled numberOfComponents (\(self.numberOfComponents)) in 'layoutSubviews()'")
            break
        }
        
    }
    
    // MARK: - Picker view data source
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return self.numberOfComponents
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.getComponentForPickerComponentPosition(component).rowCount
    }
    
    // MARK: - Picker view delegate
    
    public func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let labelWidth, compWidth: CGFloat
        
        switch (component) {
        case 0:
            labelWidth = self.labelOne.bounds.width
        case 1:
            labelWidth = self.labelTwo.bounds.width
        case 2:
            labelWidth = self.labelThree.bounds.width
        default:
            return 0.0
        }

         return (self.numberWidth + labelWidth + self.labelSpacing + self.extraComponentSpacing)

    }
    
    public func pickerView(pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusingView view: UIView!) -> UIView {
            
            // Check if view can be reused
            var newView = view
            
            if newView == nil {
                // Create new view
                let size = pickerView.rowSizeForComponent(component)
                newView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
                // Setup label and add as subview
                let label = UILabel()
                label.font = self.font
                label.textAlignment = .Left
                label.adjustsFontSizeToFitWidth = false
                label.frame.size = CGSize(width: self.numberWidth, height: size.height)
                newView.addSubview(label)
            }
            
            let label = newView.subviews.first as! UILabel
            label.text = "\(row)"
            
            return newView
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 1 {
            // Change label to singular
            
            switch (component) {
            case 0:
                self.labelOne.text = self.getSingularTextForPickerComponentPosition(component)
            case 1:
                self.labelTwo.text = self.getSingularTextForPickerComponentPosition(component)
            case 2:
                self.labelThree.text = self.getSingularTextForPickerComponentPosition(component)
            default:
                break
            }
            
        } else {
            // Change label to plural
            
            switch (component) {
            case 0:
                self.labelOne.text = self.getPluralTextForPickerComponentPosition(component)
            case 1:
                self.labelTwo.text = self.getPluralTextForPickerComponentPosition(component)
            case 2:
                self.labelThree.text = self.getPluralTextForPickerComponentPosition(component)
            default:
                break
            }
            
        }
        
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    // MARK: - Helpers
    
    private var numberOfComponents: Int {
        if let safeCount = self.componentsArray?.count {
            return safeCount
        }
        return 0
    }
    
    private func getComponentForPickerComponentPosition(componentPostiion: Int) -> Components {
        
        switch (componentPostiion) {
        case 0:
            return self.componentsArray![0]
        case 1:
            return self.componentsArray![1]
        case 2:
            return self.componentsArray![2]
        default:
            return .None
        }
        
    }
    
    private func createValidComponentsArray() {
        self.componentsArray = [Components]()
        
        if self.componentOne != .None {
            self.componentsArray?.append(self.componentOne)
        }
        
        if self.componentTwo != .None {
            self.componentsArray?.append(self.componentTwo)
        }
        
        if self.componentThree != .None {
            self.componentsArray?.append(self.componentThree)
        }
        
    }
    
    private func getPluralTextForPickerComponentPosition(componentPosition: Int) -> String {
        
        switch self.getComponentForPickerComponentPosition(componentPosition) {
        case .Hour:
            return self.hoursString
        case .Minute:
            return self.minutesString
        case .Second:
            return self.secondsString
        case .Year:
            return self.yearsString
        case .Month:
            return self.monthsString
        case .Week:
            return self.weeksString
        case .Day:
            return self.daysString
        case .None:
            return ""
        }
        
    }
    
    private func getSingularTextForPickerComponentPosition(componentPosition: Int) -> String {
        
        switch self.getComponentForPickerComponentPosition(componentPosition)  {
        case .Hour:
            return self.hourString
        case .Minute:
            return self.minuteString
        case .Second:
            return self.secondString
        case .Year:
            return self.yearString
        case .Month:
            return self.monthString
        case .Week:
            return self.weekString
        case .Day:
            return self.dayString
        case .None:
            return ""
        }
        
    }
    
    private func convertComponentsDurationToSeconds(componentsPosition: Int) -> Int {
        
        switch self.getComponentForPickerComponentPosition(componentsPosition)  {
            // Convert everything to seconds.
        case .Hour:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 60 * 60)
        case .Minute:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 60)
        case .Second:
            return (self.pickerView.selectedRowInComponent(componentsPosition))
        case .Year:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 365 * 24 * 60 * 60)
        case .Month:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 30 * 24 * 60 * 60)
        case .Week:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 7 * 24 * 60 * 60)
        case .Day:
            return (self.pickerView.selectedRowInComponent(componentsPosition) * 24 * 60 * 60)
        default:
            return 0
        }
        
    }
    
    private func getLabelTextForComponent(component: Components) -> String? {
        switch component {
        case .Hour:
            return self.hoursString
        case .Minute:
            return self.minutesString
        case .Second:
            return self.secondsString
        case .Year:
            return self.yearsString
        case .Month:
            return self.monthsString
        case .Week:
            return self.weeksString
        case .Day:
            return self.daysString
        case .None:
            return nil
        }
    }
    
    private func setPickerToTimeInterval(interval: NSTimeInterval, animated: Bool) {
        
        let time = self.secondsToHoursMinutesSeconds(Int(interval))
        
        switch self.numberOfComponents {
        case 1:
            self.pickerView.selectRow(time.hours, inComponent: 0, animated: animated)
            self.pickerView(self.pickerView, didSelectRow: time.hours, inComponent: 0)
            break
        case 2:
            self.pickerView.selectRow(time.hours, inComponent: 0, animated: animated)
            self.pickerView.selectRow(time.minutes, inComponent: 1, animated: animated)
            self.pickerView(self.pickerView, didSelectRow: time.hours, inComponent: 0)
            self.pickerView(self.pickerView, didSelectRow: time.minutes, inComponent: 1)
            break
        case 3:
            self.pickerView.selectRow(time.hours, inComponent: 0, animated: animated)
            self.pickerView.selectRow(time.minutes, inComponent: 1, animated: animated)
            self.pickerView.selectRow(time.seconds, inComponent: 2, animated: animated)
            self.pickerView(self.pickerView, didSelectRow: time.hours, inComponent: 0)
            self.pickerView(self.pickerView, didSelectRow: time.minutes, inComponent: 1)
            self.pickerView(self.pickerView, didSelectRow: time.seconds, inComponent: 2)
            break
        default:
            break
        }
    }
    
    private func setPickerComponentsToValues(componentOneValue: Int?, componentTwoValue: Int?,
        componentThreeValue: Int?, animated: Bool) {
            
            
            switch self.numberOfComponents {
            case 1:
                self.pickerView.selectRow(componentOneValue!, inComponent: 0, animated: animated)
                self.pickerView(self.pickerView, didSelectRow: componentOneValue!, inComponent: 0)
                break
            case 2:
                self.pickerView.selectRow(componentOneValue!, inComponent: 0, animated: animated)
                self.pickerView.selectRow(componentTwoValue!, inComponent: 1, animated: animated)
                self.pickerView(self.pickerView, didSelectRow: componentOneValue!, inComponent: 1)
                break
            case 3:
                self.pickerView.selectRow(componentOneValue!, inComponent: 0, animated: animated)
                self.pickerView.selectRow(componentTwoValue!, inComponent: 1, animated: animated)
                self.pickerView.selectRow(componentThreeValue!, inComponent: 2, animated: animated)
                self.pickerView(self.pickerView, didSelectRow: componentOneValue!, inComponent: 0)
                self.pickerView(self.pickerView, didSelectRow: componentTwoValue!, inComponent: 1)
                self.pickerView(self.pickerView, didSelectRow: componentThreeValue!, inComponent: 2)
                break
            default:
                break
            }
    }
    
    private func secondsToHoursMinutesSeconds(seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func getTimeIntervalAsComponentTypes() ->
        (valueOne: String, valueTwo: String, valueThree: String) {
            
            var numberOne: String!
            var numberTwo: String!
            var numberThree: String!
            
            switch self.numberOfComponents {
                
            case 1:
                numberOne = self.getComponentValueWithTypeAbbreviation(0)
                return (valueOne: numberOne, valueTwo: "", valueThree: "")
            case 2:
                numberOne = self.getComponentValueWithTypeAbbreviation(0)
                numberTwo = self.getComponentValueWithTypeAbbreviation(1)
                return (valueOne: numberOne, valueTwo: numberTwo, valueThree: "")
            case 3:
                numberOne = self.getComponentValueWithTypeAbbreviation(0)
                numberTwo = self.getComponentValueWithTypeAbbreviation(1)
                numberThree = self.getComponentValueWithTypeAbbreviation(2)
                return (valueOne: numberOne, valueTwo: numberTwo, valueThree: numberThree)
            default:
                return ("","","")
            }
    }
    
    private func getTimeIntervalInISO8601() -> String? {
        
        var isoFormatString: String?
        
        if var safeArray = self.componentsArray {
            
            // Sort array in descending order.
            let sortedComponents = sorted(safeArray){ $0.hashValue < $1.hashValue }
            
            for (index, comp) in enumerate(sortedComponents) {
                
                // get the corresponting index so we know which component to look in.
                let correspondingIndex = find(safeArray, comp)
                
                // if the corresponding index in nil, or if the corresopnding component row is zero then continue.
                if correspondingIndex == nil || self.pickerView.selectedRowInComponent(correspondingIndex!) == 0 {
                    continue
                }
                
                // Want to make sure there is only one 'P' and it's at the beginning of the string.
                if isoFormatString == nil || isEmpty(isoFormatString!) {
                    isoFormatString = "P"
                }
                
                switch comp {
                    
                case .Hour, .Minute, .Second:
                    // if we are an Hour, Minute, Second component type then we need to make sure that there is a'T' before any of these component types are added to the string.
                    if !contains(isoFormatString!, "T") {
                        isoFormatString? += "T"
                    }
                    
                    isoFormatString? += self.getComponentValueWithTypeAbbreviation(correspondingIndex!)
                    
                    break
                    
                case .None:
                    //Shouldn't happen.
                    break
                    
                default:
                    
                    isoFormatString? += self.getComponentValueWithTypeAbbreviation(correspondingIndex!)
                    
                    break
                }
            }
        }
        
        return isoFormatString
    }
    
    /**
    Gets the displayed number value in the componenent, no formatting.
    
    */
    private func getComponentValue(componentPosition: Int) -> String {
        
        if self.pickerView.selectedRowInComponent(componentPosition) == 0 {
            return ""
        }
        
        switch self.getComponentForPickerComponentPosition(componentPosition) {
        case .Hour:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Minute:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Second:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Year:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Month:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Week:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        case .Day:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))"
        default:
            return ""
        }
    }
    
    private func getComponentValueWithTypeAbbreviation(componentPosition: Int) -> String {
        
        if self.pickerView.selectedRowInComponent(componentPosition) == 0 {
            return ""
        }
        
        switch self.getComponentForPickerComponentPosition(componentPosition) {
        case .Hour:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))H"
        case .Minute:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))M"
        case .Second:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))S"
        case .Year:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))Y"
        case .Month:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))M"
        case .Week:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))W"
        case .Day:
            return "\(self.pickerView.selectedRowInComponent(componentPosition))D"
        default:
            return ""
        }
    }
    
    
    ///Gets the width of the label with the desired text. Meant to be used with the plural text to stop the labels from shifting with going from plural to singular.
    private func widthOfLabelWithText(pluralText: String) -> CGFloat {
        
        let testLabel = UILabel()
        testLabel.text = pluralText
        testLabel.font = self.font
        testLabel.sizeToFit()
        return testLabel.frame.width
        
    }
    
    // MARK: - Localization
    
    private var hoursString     = "hours"
    private var hourString      = "hour"
    private var minutesString   = "minutes"
    private var minuteString    = "minute"
    private var secondsString   = "seconds"
    private var secondString    = "second"
    private var yearsString     = "years"
    private var yearString      = "year"
    private var monthsString    = "months"
    private var monthString     = "month"
    private var weeksString     = "weeks"
    private var weekString      = "week"
    private var daysString      = "days"
    private var dayString       = "day"
    
    private func setupLocalizations() {
        
        let bundle = NSBundle(forClass: LETimeIntervalPicker.self)
        let tableName = "LETimeIntervalPickerLocalizable"
        
        self.hoursString = NSLocalizedString("hours", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the hours component of the picker.")
        
        self.hourString = NSLocalizedString("hour", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the hours text.")
        
        self.minutesString = NSLocalizedString("minutes", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the minutes component of the picker.")
        
        self.minuteString = NSLocalizedString("minute", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the minutes text.")
        
        self.secondsString = NSLocalizedString("seconds", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the seconds component of the picker.")
        
        self.secondString = NSLocalizedString("second", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the seconds text.")
        
        self.yearsString = NSLocalizedString("years", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the years component of the picker.")
        
        self.yearString = NSLocalizedString("year", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the years text.")
        
        self.monthsString = NSLocalizedString("months", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the months component of the picker.")
        
        self.monthString = NSLocalizedString("month", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the months text.")
        
        self.weeksString = NSLocalizedString("weeks", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the weeks component of the picker.")
        
        self.weekString = NSLocalizedString("week", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the weeks text.")
        
        self.daysString = NSLocalizedString("days", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the days component of the picker.")
        
        self.dayString = NSLocalizedString("day", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the days text.")
    }

}




