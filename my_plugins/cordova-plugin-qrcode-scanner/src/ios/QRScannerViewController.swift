import MercariQRScanner
import AVFoundation

@objc
public protocol QRScannerViewControllerDelegate: AnyObject {
    func didScan(code: String, error: NSError?)
}

@objcMembers
class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    weak var webviewEngine: CDVWebViewEngineProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
        setupCallJSButton()
    }
    
    private func setupCallJSButton() {
        let button = UIButton(type: .system)
        button.setTitle("Call JS", for: .normal)
        button.frame = CGRect(x: 20, y: 100, width: 100, height: 50)
        button.addTarget(self, action: #selector(callJS), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc private func callJS() {
        self.webviewEngine?.evaluateJavaScript("callFromNative()") { response, error in
            // !!!: can't use let error = error or let error = error as NSError?
            // FIXME: need to find a way to check if get an error or not
            // could consider creating a wrapper in Objective-C that includes this error and provides a method, such as hasError() -> Bool.
            guard let response = response as? String else { return }
            print(response)
        }
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }

    private func setupQRScannerView() {
        let qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
    }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

extension QRScannerViewController: @MainActor QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        guard let delegate else { return }
        delegate.didScan(code: "", error: error as NSError)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        guard let delegate else { return }
        delegate.didScan(code: code, error: nil)
    }
}

