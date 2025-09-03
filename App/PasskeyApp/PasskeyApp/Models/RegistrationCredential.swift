

public struct RegistrationCredential: Codable {
    /// The credential ID of the newly created credential.
    public let id: URLEncodedBase64
    
    /// Value will always be "public-key" (for now)
    public let type: String
    
    /// The raw credential ID of the newly created credential.
    public let rawID: [UInt8]
    
    /// The attestation response from the authenticator.
    public let attestationResponse: AuthenticatorAttestationResponse

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case rawID = "rawId"
        case attestationResponse = "response"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.rawID.base64URLEncodedString(), forKey: .rawID)
        try container.encode(self.attestationResponse, forKey: .attestationResponse)
    }

}

public struct AuthenticatorAttestationResponse {
    /// The client data that was passed to the authenticator during the creation ceremony.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let clientDataJSON: [UInt8]
    
    /// Contains both attestation data and attestation statement.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let attestationObject: [UInt8]
}

extension AuthenticatorAttestationResponse: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        clientDataJSON = try container.decodeBytesFromURLEncodedBase64(forKey: .clientDataJSON)
        attestationObject = try container.decodeBytesFromURLEncodedBase64(forKey: .attestationObject)
    }
    
    private enum CodingKeys: String, CodingKey {
        case clientDataJSON
        case attestationObject
    }
}

extension AuthenticatorAttestationResponse: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(clientDataJSON.base64URLEncodedString(), forKey: .clientDataJSON)
        try container.encode(attestationObject.base64URLEncodedString(), forKey: .attestationObject)
    }
}

