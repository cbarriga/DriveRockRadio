//
//  Environment.swift
//  DriveRockRadio
//
//  Created by Celso Barriga on 7/9/19.
//  Copyright © 2019 celsobarriga.com. All rights reserved.
//

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let streamURL = "STREAM_URL"
            static let envStr = "ENV"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: - Plist values
    static let streamURL: URL = {
        guard let streamURLstring = Environment.infoDictionary[Keys.Plist.streamURL] as? String else {
            fatalError("Stream URL not set in plist for this environment")
        }
        guard let url = URL(string: streamURLstring) else {
            fatalError("Stream URL is invalid")
        }
        return url
    }()
    
    static let envStr: String = {
        guard let envStr = Environment.infoDictionary[Keys.Plist.envStr] as? String else {
            fatalError("ENV Key not set in plist for this environment")
        }
        return envStr
    }()
}
