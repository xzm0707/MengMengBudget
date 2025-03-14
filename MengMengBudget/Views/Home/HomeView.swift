import SwiftUI

struct HomeView: View {
   @Binding var showAddTransaction: Bool
    // 修改这些状态变量的初始值为0，稍后会从API获取
    @State private var monthlyBalance: Double = 0.0
    @State private var monthlyIncome: Double = 0.0
    @State private var monthlyExpense: Double = 0.0
    @State private var recentTransactions = SampleData.transactions
    // 添加加载状态
    @State private var isLoading = false
    @State private var hasError = false

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 余额卡片
                    BalanceCardView(
                        balance: monthlyBalance,
                        income: monthlyIncome,
                        expense: monthlyExpense
                    )
                    
                    // 快捷操作
                    QuickActionsView(onAddTapped: {
                        showAddTransaction = true
                    })
                    
                    // 最近交易
                    RecentTransactionsView(transactions: recentTransactions)
                    
                    // 小贴士
                    TipCardView(
                        icon: "lightbulb.fill",
                        title: "小贴士",
                        message: "本月餐饮支出已超过预算的80%，建议控制一下哦～"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("萌萌记账")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("可爱版")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.pinkLight)
                            .foregroundColor(AppColors.pinkPrimary)
                            .cornerRadius(10)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            // 通知操作
                        } label: {
                            CircleIconButton(icon: "bell.fill", color: AppColors.pinkPrimary)
                        }
                        
                        Button {
                            // 设置操作
                        } label: {
                            CircleIconButton(icon: "gearshape.fill", color: AppColors.pinkPrimary)
                        }
                    }
                }
            } // 添加刷新控件
            .refreshable {
                await loadData()
            }
        }
         // 添加onAppear生命周期方法，在视图出现时加载数据
        .onAppear {
            loadData()
        }// 可选：添加错误提示
        .overlay(
            Group {
                if isLoading {
                    ProgressView("加载中...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                } else if hasError {
                    VStack {
                        Text("数据加载失败")
                            .foregroundColor(.red)
                        Button("重试") {
                            loadData()
                        }
                        .padding(8)
                        .background(AppColors.pinkLight)
                        .foregroundColor(AppColors.pinkPrimary)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .opacity(isLoading || hasError ? 1 : 0)
        )
    }
    // 添加加载数据的方法
    private func loadData() {
        // 如果已经在加载中，则不重复加载
        if isLoading { return }
        
        isLoading = true
        hasError = false
        
        // 先登录获取token
        NetworkService.shared.login { success in
            if success {
                // 登录成功后获取首页数据
                NetworkService.shared.getHomeSummary(
                    completion: { income, balance, expense in
                        // 在主线程更新UI
                        DispatchQueue.main.async {
                            self.monthlyIncome = income
                            self.monthlyBalance = balance
                            self.monthlyExpense = expense
                            self.isLoading = false
                        }
                    },
                    failure: {
                        // 处理获取数据失败的情况
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.hasError = true
                        }
                    }
                )
            } else {
                // 处理登录失败的情况
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasError = true
                }
            }
        }
    }
}

// 为了支持async/await的refreshable
extension HomeView {
    private func loadData() async {
        // 创建一个任务来执行同步版本的loadData方法
        Task {
            loadData()
        }
        // 等待2秒，确保异步操作有足够时间完成
        // 这是一个简化处理，实际应用中可能需要更复杂的异步处理
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

// 余额卡片
struct BalanceCardView: View {
    let balance: Double
    let income: Double
    let expense: Double
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(24)
            
            // 装饰图案
            GeometryReader { geometry in
               Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 150))
                    .foregroundColor(.white.opacity(0.1))
                    .offset(x: geometry.size.width * 0.6, y: geometry.size.height * 0.4)
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 16) {
                Text("本月结余")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("¥\(String(format: "%.2f", balance))")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundColor(Color.green.opacity(0.8))
                            Text("收入")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("¥\(String(format: "%.2f", income))")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundColor(Color.red.opacity(0.8))
                            Text("支出")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("¥\(String(format: "%.2f", expense))")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
        .frame(height: 160)
        .shadow(color: AppColors.pinkPrimary.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}

// 快捷操作视图
struct QuickActionsView: View {
    let onAddTapped: () -> Void
    
    struct QuickAction {
        let icon: String
        let title: String
        let color: Color
        let backgroundColor: Color
        let action: () -> Void
    }
    
    var actions: [QuickAction] {
        [
            QuickAction(
                icon: "plus",
                title: "记一笔",
                color: AppColors.pinkPrimary,
                backgroundColor: AppColors.pinkLight,
                action: onAddTapped
            ),
            QuickAction(
                icon: "chart.pie.fill",
                title: "统计",
                color: AppColors.purplePrimary,
                backgroundColor: AppColors.purpleLight,
                action: {}
            ),
            QuickAction(
                icon: "wallet.pass.fill",
                title: "预算",
                color: AppColors.greenPrimary,
                backgroundColor: AppColors.greenLight,
                action: {}
            ),
            QuickAction(
                icon: "creditcard.fill",
                title: "账户",
                color: AppColors.yellowPrimary,
                backgroundColor: AppColors.yellowLight,
                action: {}
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("快捷操作")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 8)
            
            HStack(spacing: 15) {
                ForEach(0..<actions.count, id: \.self) { index in
                    let action = actions[index]
                    Button {
                        action.action()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(action.backgroundColor)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: action.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(action.color)
                            }
                            
                            Text(action.title)
                                .font(.caption)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .springyButton()
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// 最近交易视图
struct RecentTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("最近交易")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    // 查看全部交易
                } label: {
                    Text("查看全部")
                        .font(.caption)
                        .foregroundColor(AppColors.pinkPrimary)
                }
                .springyButton()
            }
            .padding(.bottom, 8)
            
            if transactions.isEmpty {
                HStack {
                    Spacer()
                    Text("暂无交易记录")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                        
                        if transaction.id != transactions.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// 交易行视图
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 15) {
            // 分类图标
            let category = SampleData.getCategory(id: transaction.categoryId)
            ZStack {
                Circle()
                    .fill(category.backgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(category.color)
            }
            
            // 交易信息
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(transaction.note)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // 金额
            Text(transaction.formattedAmount)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(transaction.isExpense ? .red : (transaction.isIncome ? .green : AppColors.textPrimary))
        }
        .padding(.vertical, 12)
    }
}

// 小贴士卡片
struct TipCardView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(AppColors.yellowLight)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.yellowPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// 圆形图标按钮
struct CircleIconButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 36, height: 36)
            
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showAddTransaction: .constant(false))
    }
} 
