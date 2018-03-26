//
//  LoanDetailViewController.swift
//  dl5
//
//  Created by David Bachor on 8/5/17.
//  Copyright © 2017 David Bachor. All rights reserved.
//

import UIKit
import ContactsUI


enum AddOrEdit {
    case add
    case edit
}



// MARK: - Formatters

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()


class LoanDetailViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var selectContactButton: UIButton!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var dateCreatedField: UITextField!
    @IBOutlet var statusField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var paymentTableView: UITableView!
    
    
    var addOrEdit: AddOrEdit? = .edit
    var loanStore: LoanStore!
    var paymentStore: PaymentStore!

    var loan: Loan! {
        didSet {
            switch addOrEdit! {
            case .add:
                navigationItem.title = "new"
            case .edit:
                navigationItem.title = loan.name
            }
        }
    }
    
    func loadPaymentData() {
        if paymentStore.loadPayments(loan: loan) {
            paymentTableView.reloadData()
        } else {
            fatalError("LoansViewController.loadPaymentData: Error loading loans")
        }
    }

    
    func saveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        // save the data from the screen to the loan (aloan)
        var okToSave: Bool = true
        
        switch addOrEdit! {
        case .add:
            
            //print("addnewL \(loanStore.allLoans.index(of: nameField.text))")
            // a name is required
            guard
                let name = nameField.text,
                !name.isEmpty
                else {
                    return
            }
            
            var amt: Double!
            let amtText = amountField.text
            let value = numberFormatter.number(from: amtText!)
            
            amt = value?.doubleValue
            
            
            okToSave = loanStore.addLoan(name: nameField.text ?? "",
                                         amount: amt,
                                         phone: phoneField.text) ? true: false
            
            
            break
        case .edit:
            loan.name = nameField.text ?? ""
            loan.phone = phoneField.text
            loan.status = statusField.text
            
            if let amtText = amountField.text, let value = numberFormatter.number(from: amtText) {
                loan.amount = value.doubleValue
            } else {
                loan.amount = 0.0
            } // end if
            
            loanStore.updateLoan(loan: loan)
            
        } // end switch
        
        
        if okToSave {
            self.performSegue(withIdentifier: "unwindToLoans", sender: self)
        } else {
            
            let alertController = UIAlertController(
                title: "Alert",
                message: "A loan for this person already exists, Only 1 loan per person!"
                ,
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let okayAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // ...
            }
            
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    } // end function

    //MARK: - Contact Functions
    
    @IBAction func selectContactButtonPressed(_ sender: UIButton) {
        print("show Contacts")
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        //print(contact)
        
        //for phone in contact.phoneNumbers {
        //    print("The \(phone.label) number of \(contact.givenName) is: \(phone.value)")
        //}
        
        nameField.text = contact.givenName + " " + contact.familyName
        
        //let number = contact.phoneNumbers.first
        //let digits = number?.value.value(forKey: "digits") as? String
        //print("-first phone number : \(digits!)")
        //print("-given name: \(contact.givenName)")
        //print("-family name: \(contact.familyName)")
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }

    // MARK: - View FUnctions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentTableView.dataSource = self
        paymentTableView.delegate = self
        
        switch addOrEdit! {
        case .add:
            selectContactButton.isHidden = false
            dateCreatedField.text = "\(dateFormatter.string(from: Date()))"
            addPaymentButton.isHidden = true
            addPaymentLabel.isHidden = true
        case .edit:
            selectContactButton.isHidden = true
            addPaymentButton.isHidden = false
            addPaymentLabel.isHidden = false
            loadPaymentData()
        }
        
        phoneField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let rightBarButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LoanDetailViewController.saveBarButtonItemTapped(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        switch addOrEdit! {
        case .add:
            phoneField.becomeFirstResponder()
            break
        case .edit:
            nameField.text = loan.name
            phoneField.text = loan.phone
            statusField.text = loan.status
            amountField.text = numberFormatter.string(from: NSNumber(value: loan.amount))
            dateCreatedField.text = dateFormatter.string(from: loan.dateCreated as! Date)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        view.endEditing(true)
        
    }
    
    
    // MARK: - Text Field Delegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - payment table views
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if paymentStore == nil {
            return 0
        }
        
        return paymentStore.allPayments.count // your number of cell here
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if paymentTableView != tableView {
            print("paymentTableView == tableView: false")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        
        let payment = paymentStore.allPayments[indexPath.row]
        
        cell.amountLabel.text = "$\(payment.amount)"
        //cell.paymentDateLabel.text = "\(payment.dayte!)"
        cell.paymentDateLabel.text = dateFormatter.string(from: payment.dayte as! Date)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell selected code here
    }
    
    // MARK: - Payment functions
    
    @IBOutlet var addPaymentLabel: UILabel!
    @IBOutlet var addPaymentButton: UIButton!
    
    
    @IBAction func addPaymentPressed(_ sender: UIButton) {
    
        let alert = UIAlertController(title: "Add Payment", message: "Enter payment amount", preferredStyle: .alert)
        
        //Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            textField.keyboardType = .numberPad
        }
        
        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            
            self.createPayment(withAmount: (textField?.text)!)
            
            // reload the payments from coredata
            self.loadPaymentData()
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func createPayment(withAmount amount: String) {
        var amt: Double!
        let dayte = Date() as NSDate
        
        if let value = numberFormatter.number(from: amount) {
            amt = value.doubleValue
        } else {
            amt = 0.0
            print("Error: payment values converting to zero  - check number entry is a float")
        } // end if
        
        if amt != 0.0 {
            paymentStore.createPayment(loan: loan, amount: amt, dayte: dayte)
        } else {
            let alertController = UIAlertController(
                title: "Alert",
                message: "the amount must be a float value"
                ,
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let okayAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // ...
            }
            alertController.addAction(okayAction)
            self.present(alertController, animated: true)
        }
    }
 

}
