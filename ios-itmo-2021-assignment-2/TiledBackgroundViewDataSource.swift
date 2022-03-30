//
//  TiledBackgroundViewDataSource.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 24.11.2021.
//

import Foundation

protocol TiledBackgroundViewDataSource: AnyObject {
    var viewport: Rect { get }
    func getCellFromPoint(at point: Point) -> Bool
    func setNewState(from state: TwoDimensionalCelluralAutomata.State)
    func setTitle(from title: String)
}
