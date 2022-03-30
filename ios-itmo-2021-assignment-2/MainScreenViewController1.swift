//
//  MainScreenViewController1.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 10.12.2021.
//

import Foundation
import UIKit

class MainScreenViewController1: UIViewController, TiledBackgroundViewDataSource, LibraryDataSource, SnapshotDataSource {

    var viewport: Rect { self.mainState.viewport }
    var rule: UInt8 = 90

    var mainState: TwoDimensionalCelluralAutomata.State = TwoDimensionalCelluralAutomata.State()
    var secondaryState: ElementaryAutomata.State = ElementaryAutomata.State()
    var elementaryAutomata: ElementaryAutomata = ElementaryAutomata(rule: 90)
    var twoDimentionAutomata: TwoDimensionalCelluralAutomata!
    var backroundView: TiledBackgroundView = TiledBackgroundView(frame: .zero)
    var backroundWidth = 20
    var backroundHeight = 20
    var backroundConstraint = [NSLayoutConstraint]()

    var navigationItems: UINavigationItem = UINavigationItem()
    var selectedView: UIView = UIView()
    
    var started: CGPoint = CGPoint(x: 0, y: 0)
    var selectMode: String!
    var insertState: TwoDimensionalCelluralAutomata.State = TwoDimensionalCelluralAutomata.State()
    var insertElementaryState: ElementaryAutomata.State = ElementaryAutomata.State()
    var insertMode: Int = 0 // 0 - all cells paste, 1 - only live cells paste

    var scrollView: UIScrollView = UIScrollView()
    var navbar: UINavigationBar!
    var toolBar: UIToolbar!
    var timer: Timer = Timer()
    var AutomataType: String = "TwoDimensionalCelluralAutomata"
    var library: LibraryViewController = LibraryViewController()
    var snapshots: SnapshotViewController = SnapshotViewController()
    var currentSpeed: UISlider = UISlider()
    
    var running: Int = 0
    var shapeOfCell: String = "Circles"
    var color: Color = .blue
    
    func setState(from state: TwoDimensionalCelluralAutomata.State) {
        setupInsertMode(state: state)
        self.setTitle(from: "Insert Mode")
        drawState()
    }

    func getCellFromPoint(at point: Point) -> Bool {
        if AutomataType == "TwoDimensionalCelluralAutomata" {
            return self.mainState[point] == .active
        } else {
            return secondaryState[point] == .active
        }
    }
    
    func getShapeOfCell() -> String {
        return shapeOfCell
    }
    
    func setNewState(from state: TwoDimensionalCelluralAutomata.State) {
        self.mainState = state
        self.drawState()
    }
    
    func setSecondaryState(from state: ElementaryAutomata.State) {
        self.secondaryState = state
        self.drawState()
    }
    
    func setTitle(from title: String) {
        self.navigationItems.title = title
    }
    
    func drawState() {
        let isTDCA = AutomataType == "TwoDimensionalCelluralAutomata"
        let verticalIndices = isTDCA ? mainState.viewport.verticalIndices: secondaryState.viewport.verticalIndices
        let horizontalIndices = isTDCA ? mainState.viewport.horizontalIndices: secondaryState.viewport.horizontalIndices
        
            for x in verticalIndices {
                for y in horizontalIndices {
                    let rect = CGRect(x: x * 100, y: y * 100, width: 100, height: 100)
                    self.backroundView.setNeedsDisplay(rect)
                }
            }
    }
    
    func setSnapshot(from state: TwoDimensionalCelluralAutomata.State) {
        snapshots.navigationController?.popViewController(animated: true)
        let isTDCA = AutomataType == "TwoDimensionalCelluralAutomata"
        if isTDCA {
            mainState = state
        } else {
            var tmp = ElementaryAutomata.State()
            for x in state.viewport.horizontalIndices {
                for y in state.viewport.verticalIndices {
                    tmp[Point(x: x, y: y)] = state[Point(x: x, y: y)]
                }
            }
            secondaryState = tmp
        }
        resizePlane(w: state.viewport.size.width, h: state.viewport.size.height)
        drawState()
    }
    
    
    func setColor(color: Color) {
        self.color = color
    }
    
