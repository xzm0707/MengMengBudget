import SwiftUI

struct TransactionsView: View {
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    @State private var hasError = false
    @State private var errorMessage = "加载失败，请重试"
    @State private var currentPage = 1
    @State private var hasMoreData = true
    @State private var pageSize = 10
    @State private var selectedMonth = Date()
    @State private var selectedFilter: TransactionFilter = .all
    @State private var monthlyIncome: Double = 0
    @State private var monthlyExpense: Double = 0
    @State private var monthlyBalance: Double = 0
    
    enum TransactionFilter: String, CaseIterable {
        case all = "全部"
        case expense = "支出"
        case income = "收入"
        case food = "餐饮"
        case shopping = "购物"
        case transport = "交通"
        case entertainment = "娱乐"
        case housing = "住房"
        case medical = "医疗"
        case education = "教育"
        case gift = "礼物"
        case salary = "工资"
        case other = "其他"
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    Text("账单")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            // 搜索功能
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.pinkPrimary)
                            }
                        }
                        
                        Button(action: {
                            // 筛选功能
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(AppColors.pinkPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 月份选择器
                        MonthSelector(selectedMonth: $selectedMonth)
                            .onChange(of: selectedMonth) { _ in
                                refreshData()
                            }
                        
                        // 月度统计卡片
                        MonthlySummaryCard(income: monthlyIncome, expense: monthlyExpense, balance: monthlyBalance)
                        
                        // 筛选标签
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                                    FilterChip(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        selectedFilter = filter
                                        // 当筛选条件变化时刷新数据
                                        refreshData()
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        
                        // 交易列表
                        if transactions.isEmpty && !isLoading {
                            VStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.pinkPrimary)
                                
                                Text("暂无交易记录")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.top)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else {
                            LazyVStack(spacing: 0) {
                                // 按日期分组显示交易
                                let groupedTransactions = Dictionary(grouping: transactions) { transaction in
                                    // 使用 createdAt 按天分组
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    return dateFormatter.string(from: transaction.date)
                                }
                                
                                // 对日期进行排序(倒序)
                                let sortedDates = groupedTransactions.keys.sorted(by: >)
                                
                                ForEach(sortedDates, id: \.self) { dateString in
                                    if let dailyTransactions = groupedTransactions[dateString] {
                                        // 日期标题
                                        VStack(spacing: 0) {
                                            // 日期头部
                                            HStack {
                                                Text(formatDateHeader(dateString))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.textSecondary)
                                                
                                                Spacer()
                                                
                                                // 当日收支统计
                                                let income = dailyTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                                                let expense = dailyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                                                
                                                HStack(spacing: 8) {
                                                    if income > 0 {
                                                        Text("收入 ¥\(String(format: "%.2f", income))")
                                                            .foregroundColor(.green)
                                                    }
                                                    if expense > 0 {
                                                        Text("支出 ¥\(String(format: "%.2f", expense))")
                                                            .foregroundColor(AppColors.pinkPrimary)
                                                    }
                                                }
                                                .font(.system(size: 14))
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                            
                                            // 当日交易列表
                                            ForEach(dailyTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                                                TransactionItem(transaction: transaction)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 4)
                                            }
                                        }
                                        .background(Color.white)
                                    }
                                }
                                
                                // 加载更多指示器
                                if hasMoreData && !isLoading {
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            loadMoreTransactions()
                                        }
                                } else if !transactions.isEmpty {
                                    Text("已加载全部数据")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80) // 为底部标签栏留出空间
                }
                .refreshable {
                    await refreshData()
                }
            }
            
            if isLoading && transactions.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.pinkPrimary))
            }
            
            if hasError {
                VStack {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.pinkPrimary)
                    
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top)
                    
                    Button("重试") {
                        refreshData()
                    }
                    .padding(.top, 8)
                    .foregroundColor(AppColors.pinkPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
            }
        }
        .onAppear {
            print("TransactionsView出现，开始加载数据")
            if transactions.isEmpty {
                loadTransactions()
                loadMonthlySummary()
            }
        }
    }
    
    private func loadTransactions() {
        guard !isLoading else { return }
        
        isLoading = true
        hasError = false
        
        print("开始加载交易数据，页码：\(currentPage)，每页数量：\(pageSize)")
        
        // 获取当前月份字符串
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        // 使用选择的月份而不是当前月份
        let monthString = dateFormatter.string(from: selectedMonth)
        
        // 确定类型和分类参数
        var type = ""
        var category = ""
        
        switch selectedFilter {
        case .all: 
            // 全部交易，不设置任何过滤条件
            type = ""
            category = ""
        case .expense:
            // 仅筛选支出类型
            type = "expense"
            category = ""
        case .income:
            // 仅筛选收入类型
            type = "income"
            category = ""
        case .food:
            type = "expense"
            category = "food"
        case .shopping:
            type = "expense"
            category = "shopping"
        case .transport:
            type = "expense"
            category = "transport"
        case .entertainment:
            type = "expense"
            category = "entertainment"
        case .housing:
            type = "expense"
            category = "housing"
        case .medical:
            type = "expense"
            category = "medical"
        case .education:
            type = "expense"
            category = "education"
        case .gift:
            type = "expense"
            category = "gift"
        case .salary:
            type = "income"
            category = "salary"
        case .other:
            type = "expense"
            category = "other"
        }
        
        NetworkService.shared.getAllTransactions(
            type: type,
            category: category,
            queryType: 2,
            queryMonth: monthString,
            pageNum: currentPage,
            pageSize: pageSize
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let newTransactions):
                    print("成功加载\(newTransactions.count)条交易数据")
                    // 加载到的数据添加到列表中
                    transactions.append(contentsOf: newTransactions)
                    
                    // 关键修复：如果这次加载的数据少于pageSize，说明已经没有更多数据了
                    if newTransactions.count < pageSize {
                        hasMoreData = false
                        print("数据已全部加载完成，没有更多数据")
                    } else {
                        // 只有确实有更多数据时才增加页码
                        currentPage += 1
                    }
                    
                case .failure(let error):
                    print("加载交易数据失败：\(error)")
                    hasError = true
                    errorMessage = error.localizedDescription
                    // 出错时也应该停止显示加载更多
                    hasMoreData = false
                }
            }
        }
    }
    
    private func loadMonthlySummary() {
        // 获取当前选择的月份
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let monthString = dateFormatter.string(from: selectedMonth)
        
        // 确定类型和分类参数（与loadTransactions中相同的逻辑）
        var type = ""
        var category = ""
        
        switch selectedFilter {
        case .all: 
            type = ""
            category = ""
        case .expense:
            type = "expense"
            category = ""
        case .income:
            type = "income"
            category = ""
        case .food:
            type = "expense"
            category = "food"
        case .shopping:
            type = "expense"
            category = "shopping"
        case .transport:
            type = "expense"
            category = "transport"
        case .entertainment:
            type = "expense"
            category = "entertainment"
        case .housing:
            type = "expense"
            category = "housing"
        case .medical:
            type = "expense"
            category = "medical"
        case .education:
            type = "expense"
            category = "education"
        case .gift:
            type = "expense"
            category = "gift"
        case .salary:
            type = "income"
            category = "salary"
        case .other:
            type = "expense"
            category = "other"
        }
        
        NetworkService.shared.getHomeSummary(
            type: type,
            category: category,
            queryType: 2,  // 默认为2，与其他请求保持一致
            queryMonth: monthString,  // 使用选中的月份
            completion: { income, balance, expense in
                DispatchQueue.main.async {
                    self.monthlyIncome = income
                    self.monthlyBalance = balance
                    self.monthlyExpense = expense
                }
            }, 
            failure: {
                print("获取月度统计失败")
            }
        )
    }
    
    private func loadMoreTransactions() {
        loadTransactions()
    }
    
    private func refreshData() {
        transactions = []
        currentPage = 1
        hasMoreData = true
        loadTransactions()
        loadMonthlySummary()
    }
    
    // 添加日期格式化辅助函数
    private func formatDateHeader(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            dateFormatter.dateFormat = "MM月dd日"
            return dateFormatter.string(from: date)
        }
    }
}

