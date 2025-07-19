import SwiftUI

struct MineCell: View {
    let cell: Cell
    let row: Int
    let col: Int
    let size: CGFloat
    let fontSize: CGFloat
    let onTap: (Int, Int) -> Void
    let onLongPress: (Int, Int) -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellBackgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    Rectangle()
                        .stroke(cellBorderColor, lineWidth: cellBorderWidth)
                )
            
            Text(cell.displayText)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(row, col)
        }
        .onLongPressGesture {
            onLongPress(row, col)
        }
    }
    
    private var cellBackgroundColor: Color {
        if !cell.isRevealed {
            // Unrevealed cells have a raised 3D look
            return Color(red: 0.75, green: 0.75, blue: 0.75)
        } else if cell.isMine {
            // Mine cells are red when revealed
            return Color.red
        } else {
            // Revealed non-mine cells are light gray
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
    
    private var cellBorderColor: Color {
        if !cell.isRevealed {
            // Unrevealed cells have a 3D border effect
            return Color.black
        } else {
            // Revealed cells have a simple border
            return Color.gray
        }
    }
    
    private var cellBorderWidth: CGFloat {
        return cell.isRevealed ? 0.5 : 1.5
    }
    
    private var textColor: Color {
        if cell.isFlagged {
            return Color.red
        } else if cell.isMine {
            return Color.black
        } else {
            switch cell.adjacentMines {
            case 1: return Color.blue
            case 2: return Color.green
            case 3: return Color.red
            case 4: return Color.purple
            case 5: return Color.brown
            case 6: return Color.pink
            case 7: return Color.black
            case 8: return Color.gray
            default: return Color.black
            }
        }
    }
}

#Preview {
    VStack {
        HStack {
            MineCell(
                cell: Cell(),
                row: 0,
                col: 0,
                size: 35,
                fontSize: 18,
                onTap: { _, _ in },
                onLongPress: { _, _ in }
            )
            
            MineCell(
                cell: {
                    var cell = Cell()
                    cell.isFlagged = true
                    return cell
                }(),
                row: 0,
                col: 1,
                size: 35,
                fontSize: 18,
                onTap: { _, _ in },
                onLongPress: { _, _ in }
            )
            
            MineCell(
                cell: {
                    var cell = Cell()
                    cell.isRevealed = true
                    cell.adjacentMines = 3
                    return cell
                }(),
                row: 0,
                col: 2,
                size: 35,
                fontSize: 18,
                onTap: { _, _ in },
                onLongPress: { _, _ in }
            )
            
            MineCell(
                cell: {
                    var cell = Cell()
                    cell.isRevealed = true
                    cell.isMine = true
                    return cell
                }(),
                row: 0,
                col: 3,
                size: 35,
                fontSize: 18,
                onTap: { _, _ in },
                onLongPress: { _, _ in }
            )
        }
    }
    .padding()
}
