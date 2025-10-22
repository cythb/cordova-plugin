import MercariQRScanner
import AVFoundation

@objc
public protocol QRScannerViewControllerDelegate: AnyObject {
    func didScan(code: String, error: NSError?)
}

@objcMembers
class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
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
