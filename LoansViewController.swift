//
//  LoansViewController.swift
//  dl5
//
//  Created by David Bachor on 8/5/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import UIKit
import CoreData

class LoansViewController: UITableViewController {
    
    //var managedObjectContext: NSManagedObjectContext! = nil
    var loanStore: LoanStore!
    var paymentStore: PaymentStore!

    func loadData() {
        if loanStore.loadLoans() {
            tableView.reloadData()
        } else {
            fatalError("LoansViewController.loadData: Error loading loans")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Dollar Loan"
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        loadData()
    }
    
    /*
    @IBAction func toggleEditingMode(_ sender: UIButton) {
        
        if isEditing {
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
        } else {
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
        }
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //self.managedObjectContext = appDelegate.persistentContainer.viewContext
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
    }

    
    // MARK: - Table View Functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView.numberOfRowsInSection: loanStore.allLoans.count: \(loanStore.allLoans.count)")
        return loanStore.allLoans.count
    }
 
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "LoanCell", for: indexPath) as! LoanCell
        
        let loan = loanStore.allLoans[indexPath.row]
        
        cell.amountLabel.text = "$\(loan.amount)"
        cell.nameLabel.text = loan.name
        //cell.dateCreatedLabel.text = "Date Created: \(loan.dateCreated)"  // loan.dateCreated
        cell.dateCreatedLabel.text = dateFormatter.string(from: loan.dateCreated as! Date)
        //cell.textLabel?.text = loan.name
        //cell.detailTextLabel?.text = "\(loan.amount)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let loan = loanStore.allLoans[indexPath.row]
            
            let title = "Delete \(loan.name)'s loan?"
            let message = "Are you sure you want to delete this loan?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                
                self.loanStore.removeLoan(loan) // self is needed since we are in a closure
                // tableView.deleteRows(at: [indexPath], with: .automatic) // caused crash
                self.loadData()
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        switch segue.identifier {
        case "addLoan"?:
            let loanDetailViewController = segue.destination as! LoanDetailViewController
            loanDetailViewController.loanStore = loanStore
            loanDetailViewController.addOrEdit = .add
            self.navigationItem.title = "Loans"
        case "showLoan"?:
            if let row = tableView.indexPathForSelectedRow?.row {
                let loan = loanStore.allLoans[row]
                let loanDetailViewController = segue.destination as! LoanDetailViewController
                loanDetailViewController.loan = loan
                loanDetailViewController.loanStore = loanStore
                loanDetailViewController.addOrEdit = .edit
                loanDetailViewController.paymentStore = paymentStore
                self.navigationItem.title = "Loans"
        } // end if
        default:
            preconditionFailure("Unexpected segue identifier.")
        } // end switch
    }
    
    @IBAction func unwindToLoans(segue: UIStoryboardSegue) {
        print("sender:")
    }

    
}
