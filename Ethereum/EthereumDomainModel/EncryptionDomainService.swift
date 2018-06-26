//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public typealias RSVSignature = (r: String, s: String, v: Int)

public protocol EncryptionDomainService {

    func address(browserExtensionCode: String) -> String?
    func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount
    func randomData(byteCount: Int) throws -> Data
    func sign(message: String, privateKey: PrivateKey) throws -> RSVSignature

}