    func getColor() -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            if color == .blue {
                return UIColor(named: "CustomBlue")!
            }; if color == .orange {
                return UIColor(named: "CustomOrange")!
            }; if color == .indigo {
                return UIColor(named: "CustomIndigo")!
            }
            return UIColor(named: "CustomPurple")!
        } else {
            return .black
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAutomata()
        self.setupScrollView()
        self.setTitle(from: "Cellural Automata")
        self.setupNavBar()
        self.setupToolBar()
        self.scrollView.addSubview(backroundView)
        setGestureRecognizer()
        setupSpeed()

        self.backroundConstraint = [
            self.backroundView.widthAnchor.constraint(equalToConstant:  2000),
            self.backroundView.heightAnchor.constraint(equalToConstant: 2000),
        ]
        
        NSLayoutConstraint.activate([
            self.navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            
            self.toolBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.toolBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.toolBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            
            
            self.scrollView.topAnchor.constraint(equalTo: self.navbar.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            self.backroundView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.backroundView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.backroundView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.backroundView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.backroundConstraint[0],
            self.backroundConstraint[1],
            
            currentSpeed.bottomAnchor.constraint(equalTo: toolBar.topAnchor, constant: -10),
            currentSpeed.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentSpeed.widthAnchor.constraint(equalToConstant: 200),
            currentSpeed.heightAnchor.constraint(equalToConstant: 35)
        ])


    }
}

extension MainScreenViewController1 {
    
    func setupAutomata() {
        self.view.backgroundColor = .systemBackground
        self.secondaryState[.zero] = .inactive
        self.mainState[Point(x: 0, y: 0)] = .inactive
        self.mainState[Point(x: self.backroundWidth - 1, y: self.backroundHeight - 1)] = .inactive
        self.twoDimentionAutomata = TwoDimensionalCelluralAutomata(rule: conwaysGame)
    }
    
    func setupScrollView() {
            self.view.addSubview(scrollView)
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.delegate = self
            self.scrollView.minimumZoomScale = 0.01
            self.scrollView.maximumZoomScale = 5.0
            self.scrollView.zoomScale = 0.3
    }
    
