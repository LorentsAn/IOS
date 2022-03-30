//
//  SelectedView1.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 10.12.2021.
//

import Foundation
import UIKit

extension MainScreenViewController1 {
    
    @objc func handleLongPres(sender: UILongPressGestureRecognizer) {
        if running % 2 == 1 {
            stopAndRun()
        }
        self.selectedView.removeFromSuperview()
        for view in self.selectedView.subviews {
            view.removeFromSuperview()
        }
        selectedView = UIView()
        self.setTitle(from: "Selection Mode")
        
        let location = sender.location(in: self.backroundView)
        let x = Int(location.x / 100) * 100
        let y = Int(location.y / 100) * 100

        selectedView.frame = CGRect(x: x + 3 , y: y + 3, width: 200, height: 200)
        selectedView.backgroundColor = getColor().withAlphaComponent(0.2)
        selectedView.layer.borderColor = getColor().withAlphaComponent(0.2).cgColor
            
            self.selectedView.layer.borderWidth = 3
            self.selectedView.layer.cornerRadius = 20
            
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.resizeSelectView(sender:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPres(sender:)))
        longTapGestureRecognizer.numberOfTouchesRequired = 1
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        
        backroundView.gestureRecognizers?.forEach(backroundView.removeGestureRecognizer(_:))
        selectedView.addGestureRecognizer(panRecognizer)
        backroundView.addSubview(self.selectedView)
        backroundView.addGestureRecognizer(tapGestureRecognizer)
        backroundView.addGestureRecognizer(longTapGestureRecognizer)
            sender.isEnabled = false
            var word = findImageWitgColor()
            let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveIntoLibrary))
            let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearSelectedField))
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelselection))

            save.tintColor = getColor()
            trash.tintColor = getColor()
            done.tintColor = getColor()
            
            
            navigationItems.leftBarButtonItem = done
            self.toolBar.items = [
                UIBarButtonItem.flexibleSpace(),
                makeButton(nameOfImage: word + "103-redo", selector: #selector(turnRightInPlane), constraintConstantForWidth: 20, constraintConstantForHeight: 25),
                UIBarButtonItem.flexibleSpace(),
                makeButton(nameOfImage: word + "102-undo", selector: #selector(turnLeftInPlane), constraintConstantForWidth: 20, constraintConstantForHeight: 25),
                UIBarButtonItem.flexibleSpace(),
                save,
                UIBarButtonItem.flexibleSpace(),
                makeButton(nameOfImage: word + "383-new-tab", selector: #selector(cutAndPaste), constraintConstantForWidth: 20, constraintConstantForHeight: 20),
                UIBarButtonItem.flexibleSpace(),
                trash,
                UIBarButtonItem.flexibleSpace()
            ]
        

    }
    
    
    func setupInsertMode(state: TwoDimensionalCelluralAutomata.State) {
        if running % 2 == 1 {
            stopAndRun()
        }
        if AutomataType == "TwoDimensionalCelluralAutomata" {
            self.insertState = state
        } else {
            self.insertElementaryState.viewport = state.viewport
            self.insertElementaryState.cells = state.cells
        }
        
        let location = CGPoint(x: 0, y: 0)
        var widthSelect = state.viewport.size.width * 100
        var heightSelect = state.viewport.size.height * 100
        self.selectedView = UIView(frame: CGRect(x: Int(location.x), y: Int(location.y), width: widthSelect, height: heightSelect))
        self.selectedView.backgroundColor = getColor().withAlphaComponent(0.2)
        self.selectedView.layer.borderColor = getColor().withAlphaComponent(0.15).cgColor
        
        self.selectedView.layer.borderWidth = 3
        self.selectedView.layer.cornerRadius = 20
        
        drawInnerCells()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.resizeInsertView(sender:)))
        self.selectedView.addGestureRecognizer(panRecognizer)
        self.backroundView.addSubview(self.selectedView)
        var word = findImageWitgColor()
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelselection))
        cancel.tintColor = getColor()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(insertInState))
        done.tintColor = getColor()
        
        navigationItems.leftBarButtonItem = cancel
        navigationItems.rightBarButtonItem = done
        
        self.toolBar.items = [
            UIBarButtonItem.flexibleSpace(),
            makeButton(nameOfImage: word + "103-redo", selector: #selector(turnRight), constraintConstantForWidth: 22, constraintConstantForHeight: 27),
            UIBarButtonItem.flexibleSpace(),

            makeButton(nameOfImage: word + "102-undo", selector: #selector(turnLeft), constraintConstantForWidth: 22, constraintConstantForHeight: 27),
            UIBarButtonItem.flexibleSpace(),
            
            makeButton(nameOfImage: word + "207-eye", selector: #selector(changeModeToOnlyLiveCell), constraintConstantForWidth: 22, constraintConstantForHeight: 27),
            UIBarButtonItem.flexibleSpace(),

            makeButton(nameOfImage: word + "210-eye-blocked", selector: #selector(changeModeToAllCell), constraintConstantForWidth: 22, constraintConstantForHeight: 27),
            UIBarButtonItem.flexibleSpace(),
        ]
    }
    
    public func drawInnerCells() {
        for y in insertState.viewport.verticalIndices {
            for x in insertState.viewport.horizontalIndices {
                if insertState[Point(x: x, y: y)] == .active {
                    var path = UIBezierPath()
                    let posX = x - insertState.viewport.origin.x
                    let posY = y - insertState.viewport.origin.y
                    if shapeOfCell == "Circles" {
                        path = UIBezierPath(arcCenter: CGPoint(x: posX * 100 + 50, y: posY * 100 + 50), radius: 50, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
                    } else {
                        path = UIBezierPath(roundedRect: CGRect(x: posX * 100, y: posY * 100, width: 100, height: 100), cornerRadius: 0)
                    }

                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.fillColor = getColor().withAlphaComponent(0.5).cgColor
                    self.selectedView.layer.addSublayer(shapeLayer)
                }
            }
        }
    }
    
    @objc func resizeInsertView(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let pos = sender.location(in: self.backroundView)
            self.started.x = pos.x
            self.started.y = pos.y
        } else if sender.state != .cancelled {
            let location = sender.location(in: self.backroundView)
            let vector = CGPoint(x: location.x - started.x, y: location.y - started.y)
            self.selectedView.frame.origin.x += vector.x
            self.selectedView.frame.origin.y += vector.y
            
            self.selectedView.frame = CGRect(
                x: selectedView.frame.origin.x,
                y: selectedView.frame.origin.y,
                width: selectedView.frame.width,
                height: selectedView.frame.height)
            
            self.started = location
            self.backroundView.subviews[0].frame = CGRect(
                x: self.selectedView.frame.origin.x,
                y: self.selectedView.frame.origin.y,
                width: selectedView.frame.width,
                height: selectedView.frame.height)
            self.selectedView.setNeedsDisplay()
        }
    }
    
    @objc func insertInState() {
        let rect = self.selectedView.frame
        let originX = Int((rect.origin.x / 100).rounded())
        let originY = Int((rect.origin.y / 100).rounded())
        let width = Int((Float(selectedView.frame.width) / 100).rounded())
        let height = Int((Float(selectedView.frame.height) / 100).rounded())
    
        var count = 0
        let isTDCA = AutomataType == "TwoDimensionalCelluralAutomata"
        
        for j in originY ..< originY + height {
            for i in originX ..< originX + width {
                let isInactive = isTDCA ? (insertState.cells[count] == .inactive) : (insertElementaryState.cells[count] == .inactive)
                let isActive = isTDCA ? (self.insertState.cells[count] == .active) : (insertElementaryState.cells[count] == .active)
                
                var activity: BinaryCell? = nil
                
                if isInactive && insertMode == 0 {
                    activity = .inactive
                } else if isActive {
                    activity = .active
                }
                if isTDCA && activity != nil {
                    mainState[Point(x: i, y: j)] = activity!
                } else if activity != nil {
                    secondaryState[Point(x: i, y: j)] = activity!
                }
                count += 1
            }
        }
        self.drawState()
    }
    
    
    @objc func clearSelectedField() {
        var originX = Int((selectedView.frame.origin.x / 100).rounded())
        var originY = Int((selectedView.frame.origin.y / 100).rounded())
        let width = Int((Float(selectedView.frame.width) / 100).rounded())
        let height = Int((Float(selectedView.frame.height) / 100).rounded())
        
        var origin = AutomataType == "TwoDimensionalCelluralAutomata" ? mainState.viewport.origin : secondaryState.viewport.origin
        
        if mainState.viewport.origin.x < 0 {
            originX += origin.x
        }
        
        if mainState.viewport.origin.y < 0 {
            originY += origin.y
        }
                
        for j in originY ..< originY + height {
            for i in originX ..< originX + width {
                if AutomataType == "TwoDimensionalCelluralAutomata" {
                    mainState[Point(x: i, y: j)] = .inactive
                } else {
                    secondaryState[Point(x: i, y: j)] = .inactive
                }
            }
        }
        drawState()
    }
    
    @objc func resizeSelectView(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let pos = sender.location(in: self.backroundView)
            self.started.x = pos.x
            self.started.y = pos.y
            self.selectMode = isItCorner(x: self.started.x, y: self.started.y)
        }
        var location = sender.location(in: self.backroundView)
        if sender.state != .began && sender.state != .cancelled {
            var widthSelect: Int = Int(selectedView.frame.width)
            var heightSelect: Int = Int(selectedView.frame.height)
            var originOfSelect = selectedView.frame.origin
            if self.selectMode != "" {
                let vector = CGPoint(x: location.x - started.x, y: location.y - started.y)
                let vectorX = CGFloat(vector.x)
                let vectorY = CGFloat(vector.y)
                if selectMode == "UpperLeft" {
                    widthSelect += Int(-vectorX)
                    heightSelect += Int(-vectorY)
                    if widthSelect < 100 || heightSelect < 100 ||
                        originOfSelect.x + vectorX < -3 || originOfSelect.y + vectorY < -3 {
                        
                        widthSelect += Int(vectorX)
                        heightSelect += Int(vectorY)
                        
                    } else {
                        originOfSelect.x += vectorX
                        originOfSelect.y += vectorY
                    }
                } else if self.selectMode == "UpperRight" {
                    widthSelect += Int(vectorX)
                    heightSelect += Int(-vectorY)
                    if widthSelect < 100 || heightSelect < 100 || originOfSelect.y + vectorY < -3 {
                        widthSelect += Int(-vectorX)
                        heightSelect += Int(vectorY)
                    } else {
                        originOfSelect.x += 0
                        originOfSelect.y += vectorY
                    }
                } else if self.selectMode == "LowerLeft" {

                    widthSelect += Int(-vectorX)
                    heightSelect += Int(vectorY)
                    if widthSelect < 100 || heightSelect < 100 || originOfSelect.x + vectorX < -3 {
                        widthSelect += Int(vectorX)
                        heightSelect += Int(-vectorY)
                    } else {
                        originOfSelect.x += vectorX
                        originOfSelect.y += 0
                    }
                } else if selectMode == "LowerRight" {
                    widthSelect += Int(vectorX)
                    heightSelect += Int(vectorY)
                    if widthSelect < 100 || heightSelect < 100 {
                        widthSelect += Int(-vectorX)
                        heightSelect += Int(-vectorY)
                    } else {
                        originOfSelect.x += 0
                        originOfSelect.y += 0
                    }
                }
                originOfSelect.x = originOfSelect.x < 0 ? 0 : originOfSelect.x
                originOfSelect.y = originOfSelect.y < 0 ? 0 : originOfSelect.y
                if Int(widthSelect) + Int(originOfSelect.x) > Int(backroundWidth * 100) {
                    widthSelect = Int(backroundWidth * 100) - Int(originOfSelect.x)
                }
                if Int(heightSelect) + Int(originOfSelect.y) > Int(backroundHeight * 100) {
                    heightSelect = Int(backroundHeight * 100) - Int(originOfSelect.y)
                }
                
                self.selectedView.frame = CGRect(x: originOfSelect.x, y: originOfSelect.y, width: CGFloat(widthSelect), height: CGFloat(heightSelect))
                started = location
                self.backroundView.subviews[0].frame = CGRect(x: originOfSelect.x, y: originOfSelect.y, width: CGFloat(widthSelect), height: CGFloat(heightSelect))
                self.selectedView.setNeedsDisplay()

            } else {
                var widthSelect = selectedView.frame.width
                var heightSelect = selectedView.frame.height
                var originOfSelect = selectedView.frame.origin
                let location = sender.location(in: self.backroundView)
                let vector = CGPoint(x: location.x - started.x, y: location.y - started.y)
                
                originOfSelect.x += vector.x
                originOfSelect.y += vector.y
                self.selectedView.frame = CGRect(x: originOfSelect.x, y: originOfSelect.y, width: CGFloat(widthSelect), height: CGFloat(heightSelect))
                self.started = location
                self.backroundView.subviews[0].frame = CGRect(
                    x: originOfSelect.x,
                    y: originOfSelect.y,
                    width: CGFloat(widthSelect),
                    height: CGFloat(heightSelect))
                self.selectedView.setNeedsDisplay()
            }
        }
    }
    
    func isItCorner(x: CGFloat, y: CGFloat) -> String {
        var originOfSelect = selectedView.frame.origin
        var widthSelect = selectedView.frame.width
        var heightSelect = selectedView.frame.height
        if Float(originOfSelect.x) + 50 > Float(x) && Float(originOfSelect.y) + 50 > Float(y) {
            return "UpperLeft"
        } else if Float(originOfSelect.x) + Float(widthSelect) - 50 < Float(x) && Float(originOfSelect.y) + 50 > Float(y) {
            return "UpperRight"
        } else if Float(originOfSelect.x) + 50 > Float(x) && Float(originOfSelect.y) + Float(heightSelect) - 50 < Float(y) {
            return "LowerLeft"
        } else if Float(originOfSelect.x) + Float(widthSelect) - 50 < Float(x) && Float(originOfSelect.y) + Float(heightSelect) - 50 < Float(y) {
            return "LowerRight"
        } else {
            return ""
        }
    }
    
    @objc func turnRight() {
        var tmp = TwoDimensionalCelluralAutomata.State()
        for y in insertState.viewport.verticalIndices {
            for x in insertState.viewport.horizontalIndices {
                tmp[Point(x: insertState.viewport.size.height - y, y: x)] = insertState[Point(x: x, y: y)]
            }
        }
        turnView(st: tmp)
        self.selectedView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawInnerCells()

    }
    
    @objc func turnLeft() {
        var tmp = TwoDimensionalCelluralAutomata.State()
        for y in insertState.viewport.verticalIndices {
            for x in insertState.viewport.horizontalIndices {
                tmp[Point(x: y, y: insertState.viewport.size.width - x)] = insertState[Point(x: x, y: y)]
            }
        }
        turnView(st: tmp)
        self.selectedView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawInnerCells()

    }
    
    @objc func turnLeftInPlane() {
        let state = findState(rect: selectedView.frame)
        clearSelectedField()
        var tmp = TwoDimensionalCelluralAutomata.State()
        for y in state.viewport.verticalIndices {
            for x in state.viewport.horizontalIndices {
                tmp[Point(x: y, y: state.viewport.size.width - x)] = state[Point(x: x, y: y)]
            }
        }
        turnView(st: tmp)
        self.backroundView.subviews[0].frame = CGRect(x: selectedView.frame.origin.x, y: selectedView.frame.origin.y, width: selectedView.frame.width, height: selectedView.frame.height)
        self.insertState = tmp
        insertInState()
        selectedView.setNeedsDisplay()

    }
    
    @objc func turnRightInPlane() {
        let state = findState(rect: selectedView.frame)
        clearSelectedField()
        var tmp = TwoDimensionalCelluralAutomata.State()
        for y in state.viewport.verticalIndices {
            for x in state.viewport.horizontalIndices {
                tmp[Point(x: state.viewport.size.height - y, y: x)] = state[Point(x: x, y: y)]
            }
        }
        turnView(st: tmp)
        self.backroundView.subviews[0].frame = CGRect(x: selectedView.frame.origin.x, y: selectedView.frame.origin.y, width: selectedView.frame.width, height: selectedView.frame.height)
        self.insertState = tmp
        insertInState()
        selectedView.setNeedsDisplay()

    }
    
    func turnView(st: TwoDimensionalCelluralAutomata.State) {
        var widthSelect = st.viewport.size.width * 100
        var heightSelect = st.viewport.size.height * 100
        self.insertState = st
        self.selectedView.frame = CGRect(x: selectedView.frame.origin.x, y: selectedView.frame.origin.y, width: selectedView.frame.height, height: selectedView.frame.width)
        selectedView.setNeedsDisplay()
    }
    
    @objc func cutAndPaste() {
        let state = findState(rect: selectedView.frame)
        clearSelectedField()
        cancelselection()
        self.setState(from: state)
    }
    
    @objc func changeModeToOnlyLiveCell() {
        self.setTitle(from: "Insert only live cells")
        self.insertMode = 1
    }
    
    @objc func changeModeToAllCell() {
        self.setTitle(from: "Insert all cells")
        self.insertMode = 0
    }
    
    @objc func saveIntoLibrary() {
        var name = "Новый Элемент"
        let alert = UIAlertController(title: "Введите название элемента", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Введите название"})
        alert.addAction(UIAlertAction(title: "Ввод", style: .default, handler: {(_) in
            if alert.textFields![0].text != nil && String(alert.textFields![0].text!) != nil {
                name = String(alert.textFields![0].text!)
            }
            let stateToSave = self.findState(rect: self.selectedView.frame)
            self.library.saveNewState(state: stateToSave, name: name)
        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func cancelselection() {
        navigationItems.leftBarButtonItem = UIBarButtonItem()
        self.setTitle(from: "CelluralAutomata")
        navigationItems.rightBarButtonItem = setupMenu()
        self.toolBar.items = makeToolBarItems()
        self.selectedView.removeFromSuperview()
        for view in self.selectedView.subviews {
            view.removeFromSuperview()
        }
        backroundView.gestureRecognizers?.forEach(backroundView.removeGestureRecognizer(_:))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPres(sender:)))
        longTapGestureRecognizer.numberOfTouchesRequired = 1
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        backroundView.addGestureRecognizer(longTapGestureRecognizer)
        backroundView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func findState(rect: CGRect) -> TwoDimensionalCelluralAutomata.State {
        let originX = Int((selectedView.frame.origin.x / 100).rounded())
        let originY = Int((selectedView.frame.origin.y / 100).rounded())
        let width = Int((Float(selectedView.frame.width) / 100).rounded())
        let height = Int((Float(selectedView.frame.height) / 100).rounded())
        
        var returnState = TwoDimensionalCelluralAutomata.State()

        if AutomataType == "TwoDimensionalCelluralAutomata" {
            for j in originY ..< originY + height {
                for i in originX ..< originX + width {
                    returnState[Point(x: i, y: j)] = mainState[Point(x: i, y: j)]
                }
            }
        } else {
            for j in originY ..< originY + height {
                for i in originX ..< originX + width {
                    returnState[Point(x: i, y: j)] = secondaryState[Point(x: i, y: j)]
                }
            }
        }
        return returnState
        
    }
    
}
