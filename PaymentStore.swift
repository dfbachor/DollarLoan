//
//  PaymentStore.swift
//  dl5
//
//  Created by David Bachor on 8/6/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import UIKit
import CoreData

class PaymentStore {
    
    var managedObjectContext: NSManagedObjectContext! = nil
    var allPayments = [Payment]()
    
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    func createPayment(loan: Loan, amount: Double, dayte: NSDate) {
        print("PaymentStore:CreatePayment")
        
        // prep the new payment
        let newPayment = NSEntityDescription.insertNewObject(forEntityName: "Payment", into: self.managedObjectContext) as! Payment
        
        // for the database object
        newPayment.loan = loan
        newPayment.name = loan.name
        newPayment.amount = amount
        newPayment.dayte = dayte
        
        do {
            try self.managedObjectContext.save()
            print("createPayment: saved")
        } catch {
            print("createPayment: Error on save \(error)")
            // Do something in response to error condition
        }
        
    } // end createPayment
    
    func loadPayments(loan: Loan) -> Bool {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Payment")
        request.predicate = NSPredicate(format: "loan == %@", loan)

        
        do {
            let results = try self.managedObjectContext.fetch(request)
            allPayments = results as! [Payment]
            return true
        } catch {
            fatalError("loadPayments: Error in retreiving loan payments")
        }
        return false
    } // end loadPayments
    
}
