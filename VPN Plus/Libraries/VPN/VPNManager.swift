//
//  File.swift
//  VPN
//
//  Created by Alexandr Nesterov on 8/22/18.
//  Copyright © 2018 Alexandr Nesterov. All rights reserved.
//

import NetworkExtension

final class VPNManager: NSObject {
    
    private let KEYCHAIN_VPN_PASSWORD = "keychain_vpn_password"
    private let KEYCHAIN_SHARED_SECRET = "keychain_shared_secret"
    private let manager = NEVPNManager.shared()
    
    static let shared = VPNManager()
    
    var status: NEVPNStatus {
        return manager.connection.status
    }
    
    private override init() {
        super.init()
        loadProfile(callback: nil)
        manager.localizedDescription = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        manager.isEnabled = true
    }
    
    
    func requestPermission(connection: VpnConnection, permissionHandler: @escaping (Bool) -> Void) {
        connect(connection: connection,
                onDemand: false,
                onError: nil,
                permissionHandler: permissionHandler)
    }
    
    func connect(connection: VpnConnection,
                 onDemand: Bool,
                 onError: ((String) -> Void)?,
                 permissionHandler: ((Bool) -> Void)? = nil) {
        KeychainWrapper.standard.set(connection.password, forKey: KEYCHAIN_VPN_PASSWORD)
        let passwordDataRef = KeychainWrapper.standard.dataRef(forKey: KEYCHAIN_VPN_PASSWORD)
        guard let passwordRef = passwordDataRef else {
            onError?("Unable to save password to keychain")
            return
        }
        connectToServer(ip: connection.ip,
                        login: connection.login,
                        remoteIdentifier: connection.remoteIdentifier,
                        localIdentifier: connection.localIdentifier,
                        serverCertificateCommonName: connection.serverCertificateCommonName,
                        passwordRef: passwordRef,
                        onDemand: onDemand,
                        onError: onError,
                        permissionHandler: permissionHandler
        )
    }
    
    func disconnect() {
        let rule = NEOnDemandRuleDisconnect()
        rule.interfaceTypeMatch = .any
        manager.onDemandRules = [rule]
        manager.isOnDemandEnabled = true
        manager.connection.stopVPNTunnel()
        manager.saveToPreferences()
    }
    
    private func loadProfile(callback: ((Bool, String?) -> Void)?) {
        manager.protocolConfiguration = nil
        manager.loadFromPreferences { [unowned self] error in
            if let error = error {
                callback?(false, error.localizedDescription)
            } else {
                callback?(self.manager.protocolConfiguration != nil, nil)
            }
        }
    }
    
    private func saveProfile(callback: ((Bool, String?) -> Void)?) {
        manager.saveToPreferences { error in
            if let error = error {
                callback?(false, error.localizedDescription)
            } else {
                callback?(true, nil)
            }
        }
    }
    
    private func connectToServer(ip: String,
                                 login: String,
                                 remoteIdentifier: String,
                                 localIdentifier: String,
                                 serverCertificateCommonName: String,
                                 passwordRef: Data,
                                 onDemand enableDemand: Bool,
                                 onError: ((String) -> Void)?,
                                 permissionHandler: ((Bool) -> Void)?) {
        let vpnProtocol = NEVPNProtocolIKEv2()
        vpnProtocol.serverAddress = ip
        vpnProtocol.authenticationMethod = NEVPNIKEAuthenticationMethod.none
        vpnProtocol.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.medium
        vpnProtocol.username = login
        vpnProtocol.passwordReference = passwordRef
        vpnProtocol.certificateType = .RSA
        vpnProtocol.serverCertificateCommonName = serverCertificateCommonName
        vpnProtocol.remoteIdentifier = remoteIdentifier
        vpnProtocol.localIdentifier = localIdentifier
        vpnProtocol.disconnectOnSleep = false
        vpnProtocol.disableMOBIKE = false
        vpnProtocol.disableRedirect = false
        vpnProtocol.enableRevocationCheck = false
        vpnProtocol.enablePFS = false
        vpnProtocol.useExtendedAuthentication = true
        vpnProtocol.useConfigurationAttributeInternalIPSubnet = false
        vpnProtocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
        vpnProtocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256
        vpnProtocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
        vpnProtocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
        manager.protocolConfiguration = vpnProtocol
        if enableDemand {
            manager.isOnDemandEnabled = true
            var rules = [NEOnDemandRule]()
            let allInterfacesRule = NEOnDemandRuleConnect()
            allInterfacesRule.interfaceTypeMatch = .any
            rules.append(allInterfacesRule)
            
            manager.onDemandRules = rules
        }
        manager.isEnabled = true
        saveProfile { [unowned self] success, errorDescription in
            if let handler = permissionHandler {
                handler(success)
                return
            }
            guard success else {
                onError?(errorDescription!)
                return
            }
            self.loadProfile() { success, errorDescription in
                guard success else {
                    onError?(errorDescription!)
                    return
                }
                
                let (result, error) = self.startVPNTunnel()
                guard result else {
                    onError?(error!)
                    return
                }
            }
        }
    }
    
    private func startVPNTunnel() -> (result: Bool, error: String?) {
        var errorDescription: String?
        do {
            try self.manager.connection.startVPNTunnel()
            return (true, nil)
        } catch NEVPNError.configurationInvalid {
            errorDescription = "Failed to start tunnel (configuration invalid)"
        } catch NEVPNError.configurationDisabled {
            errorDescription = "Failed to start tunnel (configuration disabled)"
        } catch {
            errorDescription = "Failed to start tunnel (other error)"
        }
        return (false, errorDescription)
    }
}
