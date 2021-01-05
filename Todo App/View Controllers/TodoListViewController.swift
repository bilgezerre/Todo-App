//
//  ViewController.swift
//  Todo App
//
//  Created by Macbook on 28.12.2020.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    //    1ST APPROACH: Add the items to custom plist
    //    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // create context from AppDelegate for CoreData
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        print(dataFilePath)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
//        when the row is created put the checkmarks if it is exists
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        when user clicks the list item again, remove the checkmark
          itemArray[indexPath.row].done =  !itemArray[indexPath.row].done
          saveItems()
                
          tableView.deselectRow(at: indexPath, animated: true)
        
//        UPDATE DATA IN DATAMODEL
//        itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
//        DELETE
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

    }
    
//    MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item to list!", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
//            what will happen once user clicks the Add Item button on Alert
            if textField.text != "" {
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveItems()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    

//    MARK: - DATA MANIPULATION METHODS: Create and save the data to context & Load data from context to our itemArray
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("Error encoding data \(error)")
        }
        
        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

//       Create predicate to load the results by their categories
        let categoryPredicate  = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
//        when user searched, load items by category&searched keyword. otherwise use only categoryPredicate
        if let additionalpredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalpredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data\(error)")
        }
        
        tableView.reloadData()
    }

/*
      1ST APPROACH: Save and load items by encoding and decoding the data
        func saveItems(){
            let encoder = PropertyListEncoder()
    
            do {
                let data = try encoder.encode(itemArray)
                try data.write(to: dataFilePath!)
            } catch {
                print("Error encoding data \(error)")
            }
              tableView.reloadData()
        }

        func loadItems() {

                if let data = try? Data(contentsOf: dataFilePath!){
                    let decoder = PropertyListDecoder()
                    do {
                        itemArray = try decoder.decode([Item].self, from: data)
                    } catch {
                        print("Error while decoding data \(error)")
                    }
                }
                    tableView.reloadData()
        }
    */
    
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let searchedPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

//        ascending order to results
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
       
        loadItems(with: request, predicate: searchedPredicate)

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
//            go to original state: hide keyboard, hide close button,etc.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
  
}
