//
//  DispatchQueue.swift
//  Nest
//
//  Created by Manfred on 03/11/2016.
//
//

import Dispatch

extension DispatchQueue {
    public static var currentQueueLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
