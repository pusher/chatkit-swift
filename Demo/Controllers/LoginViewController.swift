import UIKit
import Environment
import PusherChatkit

class LoginViewController: UIViewController {
    
    // MARK: - Segues
    
    private static let loginSegue: String = "login"
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: - Properties
    
    private var chatkit: Chatkit?
    
    // MARK: - View lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayKeyboard()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == LoginViewController.loginSegue {
            guard let navigationController = segue.destination as? UINavigationController,
                let roomListViewController = navigationController.visibleViewController as? RoomListViewController else {
                return
            }
            
            roomListViewController.chatkit = self.chatkit
        }
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
            let tokenProvider = try? TestTokenProvider(instanceLocator: Environment.instanceLocator, userIdentifier: username),
            let chatkit = try? Chatkit(instanceLocator: Environment.instanceLocator, tokenProvider: tokenProvider) else {
                self.displayError("Failed to login due to incorrect format of instance locator.")
                return
        }
        
        self.toggleActivityIndicator(shouldDisplayActivityIndicator: true)
        
        self.chatkit = chatkit
        self.chatkit?.connect { error in
            self.toggleActivityIndicator(shouldDisplayActivityIndicator: false)
            
            if let error = error {
                self.displayError("Failed to login due to the following error: \(error.localizedDescription).")
            }
            else {
                self.performSegue(withIdentifier: LoginViewController.loginSegue, sender: self)
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
