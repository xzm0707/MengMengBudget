import SwiftUI

struct ProfileView: View {
    @State private var familyCode: String = ""
    @State private var isGeneratingCode = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var avatarImage: Image = Image(systemName: "person.circle.fill")
    @State private var username: String = "用户"
    @State private var showFamilyCodeModal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 头像和用户名卡片
                    VStack(spacing: 10) {
                        avatarImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Circle().fill(AppColors.pinkPrimary))
                            .padding(5)
                        
                        Text(username)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(AppColors.background)
                    
                    // 设置项卡片
                    VStack(spacing: 0) {
                        // 账户管理
                        SettingItemView(
                            icon: "folder.fill",
                            iconColor: Color.yellow,
                            title: "账户管理",
                            action: {}
                        )
                        
                        Divider().padding(.leading, 60)
                        
                        // 生成家庭码
                        SettingItemView(
                            icon: "qrcode",
                            iconColor: Color.green,
                            title: "生成家庭码",
                            action: {
                                generateFamilyCode()
                            }
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // 退出登录按钮
                    Button {
                        logout()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 18))
                            Text("退出登录")
                                .font(.system(size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.pinkStart, AppColors.pinkEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 100) // 为底部TabBar留出空间
            }
            .background(AppColors.background.ignoresSafeArea())
            // 移除顶部标题
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // 空的ToolbarItem，移除"个人设置"标题
                    EmptyView()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
            .overlay(
                Group {
                    if isGeneratingCode {
                        ProgressView("生成中...")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            )
            // 添加家庭码显示弹窗
            .sheet(isPresented: $showFamilyCodeModal) {
                FamilyCodeView(familyCode: familyCode)
            }
        }
        .onAppear {
            loadUserInfo()
        }
        // 添加这一行，明确指定导航视图样式
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 添加加载用户信息的方法
    private func loadUserInfo() {
        if let token = NetworkService.shared.getToken() {
            // 从token中解析用户名（假设token是JWT格式）
            let tokenParts = token.split(separator: ".")
            if tokenParts.count > 1,
               let payload = Data(base64Encoded: String(tokenParts[1])),
               let json = try? JSONSerialization.jsonObject(with: payload, options: []) as? [String: Any],
               let sub = json["sub"] as? String {
                username = sub
            }
        }
    }
    
    private func generateFamilyCode() {
        isGeneratingCode = true
        
        guard let url = URL(string: "http://localhost:8080/api/auth/generate-family") else {
            alertMessage = "无效的URL"
            showAlert = true
            isGeneratingCode = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 添加Authorization头
        if let token = NetworkService.shared.getToken() {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        } else {
            alertMessage = "未登录，请先登录"
            showAlert = true
            isGeneratingCode = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isGeneratingCode = false
                
                if let error = error {
                    alertMessage = "请求失败: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let data = data else {
                    alertMessage = "没有返回数据"
                    showAlert = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let code = json["code"] as? Int {
                        if code == 200,
                           let dataObj = json["data"] as? String {
                            familyCode = dataObj
                            // 显示家庭码弹窗
                            showFamilyCodeModal = true
                        } else {
                            let message = json["message"] as? String ?? "生成家庭码失败"
                            alertMessage = message
                            showAlert = true
                        }
                    } else {
                        alertMessage = "响应格式不正确"
                        showAlert = true
                    }
                } catch {
                    alertMessage = "解析响应失败"
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func logout() {
        NetworkService.shared.clearToken()
        // 通知ContentView登出
        NotificationCenter.default.post(name: NSNotification.Name("LogoutNotification"), object: nil)
    }
}

// 修改设置项视图样式
struct SettingItemView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
    }
}

// 家庭码视图保持不变
struct FamilyCodeView: View {
    @Environment(\.presentationMode) var presentationMode
    let familyCode: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("您的家庭码")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(familyCode)
                    .font(.system(.title2, design: .monospaced))
                    .padding()
                    .background(AppColors.pinkLight)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.pinkPrimary)
                
                Button {
                    UIPasteboard.general.string = familyCode
                    // 复制后自动关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("复制家庭码")
                    }
                    .font(.headline)
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
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 