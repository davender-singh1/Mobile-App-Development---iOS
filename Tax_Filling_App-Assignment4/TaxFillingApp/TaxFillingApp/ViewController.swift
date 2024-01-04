import UIKit
import CoreData

struct APIUser: Codable {
    let id: Int
    let name: String
    let phone: String
    let company: APICompany
    let address: APIAddress
}

struct APICompany: Codable {
    let name: String
}

struct APIAddress: Codable {
    let city: String
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var customers: [CustomerEntity] = []
    var context: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not find AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
        
        if isFirstLaunch() {
            fetchAndStoreDataIfNeeded()
        } else {
            fetchCustomers()
        }

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCustomers()
    }

    func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }

    func fetchAndStoreDataIfNeeded() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let apiUsers = try JSONDecoder().decode([APIUser].self, from: data)
                DispatchQueue.main.async {
                    self.store(apiUsers: apiUsers)
                    self.fetchCustomers()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func store(apiUsers: [APIUser]) {
        // Clear existing data if necessary
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
        
        // Store new data
        for apiUser in apiUsers {
            let customer = CustomerEntity(context: context)
            customer.id = Int64(apiUser.id)
            customer.name = apiUser.name
            customer.phone = apiUser.phone
            customer.processStatus = "AWAITED"
            
            let company = CompanyEntity(context: context)
            company.name = apiUser.company.name
            customer.relationship = company
            
            let address = AddressEntity(context: context)
            address.city = apiUser.address.city
            customer.relationship1 = address
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    func fetchCustomers() {
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        do {
            customers = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch customers: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as? CustomerTableViewCell else {
                fatalError("The dequeued cell is not an instance of CustomerTableViewCell.")
            }
        let customer = customers[indexPath.row]
        
        
        cell.nameLabel.text = customer.name
        cell.phoneLabel.text = customer.phone
        cell.cityLabel.text = customer.relationship1?.city
        cell.companyNameLabel.text = customer.relationship?.name
        cell.processStatusLabel.text = customer.processStatus

        // Set background color based on process status
        switch customer.processStatus {
        case "AWAITED":
            cell.backgroundColor = UIColor.yellow
        case "COMPLETED":
            cell.backgroundColor = UIColor.green
        case "DENIED":
            cell.backgroundColor = UIColor.red
        default:
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let detailVC = segue.destination as? DetailViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            let selectedCustomer = customers[indexPath.row]
            detailVC.customer = selectedCustomer
            detailVC.context = context
        }
    }

    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let customerToRemove = customers[indexPath.row]
            
            // Create and configure the alert controller
            let alert = UIAlertController(title: "Delete Customer", message: "Are you sure you want to delete this customer?", preferredStyle: .alert)
            
            // Add actions
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Perform the deletion
                self.context.delete(customerToRemove)
                self.customers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Save the context
                do {
                    try self.context.save()
                } catch {
                    print("Error saving context after delete: \(error)")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // Add actions to the alert controller
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            // Present the alert
            self.present(alert, animated: true)
        }
    }

    
    private func fetchFromCoreData() -> [CustomerEntity] {
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch customers: \(error)")
        }
    }
}


class CustomerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var processStatusLabel: UILabel!
}


class DetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var processStatusSegmentedControl: UISegmentedControl!

    var customer: CustomerEntity?
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        populateCustomerDetails()
    }

    func populateCustomerDetails() {
        if let customer = customer {
            nameTextField.text = customer.name
            phoneTextField.text = customer.phone
            cityTextField.text = customer.relationship1?.city
            companyNameTextField.text = customer.relationship?.name
        
            switch customer.processStatus {
            case "AWAITED":
                processStatusSegmentedControl.selectedSegmentIndex = 0
            case "COMPLETED":
                processStatusSegmentedControl.selectedSegmentIndex = 1
            case "DENIED":
                processStatusSegmentedControl.selectedSegmentIndex = 2
            default:
                processStatusSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
            }
        }
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let customer = customer else { return }
        customer.phone = phoneTextField.text
        switch processStatusSegmentedControl.selectedSegmentIndex {
        case 0:
            customer.processStatus = "AWAITED"
        case 1:
            customer.processStatus = "COMPLETED"
        case 2:
            customer.processStatus = "DENIED"
        default:
            break
        }

        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        navigationController?.popViewController(animated: true)
    }
}

