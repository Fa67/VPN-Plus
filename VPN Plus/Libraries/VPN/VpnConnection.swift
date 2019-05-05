
//
//  Connection.swift
//  VPN
//
//  Created by Alexandr Nesterov on 8/22/18.
//  Copyright © 2018 Alexandr Nesterov. All rights reserved.
//

import Foundation

public class VpnConnection: NSObject, Codable {
    
    public let ip: String
    public let login: String
    public let password: String
    public let remoteIdentifier: String
    public let localIdentifier: String
    public let serverCertificateCommonName: String
    public let countryName: String?
    public let countryIso: String?
    
    public init(ip: String,
                login: String,
                password: String,
                remoteId: String,
                localId: String,
                serverCertificateCommonName serverName: String,
                countryName: String,
                countryIso: String) {
        self.ip = ip
        self.login = login
        self.password = password
        self.remoteIdentifier = remoteId
        self.localIdentifier = localId
        self.serverCertificateCommonName = serverName
        self.countryName = countryName
        self.countryIso = countryIso
    }
}

extension VpnConnection {
    override public func isEqual(_ object: Any?) -> Bool {
        guard let con = object as? VpnConnection else {return false}
        
        return con == self
    }
    
    override public var hash: Int {
        return ip.hashValue +
            login.hashValue +
            password.hashValue +
            remoteIdentifier.hashValue +
            localIdentifier.hashValue +
            serverCertificateCommonName.hashValue +
            countryName.hashValue +
            countryIso.hashValue
    }
    
    static public func == (lhs: VpnConnection, rhs: VpnConnection) -> Bool {
        return lhs.ip == rhs.ip &&
            lhs.login == rhs.login &&
            lhs.password == rhs.password &&
            lhs.remoteIdentifier == rhs.remoteIdentifier &&
            lhs.localIdentifier == rhs.localIdentifier &&
            lhs.serverCertificateCommonName == rhs.serverCertificateCommonName &&
            lhs.countryName == rhs.countryName &&
            lhs.countryIso == rhs.countryIso
    }
}
