//
//  SnapshotViewController.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 30.12.2021.
//

import Foundation
import UIKit

class SnapshotViewController: UIViewController {
    
    public weak var dataSource: SnapshotDataSource?
    
    private var tableView: UITableView!
    
    var data = [String]()
    
    var storage = [TwoDimensionalCelluralAutomata.State]()
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = .white
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.largeContentTitle = "Library"
        self.view.addSubview(tableView!)
        self.tableView.rowHeight = 140
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(LibraryCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
}

extension SnapshotViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        navigationController?.popViewController(animated: true)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LibraryCell
        cell.title.text = "\(data[indexPath.row])"
        cell.title.font = UIFont.systemFont(ofSize: 19)
        var number = "\(data[indexPath.row])".components(separatedBy: " ")[1]
        let newState = storage[Int(number)!]
        let size = max(newState.viewport.size.width, newState.viewport.size.height) * 100
        let square = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.addTarget(nil, action: #selector(deleteSnapshot(sender:)), for: UIControl.Event.touchUpInside)
        deleteButton.tintColor = .systemRed
        deleteButton.frame = CGRect(x: cell.frame.minX + 10, y: cell.frame.minY + 10, width: 30, height: 30)
        cell.addSubview(deleteButton)
        
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
        let name = "\(data[indexPath.row])".components(separatedBy: " ")[1]
        let newState = storage[Int(name)!]

        self.dataSource?.setSnapshot(from: newState)
        navigationController?.popViewController(animated: true)
    }
    
    public func saveNewState(state: TwoDimensionalCelluralAutomata.State) {
        if self.tableView == nil {
            self.tableView = UITableView()
        }
        self.storage.append(state)
        self.data.append("Снапшот " + String(count))
        self.count += 1
        self.tableView.reloadData()
    }
    
    public func backOneGeneration() {
        let newState = storage.last!
        storage.removeLast()
        data.removeLast()
        count -= 1
        self.dataSource?.setSnapshot(from: newState)
        self.tableView.reloadData()

        //navigationController?.popViewController(animated: true)
        
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
    
    @objc func deleteSnapshot(sender: UITableViewCell) {
//        let num = Int(sender.frame.minX / 140)
        let num = Int(sender.frame.minX / 140)
        print(num)
        storage.remove(at: num)
        data.remove(at: num)
        var c = 0
        for _ in data {
            data[c] = "Снапшот " + String(c)
            c += 1
        }
        count -= 1
        let indexPath = IndexPath(row: num, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        navigationController?.popViewController(animated: true)
    }
    
    
}

class Snapshot: UITableViewCell {
    
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
