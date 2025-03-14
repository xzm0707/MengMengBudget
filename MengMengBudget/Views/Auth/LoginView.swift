import SwiftUI

struct LoginView: View {
    @State private var id = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingAlert = false
    @State private var animationAmount: CGFloat = 1
    @State private var keyboardHeight: CGFloat = 0
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // 可爱的动画图片
                    ZStack {
                        Circle()
                            .fill(AppColors.pinkLight)
                            .frame(width: 120, height: 120)
                            .scaleEffect(animationAmount)
                            .opacity(2 - animationAmount)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: animationAmount
                            )
                        
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(AppColors.pinkPrimary)
                            .frame(width: 50, height: 50)
                            .scaleEffect(0.8 + (animationAmount * 0.2))
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: animationAmount
                            )
                    }
                    .padding(.top, keyboardHeight > 0 ? 20 : 60)
                    .onAppear {
                        animationAmount = 1.2
                    }
                    
                    // 标题
                    VStack(spacing: 5) {
                        Text("萌萌记账")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.pinkPrimary)
                        
                        Text(isRegistering ? "创建新账号" : "欢迎回来")
                            .font(.title3)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, keyboardHeight > 0 ? 5 : 20)
                    
                    // 表单
                    VStack(spacing: 15) {
                        // 用户ID
                        VStack(alignment: .leading, spacing: 5) {
                            Text("用户ID")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(AppColors.pinkPrimary)
                                    .padding(.leading)
                                
                                TextField("请输入用户ID", text: $id)
                                    .padding()
                            }
                            .background(AppColors.card)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.pinkPrimary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // 用户名（仅注册时显示）
                        if isRegistering {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("用户名")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                HStack {
                                    Image(systemName: "person.text.rectangle.fill")
                                        .foregroundColor(AppColors.pinkPrimary)
                                        .padding(.leading)
                                    
                                    TextField("请输入用户名", text: $username)
                                        .padding()
                                }
                                .background(AppColors.card)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.pinkPrimary.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        
                        // 密码
                        VStack(alignment: .leading, spacing: 5) {
                            Text("密码")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(AppColors.pinkPrimary)
                                    .padding(.leading)
                                
                                SecureField("请输入密码", text: $password)
                                    .padding()
                            }
                            .background(AppColors.card)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.pinkPrimary.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // 错误信息
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // 按钮
                    VStack(spacing: 15) {
                        Button {
                            if isRegistering {
                                register()
                            } else {
                                login()
                            }
                        } label: {
                            HStack {
                                Image(systemName: isRegistering ? "person.badge.plus" : "arrow.right.circle")
                                    .font(.headline)
                                Text(isRegistering ? "注册" : "登录")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: AppColors.pinkPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading || id.isEmpty || password.isEmpty || (isRegistering && username.isEmpty))
                        .opacity(isLoading || id.isEmpty || password.isEmpty || (isRegistering && username.isEmpty) ? 0.6 : 1)
                        .scaleEffect(isLoading ? 0.95 : 1)
                        .animation(.spring(), value: isLoading)
                        
                        Button {
                            withAnimation {
                                isRegistering.toggle()
                                errorMessage = nil
                            }
                        } label: {
                            Text(isRegistering ? "已有账号？返回登录" : "没有账号？立即注册")
                                .font(.subheadline)
                                .foregroundColor(AppColors.pinkPrimary)
                                .underline()
                        }
                    }
                    .padding(.horizontal)
                    
                    // 添加足够的底部空间，确保键盘不会遮挡内容
                    Spacer()
                        .frame(height: max(keyboardHeight, 50))
                }
                .frame(minHeight: geometry.size.height)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.pinkStart.opacity(0.3), AppColors.pinkEnd.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            // 监听键盘显示/隐藏通知
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("注册成功"),
                message: Text("请使用新账号登录"),
                dismissButton: .default(Text("确定")) {
                    withAnimation {
                        isRegistering = false
                    }
                }
            )
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.pinkPrimary))
                        
                        Text("请稍候...")
                            .font(.caption)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                }
            }
        )
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        NetworkService.shared.login(id: id, password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    withAnimation {
                        onLoginSuccess()
                    }
                } else {
                    errorMessage = error ?? "登录失败，请检查用户名和密码"
                }
            }
        }
    }
    
    private func register() {
        isLoading = true
        errorMessage = nil
        
        NetworkService.shared.register(id: id, username: username, password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    showingAlert = true
                } else {
                    errorMessage = error ?? "注册失败，请稍后再试"
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onLoginSuccess: {})
    }
} 