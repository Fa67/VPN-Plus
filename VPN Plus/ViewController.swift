//
//  ViewController.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/6/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let server = "159.89.195.30.sslip.io"
    let user = "manhpham90vn"
    let pass = "123123"
    
    var delegate: VpnDelegate?
    var connection: VpnConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connection = VpnConnection.init(ip: server, login: user, password: pass, remoteId: server, localId: "", serverCertificateCommonName: "", countryName: "", countryIso: "")
        Vpn.instance.connection = connection
        Vpn.instance.delegate = self
        Vpn.instance.requestPermission()
    }

}

extension ViewController: VpnDelegate {
    func vpn(_ vpn: Vpn, statusDidChange status: VpnStatus) {
        print("statusDidChange", status)
    }
    
    func vpn(_ vpn: Vpn, didRequestPermission status: ConnectStatus) {
        print("didRequestPermission", status)
        if status == .success {
            Vpn.instance.connect()
        }
    }
    
    func vpn(_ vpn: Vpn, didConnectWithError error: String?) {
        print("error", error ?? "")
    }
    
    func vpnDidDisconnect(_ vpn: Vpn) {
        print("vpnDidDisconnect")
    }
}
