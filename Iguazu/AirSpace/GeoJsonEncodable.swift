//
//  GeoJsonEncodable.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 28.05.18.
//  Copyright © 2018 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public protocol GeoJsonEncodable {
    var geoJsonString: String? { get }
}
