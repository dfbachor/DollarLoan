//
//  Loan+CoreDataProperties.swift
//  dl5
//
//  Created by David Bachor on 8/5/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import Foundation
import CoreData


extension Loan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Loan> {
        return NSFetchRequest<Loan>(entityName: "Loan");
    }

    @NSManaged public var amount: Double
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var status: String?
    @NSManaged public var payments: NSSet?

}

// MARK: Generated accessors for payments
extension Loan {

    @objc(addPaymentsObject:)
    @NSManaged public func addToPayments(_ value: Payment)

    @objc(removePaymentsObject:)
    @NSManaged public func removeFromPayments(_ value: Payment)

    @objc(addPayments:)
    @NSManaged public func addToPayments(_ values: NSSet)

    @objc(removePayments:)
    @NSManaged public func removeFromPayments(_ values: NSSet)

}
