import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddTransaction = false
    
    var body: some View {
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
                
                Text("我的页面")
                    .tag(Tab.profile)
            }
            
            CustomTabBar(
                selectedTab: $selectedTab,
                showAddTransaction: $showAddTransaction
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 