// 月份选择器组件
struct MonthSelector: View {
    @Binding var selectedMonth: Date
    
    var body: some View {
        HStack {
            Button(action: {
                selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.pinkPrimary.opacity(0.7))
            }
            
            Spacer()
            
            Text(monthYearFormatter.string(from: selectedMonth))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: {
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                if nextMonth <= Date() {
                    selectedMonth = nextMonth
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.pinkPrimary.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }
}

// 月度统计卡片组件
struct MonthlySummaryCard: View {
    let income: Double
    let expense: Double
    let balance: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("本月支出")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    Text("¥\(String(format: "%.2f", expense))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("本月收入")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    Text("¥\(String(format: "%.2f", income))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("本月结余")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    Text("¥\(String(format: "%.2f", balance))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: AppColors.pinkPrimary.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// 筛选标签组件
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                }
                
                Text(title)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.pinkPrimary : AppColors.pinkLight)
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .cornerRadius(20)
        }
    }
}

// 日期标题组件
struct DateHeader: View {
    let date: Date
    let transactions: [Transaction]
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "calendar.day.fill")
                    .foregroundColor(AppColors.pinkPrimary)
                    .font(.system(size: 14))
                
                Text(formattedDate)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                let dailyIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                let dailyExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                
                if dailyIncome > 0 {
                    Text("收入 ¥\(String(format: "%.2f", dailyIncome))")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
                
                if dailyIncome > 0 && dailyExpense > 0 {
                    Text("|")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if dailyExpense > 0 {
                    Text("支出 ¥\(String(format: "%.2f", dailyExpense))")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.pinkPrimary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppColors.background)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        
        // 判断是否是今天、昨天或前天
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "今天"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "昨天"
        } else {
            formatter.dateFormat = "MM月dd日"
        }
        
        return formatter.string(from: date)
    }
}

// 交易项组件
struct TransactionItem: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
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
                // 上面只显示分类名称
                Text(category.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                // 下面显示时间、创建者和支付方式
                HStack(spacing: 4) {
                    Text(timeFormatter.string(from: transaction.date))
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    // 创建者信息
                    if let createdBy = transaction.createdBy, !createdBy.isEmpty {
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(createdBy)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.pinkPrimary)
                    }
                    
                    Text("·")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("支付宝")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // 金额
            Text(transaction.formattedAmount)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(transaction.isExpense ? .red : (transaction.isIncome ? .green : AppColors.textPrimary))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

extension DateFormatter {
    func then(_ configure: (DateFormatter) -> DateFormatter) -> DateFormatter {
        return configure(self)
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
} 