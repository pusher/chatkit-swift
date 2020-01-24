import UIKit
import PusherChatkit

class LoginViewController: UIViewController {
    
    // MARK: - Segues
    
    private static let loginSegue: String = "login"
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: - View lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayKeyboard()
    }
    
    // MARK: - Actions
    
    @IBAction func connect(_ sender: Any) {
        self.connect()
    }
    
    @IBAction func disconnect(_ sender: UIStoryboardSegue) {
        self.clearUsername()
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        self.toggleLoginButtonIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func displayKeyboard() {
        self.usernameTextField.becomeFirstResponder()
    }
    
    private func clearUsername() {
        self.usernameTextField.text = nil
        self.toggleLoginButtonIfNeeded()
    }
    
    private func toggleLoginButtonIfNeeded() {
        if let username = self.usernameTextField.text {
            self.loginButton.isEnabled = username.count > 0
        }
        else {
            self.loginButton.isEnabled = false
        }
    }
    
    private func toggleActivityIndicator(shouldDisplayActivityIndicator: Bool) {
        self.loginButton.isHidden = shouldDisplayActivityIndicator
        
        if shouldDisplayActivityIndicator {
            self.activityIndicator.startAnimating()
        }
        else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func displayError(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    private func connect() {
        guard let username = self.usernameTextField.text,
            let tokenProvider = try? TestTokenProvider(instanceLocator: Environment.instanceLocator, userIdentifier: username) else {
                self.displayError("Failed to login due to incorrect format of instance locator.")
                return
        }
        
        self.toggleActivityIndicator(shouldDisplayActivityIndicator: true)
        
        // TODO: In future this should be replaced with a call to connect() method of an Chatkit object.
        tokenProvider.fetchToken { result in
            // This call to the main queue is here only temporarly. The intented call to connect() method of an Chatkit object should return on the main queue.
            DispatchQueue.main.async {
                switch result {
                case .authenticated(_):
                    self.performSegue(withIdentifier: LoginViewController.loginSegue, sender: self)
                    
                case let .failure(error: error):
                    self.displayError("Failed to login due to the following error: \(error.localizedDescription).")
                }
                
                self.toggleActivityIndicator(shouldDisplayActivityIndicator: false)
            }
        }
    }
    
}

// MARK: - Text field delegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.connect()
        return true
    }
    
}
