import SwiftUI

struct ProfileView: View {
    @State private var familyCode: String = ""
    @State private var isGeneratingCode = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var avatarImage: Image = Image(systemName: "person.circle.fill")
    @State private var username: String = "用户"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 头像和用户名
                    VStack(spacing: 15) {
                        avatarImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.pinkPrimary)
                            .background(Circle().fill(AppColors.pinkLight))
                            .padding(5)
                            .background(Circle().stroke(AppColors.pinkPrimary, lineWidth: 2))
                        
                        Text(username)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.vertical, 20)
                    
                    // 设置项
                    VStack(spacing: 0) {
                        // 账户管理
                        SettingItemView(
                            icon: "folder.fill",
                            iconColor: Color.yellow,
                            title: "账户管理",
                            action: {}
                        )
                        
                        Divider().padding(.leading, 50)
                        
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
                    .background(AppColors.card)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // 家庭码显示区域
                    if !familyCode.isEmpty {
                        VStack(spacing: 10) {
                            Text("您的家庭码")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(familyCode)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(AppColors.pinkLight)
                                .cornerRadius(8)
                                .foregroundColor(AppColors.pinkPrimary)
                            
                            Button {
                                UIPasteboard.general.string = familyCode
                                alertMessage = "家庭码已复制到剪贴板"
                                showAlert = true
                            } label: {
                                Label("复制家庭码", systemImage: "doc.on.doc")
                                    .foregroundColor(AppColors.pinkPrimary)
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(AppColors.card)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    }
                    
                    // 退出登录按钮
                    Button {
                        logout()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("退出登录")
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
                    .padding(.top, 20)
                }
                .padding(.bottom, 100) // 为底部TabBar留出空间
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("个人设置")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
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
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 