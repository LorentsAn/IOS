//
//  SnapshotDataSourse.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 30.12.2021.
//

import Foundation

protocol SnapshotDataSource: AnyObject {
    func setSnapshot(from state: TwoDimensionalCelluralAutomata.State)

}
