//
//  KnapsackManager.swift
//  Knapsack
//
//  Created by Tyler Hillsman on 4/5/23.
//

import Foundation
import Boutique
import CloudKit
import CloudSyncSession
import OSLog
import Combine

class KnapsackManager: ObservableObject {
    
    private let cloudSyncSession: CloudSyncSession
    
    static let store = Store<Item>(
        storage: SQLiteStorageEngine.default(appendingPath: "Items"),
        cacheIdentifier: \.url
    )
    
    @Stored(in: store) var items
    @StoredValue(key: "lastChangeToken") var lastChangeToken: Data? = nil
    
    func add(url: String, comment: String) {
        let item = Item(url: url, comment: comment)
        Task {
            do {
                try await $items.insert(item)
            }
        }
        
        let records: [CKRecord] = [ item.ckRecord ]
        let checkpointID = UUID()
        let operation = ModifyOperation(
            records: records,
            recordIDsToDelete: [],
            checkpointID: checkpointID,
            userInfo: nil
        )

        cloudSyncSession.modify(operation)
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init() {
        cloudSyncSession = KnapsackSession.makeSharedSession()
        
        cloudSyncSession.fetchWorkCompletedSubject
            .map { _, response in
                (response.changeToken, response.changedRecords, response.deletedRecordIDs)
            }
            .sink { changeToken, ckRecords, recordIDsToDelete in
                let cloudItems = ckRecords.compactMap { Item(from: $0) }
                self.$lastChangeToken.set(changeToken?.asData())
                Task { [weak self] in
                    do {
                        try await self?.$items.insert(cloudItems)
                    }
                }
            }
            .store(in: &subscriptions)

        cloudSyncSession.modifyWorkCompletedSubject
            .map { _, response in
                (response.savedRecords, response.deletedRecordIDs)
            }
            .sink { ckRecords, recordIDsToDelete in
                let cloudItems = ckRecords.compactMap { Item(from: $0) }
                Task { [weak self] in
                    do {
                        try await self?.$items.insert(cloudItems)
                    }
                }
            }
            .store(in: &subscriptions)
        
        cloudSyncSession.haltedSubject
            .sink { error in
                // print(error ?? "")
            }
            .store(in: &subscriptions)

        cloudSyncSession.accountStatusSubject
            .sink { accountStatus in
                // print(accountStatus ?? "")
            }
            .store(in: &subscriptions)

        cloudSyncSession.$state
            .sink { state in
                // print(state)
            }
            .store(in: &subscriptions)

        cloudSyncSession.eventsPublisher
            .sink { event in
                // print(event ?? "")
            }
            .store(in: &subscriptions)
        
        cloudSyncSession.start()

        // Queue a fetch operation
        cloudSyncSession.fetch(FetchOperation(changeToken: CKServerChangeToken.build(from: lastChangeToken)))
        
        NotificationCenter.default.publisher(for: Notification.Name("fetchCloudKit"))
            .sink { [weak self] _ in
                self?.cloudSyncSession.fetch(FetchOperation(changeToken: CKServerChangeToken.build(from: self?.lastChangeToken)))
            }
            .store(in: &subscriptions)
    }
}

struct KnapsackSession {
    static let storeIdentifier: String = "iCloud.com.tylerhillsman.Knapsack"
    static let zoneID: CKRecordZone.ID = .init(zoneName: "ItemZone")
    static let subscriptionID: String = "ItemZoneSubscription"
    static let log: OSLog = .default

    static func makeSharedSession() -> CloudSyncSession {
        let container = CKContainer(identifier: Self.storeIdentifier)
        let database = container.privateCloudDatabase

        let session = CloudSyncSession(
            operationHandler: CloudKitOperationHandler(
                database: database,
                zoneID: Self.zoneID,
                subscriptionID: Self.subscriptionID,
                log: Self.log
            ),
            zoneID: Self.zoneID,
            resolveConflict: resolveConflict,
            resolveExpiredChangeToken: resolveExpiredChangeToken
        )

        session.appendMiddleware(
            AccountStatusMiddleware(
                session: session,
                ckContainer: container
            )
        )

        return session
    }

    static func resolveConflict(clientCkRecord: CKRecord, serverCkRecord: CKRecord) -> CKRecord? {
        // Implement your own conflict resolution logic

        if let clientDate = clientCkRecord.modificationDate,
            let serverDate = serverCkRecord.modificationDate
        {
            return clientDate > serverDate ? clientCkRecord : serverCkRecord
        }

        return clientCkRecord
    }

    static func resolveExpiredChangeToken() -> CKServerChangeToken? {
        // Update persisted store to reset the change token to nil

        return nil
    }
}

extension CKServerChangeToken {
    
    func asData() -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(
                withRootObject: self as Any,
                requiringSecureCoding: true
            )
        } catch {
            print(error)
            return nil
        }
    }
    
    static func build(from data: Data?) -> CKServerChangeToken? {
        guard let data else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
