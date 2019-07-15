//
//  RadioLogik.swift
//  DriveRockRadio
//
//  Created by Celso Barriga on 7/11/19.
//  Copyright © 2019 celsobarriga.com. All rights reserved.
//

import Foundation

struct RadioLogik: Codable {
    var title: String = ""
    var artist: String = ""
    var start_time: String = ""
    var duration: String = ""
    var program_name: String = ""
    var online_dj: String = ""
    var q_remaining: String = ""
    var q_endtime: String = ""
    var auto_dj: Bool = true
}
