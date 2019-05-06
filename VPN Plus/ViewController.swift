//
//  ViewController.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/6/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    @IBOutlet weak var status: UILabel!
    
    let serverAddress = "159.65.129.252"
    let sharedSecret = "4ec04e07-f030-4445-ba59-3d8c1cb180a2"
    var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account = Account(serverAddress: serverAddress, sharedSecret: sharedSecret)
        VPN.share.delegate = self
    }

    @IBAction func requestTapped(_ sender: Any) {
        VPN.share.requestPermision(account: account)
    }
    
    @IBAction func connectTapped(_ sender: Any) {
        VPN.share.connect()
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        VPN.share.disconnect()
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        VPN.share.removeFromPreferences()
    }
    
}

extension ViewController: VpnDelegate {
    func vpn(_ vpn: VPN, statusDidChange status: VpnStatus) {
        print("statusDidChange", status)
        self.status.text = status.rawValue
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

