//
//  TeamRankingView.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 25.08.22.
//

import SwiftUI
import Combine

extension TeamRankingView {
    
    class ViewModel: ObservableObject {
        
        @Published var teamResult: TeamResult?
        @Published var results: [TeamResult]
        @Published var disconnected: Bool
        
        var anyCancellable: Set<AnyCancellable>
        
        private let teamService: TeamService
        
        init(teamService: TeamService) {
            self.teamService = teamService
            self.anyCancellable = Set()
            self.results = []
            self.disconnected = false
        }
        
        func loadResults() {
            teamService.getRanking()
                .sink(
                    receiveCompletion: { result in
                        switch result {
                        case .finished:
                            self.disconnected = false
                        case .failure(let error):
                            self.disconnected = error == .unavailable
                        }
                    },
                    receiveValue: { data in
                        print(data)
                        self.teamResult = data.team
                        self.results = data.ranking.sorted()
                    }
                )
                .store(in: &anyCancellable)
        }
        
        func isTeam(_ result: TeamResult) -> Bool {
            guard let team = self.teamResult else {
                return false
            }
            return team.id == result.id
        }
    }
}

struct TeamRankingView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(teamService: TeamService) {
        self._viewModel = StateObject(wrappedValue:
            ViewModel(teamService: teamService)
        )
    }
    
    var body: some View {
        ScrollContainer {
            if let team = viewModel.teamResult {
                header(for: team)
                    .modifier(Header())
            }
            ranking
        }
        .onAppear {
            viewModel.loadResults()
        }
    }
    
    @ViewBuilder
    func header(for team: TeamResult) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Spacing.ultraSmall) {
                Text(team.name)
                    .font(.custom(Font.normal, size: 30))
                
                HStack(alignment: .bottom, spacing: Spacing.ultraSmall) {
                    Text("\(Formatter.double(team.distance))")
                        .modifier(FontTitle())
                    Text("km")
                        .modifier(FontH3())
                        .padding(.bottom, 6)
                }
            }
            
            Spacer()
            
            Text("\(team.rank).")
                .font(.custom(Font.bold, size: 60))
                .foregroundColor(.customOrange)
        }
        .padding(.bottom, Spacing.medium)
    }
    
    var ranking: some View {
        LazyVStack {
            ForEach(viewModel.results) { result in
                RankingItem(
                    result,
                    highlighted: viewModel.isTeam(result)
                )
            }
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        TeamRankingView(teamService: TeamMockService())
    }
}
