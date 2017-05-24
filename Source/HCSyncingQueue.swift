//
//  HCSyncingQueue.swift
//  HCSyncingQueue
//
//  Created by HAO WANG on 4/28/17.
//  Copyright © 2017 Hacknocraft. All rights reserved.
//

import Foundation

/// This queue solves the problem for asynchronous data requests queue.
/// Because the operation can fail and we need to put the dequeue items back,
/// there are two queues. One holds the items waiting to be sent, and other queue holds
/// the items which is currently being sent. Once sending is finished, you should call
/// `cleanCurrentSyncingQueue` to clean up the current syncing queue.
open class HCSyncingQueue: NSObject, NSCoding {

    private static var syncingQueues: [String: HCSyncingQueue]?

    private static let pendingSyncQueueKey  = "hc_sync_pendingSyncQueue"
    private static let currentSyncQueueKey  = "hc_sync_currentSyncQueue"
    private static let persistentKey        = "hc_sync_persistentKey"

    // add a prefix to avoid clash
    private static let prefix               = "hc_sync_"

    private var pendingSyncQueue = [AnyHashable]()
    private var currentSyncQueue = [AnyHashable]()

    private static func getSavedQueues() -> [String: HCSyncingQueue] {

        if syncingQueues == nil,
            let decoded = UserDefaults.standard
                .object(forKey: HCSyncingQueue.persistentKey) as? Data {
            syncingQueues = NSKeyedUnarchiver
                .unarchiveObject(with: decoded) as? [String: HCSyncingQueue]
        }
        return syncingQueues ?? [String: HCSyncingQueue]()
    }

    open static func getQueue(withKey key: String) -> HCSyncingQueue {

        // add a prefix to avoid clash
        let domainKey = "\(HCSyncingQueue.prefix)\(key)"
        var savedQueues = HCSyncingQueue.getSavedQueues()
        if let syncQueue = savedQueues[domainKey] {
            return syncQueue
        } else {
            let syncQueue = HCSyncingQueue()
            savedQueues[domainKey] = syncQueue
            HCSyncingQueue.syncingQueues = savedQueues
            return syncQueue
        }
    }

    open static func removeQueue(withKey key: String) {
        HCSyncingQueue.syncingQueues?.removeValue(forKey: "\(HCSyncingQueue.prefix)\(key)")
        save()
    }

    // MARK: - persistence

    open static func save() {
        /// save the queue to UserDefault
        if let queue = HCSyncingQueue.syncingQueues {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: queue)
            UserDefaults.standard.set(encodedData,
                                      forKey: HCSyncingQueue.persistentKey)
            UserDefaults.standard.synchronize()
        }
    }

    override init() {}

    required public init(coder decoder: NSCoder) {
        self.pendingSyncQueue = decoder.decodeObject(forKey: HCSyncingQueue.pendingSyncQueueKey)
            as? [AnyHashable] ?? [AnyHashable]()
        self.currentSyncQueue = decoder.decodeObject(forKey: HCSyncingQueue.currentSyncQueueKey)
            as? [AnyHashable] ?? [AnyHashable]()
    }

    public func encode(with coder: NSCoder) {
        coder.encode(pendingSyncQueue, forKey: HCSyncingQueue.pendingSyncQueueKey)
        coder.encode(currentSyncQueue, forKey: HCSyncingQueue.currentSyncQueueKey)
    }

    // MARK: - enqueue and dequeue

    open func enqueue(item: AnyHashable) {
        if !self.pendingSyncQueue.contains(item) {
            self.pendingSyncQueue.append(item)
            HCSyncingQueue.save()
        }
    }

    open func getSyncingItems() -> [AnyHashable] {
        if currentSyncQueue.count > 0 {
            return currentSyncQueue
        } else {
            currentSyncQueue.append(contentsOf: self.pendingSyncQueue)
            self.pendingSyncQueue = [AnyHashable]()
        }
        return currentSyncQueue
    }

    open func cleanCurrentSyncingQueue() {
        currentSyncQueue = [AnyHashable]()
        HCSyncingQueue.save()
    }
}
