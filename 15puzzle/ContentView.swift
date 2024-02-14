//
//  ContentView.swift
//  15puzzle
//
//  Created by นายธนบูรณ์ จิวริยเวชช์ on 14/2/2567 BE.
//

import SwiftUI

class PuzzleViewModel: ObservableObject {
    @Published var tiles: [Int]
    @Published var emptyIndex: Int = 15 // Initialized with a default value
    
    @Published var moves: Int
    @Published var isGameCompleted: Bool
    
    let gridSize = 4
    
    init() {
        tiles = Array(1...16)
        moves = 0
        isGameCompleted = false
        
        shuffleTiles() // Perform shuffling and solvability check after all properties are initialized
    }
    
    func shuffleTiles() {
        moves = 0
        isGameCompleted = false
        
        for _ in 0..<1000 {
            let adjacentIndices = findAdjacentIndices(to: emptyIndex)
            guard let randomAdjacentIndex = adjacentIndices.randomElement() else { continue }
            tiles.swapAt(randomAdjacentIndex, emptyIndex)
            emptyIndex = randomAdjacentIndex
        }
    }
    
    func moveTile(at index: Int) {
        if canMoveTile(at: index) {
            tiles.swapAt(index, emptyIndex)
            emptyIndex = index
            moves += 1
            
            if tiles == Array(1...16) {
                isGameCompleted = true
            }
        }
    }
    
    func canMoveTile(at index: Int) -> Bool {
        let rowDiff = abs(index / gridSize - emptyIndex / gridSize)
        let colDiff = abs(index % gridSize - emptyIndex % gridSize)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func findAdjacentIndices(to index: Int) -> [Int] {
        var adjacentIndices: [Int] = []
        
        let row = index / gridSize
        let col = index % gridSize
        
        // Check adjacent tiles in all four directions
        if row > 0 { // Up
            adjacentIndices.append(index - gridSize)
        }
        if row < gridSize - 1 { // Down
            adjacentIndices.append(index + gridSize)
        }
        if col > 0 { // Left
            adjacentIndices.append(index - 1)
        }
        if col < gridSize - 1 { // Right
            adjacentIndices.append(index + 1)
        }
        
        return adjacentIndices
    }
}

struct PuzzleTileView: View {
    let number: Int?
    let action: () -> Void
    
    var body: some View {
        if let number = number {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                    Text("\(number)")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                }
                .frame(width: 60, height: 60)
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            Color.clear
                .frame(width: 60, height: 60)
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = PuzzleViewModel()
    
    var body: some View {
        VStack {
            ForEach(0..<4) { row in
                HStack {
                    ForEach(0..<4) { col in
                        let index = row * self.viewModel.gridSize + col
                        PuzzleTileView(number: self.viewModel.tiles[index] == 16 ? nil : self.viewModel.tiles[index]) {
                            self.viewModel.moveTile(at: index)
                        }
                        .padding(5)
                    }
                }
            }

            HStack {
                Spacer()
                Text("Moves: \(viewModel.moves)")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding()
                Spacer()
                Button("New Game") {
                    viewModel.shuffleTiles()
                }
                .padding()
                .background(viewModel.isGameCompleted ? Color.green : Color.gray) // Change button color based on game completion
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
            }
            Text("Congratulations! You solved the puzzle!")
                .foregroundColor(.green)
                .opacity(viewModel.isGameCompleted ? 1 : 0)
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Set background color for dark mode
        .edgesIgnoringSafeArea(.all) // Ignore safe area for dark mode
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light) // Preview light mode
            ContentView()
                .preferredColorScheme(.dark) // Preview dark mode
        }
    }
}
