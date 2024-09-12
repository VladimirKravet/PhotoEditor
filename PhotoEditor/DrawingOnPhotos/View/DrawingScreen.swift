//
//  DrawingScreen.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 10.09.2024.
//

import SwiftUI

struct DrawingScreen: View {
    @EnvironmentObject var viewModel: DrawingViewModel
    
    @State private var isAnimating: Bool = false
    
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                let size = proxy.frame(in: .global)
                
                
                ZStack {
                    CanvasView(canvas: $viewModel.canvas, imageData: $viewModel.imageData, toolPicker: $viewModel.toolPicker, rect: size.size)
                        .padding()
                        .rotationEffect(viewModel.rotation)
                        .animation(.linear(duration: 1), value: isAnimating)
                        .offset(x: viewModel.imageOffset.width, y: viewModel.imageOffset.height)
                        .scaleEffect(viewModel.imageScale)
                        .gesture(
                            !viewModel.isDrawing ? nil : SimultaneousGesture(
                                RotationGesture()
                                    .onChanged { value in
                                        viewModel.rotation = value
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        withAnimation(.linear(duration: 1)) {
                                            if viewModel.imageScale <= 1 {
                                                viewModel.imageOffset = value.translation
                                            } else {
                                                viewModel.imageOffset = value.translation
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        if viewModel.imageScale <= 1 {
                                            resetImageState()
                                        }
                                    }
                            )
                        )
                    
                    ForEach(viewModel.textBoxes) { box in
                        Text(viewModel.textBoxes[viewModel.currentIndex].id == box.id && viewModel.addNewBox ? "" : box.text)
                            .font(.system(size: 30))
                            .fontWeight(box.isBold ? .bold : .none)
                            .foregroundColor(box.textColor)
                            .offset(box.offset)
                            .gesture(DragGesture().onChanged { value in
                                let current = value.translation
                                let lastOffset = box.lastOffset
                                let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                                viewModel.textBoxes[getIndex(textBox: box)].offset = newTranslation
                            }
                                .onEnded { value in
                                    viewModel.textBoxes[getIndex(textBox: box)].lastOffset = value.translation
                                })
                            .onLongPressGesture {
                                viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                                viewModel.canvas.resignFirstResponder()
                                viewModel.currentIndex = getIndex(textBox: box)
                                viewModel.addNewBox = true
                            }
                    }
                }
                .overlay(
                    HStack{
                        // SCALE DOWN
                        Button{
                            withAnimation(.spring()){
                                if viewModel.imageScale > 1 {
                                    viewModel.imageScale -= 1
                                    
                                    if viewModel.imageScale <= 1 {
                                        resetImageState()
                                    }
                                }
                            }
                        } label: {
                            ControlImageView(icon: "minus.magnifyingglass")
                        }
                        
                        // RESET
                        Button{
                            resetImageState()
                        } label: {
                            ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
                        }
                        
                        // SCALE UP
                        Button{
                            withAnimation(.spring()){
                                if viewModel.imageScale < 5 {
                                    viewModel.imageScale += 1
                                    
                                    if viewModel.imageScale > 5 {
                                        viewModel.imageScale = 5
                                    }
                                }
                            }
                        } label: {
                            ControlImageView(icon: "plus.magnifyingglass")
                        }
                        Button(action: {
                            viewModel.isDrawing.toggle()
                        }, label: {
                            ControlImageView(icon : !viewModel.isDrawing ? "pencil.and.scribble" : "rectangle.portrait.rotate")
                        })
                        
                    }
                        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .offset(y: 200)
                )
                .onAppear {
                    DispatchQueue.main.async {
                        if viewModel.rect == .zero {
                            viewModel.rect = size
                        }
                    }
                }
            }
        }
        .onAppear{
            viewModel.isImageChoosen = true
        }
    }
    
    func getIndex(textBox: TextBox) -> Int {
        return viewModel.textBoxes.firstIndex { $0.id == textBox.id } ?? 0
    }
    func resetImageState() {
        
        return withAnimation(.spring()){
            viewModel.imageScale = 1
            viewModel.imageOffset = .zero
            
        }
    }
}


struct ControlImageView: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 36))
    }
}
