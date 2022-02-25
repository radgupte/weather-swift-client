import Alamofire

public protocol WeatherService {
    func getTemperature(completion: @escaping (_ response: Result<Int /* Temperature */, Error>) -> Void)
    func getGreeting(completion: @escaping (_ response: Result<String /* Greeting */, Error>) -> Void)
}

public class WeatherServiceImpl: WeatherService {
    let w_url = "http://54.189.99.230:3000/v1/weather"
    let auth_url = "http://54.189.99.230:3000/v1/auth"
    let h_url = "http://54.189.99.230:3000/v1/hello"
    let parameters = ["username": "rad", "password": "abc54321"]

    public func getTemperature(completion: @escaping (_ response: Result<Int /* Temperature */, Error>) -> Void) {
        AF.request(auth_url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200..<300).responseDecodable(of: Auth.self) { response in
        switch response.result {
            case let .success(auth):
                print(auth)
                let token = auth.access_token
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                AF.request(self.w_url, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300).responseDecodable(of: Weather.self) { response in
                    switch response.result {
                    case let .success(weather):
                        let temperature = weather.main.temp
                        print(temperature)
                        let temperatureInt = Int(temperature)
                        completion(.success(temperatureInt))

                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
                case let .failure(error):
                    completion(.failure(error))
            }    
        }
    }

    public func getGreeting(completion: @escaping (_ response: Result<String /* Greeting */, Error>) -> Void) {
        AF.request(auth_url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200..<300).responseDecodable(of: Auth.self) { response in
        switch response.result {
            case let .success(auth):
                print(auth)
                let token = auth.access_token
                print(token)
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                AF.request(self.h_url, method: .get, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300).responseDecodable(of: Greeting.self) { response in
                    switch response.result {
                    case let .success(greeting):
                        let message = greeting.message
                        print(message)
                        completion(.success(message))

                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
                case let .failure(error):
                    completion(.failure(error))
            }    
        }
    }
}

private struct Weather: Decodable {
    let main: Main

    struct Main: Decodable {
        let temp: Double
    }
}

private struct Auth: Decodable {
    let access_token, expires: String
}

private struct Greeting: Decodable {
    let message: String
}
