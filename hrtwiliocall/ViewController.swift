//
//  ViewController.swift
//  hrtwiliocall
//
//  Created by Elizabeth Siegle on 1/2/17.
//  Copyright © 2017 Elizabeth Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity
import WebKit
import Alamofire

class ViewController: UIViewController, WCSessionDelegate, UITextViewDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var phoneNumTextField: UITextField!
    
    @IBOutlet weak var enterButton: UIButton!
    var minFromArr: Double = 0
    var maxFromArr: Double = 0
    var heartRateVal : Double = 0
    var wcSesh : WCSession!
    var timeToCall: Bool = false //init
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 207, green: 207, blue: 196, alpha:150)
        self.navigationController?.isToolbarHidden = false
        //watchConnectivitySession
        if(WCSession.isSupported()) {
            wcSesh = WCSession.default()
            wcSesh.delegate = self
            wcSesh.activate()
        }
        phoneNumTextField.keyboardType = UIKeyboardType.phonePad
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("deactivate")
    }
    private func session(wcSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let boolFromWatch = message["buttonTap"] as? Bool { //String?
            timeToCall = boolFromWatch
        }
    }
    
    @IBAction func sendData(sender: AnyObject) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: Parameters = [
            "To": phoneNumTextField.text ?? "",
            "Body": heartRateVal
        ]
        
        Alamofire.request("YOUR_NGROK_URL/sms", method: .post, parameters: parameters, headers: headers).response { response in
            print(response)
            
        }
    }
    
    
}

