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
    
    lazy var account = Account(serverAddress: serverAddress, sharedSecret: sharedSecret)
    
    let serverAddress = "159.65.129.252"
    let sharedSecret = "4ec04e07-f030-4445-ba59-3d8c1cb180a2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func requestTapped(_ sender: Any) {
        vpn.requestPermision(account: account)
    }
    
    @IBAction func connectTapped(_ sender: Any) {
        vpn.connect()
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
        print("statusDidChange", status)
        self.status.text = status.description
    }
    
    func vpn(_ vpn: VPN, didRequestPermission status: ConnectStatus) {
        print("didRequestPermission", status)
    }
    
    func vpn(_ vpn: VPN, didConnectWithError error: String?) {
        print("didConnectWithError", error ?? "")
    }
    
    func vpnDidDisconnect(_ vpn: VPN) {
        print("vpnDidDisconnect")
    }
    
    
}

