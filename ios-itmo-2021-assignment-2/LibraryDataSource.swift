//
//  LibraryDataSourse.swift
//  ios-itmo-2021-assignment-2
//
//  Created by user on 12.12.2021.
//

import Foundation

protocol LibraryDataSource: AnyObject {
    func setState(from state: TwoDimensionalCelluralAutomata.State)
    func setTitle(from title: String)
}
