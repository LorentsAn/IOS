//
//  LibraryView.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 12.12.2021.
//

import Foundation
import UIKit

class LibraryViewController: UIViewController {
    
    public weak var dataSource: LibraryDataSource?
    
    private var tableView: UITableView!
    
    var data = [String]()
    
    var storage = [TwoDimensionalCelluralAutomata.State]()
    
    var count = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.largeContentTitle = "Library"
        self.view.addSubview(tableView!)
        self.tableView.rowHeight = 140
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(LibraryCell.self, forCellReuseIdentifier: "cell")
        
        var state = TwoDimensionalCelluralAutomata.State()
        state[Point(x: 0, y: 1)] = .active
        state[Point(x: 1, y: 0)] = .active
        state[Point(x: 1, y: 1)] = .active
        state[Point(x: 2, y: 1)] = .active
        saveNewState(state: state, name: "Triangle")
        
        state = TwoDimensionalCelluralAutomata.State()
        state[Point(x: 1, y: 0)] = .active
        state[Point(x: 2, y: 0)] = .active
        state[Point(x: 3, y: 0)] = .active
        
        state[Point(x: 0, y: 1)] = .active
        state[Point(x: 4, y: 1)] = .active
        
        state[Point(x: 0, y: 2)] = .active
        state[Point(x: 4, y: 2)] = .active
        
        state[Point(x: 0, y: 3)] = .active
        state[Point(x: 4, y: 3)] = .active
        
        state[Point(x: 1, y: 4)] = .active
        state[Point(x: 2, y: 4)] = .active
        state[Point(x: 3, y: 4)] = .active
        saveNewState(state: state, name: "Circle")

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
}

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LibraryCell
        cell.title.text = "\(data[indexPath.row])"
        cell.title.font = UIFont.systemFont(ofSize: 19)
        let name = "\(data[indexPath.row])"
        var number = 0
        for item in data {
            if name == item {
                break
            }
            number += 1
        }
        let newState = storage[number]
        let size = max(newState.viewport.size.width, newState.viewport.size.height) * 100
        let square = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))

        let view = drawInnerCells(state: newState)
        view.frame = CGRect(x: square.center.x - view.frame.width / 2, y: square.center.y - view.frame.height / 2, width: view.frame.width, height: view.frame.height)
        square.addSubview(view)

        let renderer = UIGraphicsImageRenderer(size: square.bounds.size)
        let image = renderer.image { ctx in
            square.drawHierarchy(in: square.bounds, afterScreenUpdates: true)
        }
        cell.image.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var state = TwoDimensionalCelluralAutomata.State()

            let name = "\(data[indexPath.row])"
            var number = 0
            for item in data {
                if name == item {
                    break
                }
                number += 1
            }
            let newState = storage[number]
            for i in newState.viewport.origin.x ..< newState.viewport.origin.x + newState.viewport.size.width {
                for j in newState.viewport.origin.y ..< newState.viewport.origin.y + newState.viewport.size.height {
                    state[Point(x: i, y: j)] = newState[Point(x: i, y: j)]
                }
            }
        self.dataSource?.setState(from: state)
        self.dataSource?.setTitle(from: "\(data[indexPath.row])")
        navigationController?.popViewController(animated: true)
    }
    
    public func saveNewState(state: TwoDimensionalCelluralAutomata.State, name: String) {
        self.count += 1
        self.storage.append(state)
        self.data.append(name)
        if self.tableView == nil {
            self.tableView = UITableView()
        }
        self.tableView.reloadData()
    }
    
    func drawInnerCells(state: TwoDimensionalCelluralAutomata.State) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: state.viewport.size.width * 100, height: state.viewport.size.height * 100)
        for y in state.viewport.verticalIndices {
            for x in state.viewport.horizontalIndices {
                if state[Point(x: x, y: y)] == .active {
                    var path = UIBezierPath()
                    let posX = x - state.viewport.origin.x
                    let posY = y - state.viewport.origin.y
                    path = UIBezierPath(arcCenter: CGPoint(x: posX * 100 + 50, y: posY * 100 + 50), radius: 50, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.fillColor = UIColor.systemGray.cgColor
                    view.layer.addSublayer(shapeLayer)
                }
            }
        }
        return view
        
    }
    
    
}

class LibraryCell: UITableViewCell {
    
    var title: UILabel!
    var image: UIImageView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.title = UILabel()
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.title)
        
        self.image = UIImageView()
        self.image.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.image)
        
        NSLayoutConstraint.activate([
            self.image.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.image.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: -100),
            self.image.widthAnchor.constraint(equalToConstant: 110),
            self.image.heightAnchor.constraint(equalToConstant: 110),
            
            self.title.centerYAnchor.constraint(equalTo: self.image.centerYAnchor),
            self.title.leadingAnchor.constraint(equalTo: self.image.trailingAnchor, constant: 40)
        ])
    }
    
}
