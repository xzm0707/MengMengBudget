import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddTransaction = false
    @State private var isLoggedIn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if !isLoggedIn {
                // 登录视图
                LoginView(onLoginSuccess: {
                    print("登录成功，切换到主界面")
                    isLoggedIn = true
                })
            } else {
                // 主应用视图
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        HomeView(showAddTransaction: $showAddTransaction)
                            .tag(Tab.home)
                        
                        Text("账单页面")
                            .tag(Tab.transactions)
                        
                        Color.clear
                            .tag(Tab.add)
                        
                        Text("统计页面")
                            .tag(Tab.statistics)
                        
                        ProfileView()
                            .tag(Tab.profile)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // 自定义底部导航栏
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        showAddTransaction: $showAddTransaction
                    )
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
        .onAppear {
            // 检查是否已登录
            if NetworkService.shared.isLoggedIn() {
                print("用户已登录，直接显示主界面")
                isLoggedIn = true
            } else {
                print("用户未登录，显示登录界面")
                isLoggedIn = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LogoutNotification"))) { _ in
            print("收到登出通知，切换到登录界面")
            isLoggedIn = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 