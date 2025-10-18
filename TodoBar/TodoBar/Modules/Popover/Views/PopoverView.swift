///
/// PopoverView.swift
/// TodoBar
///
/// Popover 主视图，包含 Tab 切换和内容显示
///

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var coordinator: PopoverCoordinator
    @EnvironmentObject var persistence: PersistenceController
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            TabBarView(selectedTab: $coordinator.selectedTab)
                .padding(.horizontal, UIConstants.spacing)
                .padding(.top, UIConstants.spacing)
            
            Divider()
                .padding(.vertical, UIConstants.smallSpacing)
            
            // Tab Content
            TabContentView()
        }
        .frame(width: UIConstants.popoverWidth, height: UIConstants.popoverHeight)
        .background(Color.themeBackground)
    }
}

// MARK: - Tab Bar View

struct TabBarView: View {
    @Binding var selectedTab: PopoverTab
    
    var body: some View {
        HStack(spacing: UIConstants.smallSpacing) {
            ForEach(PopoverTab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.easeInOut(duration: UIConstants.animationDuration)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let tab: PopoverTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: UIConstants.iconSize))
                
                Text(LocalizedStringKey(tab.rawValue))
                    .font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, UIConstants.smallSpacing)
            .background(
                isSelected ? Color.themePrimary.opacity(0.1) : Color.clear
            )
            .foregroundColor(isSelected ? .themePrimary : .themeSecondaryText)
            .cornerRadius(UIConstants.smallCornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Content View

struct TabContentView: View {
    @EnvironmentObject var coordinator: PopoverCoordinator
    
    var body: some View {
        Group {
            switch coordinator.selectedTab {
            case .todoList:
                TodoListView()
            case .dashboard:
                DashboardView()
            case .analytics:
                AnalyticsView()
            case .settings:
                SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}