    func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPres(sender:)))
        longTapGestureRecognizer.numberOfTouchesRequired = 1
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        scrollView.addSubview(backroundView)
        backroundView.translatesAutoresizingMaskIntoConstraints = false
        backroundView.tiledLayer.tileSize = CGSize(width: 100, height: 100)
        backroundView.addGestureRecognizer(tapGestureRecognizer)
        backroundView.addGestureRecognizer(longTapGestureRecognizer)
        backroundView.dataSource = self
    }
    
    func setupNavBar() {
        self.navbar = UINavigationBar()
        self.navbar.translatesAutoresizingMaskIntoConstraints = false
    
        self.navbar.backgroundColor = .systemBackground
        self.navbar.tintColor = getColor()

        navigationItems.rightBarButtonItem = setupMenu()
        self.navbar.setItems([navigationItems], animated: true)
        self.view.addSubview(navbar)
    }
    
    func setupMenu() -> UIBarButtonItem {
        let submenuOfShape = UIMenu(title: "Форма клетки", options: .displayInline, children: [
            UIAction(title: "Круглая", state: shapeOfCell == "Circles" ? .on : .off , handler: changeShape(sender: )),
            UIAction(title: "Квадратная", state: shapeOfCell != "Circles" ? .on : .off , handler: changeShape(sender: ))]
        )
        let submenuOfLightMode = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Темная тема", state: traitCollection.userInterfaceStyle == .dark ? .on : .off, handler: DarkMode(sender: )),
            UIAction(title: "Светлая тема", state: traitCollection.userInterfaceStyle != .dark ? .on : .off, handler: LightMode(sender:)),]
        )
        let submenuOfColor = UIMenu(title: "Цвет выделения", options: .displayInline, children: [
            UIAction(title: "Голубой", state: color == .blue ? .on : .off, handler: changeBlue(sender: )),
            UIAction(title: "Розовый", state: color == .purple ? .on : .off, handler: changePurple(sender: )),
            UIAction(title: "Оранжевый", state: color == .orange ? .on : .off, handler: changeOrange(sender: )),
            UIAction(title: "Индиго", state: color == .indigo ? .on : .off, handler: changeIndigo(sender: )),
        ]
        )
        var children = [submenuOfShape, submenuOfLightMode]
        if traitCollection.userInterfaceStyle == .dark {
            children.append(submenuOfColor)
        }
        let navBarMenu = [
            UIMenu(title: "Выбрать автомат", children: [
                UIAction(title: "Элементарный автомат", handler: setElementary(sender: )),
                UIAction(title: "Двухмерный автомат", handler: setTwoDimensional(sender: )),
            ]),
            UIAction(title: "Изменить размер", handler: changeSize(sender: )),
            UIAction(title: "Очистить поле", handler: removePlane(sender: )),
            UIMenu(title: "Внешний вид", children: children),
        ]
        let menu = UIMenu(title: "", children: navBarMenu)
        let settings = UIBarButtonItem(title: "Cellural Automata", image: UIImage(named: "gear-_2_"), primaryAction: nil, menu: menu)
        settings.tintColor = getColor()
        return settings
    }
    
    func setupSpeed() {
        currentSpeed.frame = CGRect(x: 0, y: 0, width: 250, height: 35)
        currentSpeed.translatesAutoresizingMaskIntoConstraints = false
        currentSpeed.minimumTrackTintColor = getColor()
        currentSpeed.maximumTrackTintColor = getColor()
        currentSpeed.thumbTintColor = .systemGray

        currentSpeed.maximumValue = 10
        currentSpeed.minimumValue = 1
        currentSpeed.addTarget(self, action: #selector(changeVlaue(slider:)), for: .valueChanged)
        
        currentSpeed.setValue(5, animated: false)
        self.view.addSubview(currentSpeed)
//        currentSpeed.center.x = view.center.x
//        currentSpeed.center.y = toolBar.center.y - 40
        
        currentSpeed.isHidden = true
        
    }
    
    @objc func settings() -> UIMenu {
        let navBarMenu = [
            UIMenu(title: "Выбрать автомат", children: [
                UIAction(title: "Элементарный автомат", handler: setElementary(sender: )),
                UIAction(title: "Двумерный автомат", handler: setTwoDimensional(sender: )),
            ]),
            UIAction(title: "Изменить размер", handler: changeSize(sender: )),
            UIAction(title: "Очистить поле", handler: removePlane(sender: )),
        ]
        return UIMenu(title: "", children: navBarMenu)
    }
    
    func removePlane(sender: UIAction) {
        let alertViewController = UIAlertController(title: "Очистить поле?", message: nil, preferredStyle: .actionSheet)

        alertViewController.addAction(UIAlertAction(title: "Очистить", style: .destructive, handler: { (_) in
            self.removeField()
        }))
        alertViewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func changeSize(sender: UIAction) {
        let alert = UIAlertController(title: "Введите новые размеры поля", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Введите ширину"})
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Введите высоту"})
        alert.addAction(UIAlertAction(title: "Ввод", style: .default, handler: {(_) in
            if UInt8(alert.textFields![0].text!) != nil && UInt8(alert.textFields![1].text!) != nil {
                let width = Int(alert.textFields![0].text ?? "0") ?? 0
                let height = Int(alert.textFields![1].text ?? "0") ?? 0
                self.resizeArrayOfCells(width: width, height: height)
            }
        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setElementary(sender: UIAction) {
        self.AutomataType = "ElementaryAutomata"
        resizePlane(w: secondaryState.viewport.size.width, h: secondaryState.viewport.size.height)
        self.drawState()
        let editRule = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enterRule))
        editRule.tintColor = .darkGray
        navigationItems.leftBarButtonItem = editRule
    }
    
    func setTwoDimensional(sender: UIAction) {
        self.AutomataType = "TwoDimensionalCelluralAutomata"
        self.navigationItems.leftBarButtonItem = UIBarButtonItem()
        resizePlane(w: mainState.viewport.size.height, h: mainState.viewport.size.height)
    }
    
    func setupToolBar() {
        self.toolBar = UIToolbar()
        _ = [UIBarButtonItem]()
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.toolBar.barTintColor = .systemBackground

        self.toolBar.setItems(makeToolBarItems(), animated: true)

        self.view.addSubview(toolBar)
    }
    
    func makeButton(nameOfImage: String, selector: Selector, constraintConstantForWidth: CGFloat, constraintConstantForHeight: CGFloat) -> UIBarButtonItem {
        let doneItem = UIButton(type: .custom)
        doneItem.setImage(UIImage(named: nameOfImage), for: .normal)
        doneItem.addTarget(nil, action: selector, for: UIControl.Event.touchUpInside)
        let settingItem = UIBarButtonItem(customView: doneItem)
        settingItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        settingItem.customView?.widthAnchor.constraint(equalToConstant: constraintConstantForWidth).isActive = true
        settingItem.customView?.heightAnchor.constraint(equalToConstant: constraintConstantForHeight).isActive = true
        settingItem.tintColor = .systemGray
        return settingItem
    }
    
    func makeToolBarItems() -> [UIBarButtonItem] {
        let word = findImageWitgColor()
        
        let play = UIButton()
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopAndRun))
        var longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseSpeed(sender:)))
        longTapGestureRecognizer.numberOfTouchesRequired = 1
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        play.addGestureRecognizer(tapGesture)
        play.addGestureRecognizer(longTapGestureRecognizer)
        play.setImage(UIImage(systemName: "play"), for: .normal)
        play.tintColor = getColor()
        let playFinish = UIBarButtonItem(customView: play)
        
        let snapshotButton = UIButton()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(backOneGeneration))
        longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showSnapshotBoad(sender:)))
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        snapshotButton.addGestureRecognizer(tapGesture)
        snapshotButton.addGestureRecognizer(longTapGestureRecognizer)
        snapshotButton.setImage(UIImage(named: word + "arrow left direction"), for: .normal)
        let snapshotBarButton = UIBarButtonItem(customView: snapshotButton)
        snapshotBarButton.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        snapshotBarButton.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let ans = [
            makeButton(nameOfImage: word + "horizontal-dots", selector: #selector(showLibraryView(sender:)), constraintConstantForWidth: 30, constraintConstantForHeight: 7),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            snapshotBarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            playFinish,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            makeButton(nameOfImage: word + "arrow right direction", selector: #selector(oneGenerationAhead), constraintConstantForWidth: 24, constraintConstantForHeight: 24),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            makeButton(nameOfImage: word + "plus", selector: #selector(saveSnapshot), constraintConstantForWidth: 24, constraintConstantForHeight: 24)
        ]
        return ans
    }
    
    @objc func showSnapshotBoad(sender: UIAction) {
        if !snapshots.isBeingPresented {
            snapshots.modalPresentationStyle = .pageSheet
            snapshots.dataSource = self
            self.show(snapshots, sender: sender)
        }
    }
    
    @objc func chooseSpeed(sender: UILongPressGestureRecognizer) {
        stopAndRun()
        if currentSpeed.isHidden {
            currentSpeed.isHidden = false
        }
    }
    
    @objc func changeVlaue(slider: UISlider) {
        var cur = slider.value
        cur = 11 - cur
        let time = cur * 2 / 10
        setupAccurateTimer(time: Double(time))
    }
    
    @objc func oneGenerationAhead() {
        // действие активно когда симуляция на паузе
        if !(running % 2 == 1) {
            updateTimer()
        } else {
            let alert = UIAlertController(title: "Ой", message: "Нельзя перематывать пока работает автомат", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понял", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func saveSnapshot() {
        if AutomataType == "TwoDimensionalCelluralAutomata" {
            snapshots.saveNewState(state: mainState)
        } else {
            var st = TwoDimensionalCelluralAutomata.State()
            st.cells = secondaryState.cells
            st.viewport = secondaryState.viewport
            snapshots.saveNewState(state: st)
        }
        let notification = UIAlertController(title: "Снапшот сохранен", message: nil, preferredStyle: .alert)
        notification.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(notification, animated: true, completion: nil)
        snapshots.navigationController?.popViewController(animated: true)
    }

    
    @objc func showLibraryView(sender: UIBarButtonItem) {
        library.modalPresentationStyle = .pageSheet
        library.dataSource = self
        self.show(library, sender: sender)
    }
    
    @objc func stopAndRun() {
        running += 1
        // 1 - run, 2 - stop
        if !currentSpeed.isHidden {
            currentSpeed.isHidden = true
        }
        let play = UIButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopAndRun))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseSpeed(sender:)))
        longTapGestureRecognizer.numberOfTouchesRequired = 1
        longTapGestureRecognizer.minimumPressDuration = TimeInterval(1.0)
        
        play.addGestureRecognizer(tapGesture)
        play.addGestureRecognizer(longTapGestureRecognizer)
        
        play.tintColor = getColor()
        if (running % 2 == 1) {
            play.setImage(UIImage(systemName: "stop"), for: .normal)
            setupTimer()
            
        } else {
            play.setImage(UIImage(systemName: "play"), for: .normal)
            cancelTimer()
        }
        let playFinish = UIBarButtonItem(customView: play)
        toolBar.items?[4] = playFinish
    }
    
    func setupTimer() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTimer),
                                         userInfo: nil,
                                         repeats: true)
        self.timer.tolerance = 0.1
        RunLoop.current.add(self.timer, forMode: .common)
    }
    
    func setupAccurateTimer(time: Double) {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(time),
                                         target: self,
                                         selector: #selector(updateTimer),
                                         userInfo: nil,
                                         repeats: true)
        self.timer.tolerance = 0.1
        RunLoop.current.add(self.timer, forMode: .common)
    }
    
    func cancelTimer() {
        self.timer.invalidate()
    }
    
    @objc func updateTimer() {
        if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
            let newGeneration = try!twoDimentionAutomata.simulate(mainState, generations: 2)
            print(newGeneration.viewport.size.width, mainState.viewport.size.width)
            
            let oldW = mainState.viewport.size.width
            let oldH = mainState.viewport.size.height
            let newW = newGeneration.viewport.size.width
            let newH = newGeneration.viewport.size.height
            
            self.mainState = newGeneration
            
            if newGeneration.viewport.origin.x < 0 || newGeneration.viewport.origin.y < 0 {
                changeOrigin()
            }
            
            if (oldW != newW || oldH != newH) {
                resizePlane(w: newW, h: newH)
            }
        } else {
            let newGeneration = try!elementaryAutomata.simulate(secondaryState, generations: 1)
            
            let oldW = secondaryState.viewport.size.width
            let oldH = secondaryState.viewport.size.height
            let newW = newGeneration.viewport.size.width
            let newH = newGeneration.viewport.size.height
            
            self.secondaryState = newGeneration
            
            if newGeneration.viewport.origin.x < 0 || newGeneration.viewport.origin.y < 0 {
                changeOrigin()
            }
            
            if (oldW != newW || oldH != newH) {
                resizePlane(w: newW, h: newH)
            }
        }
        drawState()
    }
    
    func changeOrigin() {
        if AutomataType == "TwoDimensionalCelluralAutomata" {
            var state = TwoDimensionalCelluralAutomata.State()
            var deltaX = 0
            var deltaY = 0
            if mainState.viewport.origin.x < 0 {
                deltaX = -mainState.viewport.origin.x
            }
            if mainState.viewport.origin.y < 0 {
                deltaY = -mainState.viewport.origin.y
            }
            for y in mainState.viewport.verticalIndices {
                for x in mainState.viewport.horizontalIndices {
                    state[Point(x: x + deltaX, y: y + deltaY)] = mainState[Point(x: x, y: y)]
                }
            }
            self.mainState = state
        } else {
            var state = ElementaryAutomata.State()
            var deltaX = 0
            var deltaY = 0
            if secondaryState.viewport.origin.x < 0 {
                deltaX = -secondaryState.viewport.origin.x
            }
            if secondaryState.viewport.origin.y < 0 {
                deltaY = -secondaryState.viewport.origin.y
            }
            for y in secondaryState.viewport.verticalIndices {
                for x in secondaryState.viewport.horizontalIndices {
                    state[Point(x: x + deltaX, y: y + deltaY)] = secondaryState[Point(x: x, y: y)]
                }
            }
            self.secondaryState = state
        }
    }
    
    @objc func backOneGeneration() {
        if snapshots.storage.count == 0 {
            let dangerous = UIAlertController(title: "Нет сохраненных снепшотов", message: "Хотите вернутся к пустому полю?", preferredStyle: .alert)
            dangerous.addAction(UIAlertAction(title: "Вернуться к пустому полю", style: .destructive, handler: { _ in
                self.removeField()
                self.setNewState(from: self.mainState)
            }))
            dangerous.addAction(UIAlertAction(title: "Отменить", style: .default, handler: nil))
            present(dangerous, animated: true, completion: nil)
        } else {
            snapshots.dataSource = self
            snapshots.backOneGeneration()
        }
    }
    
    func resizePlane(w: Int, h: Int) {
        backroundView.removeConstraint(self.backroundConstraint[0])
        backroundView.removeConstraint(self.backroundConstraint[1])
        backroundConstraint[0] = self.backroundView.widthAnchor.constraint(equalToConstant:  CGFloat(w * 100))
        backroundConstraint[1] = self.backroundView.heightAnchor.constraint(equalToConstant: CGFloat(h * 100))
        self.backroundConstraint[0].isActive = true
        self.backroundConstraint[1].isActive = true
        backroundView.setNeedsDisplay()
    }
    
    
    @objc func singleTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: backroundView)
            let x = Int(location.x / 100)
            let y = Int(location.y / 100)
            
            if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
                let originX = mainState.viewport.origin.x
                let originY = mainState.viewport.origin.y
                
                if (originX <= x &&
                    x < mainState.viewport.size.width + originX &&
                    originY <= y &&
                    y < mainState.viewport.size.height + originY) {
                    
                    changeStateAndReturnNewState(x: x, y: y)
                    self.drawState()
                }
            } else {
                let originX = secondaryState.viewport.origin.x
                let originY = secondaryState.viewport.origin.y
                
                if (originX <= x &&
                    x < secondaryState.viewport.size.width + originX &&
                    originY <= y &&
                    y < secondaryState.viewport.size.height + originY) {
                    
                    changeStateAndReturnNewState(x: x, y: y)
                    self.drawState()
                }
            }
            
        }
    }
    
    public func changeStateAndReturnNewState(x: Int, y: Int)  {
        if AutomataType == "TwoDimensionalCelluralAutomata" {
            if (self.mainState[Point(x: Int(x), y: Int(y))] == .active) {
                self.mainState[Point(x: Int(x), y: Int(y))] = .inactive
            } else {
                self.mainState[Point(x: Int(x), y: Int(y))] = .active
            }
        } else {
            if (self.secondaryState[Point(x: Int(x), y: Int(y))] == .active) {
                self.secondaryState[Point(x: Int(x), y: Int(y))] = .inactive
            } else {
                self.secondaryState[Point(x: Int(x), y: Int(y))] = .active
            }
        }

    }
    
    func conwaysGame(_ neibor: [BinaryCell]) -> UInt {
        var count = 0
        for i in 0...8 {
            if (i != 4 && neibor[i].rawValue == 1) {
                count += 1
            }
        }
        if (count == 3 && neibor[4].rawValue == 0) {
            return 1
        }
        if (neibor[4].rawValue == 1 && (count == 2 || count == 3)) {
            return 1
        }

        return 0
    }
    
    public func resizeArrayOfCells(width: Int, height: Int) {
        var newState: TwoDimensionalCelluralAutomata.State!
        var ElementaryState: ElementaryAutomata.State!
        var originY = 0
        var originX = 0
        var oldWidth = 0
        var oldHeight = 0
        if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
            newState = TwoDimensionalCelluralAutomata.State()
            originX = self.mainState.viewport.origin.x
            originY = self.mainState.viewport.origin.y
            oldWidth = self.mainState.viewport.size.width
            oldHeight = self.mainState.viewport.size.height
        } else {
            ElementaryState = ElementaryAutomata.State()
            originX = self.secondaryState.viewport.origin.x
            originY = self.secondaryState.viewport.origin.y
            oldWidth = self.secondaryState.viewport.size.width
            oldHeight = self.secondaryState.viewport.size.height
        }
        for i in 0 ..< height {
            for j in 0 ..< width {
                
                if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
                    if (j >= oldWidth + originX || i >= oldHeight + originY) {
                            newState[Point(x: j, y: i)] = .inactive
                    } else {
                        newState[Point(x: j, y: i)] = self.mainState[Point(x: j, y: i)]
                    }
                } else {
                    if (j >= oldWidth + originX || i >= oldHeight + originY) {
                            ElementaryState[Point(x: j, y: i)] = .inactive
                    } else {
                        ElementaryState[Point(x: j, y: i)] = self.secondaryState[Point(x: j, y: i)]
                    }
                }

            }
        }
        if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
            self.mainState = newState
        } else {
            self.secondaryState = ElementaryState
        }
        
        resizePlane(w: width, h: height)
        drawState()
    }
    
    func findImageWitgColor() -> String{
        var word = ""
        if traitCollection.userInterfaceStyle == .dark {
            if color == .blue {
                word = "blue "
            } else if color == .orange {
                word = "orange "
            } else if color == .indigo {
                word = "indigo "
            } else {
                word = "purple "
            }
        }
        return word
    }
    
}

