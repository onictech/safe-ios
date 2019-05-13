//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// New request that uses Ethereum's create2 operation code on the backend.
///
/// This allows to calculate safe address off-chain by knowing initialization data that is
/// going to be sent to the contract during creation.
///
/// Before create2, to calculate the to-be-deployed safe address, we would generate a signature
/// of a creation transaction partly on the client side, partly on the server side,
/// and based on that signature's owner nonce we would generate contract address.
/// With create2, the Ethereum blockchain now allows to calculate the to-be-deployed contract address
/// by just knowing the transaction contents that will deploy the contract.
public struct SafeCreation2Request: Codable {

    /// Number used once, generated by the client (the app). **Important**: use random value.
    public let saltNonce: String

    /// Addresses of signers. Hexadecimal numbers as strings of format 0x... . 0-address is forbidden.
    public let owners: [String]

    /// Transaction confirmation count. Values from 1 to `owners.count`
    public let threshold: Int

    /// Address of a token to pay for creation.
    public let paymentToken: String

    public init(saltNonce: BigUInt, owners: [Address], confirmationCount: Int, paymentToken: Address) {
        precondition(!owners.isEmpty, "Must have at least one owner but owners parameter is empty array")
        precondition((1...owners.count).contains(confirmationCount),
                     "Invalid threshold parameter value: '\(confirmationCount)'")
        for owner in owners {
            precondition(!owner.isZero, "Owner's address '\(owner.value)' must be non-zero 20 bytes")
        }
        self.saltNonce = String(saltNonce)
        self.owners = owners.map { $0.value }
        self.threshold = confirmationCount
        self.paymentToken = paymentToken.value
    }

    public struct Response: Codable {

        public let safe: String
        public let masterCopy: String
        public let proxyFactory: String
        public let paymentToken: String
        public let payment: Int
        public let paymentReceiver: String
        public let setupData: String

        /// Expected gas (eth)
        public let gasEstimated: Int

        /// Expected eth price per 1 gas
        public let gasPriceEstimated: Int

        /// Safe address (calculated based on the initial transaction data)
        public var safeAddress: Address {
            return Address(safe)
        }

        /// Address of a master contract (actual smart contract code)
        public var masterCopyAddress: Address {
            return Address(masterCopy)
        }

        /// Address of a contract that creates a "proxy" contract, which relays all calls to master contract.
        public var proxyFactoryAddress: Address {
            return Address(proxyFactory)
        }

        /// The ERC20 payment token (or 0x0 address for Ether)
        public var paymentTokenAddress: Address {
            return Address(paymentToken)
        }

        /// The contract creation fee
        public var deploymentFee: BigInt {
            return BigInt(payment)
        }

        /// Receiver of creation fee.
        ///
        /// The contract is deployed by an API service, which is a source of creation transaction.
        /// The gas costs for running that transaction are deducted from paymentReceiver.
        public var paymentReceiverAddress: Address {
            return Address(paymentReceiver)
        }

        // swiftlint:disable line_length
        /// The part of the init_data of the safe creation transaction.
        ///
        /// ABI-encoded call to the `GnosisSafe.setup()` method. This is needed for calculating the
        /// safe's address
        ///
        /// See Also:
        /// - `GnosisSafeContractProxy.setup()`
        /// - https://github.com/gnosis/safe-contracts/blob/703dde2ea9882a35762146844d5cfbeeec73e36f/contracts/GnosisSafe.sol#L52
        public var setupDataValue: Data {
            return Data(hex: setupData)
        }

    }

}
