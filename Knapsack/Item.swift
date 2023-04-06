//
//  Item.swift
//  Knapsack
//
//  Created by Tyler Hillsman on 4/5/23.
//

import Foundation
import CloudKit

struct Item: Codable, Equatable, Identifiable {
    
    init(url: String, comment: String) {
        self.url = url
        self.comment = comment
    }
    
    var id: String { url }
    
    let url: String
    let comment: String
    
    // CloudKit
    
    init?(from ckRecord: CKRecord) {
        guard let url = ckRecord.value(forKey: "url") as? String,
              let comment = ckRecord.value(forKey: "comment") as? String
        else { return nil }
        
        self.url = url
        self.comment = comment
    }
    
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: "Item", recordID: CKRecord.ID(recordName: url, zoneID: KnapsackSession.zoneID))
        record.setValue(url, forKey: "url")
        record.setValue(comment, forKey: "comment")
        return record
    }
}
