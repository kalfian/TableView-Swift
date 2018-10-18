//
//  ViewController.swift
//  TableView
//
//  Created by Kukuh on 10/10/18.
//  Copyright © 2018 Kukuh. All rights reserved.
//

import UIKit
import CoreData
class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData()
//        if items = ud.array(forKey: "ToDoListArray") as? [Item]{
//            itemArray = items
//        }
    }

    //MARK: - TableView Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell",for: indexPath)
        let item = itemArray[indexPath.row]
        
        
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        //Ternary operator
        cell.accessoryType = item.stat ? .checkmark : .none
        
        return cell
    }
    
    //MARK: Tableview Delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].stat = !itemArray[indexPath.row].stat
        
        self.saveData()
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//           tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//           tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Delete Data
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let act = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, selesai) in
            
            self.ctx.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            
            self.loadData()
            self.saveData()
            
            selesai(true)
        }
        act.title = "Busek"
        act.backgroundColor = .red
        
        return act
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: -- Add New Item
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (UIAlertAction) in
            // Saat user meng-klik didalam alert
            
            let newItem = Item(context: self.ctx)
            
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveData()
            
        }
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "Create New item"
            
            textField = UITextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveData(){
        
        do{
            try ctx.save()
        }catch {
            print("Error saving Context : \(error)")
        }
        //            self.ud.set(self.itemArray, forKey: "ToDoListArray")
        
        print("Success")
        self.tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(),prediksi: NSPredicate? = nil){
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let catPrediksi = NSPredicate(format: "parentCategory.name MATCHES [cd] %@", selectedCategory!.name!)
        
        if let addPrediksi = prediksi {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [catPrediksi,addPrediksi])
        }else{
            request.predicate = catPrediksi
        }
        
        do{
           itemArray = try ctx.fetch(request)
        }catch{
            print("Error fetch Request : \(error)")
        }
    }
}
// MARK: - SearchBar
extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let req: NSFetchRequest<Item> = Item.fetchRequest()
            
        let prediksi = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)

        req.predicate = prediksi

        let sd = NSSortDescriptor(key: "title", ascending: true)

        req.sortDescriptors = [sd]
        
        loadData(with: req)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}
