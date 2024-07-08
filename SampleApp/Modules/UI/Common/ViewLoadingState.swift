//
//  ViewLoadingState.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

enum ViewLoadingState {
    /// The view's data is loading.
    case loading
    /// The view's data is loaded and ready to be displayed.
    case loaded
    /// There was an error loading the view's data.
    case error
}
