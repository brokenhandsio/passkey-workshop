import Foundation

struct ResourceRequest<ResourceType> where ResourceType: Codable {
    let resourceURL: URL
    
    init(apiHostname: String, resourcePath: String) {
        let baseURL = "\(apiHostname)/"
        guard let resourceURL = URL(string: baseURL) else {
            fatalError("Failed to convert baseURL to a URL")
        }
        self.resourceURL =
        resourceURL.appendingPathComponent(resourcePath)
    }
    
    func getAll(auth: Auth) async throws -> [ResourceType] {
        guard let token = auth.token else {
            auth.logout()
            throw AuthError.notLoggedIn
        }
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode([ResourceType].self, from: data)
    }
    
    func save<CreateType>(_ saveData: CreateType, auth: Auth, authRequired: Bool = true) async throws -> ResourceType where CreateType: Codable {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if authRequired {
            guard let token = auth.token else {
                auth.logout()
                throw AuthError.notLoggedIn
            }
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = try JSONEncoder().encode(saveData)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResourceRequestError.noData
        }
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                auth.logout()
                throw AuthError.notLoggedIn
            }
            throw ResourceRequestError.badResponse
        }
        return try JSONDecoder().decode(ResourceType.self, from: data)
    }
}
