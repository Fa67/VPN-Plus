//
//  Main.swift
//  VPN
//
//  Created by Alexandr Nesterov on 8/22/18.
//  Copyright © 2018 Alexandr Nesterov. All rights reserved.
//

import NetworkExtension

/// VpnStatus used to see current status of working VPN
///
public enum VpnStatus {
    case connected
    case disconnected
    case connecting
    case reasserting
    case disconnecting
    case invalid
}

/// Connection status used to see current status of connection
///
public enum ConnectStatus {
    case success
    case failure
}

public protocol VpnDelegate: class {
    /// Pushed when status of connection is changed
    func vpn(_ vpn: Vpn, statusDidChange status: VpnStatus)
    
    /// Pushed when permission was request, return users answer
    func vpn(_ vpn: Vpn, didRequestPermission status: ConnectStatus)
    
    /// Pushed only when connect with error
    /// If you want to know, when vpn is connected with or without error,
    /// use vpn(_, statusDidChange)
    func vpn(_ vpn: Vpn, didConnectWithError error: String?)
    
    /// Pushed on disconnect vpn
    func vpnDidDisconnect(_ vpn: Vpn)
}

public final class Vpn {
    
    public static let instance = Vpn(delegate: nil, connection: nil)
    
    public var connection: VpnConnection?
    private var vpnStatus: NEVPNStatus!
    private let vpnManager: VPNManager
    
    public weak var delegate: VpnDelegate?
    
    /// Setup the Vpn
    ///
    /// - parameter delegate: Optional delegate of vpn
    /// - parameter connection: vpn connection
    init(delegate: VpnDelegate? = nil,
         connection: VpnConnection? = nil){
        
        self.vpnManager = VPNManager.shared
        self.delegate = delegate
        self.connection = connection
    }
    
    deinit {
        removeObservers()
    }
    
    /// Added observers on vpn status, add observers on loading view that have animations or other work on change vpn status
    ///
    /// - parameter inQueue: Optional operationQueue in which notification will work
    public func addObservers(inQueue queue: OperationQueue = OperationQueue.main) {
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
    
    
    /// Remove observers on exit of viewController that have animations or other work on change vpn status
    public func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
    }
    
    
    /// Ask for permission to use VPN
    ///
    /// First need to set connection!
    /// @see VpnConnection
    ///
    /// - parameter inQueue: Optional dispatch queue, default is background
    public func requestPermission(inQueue queue: DispatchQueue = DispatchQueue.global(qos: .background)) {
        guard let connection = connection else {delegate?.vpn(self, didRequestPermission: .failure);return}
        queue.async {
            self.vpnManager.requestPermission(connection: connection) { success in
                if success {
                    self.delegate?.vpn(self, didRequestPermission: .success)
                } else {
                    self.delegate?.vpn(self, didRequestPermission: .failure)
                }
            }
        }
    }
    
    
    /// Switch current status of vpn from connected to disconnected and backward
    public func toggleVpn() {
        if vpnStatus == .connected  {
            disconnect()
        } else if vpnStatus == .disconnected {
            connect()
        }
    }
    
    
    /// Connects to vpn
    public func connect() {
        guard let connection = connection else {delegate?.vpn(self, didConnectWithError: "No connection available") ;return}
        vpnManager.connect(connection: connection, onDemand: true, onError: { error in
            self.delegate?.vpn(self, didConnectWithError: error)
        })
    }
    
     /// Disconnect from vpn
    public func disconnect() {
        vpnManager.disconnect()
        delegate?.vpnDidDisconnect(self)
    }
    
    
    /// Gets current connection status
    public func status() -> VpnStatus {
        switch vpnManager.status {
        case .connected: return .connected
        case .connecting: return .connecting
        case .disconnected: return .disconnected
        case .disconnecting: return .disconnecting
        case .invalid: return .invalid
        case .reasserting: return .reasserting
        }
    }
}

