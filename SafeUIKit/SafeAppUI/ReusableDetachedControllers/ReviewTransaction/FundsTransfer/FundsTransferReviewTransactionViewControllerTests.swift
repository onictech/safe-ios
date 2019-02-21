//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import SafeUIKit

class FundsTransferReviewTransactionViewControllerTests: ReviewTransactionViewControllerTests {

    // MARK: - Layout

    func test_whenLoaded_thenSetsTransactionHeaderAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let headerCell = vc.cellForRow(0) as! TransactionHeaderCell
        XCTAssertEqual(headerCell.transactionHeaderView.assetCode, data.amountTokenData.code)
        XCTAssertEqual(headerCell.transactionHeaderView.assetInfo,
                       LocalizedString("transaction.outgoing_transfer", comment: ""))
    }

    func test_whenLoaded_thenSetsTransferViewAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let transferViewCell = vc.cellForRow(1) as! TransferViewCell
        XCTAssertEqual(transferViewCell.transferView.fromAddress, data.sender)
        XCTAssertEqual(transferViewCell.transferView.toAddress, data.recipient)
        XCTAssertEqual(transferViewCell.transferView.tokenData, data.amountTokenData)
    }

    func test_whenLoadedForEtherTransfer_theneTransactionFeeCellHasCorrectValues() {
        let (data, vc) = ethDataAndCotroller()
        XCTAssertEqual(vc.cellCount(), 4)

        let cell = vc.cellForRow(2) as! TransactionFeeCell
        let balance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!

        XCTAssertEqual(cell.transactionFeeView.currentBalance?.balance,
                       balance)
        XCTAssertEqual(cell.transactionFeeView.transactionFee?.balance,
                       data.feeTokenData.balance!)
        XCTAssertEqual(cell.transactionFeeView.resultingBalance?.balance,
                       balance - data.feeTokenData.balance! - data.amountTokenData.balance!)
    }

    func test_whenLoadedForTokenTransfer_thenHasTwoTransactionFeeCellsWithCorrectValues() {
        let (data, vc) = tokenDataAndCotroller()
        XCTAssertEqual(vc.cellCount(), 5)

        let cellOne = vc.cellForRow(2) as! TransactionFeeCell
        let tokenBalance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!

        XCTAssertEqual(cellOne.transactionFeeView.currentBalance?.balance,
                       tokenBalance)
        XCTAssertNil(cellOne.transactionFeeView.transactionFee?.balance)
        XCTAssertEqual(cellOne.transactionFeeView.resultingBalance?.balance,
                       tokenBalance - data.amountTokenData.balance!)

        let cellTwo = vc.cellForRow(3) as! TransactionFeeCell
        let feeBalance = service.accountBalance(tokenID: BaseID(data.feeTokenData.address))!

        XCTAssertNil(cellTwo.transactionFeeView.currentBalance?.balance)
        XCTAssertEqual(cellTwo.transactionFeeView.transactionFee?.balance,
                       data.feeTokenData.balance!)
        XCTAssertEqual(cellTwo.transactionFeeView.resultingBalance?.balance,
                       feeBalance - data.feeTokenData.balance!)
    }

}
