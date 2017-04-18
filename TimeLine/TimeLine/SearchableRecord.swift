//
//  SearchableRecord.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/18/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
