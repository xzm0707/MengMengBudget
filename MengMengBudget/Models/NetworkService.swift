import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8080/api"
    private var authToken: String?
    
    private init() {}

    // 在NetworkService类中添加注册方法
func register(id: String, username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
    let registerURL = URL(string: "\(baseURL)/auth/register")!
    var request = URLRequest(url: registerURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let registerData = ["id": id, "username": username, "password": password]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: registerData)
    } catch {
        completion(false, "数据序列化失败")
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "网络请求失败: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            completion(false, "没有返回数据")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let code = json["code"] as? Int {
                if code == 200 {
                    completion(true, nil)
                } else {
                    let message = json["message"] as? String ?? "注册失败"
                    completion(false, message)
                }
            } else {
                completion(false, "响应格式不正确")
            }
        } catch {
            completion(false, "解析响应失败")
        }
    }.resume()
}
    
  // 修改login方法，添加用户名和密码参数
func login(id: String, password: String, completion: @escaping (Bool, String?) -> Void) {
    let loginURL = URL(string: "\(baseURL)/auth/login")!
    var request = URLRequest(url: loginURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let loginData = ["id": id, "username": id, "password": password]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
    } catch {
        completion(false, "数据序列化失败")
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, "网络请求失败: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            completion(false, "没有返回数据")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let code = json["code"] as? Int {
                if code == 200,
                   let dataObj = json["data"] as? [String: Any],
                   let token = dataObj["token"] as? String {
                    // 确保token格式正确，如果后端返回的不包含"Bearer "前缀，则添加
                    if !token.starts(with: "Bearer ") {
                        self.authToken = "Bearer \(token)"
                    } else {
                        self.authToken = token
                    }
                    completion(true, nil)
                } else {
                    let message = json["message"] as? String ?? "登录失败"
                    completion(false, message)
                }
            } else {
                completion(false, "响应格式不正确")
            }
        } catch {
            completion(false, "解析响应失败")
        }
    }.resume()
}
    
    func getHomeSummary(completion: @escaping (Double, Double, Double) -> Void, failure: @escaping () -> Void) {
        guard let token = authToken else {
            print("未登录，请先登录")
            failure()
            return
        }

        print("开始获取首页数据，使用token: \(token)")
        let summaryURL = URL(string: "\(baseURL)/transactions/home-summary")!
        var request = URLRequest(url: summaryURL)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        print("发送请求: \(summaryURL)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("获取首页数据失败: \(error)")
                failure()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("收到响应，状态码: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("获取首页数据没有返回数据")
                failure()
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("响应数据: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let code = json["code"] as? Int,
                   code == 200,
                   let dataObj = json["data"] as? [String: Any] {
                    
                    // 打印完整的数据对象，帮助调试
                    print("解析到的数据对象: \(dataObj)")
                    
                    let income = (dataObj["income"] as? Double) ?? 0.0
                    let balance = (dataObj["balance"] as? Double) ?? 0.0
                    let expense = (dataObj["expense"] as? Double) ?? 0.0
                    
                    print("解析到的数据: income=\(income), balance=\(balance), expense=\(expense)")
                    
                    DispatchQueue.main.async {
                        completion(income, balance, expense)
                    }
                } else {
                    print("首页数据响应格式不正确")
                    failure()
                }
            } catch {
                print("解析首页数据响应失败: \(error)")
                failure()
            }
        }.resume()
    }

    // 在NetworkService类中添加
    func clearToken() {
        self.authToken = nil
    }

    // 在NetworkService类中添加
    func getToken() -> String? {
        return authToken
    }

    // 在NetworkService类中添加
    func isLoggedIn() -> Bool {
        return authToken != nil && !authToken!.isEmpty
    }
}

struct HomeSummary {
    let income: Double
    let balance: Double
    let expense: Double
} 

