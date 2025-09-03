import Foundation
import AuthenticationServices

enum PasskeyRequests {
    static func getPasskeyRegistrationFromServer() async throws -> PublicKeyCredentialCreationOptionsResponse {
        do {
            let url = URL(string: "\(PasskeyApp.apiHostname)/auth/app/makeCredentials")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw Error.apiError
            }
            let makeCredentialsData = try JSONDecoder().decode(PublicKeyCredentialCreationOptionsResponse.self, from: data)
            return makeCredentialsData
        }
        catch {
            print("ERROR: \(error)")
            throw error
        }
    }

    static func completePasskeyRegistration(account: ASAuthorizationAccountCreationPlatformPublicKeyCredential) async throws -> Data {
        let url = URL(string: "\(PasskeyApp.apiHostname)/auth/app/makeCredentials")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let registrationCredential = RegistrationCredential(id: account.credentialRegistration.credentialID.base64URLEncodedString(), type: "public-key", rawID: account.credentialRegistration.credentialID.toByteArray(), attestationResponse: .init(clientDataJSON: account.credentialRegistration.rawClientDataJSON.toByteArray(), attestationObject: account.credentialRegistration.rawAttestationObject!.toByteArray()))
        guard case let .email(email) = account.contactIdentifier else {
            throw Error.missingData
        }
        let name = "\(account.name?.givenName ?? "") \(account.name?.familyName ?? "")"
        let requestBody = CompletePasskeyRegistration(name: name, email: email.value, credential: registrationCredential)
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.apiError
        }
        return data
    }

    static func getAssertionData() async throws -> PublicKeyCredentialRequestOptionsResponse {
        do {
            let url = URL(string: "\(PasskeyApp.apiHostname)/auth/app/authenticate")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw Error.apiError
            }
            let makeCredentialsData = try JSONDecoder().decode(PublicKeyCredentialRequestOptionsResponse.self, from: data)
            return makeCredentialsData
        }
        catch {
            print("ERROR: \(error)")
            throw error
        }
    }

    static func completePasskeyAssertion(assertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) async throws -> Data {
        let url = URL(string: "\(PasskeyApp.apiHostname)/auth/app/authenticate")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        let authenticationCredential = AuthenticationCredential(id: assertion.credentialID.base64URLEncodedString(), rawID: [UInt8](assertion.credentialID), response: .init(clientDataJSON: assertion.rawClientDataJSON.toByteArray(), authenticatorData: assertion.rawAuthenticatorData.toByteArray(), signature: assertion.signature.toByteArray(), userHandle: assertion.userID.toByteArray(), attestationObject: nil), authenticatorAttachment: "\(assertion.attachment)", type: "public-key")
        urlRequest.httpBody = try JSONEncoder().encode(authenticationCredential)

        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.apiError
        }
        return data
    }


    enum Error: Swift.Error {
        case apiError
        case missingData
    }

}

extension Data {
    func toByteArray() -> [UInt8] {
        return [UInt8](self)
    }
}
