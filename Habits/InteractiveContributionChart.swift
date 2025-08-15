//
//  InteractiveContributionChart.swift
//  Habits
//
//  Created by Abderrahim on 15/08/2025.
//

import SwiftUI

struct InteractiveContributionChart: View {
    let data: [Double]
    let rows: Int
    let columns: Int
    let targetValue: Double
    let blockColor: Color
    let blockBackgroundColor: Color
    let rectangleWidth: Double
    let rectangleSpacing: Double
    let rectangleRadius: Double
    let onDayTapped: (Int) -> Void
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    HStack(spacing: rectangleSpacing) {
                        ForEach(0..<columns, id: \.self) { columnIndex in
                            let start = columnIndex * rows
                            let end = (columnIndex + 1) * rows
                            let splitedData = Array(data[start..<end])
                            
                            InteractiveContributionColumn(
                                columnData: splitedData,
                                columnIndex: columnIndex,
                                rows: rows,
                                targetValue: targetValue,
                                blockColor: blockColor,
                                blockBackgroundColor: blockBackgroundColor,
                                rectangleWidth: rectangleWidth,
                                rectangleSpacing: rectangleSpacing,
                                rectangleRadius: rectangleRadius,
                                onDayTapped: onDayTapped
                            )
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
        }
        .padding()
    }
}

struct InteractiveContributionColumn: View {
    let columnData: [Double]
    let columnIndex: Int
    let rows: Int
    let targetValue: Double
    let blockColor: Color
    let blockBackgroundColor: Color
    let rectangleWidth: Double
    let rectangleSpacing: Double
    let rectangleRadius: Double
    let onDayTapped: (Int) -> Void
    
    var body: some View {
        VStack(spacing: rectangleSpacing) {
            ForEach(0..<rows, id: \.self) { rowIndex in
                let dayIndex = columnIndex * rows + rowIndex
                
                ZStack {
                    RoundedRectangle(cornerRadius: rectangleRadius)
                        .frame(width: rectangleWidth, height: rectangleWidth)
                        .foregroundColor(blockBackgroundColor)
                    
                    RoundedRectangle(cornerRadius: rectangleRadius)
                        .frame(width: rectangleWidth, height: rectangleWidth)
                        .foregroundColor(blockColor.opacity(opacityRatio(index: rowIndex)))
                }
                .onTapGesture {
                    onDayTapped(dayIndex)
                }
            }
        }
    }
    
    func opacityRatio(index: Int) -> Double {
        let value = columnData[index]
        
        // Handle special case for future days (-1.0)
        if value < 0 {
            return 0.0 // Completely transparent for future days
        }
        
        // For past days with no data (0.0), show a minimal opacity to make them visible
        if value == 0.0 {
            return 0.1 // Very light grey for days with no activity
        }
        
        // For days with activity, calculate normal opacity
        let opacityRatio: Double = Double(value) / Double(targetValue)
        return opacityRatio > 1.0 ? 1.0 : opacityRatio
    }
}