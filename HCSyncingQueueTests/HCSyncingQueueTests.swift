//
//  HCSyncingQueueTests.swift
//  HCSyncingQueueTests
//
//  Created by HAO WANG on 4/28/17.
//  Copyright © 2017 Hacknocraft. All rights reserved.
//

import XCTest
@testable import HCSyncingQueue

class HCSyncingQueueTests: XCTestCase {

    let testQueueKey = "test_queue"
    let initialSyncItems = ["1", "2", "3", "4"]

    override func setUp() {
        super.setUp()

        var syncingQueue = HCSyncingQueue.getQueue(withKey: testQueueKey)
        HCSyncingQueue.removeQueue(withKey: testQueueKey)
        syncingQueue = HCSyncingQueue.getQueue(withKey: testQueueKey)
        for item in initialSyncItems {
            syncingQueue.enqueue(item: item)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetSyncItems() {

        let syncingQueue = HCSyncingQueue.getQueue(withKey: "test_queue")
        syncingQueue.enqueue(item: "4") // this shouldn't change count
        var count = syncingQueue.getSyncingItems()?.count
        XCTAssertTrue(count ?? 0 == initialSyncItems.count)

        syncingQueue.enqueue(item: "4")
        syncingQueue.cleanCurrentSyncingQueue()
        count = syncingQueue.getSyncingItems()?.count
        XCTAssertTrue(count ?? 0 == 1)
    }
}
