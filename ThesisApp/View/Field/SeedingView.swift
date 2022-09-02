//
//  SeedOption.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 28.08.22.
//

import SwiftUI
import Combine

extension SeedingView {
    
    class ViewModel: ObservableObject {
        
        @Published var field: Field
        @Published var selectedSeed: Seed?
        
        @Binding var isPresented: Bool
        
        private let fieldService: FieldService
        private let persistenceController: PersistenceController
        
        var anyCancellable: Set<AnyCancellable>
        
        init(
            field: Field,
            isPresented: Binding<Bool>,
            fieldService: FieldService,
            persistenceController: PersistenceController
        ) {
            self.field = field
            self._isPresented = isPresented
            self.fieldService = fieldService
            self.persistenceController = persistenceController
            self.anyCancellable = Set()
        }
        
        var seeds: [Seed] {
            field.seeds
        }
        
        var plantingDisabled: Bool {
            selectedSeed == nil
        }
        
        func isAvailable(_ seed: Seed) -> Bool {
            let points = UserDefaults.standard.double(for: .points) ?? 0
            return seed.price <= Int(points)
        }
        
        func isSelected(_ seed: Seed) -> Bool {
            self.selectedSeed == seed
        }
        
        func select(_ seed: Seed) {
            guard isAvailable(seed) else {
                return
            }
            if selectedSeed == seed {
                self.selectedSeed = nil
            } else {
                self.selectedSeed = seed
            }
        }
        
        func createPlant() {
            guard let seed = selectedSeed else {
                return
            }
            
            self.fieldService.createPlant(
                .init(fieldId: field.id, seedId: seed.id)
            )
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { data in
                    UserDefaults.standard.set(data.points, for: .points)
                    self.persistenceController.saveField(with: data.data)
                    self.selectedSeed = nil
                    self.isPresented = false
                }
            )
            .store(in: &anyCancellable)
        }
    }
}

struct SeedingView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(
        field: Field,
        isPresented: Binding<Bool>,
        fieldService: FieldService,
        persistenceController: PersistenceController
    ) {
        self._viewModel = StateObject(wrappedValue:
            ViewModel(
                field: field,
                isPresented: isPresented,
                fieldService: fieldService,
                persistenceController: persistenceController
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(viewModel.seeds) { seed in
                    item(for: seed)
                        .onTapGesture {
                            viewModel.select(seed)
                        }
                }
            }
            .padding(.vertical, Spacing.large)
            
            ButtonIcon(
                "Jetzt planzen",
                icon: "plus",
                disabled: viewModel.plantingDisabled
            ) {
                viewModel.createPlant()
            }
        }
        .padding(Spacing.medium)
    }
    
    @ViewBuilder
    func item(for seed: Seed) -> some View {
        ZStack {
            Image(seed.name)
                .resizable()
                .scaledToFit()
                .padding(.bottom, Spacing.medium)
            
            VStack {
                Spacer()
                
                HStack {
                    Text(seed.name.uppercased())
                        .font(.custom(Font.normal, size: 12))
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.customOrange)
                            .frame(width: 20, height: 20)
                        
                        Text("\(seed.price)")
                            .font(.custom(Font.normal, size: 10))
                    }
                }
            }
            .padding(Spacing.extraSmall)
        }
        .aspectRatio(1/1, contentMode: .fit)
        .background(
            viewModel.isSelected(seed) ? Color.customLightBrown : Color.customLightBeige
        )
        .opacity(viewModel.isAvailable(seed) ? 1 : 0.5)
        .cornerRadius(18)
    }
}
