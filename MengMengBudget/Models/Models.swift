import SwiftUI

// 交易类型
enum TransactionType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
    case transfer = "transfer"
    
    var title: String {
        switch self {
        case .expense: return "支出"
        case .income: return "收入"
        case .transfer: return "转账"
        }
    }
}

// 交易模型
struct Transaction: Identifiable {
    var id = UUID().uuidString
    var amount: Double
    var type: TransactionType
    var categoryId: String
    var accountId: String
    var date: Date
    var note: String
    
    var isExpense: Bool { type == .expense }
    var isIncome: Bool { type == .income }
    
    var formattedAmount: String {
        let prefix = isExpense ? "-" : (isIncome ? "+" : "")
        return "\(prefix)¥\(String(format: "%.2f", abs(amount)))"
    }
}

// 分类模型
struct Category: Identifiable {
    var id: String
    var name: String
    var icon: String
    var color: Color
    var backgroundColor: Color
}

// 账户模型
struct Account: Identifiable {
    var id: String
    var name: String
    var balance: Double
    var icon: String
    
    var formattedBalance: String {
        return "¥\(String(format: "%.2f", balance))"
    }
}

// 示例数据
class SampleData {
    static let categories: [Category] = [
        Category(id: "food", name: "餐饮", icon: "fork.knife", color: AppColors.pinkPrimary, backgroundColor: AppColors.pinkLight),
        Category(id: "shopping", name: "购物", icon: "bag", color: AppColors.purplePrimary, backgroundColor: AppColors.purpleLight),
        Category(id: "transport", name: "交通", icon: "car", color: AppColors.yellowPrimary, backgroundColor: AppColors.yellowLight),
        Category(id: "entertainment", name: "娱乐", icon: "gamecontroller", color: AppColors.pinkPrimary, backgroundColor: AppColors.pinkLight),
        Category(id: "housing", name: "住房", icon: "house", color: AppColors.greenPrimary, backgroundColor: AppColors.greenLight),
        Category(id: "medical", name: "医疗", icon: "heart", color: AppColors.pinkPrimary, backgroundColor: AppColors.pinkLight),
        Category(id: "education", name: "教育", icon: "book", color: AppColors.purplePrimary, backgroundColor: AppColors.purpleLight),
        Category(id: "gift", name: "礼物", icon: "gift", color: AppColors.yellowPrimary, backgroundColor: AppColors.yellowLight),
        Category(id: "salary", name: "工资", icon: "dollarsign.circle", color: AppColors.greenPrimary, backgroundColor: AppColors.greenLight),
        Category(id: "other", name: "其他", icon: "ellipsis", color: AppColors.textSecondary, backgroundColor: AppColors.pinkLight)
    ]
    
    static let accounts: [Account] = [
        Account(id: "alipay", name: "支付宝", balance: 3856.75, icon: "creditcard"),
        Account(id: "wechat", name: "微信", balance: 2458.10, icon: "message"),
        Account(id: "cash", name: "现金", balance: 1250.00, icon: "banknote"),
        Account(id: "bank", name: "工商银行", balance: 35300.45, icon: "building.columns")
    ]
    
    static let transactions: [Transaction] = [
        Transaction(
            amount: 35.0,
            type: .expense,
            categoryId: "food",
            accountId: "alipay",
            date: Date(),
            note: "午餐"
        ),
        Transaction(
            amount: 128.5,
            type: .expense,
            categoryId: "shopping",
            accountId: "wechat",
            date: Date(),
            note: "超市购物"
        ),
        Transaction(
            amount: 8750.0,
            type: .income,
            categoryId: "salary",
            accountId: "bank",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            note: "工资"
        ),
        Transaction(
            amount: 45.5,
            type: .expense,
            categoryId: "transport",
            accountId: "alipay",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            note: "打车"
        )
    ]
    
    static func getCategory(id: String) -> Category {
        return categories.first { $0.id == id } ?? categories.last!
    }
    
    static func getAccount(id: String) -> Account {
        return accounts.first { $0.id == id } ?? accounts.first!
    }
} 