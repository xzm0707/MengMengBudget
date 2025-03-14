import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8080/api"
    private var authToken: String?
    
    private init() {}
    
    func login(completion: @escaping (Bool) -> Void) {
        let loginURL = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = ["id": "lb", "username": "lb", "password": "123"]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        } catch {
            print("登录数据序列化失败: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("登录请求失败: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("登录没有返回数据")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let code = json["code"] as? Int,
                   code == 200,
                   let dataObj = json["data"] as? [String: Any],
                   let token = dataObj["token"] as? String {
                    self.authToken = token
                    print("登录成功，获取到token")
                    completion(true)
                } else {
                    print("登录响应格式不正确")
                    completion(false)
                }
            } catch {
                print("解析登录响应失败: \(error)")
                completion(false)
            }
        }.resume()
    }
    
    func getHomeSummary(completion: @escaping (Double, Double, Double) -> Void, failure: @escaping () -> Void) {
        guard let token = authToken else {
            print("未登录，请先登录")
            failure()
            return
        }
        
        let summaryURL = URL(string: "\(baseURL)/transactions/home-summary")!
        var request = URLRequest(url: summaryURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("获取首页数据失败: \(error)")
                failure()
                return
            }
            
            guard let data = data else {
                print("获取首页数据没有返回数据")
                failure()
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let code = json["code"] as? Int,
                   code == 200,
                   let dataObj = json["data"] as? [String: Any],
                   let income = dataObj["income"] as? Double,
                   let balance = dataObj["balance"] as? Double,
                   let expense = dataObj["expense"] as? Double {
                    
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
}

struct HomeSummary {
    let income: Double
    let balance: Double
    let expense: Double
} 