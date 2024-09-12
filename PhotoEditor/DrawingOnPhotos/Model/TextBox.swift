//
//  TextBox.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 10.09.2024.
//

import SwiftUI
import PencilKit

struct TextBox: Identifiable {
    var id = UUID().uuidString
    var text: String = ""
    var isBold: Bool = false
    var offset: CGSize = .zero
    var lastOffset:CGSize = .zero
    var textColor: Color = .white
    var isAdded: Bool = false
}
