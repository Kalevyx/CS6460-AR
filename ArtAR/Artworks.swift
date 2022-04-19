//
//  Artworks.swift
//  ArtAR
//
//  Created by Claire Li on 4/10/22.
//  Copyright © 2022 C. All rights reserved.
//

import Foundation

struct Artwork: Decodable {
    let name: String
    let artist: String
    let description: String
    let fact: String
    let sources: String
}
