//
//  ChatkitClient.swift
//  Chatkit
//
//  Created by Mike Pye on 17/09/2019.
//  Copyright © 2019 Pusher Ltd. All rights reserved.
//

import Foundation

/// FOR TESTING ONLY. Should be Service, but that protocol is not complete and we want to do some stubbing.
protocol ChatkitClient {
    func fetchMessages(room: String, from: String?, order: String, amount: UInt, completionHandler: (Error?) -> ())
}
