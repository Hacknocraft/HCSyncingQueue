//
//  HCSyncingQueue.swift
//  HCSyncingQueue
//
//  Created by HAO WANG on 4/28/17.
//  Copyright © 2017 Hacknocraft. All rights reserved.
//

import Foundation

open class HCSyncingQueue: NSCoder {

    private static var syncingQueues: [String: HCSyncingQueue]?

    private static let pendingSyncQueueKey  = "hc_sync_pendingSyncQueue"
    private static let currentSyncQueueKey  = "hc_sync_currentSyncQueue"
    private static let persistentKey        = "hc_sync_persistentKey"

    // add a prefix to avoid clash
    private static let prefix               = "hc_sync_"

    private var pendingSyncQueue: [AnyHashable]
    private var currentSyncQueue: [AnyHashable]

    static func getSavedQueues() -> [String: HCSyncingQueue] {

        if syncingQueues == nil {
            syncingQueues = UserDefaults.standard
                .object(forKey: HCSyncingQueue.pendingSyncQueueKey) as? [String: HCSyncingQueue]
        }
        if syncingQueues == nil {
            syncingQueues = [String: HCSyncingQueue]()
        }
        return syncingQueues ?? [String: HCSyncingQueue]()
    }

    open static func queue(withKey key: String) -> HCSyncingQueue {

        // add a prefix to avoid clash
        let domainKey = "\(HCSyncingQueue.prefix)\(key)"
        var savedQueues = HCSyncingQueue.getSavedQueues()
        if let syncQueue = savedQueues[domainKey] {
            return syncQueue
        } else {
            let syncQueue = HCSyncingQueue()
            savedQueues[domainKey] = syncQueue
            return syncQueue
        }
    }

    override init() {
        pendingSyncQueue = UserDefaults.standard
            .object(forKey: HCSyncingQueue.pendingSyncQueueKey) as? [AnyHashable]
            ?? [AnyHashable]()
        currentSyncQueue = UserDefaults.standard
            .object(forKey: HCSyncingQueue.pendingSyncQueueKey) as? [AnyHashable]
            ?? [AnyHashable]()
    }

    required public init(coder decoder: NSCoder) {
        self.pendingSyncQueue = decoder.decodeObject(forKey: HCSyncingQueue.pendingSyncQueueKey)
            as? [AnyHashable] ?? [AnyHashable]()
        self.currentSyncQueue = decoder.decodeObject(forKey: HCSyncingQueue.currentSyncQueueKey)
            as? [AnyHashable] ?? [AnyHashable]()
    }

    func encode(with coder: NSCoder) {
        coder.encode(pendingSyncQueue, forKey: HCSyncingQueue.pendingSyncQueueKey)
        coder.encode(currentSyncQueue, forKey: HCSyncingQueue.currentSyncQueueKey)
    }

    // MARK: - persistence

    open func save() {
        /// save the queue to UserDefault
        UserDefaults.standard.set(HCSyncingQueue.syncingQueues,
                                  forKey: HCSyncingQueue.persistentKey)
        UserDefaults.standard.synchronize()
    }

    // MARK: - enqueue and dequeue

    open func enqueue(item: AnyHashable) {
        if !self.pendingSyncQueue.contains(item) {
            self.pendingSyncQueue.append(item)
        }
    }

    open func getSyncingItems() -> [AnyHashable]? {
        if currentSyncQueue.count > 0 {
            return currentSyncQueue
        } else {
            currentSyncQueue.append(contentsOf: self.pendingSyncQueue)
            self.pendingSyncQueue.removeAll()
        }
        return currentSyncQueue
    }

    open func cleanCurrentSyncingQueue() {
        currentSyncQueue.removeAll()
        save()
    }
}
