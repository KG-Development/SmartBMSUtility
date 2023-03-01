//
//  loggingGraphController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 07.04.21.
//

import ScrollableGraphView
import SwiftCSV
import ActionSheetPicker_3_0
import LGButton

class loggingGraphController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var graph: ScrollableGraphView!
    
    static var filename: String?
    
    var data: CSV?
    var linePlot = LinePlot(identifier: "line")
    
    var referenceLines = ReferenceLines()
    
    var selectedGraph = "totalVoltage"
    
    var graphOptions = [(String, String)]()
    
    @IBOutlet weak var graphSelectionButton: LGButton!
    
    @IBOutlet weak var stepper: UIStepper!
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        data = loggingController.getLogData(uuid: listLogFilesController.uuid, filename: loggingGraphController.filename ?? "demo")
        
        
        graph.dataSource = self
        setupButtonArrays()
        updateColours()
        
        setupGraph(value: "totalVoltage")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
    }
    
    func setupButtonArrays() {
        if data == nil {
            return
        }
        for head in data!.header {
            switch head {
            case "timestampUTC":
                break
            case "totalVoltage":
                graphOptions.append(("Total voltage", head))
            case "chargingCurrentA":
                graphOptions.append(("Charging current", head))
            case "disChargingCurrentA":
                graphOptions.append(("Discharging current", head))
            case "remainingCapacityAh":
                graphOptions.append(("Remaining capacity (Ah)", head))
            case "socPercent":
                graphOptions.append(("State of charge", head))
            default:
                if head.hasPrefix("t") {
                    let number = parseNumber(value: head)
                    graphOptions.append(("Temperature \(number)", head))
                } else if head.hasPrefix("c") {
                    let number = parseNumber(value: head)
                    graphOptions.append(("Cellvoltage \(number)", head))
                }
            }
        }
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "line":
            let value = data?.namedColumns[selectedGraph]
            return Double(value?[pointIndex] ?? "0.0") ?? 0.0
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return ""
    }

    func numberOfPoints() -> Int {
        return data?.namedColumns[selectedGraph]?.count ?? 0
    }
    
    func getMinMax(header: String) -> (Double, Double) {
        var minimum = Double.infinity
        var maximum = 0.0
        
        if data != nil {
            if (data!.namedColumns[header]?.count ?? 0) > 0 {
                for i in 0...data!.namedColumns[header]!.count-1 {
                    let strValue = data!.namedColumns[header]![i]
                    let dblValue = Double(strValue) ?? 0.0
                    minimum = min(minimum, dblValue)
                    maximum = max(maximum, dblValue)
                }
            }
        }
//        print("getMinMax: \(minimum*0.95) \(maximum*1.05)")
        return (minimum*0.99, maximum*1.01)
    }
    
    @IBAction func didChangeZoom(_ sender: UIStepper) {
//        print(sender.value/4.0)
        let zoom = CGFloat(sender.value/4.0)
        graph.dataPointSpacing = zoom
        
        graph.contentOffset = calculateContentOffset(zoom: zoom, contentOffset: graph.contentOffset)
        graph.updateContentSize()
        graph.reload()
    }
    
    func calculateContentOffset(zoom: CGFloat, contentOffset: CGPoint) -> CGPoint {
        let result = CGPoint(x: contentOffset.x/zoom, y: 0)
        return result
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColours()
    }
    
    func updateColours() {
        if self.traitCollection.userInterfaceStyle == .dark {
        }
        else {
            
        }
        graph.backgroundFillColor = .systemBackground
        referenceLines.referenceLineColor = .label
        referenceLines.dataPointLabelColor = .label
        referenceLines.referenceLineLabelColor = .label
        linePlot.fillGradientStartColor = .systemOrange
        linePlot.fillGradientEndColor = UIColor(named: "accentColor") ?? .systemOrange
        graph.reload()
    }
    
    func setupGraph(value: String) {
        print("setupGraph: \(value)")
        selectedGraph = value
        let (min, max) = getMinMax(header: selectedGraph)
        print(min, max)
        graph.rangeMin = min
        graph.rangeMax = max
        
        graph.shouldAnimateOnStartup = false
        graph.dataPointSpacing = 4.0
        graph.leftmostPointPadding = 0
        graph.rightmostPointPadding = 0
        graph.topMargin = 50.0
        graph.bottomMargin = 20.0
        graph.shouldAdaptRange = false
        stepper.value = Double(graph.dataPointSpacing*4)
        linePlot.lineStyle = .smooth
        linePlot.shouldFill = true
        linePlot.fillType = .gradient
        linePlot.animationDuration = 0.15
//        linePlot2.lineStyle = .smooth
//        linePlot2.shouldFill = true
//        linePlot2.fillType = .gradient
//        linePlot2.animationDuration = 0.15
        graph.addPlot(plot: linePlot)
//        graph.addPlot(plot: linePlot2)
        referenceLines.referenceLineNumberOfDecimalPlaces = 2
        graph.addReferenceLines(referenceLines: referenceLines)
        graph.updateContentSize()
        graph.reload()
    }
    
    @IBAction func graphSelectorButton(_ sender: Any) {
        
        ActionSheetStringPicker.show(withTitle: "Select graph", rows: filter2DArray(array: graphOptions, index: 0), initialSelection: 0, doneBlock: { (picker, indexes, value) in
            let newval = value as? String
            if newval == nil {
                return
            }
            self.setupGraph(value: self.getHeaderForDescription(newval!))
            self.graphSelectionButton.titleString = newval!
            
        }, cancel: { (_) in
            return
        }, origin: sender)
    }
    
    func parseNumber(value: String) -> Int {
        let parsed = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let result = Int(parsed)
        return result ?? 0
    }
    
    func filter2DArray(array: [(String, String)], index: Int) -> [String] {
        var result = [String]()
        
        if index == 0 {
            for str in array {
                result.append(str.0)
            }
        }
        else if index == 1 {
            for str in array {
                result.append(str.1)
            }
        }
        return result
    }
    
    func getHeaderForDescription(_ description: String) -> String {
        for opt in graphOptions {
            if opt.0 == description {
                return opt.1
            }
        }
        return ""
    }
}
