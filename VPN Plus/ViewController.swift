//
//  ViewController.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/6/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import UIKit
import MPVPN

class ViewController: UIViewController {

    @IBOutlet weak var status: UILabel!
    
    lazy var vpn: VPN = {
        let _vpn = VPN(delegate: self)
        return _vpn
    }()
    
    var account = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account.append(Account(serverAddress: "178.128.91.181", sharedSecret: "04a4b50e-d456-4e61-bfea-ce861bb54947"))
        account.append(Account(serverAddress: "178.128.62.207", sharedSecret: "7ecfe2f8-f5d4-4266-8a89-8de0e8277ec6"))
    }

    @IBAction func requestTapped(_ sender: Any) {
        if vpn.status() == .connected {
            vpn.disconnect()
        }
        vpn.requestPermision(account: account[0])
    }
    
    @IBAction func connectTapped(_ sender: Any) {
        if vpn.status() == .connected {
            vpn.disconnect()
        }
        vpn.requestPermision(account: account[1])
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        vpn.disconnect()
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        vpn.removeFromPreferences()
    }
    
}

extension ViewController: VPNDelegate {
    func vpn(_ vpn: VPN, statusDidChange status: VpnStatus) {
        self.status.text = status.description
    }
    
    func vpn(_ vpn: VPN, didRequestPermission status: ConnectStatus) {
        if status == .success {
            vpn.connect()
        }
    }
    
    func vpn(_ vpn: VPN, didConnectWithError error: String?) {
        
    }
    
    func vpnDidDisconnect(_ vpn: VPN) {
        
    }
    
}

