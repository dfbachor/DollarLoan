//
//  Payment+CoreDataProperties.swift
//  dl5
//
//  Created by David Bachor on 8/5/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import Foundation
import CoreData


extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment");
    }

    @NSManaged public var amount: Double
    @NSManaged public var name: String?
    @NSManaged public var dayte: NSDate?
    @NSManaged public var loan: Loan?

}
