import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var showAddTransaction: Bool
    
    var body: some View {
        HStack {
            TabBarButton(
                icon: "house.fill",
                title: "首页",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            TabBarButton(
                icon: "list.bullet",
                title: "账单",
                isSelected: selectedTab == .transactions
            ) {
                selectedTab = .transactions
            }
            
            // 中间的添加按钮
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(Circle())
                .frame(width: 56, height: 56)
                .shadow(color: AppColors.pinkPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Button {
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .springyButton()
            }
            .offset(y: -20)
            
            TabBarButton(
                icon: "chart.pie.fill",
                title: "统计",
                isSelected: selectedTab == .statistics
            ) {
                selectedTab = .statistics
            }
            
            TabBarButton(
                icon: "person.fill",
                title: "我的",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 15)
        .padding(.bottom, 30)
        .background(
            AppColors.card
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? AppColors.pinkPrimary : AppColors.textSecondary)
        }
        .springyButton()
        .frame(maxWidth: .infinity)
    }
}

enum Tab {
    case home, transactions, add, statistics, profile
} 