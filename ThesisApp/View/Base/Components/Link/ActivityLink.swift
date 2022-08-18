//
//  ActivityLink.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 14.07.22.
//

import SwiftUI

struct ActivityLink: View {
    
    var activity: Activity
    
    init(_ activity: Activity) {
        self.activity = activity
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            ListItem(
                headline:
                    "\(activity.movement.name) " +
                    "\(Formatter.double(activity.distance)) km",
                subline: Formatter.date(activity.date)
            )
        }
    }
    
    var destination: some View {
        ActivityDetailView(activity)
            .navigationLink()
    }
    
    let spacing: CGFloat = 5
}

struct ActivityLink_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        let activites: [Activity] = try! persistenceController.container.viewContext.fetch(Activity.fetchRequest())
        
        NavigationView {
            ActivityLink(activites.randomElement()!)
        }
    }
}
