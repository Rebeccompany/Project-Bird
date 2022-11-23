//
//  ContentView.swift
//  
//
//  Created by Gabriel Ferreira de Carvalho on 14/09/22.
//

import SwiftUI
import Models
import DeckFeature
import NewDeckFeature
import HummingBird
import Flock
import NewCollectionFeature
import Habitat
import Storage
import StoreFeature
import OnboardingFeature
import StoreState

public struct ContentView: View {
    @AppStorage("com.projectbird.birdmodules.appfeature.onboarding") private var onboarding: Bool = true
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var editModeForCollection: EditMode = .inactive
    @State private var editModeForDeck: EditMode = .inactive
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    @StateObject private var appRouter: AppRouter = AppRouter()
    @StateObject private var shopStore: ShopStore = ShopStore()
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public init() {}
    
    public var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                TabView(selection: $appRouter.selectedTab) {
                    mainView
                        .tabItem {
                            Label("Baralhos", systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
                        }
                        .tag(AppRouter.Tab.study)
                    
                    NavigationStack(path: $appRouter.storePath) {
                        StoreView(store: shopStore)
                    }
                    .tabItem {
                        Label("Loja", systemImage: "bag")
                    }
                    .tag(AppRouter.Tab.store)
                }
                
            } else {
                mainView
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $onboarding) {
            OnboardingView()
        }
        .onChange(of: viewModel.sidebarSelection) { _ in
            appRouter.path.removeLast(appRouter.path.count - 1)
        }
        .onAppear(perform: viewModel.startup)
        .onOpenURL(perform: appRouter.onOpen)
    }
    
    @ViewBuilder
    private var mainView: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detail
        }
    }
    
    @ViewBuilder
    private var sidebar: some View {
        CollectionsSidebar(
            selection: $viewModel.sidebarSelection,
            editMode: $editModeForCollection
        )
        .environmentObject(viewModel)
        .environmentObject(shopStore)
        .environment(\.editMode, $editModeForCollection)
        .environment(\.horizontalSizeClass, horizontalSizeClass)
    }
    
    @ViewBuilder
    private var detail: some View {
        Router(path: $appRouter.path) {
            DetailView(editMode: $editModeForDeck)
                .toolbar(
                    editModeForDeck.isEditing ? .hidden :
                            .automatic,
                    for: .tabBar)
                .environmentObject(viewModel)
                .environment(\.editMode, $editModeForDeck)
        } destination: { (route: StudyRoute) in
            StudyRoutes.destination(for: route, viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HabitatPreview {
            ContentView()
        }
    }
}
