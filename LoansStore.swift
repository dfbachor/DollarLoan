//
//  LoansStore.swift
//  dl5
//
//  Created by David Bachor on 8/5/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import UIKit
import CoreData

class LoanStore {
    
    var managedObjectContext: NSManagedObjectContext! = nil
    var allLoans = [Loan]()
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    func loadLoans() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Loan")
        
        do {
            let results = try self.managedObjectContext.fetch(request)
            allLoans = results as! [Loan]
            return true
        } catch {
            fatalError("loadData: Error in retreiving loan items")
        }
        return false
    }
    
    func updateLoan(loan: Loan) {
        let name = loan.name
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Loan")
        request.predicate = NSPredicate(format: "name == %@", name!)
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedObjectContext.fetch(request)
            
            if results.count == 1
            {
                for result in results as! [NSManagedObject]
                {
                    result.setValue(loan.name, forKey: "name")
                    result.setValue(loan.amount, forKey: "amount")
                    result.setValue(loan.phone, forKey: "phone")
                    result.setValue(loan.status, forKey: "status")
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print("Error saving loan for update \(error)")
                    }
                    
                }
            } else {
                print("Error: rows returned not equal to 1 for update")
            }
        } catch {
            print("Error fetching loan for update \(error)")
        }
    }

    
    func addLoan(name: String,  amount: Double?, phone: String?) -> Bool {
        
        // check for dups
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Loan")
        request.predicate = NSPredicate(format: "name == %@", name)
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try self.managedObjectContext.fetch(request)
            
            if results.count > 0 {
                print("createLoan: duplicate entry attempt")
                return false
            }
        } catch {
            print("createLoan: cannot fetch from database for new save")
        }

        
        // prep the new loan
        let loan = NSEntityDescription.insertNewObject(forEntityName: "Loan", into: self.managedObjectContext) as! Loan
        
        loan.name = name
        loan.amount = amount!
        loan.dateCreated = Date() as NSDate?
        loan.status = "New"
        loan.phone = phone
        
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("addNewItem: Error in storing Core Date")
        }
        
        return true
    } //end addLoan func
    
    func removeLoan(_ loan: Loan) {
        
        let predicate = NSPredicate(format: "name == %@", loan.name!)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Loan")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest) as! [Loan]
            if let loanToDelete = fetchedEntities.first {
                self.managedObjectContext.delete(loanToDelete)
            }
        } catch {
            print("Error deleting: \(error)")
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("removeLoan: Error deleting: self.managedObjectContext.save() \(error)")
        }
    }

    
} // end class
