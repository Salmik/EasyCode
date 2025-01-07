//
//  View+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import SwiftUI
import Charts

public protocol ChartDataPoint: Identifiable {
    var xValue: String { get }
    var yValue: Double { get }
    var xAxisLabel: String? { get }
    var yAxisLabel: String? { get }
}

public struct DataPoint: ChartDataPoint {
    public let id = UUID()
    public let xValue: String
    public let yValue: Double
    public var xAxisLabel: String?
    public var yAxisLabel: String?
}

public struct RangeDataPoint: Identifiable {
    public let id = UUID()
    public let label: String
    public let minValue: Double
    public let maxValue: Double
}

@available(iOS 16.0, *)
public extension View {

    var uiView: UIView { HostingView(rootView: self) }

    func createBarChart<DataType: ChartDataPoint>(dataPoints: [DataType], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(dataPoints) { dataPoint in
                BarMark(
                    x: .value(dataPoint.xAxisLabel ?? "X", dataPoint.xValue),
                    y: .value(dataPoint.yAxisLabel ?? "Y", dataPoint.yValue)
                )
            }
            .padding()
        }
    }

    func createLineChart<DataType: ChartDataPoint>(dataPoints: [DataType], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(dataPoints) { dataPoint in
                LineMark(
                    x: .value(dataPoint.xAxisLabel ?? "X", dataPoint.xValue),
                    y: .value(dataPoint.yAxisLabel ?? "Y", dataPoint.yValue)
                )
            }
            .padding()
        }
    }

    func createAreaChart<DataType: ChartDataPoint>(dataPoints: [DataType], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(dataPoints) { dataPoint in
                AreaMark(
                    x: .value(dataPoint.xAxisLabel ?? "X", dataPoint.xValue),
                    y: .value(dataPoint.yAxisLabel ?? "Y", dataPoint.yValue)
                )
            }
            .padding()
        }
    }

    func createPointChart<DataType: ChartDataPoint>(dataPoints: [DataType], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(dataPoints) { dataPoint in
                PointMark(
                    x: .value(dataPoint.xAxisLabel ?? "X", dataPoint.xValue),
                    y: .value(dataPoint.yAxisLabel ?? "Y", dataPoint.yValue)
                )
            }
            .padding()
        }
    }

    func createRangeAreaChart(rangeDataPoints: [RangeDataPoint], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(rangeDataPoints) { dataPoint in
                AreaMark(
                    x: .value("Label", dataPoint.label),
                    yStart: .value("Min Value", dataPoint.minValue),
                    yEnd: .value("Max Value", dataPoint.maxValue)
                )
            }
            .padding()
        }
    }

    @available(iOS 17.0, *)
    func createPieChart<DataType: ChartDataPoint>(dataPoints: [DataType], title: String? = nil) -> some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            Chart(dataPoints) { dataPoint in
                SectorMark(
                    angle: .value(dataPoint.xAxisLabel ?? "Angle", dataPoint.xValue),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(1.0)
                )
            }
            .padding()
        }
    }
}