extension MainScreenViewController1: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        self.backroundView
    }
}

class TiledBackgroundView: UIView {
    let sideLength: CGFloat = 30
    public weak var dataSource: TiledBackgroundViewDataSource?
    
    override class var layerClass: AnyClass { CATiledLayer.self }
    
    var tiledLayer: CATiledLayer { layer as! CATiledLayer }
    
    override var contentScaleFactor: CGFloat {
        didSet { super.contentScaleFactor = 1 }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let dataSource = dataSource else { return }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBackground.cgColor)
        context?.fill(rect)
        if (dataSource.getCellFromPoint(at: Point(x: Int(rect.minX / 100), y: Int(rect.minY / 100)))) {
            context?.setFillColor(dataSource.getColor().withAlphaComponent(0.8).cgColor)
        } else {
            context?.setFillColor(UIColor.systemBackground.cgColor)
            context?.setLineWidth(5)
            context?.setStrokeColor(dataSource.getColor().withAlphaComponent(0.8).cgColor)
        }
        if dataSource.getShapeOfCell() == "Circles" {
            context?.strokeEllipse(in: rect.inset(by: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)))
            context?.fillEllipse(in: rect.inset(by: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)))
        } else {
            context?.setStrokeColor(dataSource.getColor().withAlphaComponent(0.8).cgColor)
            context?.stroke(rect.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 2)))
            context?.fill(rect.inset(by: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)))
        }

        
    }
}

