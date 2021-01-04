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
    
    @IBOutlet weak var searchBar: UISearchBar!
    //    1ST APPROACH
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
//    2ND APPROACH (COREDATA) create context from AppDeleghate for CoreData
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        print(dataFilePath)
        
        loadItems()
        
    }
    
//    UITableViewDataSource
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
    
//    UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        UPDATE DATA IN DATAMODEL
//        itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
//        DELETE
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
//        when user clicks the list item again, remove the checkmark
        itemArray[indexPath.row].done =  !itemArray[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func saveItems(){
        
//  1ST APPROACH:
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("Error encoding data \(error)")
//        }

//  2ND APPROACH(COREDATA): Crete and save the data to context
        do {
            try context.save()
        } catch {
            print("Error encoding data \(error)")
        }
        
        tableView.reloadData()
    }

//   1ST APPROACH:
//    func loadItems() {

//            if let data = try? Data(contentsOf: dataFilePath!){
//                let decoder = PropertyListDecoder()
//                do {
//                    itemArray = try decoder.decode([Item].self, from: data)
//                } catch {
//                    print("Error while decoding data \(error)")
//                }
//            }
        
//                tableView.reloadData()
        
//    }
    
//    2ND APPROACH (COREDATA) : Load data from context to our itemArray
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
//        let  request : NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data\(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        print(searchBar.text!)
//        ascending order to results
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
       
        loadItems(with: request)

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
