//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import MultisigWalletImplementations
import DateTools

class TransactionsTableViewControllerTests: XCTestCase {

    var controller = TransactionsTableViewController.create()
    let service = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func work_in_progress_disabled_test_hasContent() {
        service.expect_grouppedTransactions(result: [])
        createWindow(controller)
        XCTAssertGreaterThan(controller.tableView.numberOfSections, 0)
        XCTAssertGreaterThan(controller.tableView.numberOfRows(inSection: 0), 1)
        let firstCell = cell(at: 0)
        XCTAssertNotNil(firstCell.transactionIconImageView.image)
        XCTAssertNotNil(firstCell.transactionTypeIconImageView.image)
        XCTAssertNotNil(firstCell.transactionDescriptionLabel.text)
        XCTAssertNotNil(firstCell.transactionDateLabel.text)
        XCTAssertNotNil(firstCell.fiatAmountLabel.text)
        XCTAssertNotNil(firstCell.tokenAmountLabel.text)
        XCTAssertFalse(firstCell.pairValueStackView.isHidden)
        XCTAssertNil(firstCell.singleValueLabel.text)
        XCTAssertTrue(firstCell.singleValueLabelStackView.isHidden)
        XCTAssertNotNil(firstCell.progressView)
        XCTAssertGreaterThan(firstCell.progressView.progress, 0)
        XCTAssertFalse(firstCell.progressView.isHidden)
    }

    func work_in_progress_disabled_test_whenSelectingRow_thenDeselectsIt() {
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    private func cell(at row: Int) -> TransactionTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! TransactionTableViewCell
    }

    func test_whenLoading_thenLoadsFromAppService() {
        service.expect_grouppedTransactions(result: [])
        createWindow(controller)
        XCTAssertTrue(service.verify())
    }

    func test_whenHasOneGroup_thenHasOneSection() {
        service.expect_grouppedTransactions(result: [.group()])
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfSections, 1)
    }

    func test_whenGroupHasTransactinos_thenSectionHasRows() {
        service.expect_grouppedTransactions(result: [.group(), .group(count: 3)])
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 3)
    }

    func test_whenGroupTypePending_thenNameIsLocalized() {
        service.expect_grouppedTransactions(result: [.group(type: .pending)])
        createWindow(controller)
        let headerView = controller.tableView.headerView(forSection: 0) as! TransactionsGroupHeaderView
        XCTAssertEqual(headerView.headerLabel.text, TransactionsGroupHeaderView.Strings.pending)
    }

    func test_whenGroupTypeProcessedInFuture_thenNameIsRelativeToGroupDate() {
        template_testGroupHeader(for: Date() + 1.days, string: TransactionsGroupHeaderView.Strings.future)
        template_testGroupHeader(for: Date(), string: TransactionsGroupHeaderView.Strings.today)
        template_testGroupHeader(for: Date() - 1.days, string: TransactionsGroupHeaderView.Strings.yesterday)
        let past = Date() - 2.days
        template_testGroupHeader(for: past, string: past.format(with: .short))
    }

    private func template_testGroupHeader(for date: Date,
                                          string: String,
                                          file: StaticString = #file,
                                          line: UInt = #line) {
        controller = TransactionsTableViewController.create()
        service.expect_grouppedTransactions(result: [.group(date: date)])
        createWindow(controller)
        let headerView = controller.tableView.headerView(forSection: 0) as! TransactionsGroupHeaderView
        XCTAssertEqual(headerView.headerLabel.text, string, file: file, line: line)
    }

}

extension TransactionGroupData {

    static func group(type: GroupType = .processed, date: Date? = nil, count: Int = 0) -> TransactionGroupData {
        let transactions = (0..<count).map { i in
            TransactionData(id: String(i),
                            sender: "sender",
                            recipient: "recipient",
                            amount: 0,
                            token: "eth",
                            fee: 0,
                            status: .success)
        }
        return TransactionGroupData(type: type, date: date, transactions: transactions)
    }

}
