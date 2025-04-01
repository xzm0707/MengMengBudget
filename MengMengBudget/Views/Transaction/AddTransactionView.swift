import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategoryId: String = "food"
    @State private var selectedAccountId: String = "alipay"
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = "保存失败，请重试"
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 金额输入
                        AmountInputView(
                            amount: $amount,
                            selectedType: $selectedType
                        )
                        
                        // 分类选择
                        CategorySelectionView(
                            selectedType: selectedType,
                            selectedCategoryId: $selectedCategoryId
                        )
                        
                        // 表单卡片
                        FormCard(
                            selectedAccountId: $selectedAccountId,
                            date: $date,
                            note: $note
                        )
                        
                        // 保存按钮
                        Button {
                            saveTransaction()
                        } label: {
                            Text("保存")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: AppColors.pinkPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .springyButton()
                        .padding(.top, 10)
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("添加交易")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .springyButton()
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("错误"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
    }
    
    private func saveTransaction() {
           // 验证输入
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "请输入有效金额"
            showError = true
            return
        }
        
        isLoading = true
        
        // 准备请求数据
        let transactionData: [String: Any] = [
            "type": selectedType.rawValue,
            "amount": amountValue,
            "category": selectedCategoryId,
            "description": note
        ]
        
        // 调用API保存交易
        NetworkService.shared.addTransaction(data: transactionData) { success, message in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    // 发送通知，刷新首页数据
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshHomeData"), object: nil)
                    
                    // 关闭视图
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = message ?? "保存失败，请重试"
                    showError = true
                }
            }
        }
    }
}

// 金额输入视图
struct AmountInputView: View {
    @Binding var amount: String
    @Binding var selectedType: TransactionType
    
    var body: some View {
        VStack(spacing: 15) {
            // 类型选择器
            typeSelector
            
            // 金额输入框
            amountInput
        }
    }
    
    // 将类型选择器拆分为计算属性
    private var typeSelector: some View {
        HStack {
            ForEach(TransactionType.allCases, id: \.self) { type in
                typeButton(for: type)
            }
        }
    }
    
    // 单个类型按钮
    private func typeButton(for type: TransactionType) -> some View {
        Button {
            selectedType = type
        } label: {
            Text(type.title)
                .font(.headline)
                .foregroundColor(selectedType == type ? .white : AppColors.textPrimary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if selectedType == type {
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            AppColors.card
                        }
                    }
                )
                .cornerRadius(12)
                .shadow(
                    color: selectedType == type ?
                        AppColors.pinkPrimary.opacity(0.3) :
                        Color.black.opacity(0.05),
                    radius: 5,
                    x: 0,
                    y: 3
                )
        }
        .springyButton()
    }
    
    // 金额输入框
    private var amountInput: some View {
        HStack {
            Text("¥")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            TextField("0.00", text: $amount)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// 分类选择视图
struct CategorySelectionView: View {
    let selectedType: TransactionType
    @Binding var selectedCategoryId: String
    
    var categories: [Category] {
        SampleData.categories
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("选择分类")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategoryId == category.id
                    ) {
                        selectedCategoryId = category.id
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

// 分类按钮
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : category.backgroundColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : category.color)
                }
                
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .springyButton()
    }
}

// 表单卡片
struct FormCard: View {
    @Binding var selectedAccountId: String
    @Binding var date: Date
    @Binding var note: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 账户选择
            FormRow(icon: "creditcard", title: "账户") {
                Picker("账户", selection: $selectedAccountId) {
                    ForEach(SampleData.accounts) { account in
                        Text(account.name).tag(account.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Divider().padding(.leading, 50)
            
            // 日期选择
            FormRow(icon: "calendar", title: "日期") {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
            }
            
            Divider().padding(.leading, 50)
            
            // 备注输入
            FormRow(icon: "text.bubble", title: "备注") {
                TextField("添加备注", text: $note)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// 表单行
struct FormRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    
    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.pinkPrimary)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            content
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 12)
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
    }
} 
