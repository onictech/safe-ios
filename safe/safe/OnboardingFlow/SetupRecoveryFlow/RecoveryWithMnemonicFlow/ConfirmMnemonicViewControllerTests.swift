//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class ConfirmMnemonicViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockConfirmMnemonicDelegate()
    private var controller: ConfirmMnemonicViewController!
    private var words = ["some", "random", "words", "from", "a", "mnemonic"]

    override func setUp() {
        super.setUp()
        createController(words: words)
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertTrue(controller.firstWordTextInput.delegate === controller)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertTrue(controller.secondWordTextInput.delegate === controller)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertNotNil(controller.confirmButton)
        XCTAssertTrue(controller.delegate === delegate)
        XCTAssertEqual(words, controller.words)
    }

    func test_viewDidLoad_setsRandomCheckingWords() {
        assertRandomWords()
        createController(words: ["two", "words"])
        assertRandomWords()
    }

    func test_viewDidLoad_dismissesIfMnemonicIsNil() throws {
        let controller = ConfirmMnemonicViewController()
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_viewDidLoad_dismissesIfMnemonicHasLessThanTwoWords() throws {
        createController(words: ["word"])
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_viewDidLoad_setsCorrectWordsLabelText() {
        controller.viewDidLoad()
        let firstWordIndex = words.index(of: controller.firstMnemonicWordToCheck)!
        let secondWordIndex = words.index(of: controller.secondMnemonicWordToCheck)!
        XCTAssertEqual("\(firstWordIndex + 1).", controller.firstWordNumberLabel.text)
        XCTAssertEqual("\(secondWordIndex + 1).", controller.secondWordNumberLabel.text)
    }

    func test_confirm_callsDelegate() {
        controller.confirm(self)
        XCTAssertTrue(delegate.confirmed)
    }

    func test_whenTextInputsHaveNoWords_thenConfirmButtonDisabled() {
        XCTAssertEqual(controller.firstWordTextInput.text, "")
        XCTAssertEqual(controller.secondWordTextInput.text, "")
        XCTAssertFalse(controller.confirmButton.isEnabled)
    }

    func test_whenTextInputsHaveWrongWords_thenConfirmButtonDisabled() {
        setTextInputs("wrong", controller.secondMnemonicWordToCheck)
        XCTAssertFalse(controller.confirmButton.isEnabled)
        setTextInputs(controller.firstMnemonicWordToCheck, "wrong")
        XCTAssertFalse(controller.confirmButton.isEnabled)
    }

    func test_whenTextInputsHaveCorrectWords_thenConfirmButtonEnabled() {
        setTextInputs(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
        XCTAssertTrue(controller.confirmButton.isEnabled)
    }

}

extension ConfirmMnemonicViewControllerTests {

    private func setTextInputs(_ first: String, _ second: String) {
        controller.firstWordTextInput.text = first
        controller.secondWordTextInput.text = second
        controller.textInputDidReturn(controller.secondWordTextInput)
    }

    private func createController(words: [String]) {
        controller = ConfirmMnemonicViewController.create(delegate: delegate, words: words)
        controller.loadViewIfNeeded()
    }

    private func createWindow(_ controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
    }

    private func assertRandomWords() {
        for _ in 0...100 {
            controller.viewDidLoad()
            XCTAssertNotEqual(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
            XCTAssertTrue(controller.words.contains(controller.firstMnemonicWordToCheck))
            XCTAssertTrue(controller.words.contains(controller.secondMnemonicWordToCheck))
        }
    }

}

final class MockConfirmMnemonicDelegate: ConfirmMnemonicDelegate {

    var confirmed = false

    func didConfirm() {
        confirmed = true
    }

}
