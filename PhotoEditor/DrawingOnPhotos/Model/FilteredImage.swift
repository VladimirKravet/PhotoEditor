//
//  FilteredImage.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 11.09.2024.
//

import CoreImage
import SwiftUI

struct FilteredImage: Identifiable {
    var id = UUID().uuidString
    var image:UIImage
    var filter: CIFilter
    var isEditable: Bool
}
