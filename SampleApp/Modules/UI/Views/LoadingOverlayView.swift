//
//  LoadingOverlayView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// View with a loading animation and copy.
struct LoadingOverlayView: View {
    // MARK: Properties

    private let foregroundColor: Color
    private let backgroundColor: Color
    private let symbols: [String]
    private let symbolTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let title: LocalizedStringKey
    @State private var currentSymbolIndex = 0

    // MARK: Body

    var body: some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.medium12) {
            Spacer()
            Image(systemName: symbols[currentSymbolIndex])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .apply {
                    if #available(iOS 17.0, *) {
                        $0.contentTransition(.symbolEffect(.replace))
                    } else {
                        $0
                    }
                }
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UIConstant.Spacing.xxxxLarge40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .onReceive(symbolTimer) { _ in
            currentSymbolIndex = (currentSymbolIndex + 1) % symbols.count
        }
    }

    // MARK: Lifecycle

    init(
        title: LocalizedStringKey = "LoadingOverlayView.Title",
        symbols: [String] = [
            "heart.text.square",
            "stethoscope",
            "cross.case",
            "figure.2.and.child.holdinghands",
            "bandage",
            "cross",
        ],
        foregroundColor: Color = .dxButtonSecondary,
        backgroundColor: Color = .dxBackgroundPrimary
    ) {
        self.title = title
        self.symbols = symbols
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

#Preview {
    ZStack {
        Color.orange
        LoadingOverlayView(title: "MainView.LastVirtualVisit.LoadingView.ResumingVisit")
    }
}
