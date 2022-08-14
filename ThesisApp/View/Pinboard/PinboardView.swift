//
//  PinboardView.swift
//  thesis-app
//
//  Created by Lisa Wittmann on 12.07.22.
//

import SwiftUI

struct PinboardView: View {
    
    @FetchRequest(
        entity: Posting.entity(),
        sortDescriptors: [NSSortDescriptor(key: "creationDate_", ascending: true)]
    ) var entries: FetchedResults<Posting>
    
    var body: some View {
        ScrollContainer {
            Text("Schwarzes Brett")
                .modifier(FontTitle())
            
            VStack(spacing: Spacing.medium) {
                ButtonIcon("Neuer Aushang", icon: "plus", action: {})
                ButtonIcon("Suchen", icon: "magnifyingglass", action: {})
            }
            .padding(.bottom, Spacing.medium)
            
            VStack(spacing: Spacing.large) {
                ForEach(entries) { entry in
                    PostingLink(entry)
                }
            }
        }
    }
}

struct PinboardView_Previews: PreviewProvider {
    static var previews: some View {

        NavigationView {
            PinboardView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
