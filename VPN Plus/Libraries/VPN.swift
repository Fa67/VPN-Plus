//
//  VPN.swift
//  VPN Plus
//
//  Created by Manh Pham on 5/6/19.
//  Copyright © 2019 Manh Pham. All rights reserved.
//

import Foundation
import NetworkExtension

enum VpnStatus: String {
    case connected
    case disconnected
    case connecting
    case reasserting
    case disconnecting
    case invalid
}

enum ConnectStatus {
    case success
    case failure
}

protocol VpnDelegate: class {
    func vpn(_ vpn: VPN, statusDidChange status: VpnStatus)
    func vpn(_ vpn: VPN, didRequestPermission status: ConnectStatus)
    func vpn(_ vpn: VPN, didConnectWithError error: String?)
    func vpnDidDisconnect(_ vpn: VPN)
}

class VPN {
    
    public static let share = VPN()
    public weak var delegate: VpnDelegate?
    
    public func status() -> VpnStatus {
        guard let status = self.vpnStatus else { return .invalid}
        switch status {
        case .connected: return .connected
        case .connecting: return .connecting
        case .disconnected: return .disconnected
        case .disconnecting: return .disconnecting
        case .invalid: return .invalid
        case .reasserting: return .reasserting
        }
    }

    private let KEYCHAIN_VPN_SECRET = "keychain_vpn_secret"
    private var vpnStatus: NEVPNStatus!
    private var manager: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    private init() {
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func requestPermision(account: Account) {
        loadFromPreferences {
            self.save(account: account)
        }
    }
    
    func loadFromPreferences(completion: @escaping () -> Void) {
        manager.loadFromPreferences { error in
            guard error == nil else {
                self.delegate?.vpn(self, didRequestPermission: .failure)
                return
            }
            completion()
        }
    }
    
    func removeFromPreferences() {
        manager.removeFromPreferences { (_) in
            
        }
    }
    
    func save(account: Account) {
        
        KeychainWrapper.standard.set(account.sharedSecret, forKey: KEYCHAIN_VPN_SECRET)
        let passwordDataRef = KeychainWrapper.standard.dataRef(forKey: KEYCHAIN_VPN_SECRET)
        guard let passwordRef = passwordDataRef else {
            self.delegate?.vpn(self, didConnectWithError: "Unable to save password to keychain")
            return
        }
        
        let neVPNProtocolIKEv2 = NEVPNProtocolIKEv2()
        neVPNProtocolIKEv2.remoteIdentifier = account.serverAddress
        neVPNProtocolIKEv2.serverAddress = account.serverAddress
        neVPNProtocolIKEv2.useExtendedAuthentication = true
        neVPNProtocolIKEv2.authenticationMethod = .sharedSecret
        neVPNProtocolIKEv2.sharedSecretReference = passwordRef
        neVPNProtocolIKEv2.disconnectOnSleep = false
        
        manager.protocolConfiguration = neVPNProtocolIKEv2
        manager.isEnabled = true
        
        manager.saveToPreferences { (error) in
            guard error == nil else {
                self.delegate?.vpn(self, didRequestPermission: .failure)
                return
            }
            self.delegate?.vpn(self, didRequestPermission: .success)
        }
    }
    
    func connect() {
        do {
            try manager.connection.startVPNTunnel()
        } catch NEVPNError.configurationInvalid {
            self.delegate?.vpn(self, didConnectWithError: "configurationInvalid")
        } catch NEVPNError.configurationDisabled {
            self.delegate?.vpn(self, didConnectWithError: "configurationDisabled")
        } catch NEVPNError.configurationReadWriteFailed {
            self.delegate?.vpn(self, didConnectWithError: "configurationReadWriteFailed")
        } catch NEVPNError.configurationStale {
            self.delegate?.vpn(self, didConnectWithError: "configurationStale")
        } catch {
            self.delegate?.vpn(self, didConnectWithError: "error")
        }
    }
    
    func disconnect() {
        manager.connection.stopVPNTunnel()
        delegate?.vpnDidDisconnect(self)
    }
    
    func toggleVpn() {
        if vpnStatus == .connected  {
            disconnect()
        } else if vpnStatus == .disconnected {
            connect()
        }
    }
    
    func addObservers(inQueue queue: OperationQueue = OperationQueue.main) {
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name.NEVPNStatusDidChange,
                object: nil,
                queue: queue,
                using: { notification in
                    let vpnConnection = notification.object as! NEVPNConnection
                    self.vpnStatus = vpnConnection.status
                    if self.vpnStatus == .connected {
                        self.delegate?.vpn(self, statusDidChange: .connected)
                    } else if self.vpnStatus == .disconnected {
                        self.delegate?.vpn(self, statusDidChange: .disconnected)
                    } else if self.vpnStatus == .connecting {
                        self.delegate?.vpn(self, statusDidChange: .connecting)
                    } else if self.vpnStatus == .reasserting {
                        self.delegate?.vpn(self, statusDidChange: .reasserting)
                    } else if self.vpnStatus == .disconnecting {
                        self.delegate?.vpn(self, statusDidChange: .disconnecting)
                    } else if self.vpnStatus == .invalid {
                        self.delegate?.vpn(self, statusDidChange: .invalid)
                    }
            })
    }

    
    func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
    }
    
}
