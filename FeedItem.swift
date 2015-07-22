//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Kashish Goel on 2015-07-22.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import Foundation
import CoreData
@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var uniqueID: String
    @NSManaged var filtered: NSNumber

}
