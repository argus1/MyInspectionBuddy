//
//  PPContentView.swift
//  PrivacyPolicyDisplay
//
//  Created by Tanay Doppalapudi on 6/25/25.
//

// PPContentView.swift
// Sets up the root navigation for displaying privacy policies.

import SwiftUI

// Main entry view that embeds the PrivacyPoliciesView in a NavigationStack.
struct PPContentView: View {
    // The view hierarchy, starting with a NavigationStack to enable in-app navigation.
    var body: some View {
        NavigationStack {
            PrivacyPoliciesView()
        }
    }
}

// Preview provider for rendering PPContentView in Xcode previews.
struct PPContentView_Previews: PreviewProvider {
    // Returns an instance of PPContentView for previewing.
    static var previews: some View {
        PPContentView()
    }
}
