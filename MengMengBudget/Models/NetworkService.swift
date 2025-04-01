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
    
    func getHomeSummary(type: String, category: String, queryType: Int, queryMonth: String, completion: @escaping (Double, Double, Double) -> Void, failure: @escaping () -> Void) {
        guard let token = authToken else {
            print("未登录，请先登录")
            failure()
            return
        }

        print("开始获取首页数据，使用token: \(token)")
        let summaryURL = URL(string: "\(baseURL)/transactions/home-summary")!
        var request = URLRequest(url: summaryURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        // 准备请求参数
        let parameters: [String: Any] = [
            "type": type,
            "category": category,
            "queryType": queryType,
            "queryMonth": queryMonth
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
            
            print("发送请求: \(summaryURL), 参数: \(parameters)")
            
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
        } catch {
            print("准备请求数据失败: \(error)")
            failure()
        }
    }

    // 在 NetworkService 类中添加
func getRecentTransactions(completion: @escaping ([Transaction]) -> Void, failure: @escaping () -> Void) {
    guard let token = authToken else {
        print("未登录，请先登录")
        failure()
        return
    }
    
    print("开始获取最近交易数据，使用token: \(token)")
    let recentURL = URL(string: "\(baseURL)/transactions/home-rencent")!
    var request = URLRequest(url: recentURL)
    request.httpMethod = "GET"
    request.addValue(token, forHTTPHeaderField: "Authorization")
    
    print("发送请求: \(recentURL)")
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("获取最近交易数据失败: \(error)")
            failure()
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("收到响应，状态码: \(httpResponse.statusCode)")
        }
        
        guard let data = data else {
            print("获取最近交易数据没有返回数据")
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
               let dataArray = json["data"] as? [[String: Any]] {
                
                var transactions: [Transaction] = []
                
                for item in dataArray {
                    let id = String(describing: item["id"] ?? "")
                    let amount = (item["amount"] as? Double) ?? 0.0
                    let typeString = (item["type"] as? String) ?? "expense"
                    let type = TransactionType(rawValue: typeString) ?? .expense
                    let category = (item["category"] as? String) ?? ""
                    let description = (item["description"] as? String) ?? ""
                    let userId = (item["userId"] as? String)
                    let createdBy = (item["createdBy"] as? String)
                    
                    // 解析日期
                    var date = Date()
                    if let dateString = item["createdAt"] as? String {
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime]
                        if let parsedDate = formatter.date(from: dateString) {
                            date = parsedDate
                        }
                    }
                    
                    let transaction = Transaction(
                        id: id,
                        amount: amount,
                        type: type,
                        categoryId: category,
                        accountId: "default", // 假设默认账户
                        date: date,
                        note: description,
                        userId: userId,
                        createdBy: createdBy
                    )
                    
                    transactions.append(transaction)
                }
                
                DispatchQueue.main.async {
                    completion(transactions)
                }
            } else {
                print("最近交易数据响应格式不正确")
                failure()
            }
        } catch {
            print("解析最近交易数据响应失败: \(error)")
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

    // 在 NetworkService 类中添加
    func addTransaction(data: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken else {
            print("未登录，请先登录")
            completion(false, "未登录，请先登录")
            return
        }
        
        let addURL = URL(string: "\(baseURL)/transactions/add")!
        var request = URLRequest(url: addURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
            
            print("发送添加交易请求: \(data)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("添加交易失败: \(error)")
                    completion(false, "网络错误，请重试")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("收到响应，状态码: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode != 200 {
                        completion(false, "服务器错误 (状态码: \(httpResponse.statusCode))")
                        return
                    }
                }
                
                guard let data = data else {
                    print("添加交易没有返回数据")
                    completion(false, "没有收到服务器响应")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("响应数据: \(responseString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let code = json["code"] as? Int {
                        if code == 200 {
                            completion(true, nil)
                        } else {
                            let message = (json["message"] as? String) ?? "保存失败，请重试"
                            completion(false, message)
                        }
                    } else {
                        completion(false, "解析响应失败")
                    }
                } catch {
                    print("解析添加交易响应失败: \(error)")
                    completion(false, "解析响应失败")
                }
            }.resume()
        } catch {
            print("准备请求数据失败: \(error)")
            completion(false, "准备请求数据失败")
        }
    }

    // 在 NetworkService 类中添加
    enum NetworkError: Error {
        case unauthorized
        case serverError(String)
        case decodingError
        case noData
    }

    func getAllTransactions(
        type: String,
        category: String,
        queryType: Int,
        queryMonth: String,
        pageNum: Int,
        pageSize: Int,
        completion: @escaping (Result<[Transaction], Error>) -> Void
    ) {
        guard let token = authToken else {
            print("未登录，请先登录")
            completion(.failure(NetworkError.unauthorized))
            return
        }
        
        let url = URL(string: "\(baseURL)/transactions/home-all")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        // 准备请求参数
        let parameters: [String: Any] = [
            "type": type,
            "category": category,
            "queryType": queryType,
            "queryMonth": queryMonth,
            "pageNum": pageNum,
            "pageSize": pageSize
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
            
            print("发送获取所有交易请求: \(url), 参数: \(parameters)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("获取所有交易失败: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("收到响应，状态码: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        completion(.failure(NetworkError.unauthorized))
                        return
                    }
                    
                    if httpResponse.statusCode != 200 {
                        completion(.failure(NetworkError.serverError("服务器错误 (状态码: \(httpResponse.statusCode))")))
                        return
                    }
                }
                
                guard let data = data else {
                    print("获取所有交易没有返回数据")
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("响应数据: \(responseString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let code = json["code"] as? Int,
                       code == 200,
                       let dataObj = json["data"] as? [String: Any],
                       let transactionsList = dataObj["list"] as? [[String: Any]] {
                        
                        print("成功解析分页数据，共有 \(transactionsList.count) 条交易记录")
                        
                        var transactions: [Transaction] = []
                        
                        for item in transactionsList {
                            let id = String(describing: item["id"] ?? "")
                            let amount = (item["amount"] as? Double) ?? 0.0
                            let typeString = (item["type"] as? String) ?? "expense"
                            let type = TransactionType(rawValue: typeString) ?? .expense
                            let category = (item["category"] as? String) ?? ""
                            let description = (item["description"] as? String) ?? ""
                            let userId = (item["userId"] as? String)
                            let createdBy = (item["createdBy"] as? String)
                            
                            // 解析日期
                            var date = Date()
                            if let dateString = item["createdAt"] as? String {
                                let formatter = ISO8601DateFormatter()
                                formatter.formatOptions = [.withInternetDateTime]
                                if let parsedDate = formatter.date(from: dateString) {
                                    date = parsedDate
                                }
                            }
                            
                            let transaction = Transaction(
                                id: id,
                                amount: amount,
                                type: type,
                                categoryId: category,
                                accountId: "default", // 假设默认账户
                                date: date,
                                note: description,
                                userId: userId,
                                createdBy: createdBy
                            )
                            
                            transactions.append(transaction)
                        }
                        
                        // 检查是否还有更多页
                        let hasNextPage = (dataObj["hasNextPage"] as? Bool) ?? false
                        
                        print("解析完成，获取到 \(transactions.count) 条交易记录，是否有下一页: \(hasNextPage)")
                        
                        // 如果当前页是最后一页，通知视图没有更多数据
                        if !hasNextPage {
                            completion(.success(transactions))
                        } else {
                            completion(.success(transactions))
                        }
                    } else {
                        print("解析交易数据失败，数据格式不符合预期")
                        completion(.failure(NetworkError.decodingError))
                    }
                } catch {
                    print("解析所有交易响应失败: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            print("准备请求数据失败: \(error)")
            completion(.failure(error))
        }
    }
}

struct HomeSummary {
    let income: Double
    let balance: Double
    let expense: Double
} 

