             import SwiftUI

struct HomeView: View {
    @Binding var showAddTransaction: Bool
    
    @State private var monthlyBalance: Double = 3254.65
    @State private var monthlyIncome: Double = 8750.00
    @State private var monthlyExpense: Double = 5495.35
    @State private var recentTransactions = SampleData.transactions
    
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
            }
        }
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
