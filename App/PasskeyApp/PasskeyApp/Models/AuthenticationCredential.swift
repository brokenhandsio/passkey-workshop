import Foundation

public struct AuthenticationCredential {
    /// The credential ID of the newly created credential.
    public let id: URLEncodedBase64

    /// The raw credential ID of the newly created credential.
    public let rawID: [UInt8]

    /// The attestation response from the authenticator.
    public let response: AuthenticatorAssertionResponse

    /// Reports the authenticator attachment modality in effect at the time the navigator.credentials.create() or
    /// navigator.credentials.get() methods successfully complete
    public let authenticatorAttachment: String?

    /// Value will always be "public-key" (for now)
    public let type: String
}

extension AuthenticationCredential: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(URLEncodedBase64.self, forKey: .id)
        rawID = try container.decodeBytesFromURLEncodedBase64(forKey: .rawID)
        response = try container.decode(AuthenticatorAssertionResponse.self, forKey: .response)
        authenticatorAttachment = try container.decodeIfPresent(String.self, forKey: .authenticatorAttachment)
        type = try container.decode(String.self, forKey: .type)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.rawID.base64URLEncodedString(), forKey: .rawID)
        try container.encode(self.response, forKey: .response)
        try container.encodeIfPresent(self.authenticatorAttachment, forKey: .authenticatorAttachment)
        try container.encode(self.type, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case rawID = "rawId"
        case response
        case authenticatorAttachment
        case type
    }
}

public struct AuthenticatorAssertionResponse {
    /// Representation of what we passed to `navigator.credentials.get()`
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let clientDataJSON: [UInt8]

    /// Contains the authenticator data returned by the authenticator.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let authenticatorData: [UInt8]

    /// Contains the raw signature returned from the authenticator
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let signature: [UInt8]

    /// Contains the user handle returned from the authenticator, or null if the authenticator did not return
    /// a user handle. Used by to give scope to credentials.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let userHandle: [UInt8]?

    /// Contains an attestation object, if the authenticator supports attestation in assertions.
    /// The attestation object, if present, includes an attestation statement. Unlike the attestationObject
    /// in an AuthenticatorAttestationResponse, it does not contain an authData key because the authenticator
    /// data is provided directly in an AuthenticatorAssertionResponse structure.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let attestationObject: [UInt8]?
}

extension AuthenticatorAssertionResponse: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        clientDataJSON = try container.decodeBytesFromURLEncodedBase64(forKey: .clientDataJSON)
        authenticatorData = try container.decodeBytesFromURLEncodedBase64(forKey: .authenticatorData)
        signature = try container.decodeBytesFromURLEncodedBase64(forKey: .signature)
        userHandle = try container.decodeBytesFromURLEncodedBase64IfPresent(forKey: .userHandle)
        attestationObject = try container.decodeBytesFromURLEncodedBase64IfPresent(forKey: .attestationObject)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.clientDataJSON.base64URLEncodedString(), forKey: .clientDataJSON)
        try container.encode(self.authenticatorData.base64URLEncodedString(), forKey: .authenticatorData)
        try container.encode(self.signature.base64URLEncodedString(), forKey: .signature)
        try container.encodeIfPresent(self.userHandle?.base64URLEncodedString(), forKey: .userHandle)
        try container.encodeIfPresent(self.attestationObject?.base64URLEncodedString(), forKey: .attestationObject)
    }

    private enum CodingKeys: String, CodingKey {
        case clientDataJSON
        case authenticatorData
        case signature
        case userHandle
        case attestationObject
    }
}
