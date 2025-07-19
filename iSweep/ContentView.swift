import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingDifficultyPicker = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var baseZoomScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    // Header with mine count, smiley face, and timer
                    headerView
                    
                    // Game grid with zoom support
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        gameGrid
                            .scaleEffect(zoomScale)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                // Apply zoom relative to base scale
                                let newScale = max(0.5, min(3.0, baseZoomScale * value))
                                zoomScale = newScale
                            }
                            .onEnded { value in
                                // Update base scale when gesture ends
                                baseZoomScale = zoomScale
                            }
                    )
                    .onTapGesture(count: 2) {
                        // Double-tap to reset zoom
                        withAnimation(.easeInOut(duration: 0.3)) {
                            zoomScale = 1.0
                            baseZoomScale = 1.0
                        }
                    }
                    .clipped()
                    
                    // Only show spacer and difficulty button if there's enough vertical space
                    if geometry.size.height > 500 {
                        Spacer()
                        difficultyButton
                        Spacer()
                    } else {
                        difficultyButton
                            .padding(.vertical, 8)
                    }
                }
                .navigationTitle("iSweep")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Forces single view layout on all devices
        }
        .sheet(isPresented: $showingDifficultyPicker) {
            difficultyPickerView
        }
        .onChange(of: viewModel.difficulty) {
            // Reset zoom when difficulty changes
            withAnimation(.easeInOut(duration: 0.3)) {
                zoomScale = 1.0
                baseZoomScale = 1.0
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Mine count display
            digitalDisplay(text: viewModel.formattedMineCount())
            
            Spacer()
            
            // Smiley face reset button
            Button(action: {
                viewModel.resetGame()
            }) {
                Text(viewModel.smileyFace)
                    .font(.system(size: 30))
                    .frame(width: 50, height: 50)
                    .background(Color(red: 0.75, green: 0.75, blue: 0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Timer display
            digitalDisplay(text: viewModel.formattedTime())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(red: 0.8, green: 0.8, blue: 0.8))
        .overlay(
            Rectangle()
                .stroke(Color.black, lineWidth: 2)
        )
    }
    
    // MARK: - Digital Display
    private func digitalDisplay(text: String) -> some View {
        Text(text)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(.red)
            .frame(width: 80, height: 40)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(4)
    }
    
    // MARK: - Game Grid
    private var gameGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.cellSize), spacing: viewModel.gridSpacing), count: viewModel.gridWidth), spacing: viewModel.gridSpacing) {
            ForEach(0..<(viewModel.gridHeight * viewModel.gridWidth), id: \.self) { index in
                let row = index / viewModel.gridWidth
                let col = index % viewModel.gridWidth
                MineCell(
                    cell: viewModel.cells[row][col],
                    row: row,
                    col: col,
                    size: viewModel.cellSize,
                    fontSize: viewModel.fontSize,
                    onTap: viewModel.cellTapped,
                    onLongPress: viewModel.cellLongPressed
                )
            }
        }
        .id(viewModel.difficulty) // Force recreation when difficulty changes
        .padding(8)
        .background(Color(red: 0.75, green: 0.75, blue: 0.75))
        .overlay(
            Rectangle()
                .stroke(Color.black, lineWidth: 3)
        )
    }
    
    // MARK: - Difficulty Button
    private var difficultyButton: some View {
        Button("Difficulty: \(viewModel.difficulty.displayName)") {
            showingDifficultyPicker = true
        }
        .font(.headline)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Difficulty Picker View
    private var difficultyPickerView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Difficulty")
                    .font(.title)
                    .padding()
                
                ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                    Button(action: {
                        viewModel.changeDifficulty(to: difficulty)
                        showingDifficultyPicker = false
                    }) {
                        VStack {
                            Text(difficulty.displayName)
                                .font(.headline)
                            Text("\(difficulty.gridSize.width) × \(difficulty.gridSize.height)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(difficulty.mineCount) mines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.difficulty == difficulty ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.difficulty == difficulty ? .white : .primary)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Difficulty")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                showingDifficultyPicker = false
            })
        }
    }
}

#Preview {
    ContentView()
}
