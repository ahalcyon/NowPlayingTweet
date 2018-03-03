/**
 *  KeyEquivalentsPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Magnet
import KeyHolder

class KeyEquivalentsPaneController: NSViewController, RecordViewDelegate {

    static let shared: KeyEquivalentsPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .keyEquivalentsPaneController)
        return windowController as! KeyEquivalentsPaneController
    }()

    var userDefaults: UserDefaults = UserDefaults.standard

    let twitterClient: TwitterClient = TwitterClient.shared

    let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    @IBOutlet weak var currentRecordLabel: NSTextField!
    @IBOutlet weak var currentRecortView: RecordView!

    @IBOutlet weak var cancelButton: NSButton!

    @IBOutlet weak var accountShortcutLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.currentRecortView.tintColor = .systemBlue
        self.currentRecortView.cornerRadius = 12
        self.currentRecortView.delegate = self
        self.currentRecortView.identifier = NSUserInterfaceItemIdentifier(rawValue: "Current")
        self.currentRecortView.keyCombo = self.userDefaults.keyCombo(forKey: "Current")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.reloadView()
    }

    func reloadView() {
        let numOfAccounts = self.twitterClient.numberOfAccounts
        for subview in self.view.subviews { subview.removeFromSuperview() }
        self.view.addSubview(self.currentRecordLabel)
        self.view.addSubview(self.currentRecortView)
        self.view.addSubview(self.accountShortcutLabel)

        var newFrameSize: CGSize
        // width: 500
        if numOfAccounts == 0 {
            // height: 100
            newFrameSize = CGSize(width: 500, height: 100)
            self.accountShortcutLabel.isHidden = true
        } else {
            newFrameSize = CGSize(width: 500, height: 144 + 32 * numOfAccounts)
            self.accountShortcutLabel.isHidden = false
        }

        self.view.window?.setContentSize(newFrameSize)

        self.cancelButton.setFrameOrigin(CGPoint(x: 216, y: 20))
        self.view.addSubview(self.cancelButton)

        if numOfAccounts == 0 { return }

        let labelSize = CGSize(width: 210, height: 17)
        let viewSize = CGSize(width: 158, height: 24)

        var labelYPoint = 64 + 32 * numOfAccounts
        var recordYPoint = 61 + 32 * numOfAccounts

        for accountID in self.twitterClient.accountIDs {
            labelYPoint -= 32
            recordYPoint -= 32
            let labelOrigin = CGPoint(x: 62, y: labelYPoint)
            let viewOrigin = CGPoint(x: 280, y: recordYPoint)

            let labelFrame = CGRect(origin: labelOrigin, size: labelSize)
            let viewFrame = CGRect(origin: viewOrigin, size: viewSize)

            // x: 62, y: 64
            let accountName: String = (self.twitterClient.accounts[accountID]?.screenName)!
            let recordLabel: NSTextField = Label(with: "Tweet with @\(accountName):",
                                                 frame: labelFrame,
                                                 alignment: .right) as NSTextField

            // x: 280, y: 61
            let recordView: RecordView = RecordView(frame: viewFrame)
            recordView.tintColor = .systemBlue
            recordView.cornerRadius = 12
            recordView.delegate = self
            recordView.identifier = NSUserInterfaceItemIdentifier(rawValue: accountID)
            recordView.keyCombo = self.userDefaults.keyCombo(forKey: accountID)

            self.view.addSubview(recordLabel)
            self.view.addSubview(recordView)
        }
    }

    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        guard let _: String = recordView.identifier?.rawValue else { return false }
        recordView.keyCombo = nil
        return true
    }

    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        guard let identifier: String = recordView.identifier?.rawValue else { return false }
        self.keyEquivalents.unregister(identifier)
        return true
    }

    func recordViewDidClearShortcut(_ recordView: RecordView) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.unregister(identifier)
    }

    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.register(identifier, keyCombo: keyCombo)
    }

    func recordViewDidEndRecording(_ recordView: RecordView) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        recordView.keyCombo = self.userDefaults.keyCombo(forKey: identifier)
    }

    @IBAction func changeCancel(_ sender: NSButton) {
        self.currentRecortView.endRecording()
    }

}
