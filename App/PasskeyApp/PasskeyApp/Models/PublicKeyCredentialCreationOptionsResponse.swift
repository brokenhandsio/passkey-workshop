import Foundation

// MARK: - Top-level options

public struct PublicKeyCredentialCreationOptionsResponse: Decodable {
    /// Random challenge from the RP (decoded from base64url)
    public let challenge: [UInt8]

    /// User entity (with base64url-decoded id)
    public let user: PublicKeyCredentialUserEntityResponse

    /// Relying Party entity
    public let relyingParty: PublicKeyCredentialRpEntity

    /// Supported credential parameters
    public let publicKeyCredentialParameters: [PublicKeyCredentialParameters]

    /// Timeout (hint) in milliseconds
    public let timeoutInMilliseconds: UInt32?

    /// Attestation conveyance preference
    public let attestation: AttestationConveyancePreference

    private enum CodingKeys: String, CodingKey {
        case challenge
        case user
        case relyingParty = "rp"
        case publicKeyCredentialParameters = "pubKeyCredParams"
        case timeoutInMilliseconds = "timeout"
        case attestation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // challenge is base64url-encoded
        let challengeB64Url = try container.decode(String.self, forKey: .challenge)
        guard let challengeB64Data = URLEncodedBase64(challengeB64Url).decodedBytes else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [],
                      debugDescription: "Invalid base64url string")
            )
        }
        self.challenge = challengeB64Data

        self.user = try container.decode(PublicKeyCredentialUserEntityResponse.self, forKey: .user)
        self.relyingParty = try container.decode(PublicKeyCredentialRpEntity.self, forKey: .relyingParty)
        self.publicKeyCredentialParameters = try container.decode([PublicKeyCredentialParameters].self, forKey: .publicKeyCredentialParameters)
        self.timeoutInMilliseconds = try container.decodeIfPresent(UInt32.self, forKey: .timeoutInMilliseconds)
        self.attestation = try container.decode(AttestationConveyancePreference.self, forKey: .attestation)
    }
}

// MARK: - Credential parameters

public struct PublicKeyCredentialParameters: Decodable, Equatable {
    /// "public-key"
    public let type: String
    /// COSE algorithm identifier (e.g., -7 = ES256)
    public let alg: COSEAlgorithmIdentifier
}

// Keep as an enum with strict decoding. If you prefer to allow unknown values,
// change this to a wrapper struct with a raw Int.
public enum COSEAlgorithmIdentifier: Int, Decodable {
    case es256 = -7     // ECDSA w/ SHA-256 over P-256
    case algES384 = -35 // AlgES384 ECDSA with SHA-384
    case algES512 = -36 // AlgES512 ECDSA with SHA-512

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        guard let alg = COSEAlgorithmIdentifier(rawValue: value) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Unsupported COSE alg \(value)")
            )
        }
        self = alg
    }
}

// MARK: - Entities

public struct PublicKeyCredentialRpEntity: Decodable {
    public let id: String
    public let name: String
}

public struct PublicKeyCredentialUserEntityResponse: Decodable {
    /// base64url-decoded bytes
    public let id: [UInt8]
    public let name: String
    public let displayName: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // user.id is base64url-encoded
        let idB64Url = try container.decode(String.self, forKey: .id)
        guard let idData = URLEncodedBase64(idB64Url).decodedBytes else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [],
                      debugDescription: "Invalid base64url string")
            )
        }
        self.id = idData
        self.name = try container.decode(String.self, forKey: .name)
        self.displayName = try container.decode(String.self, forKey: .displayName)
    }
}

// MARK: - Attestation

public enum AttestationConveyancePreference: String, Decodable {
    case none
    case indirect
    case direct
    case enterprise
}

