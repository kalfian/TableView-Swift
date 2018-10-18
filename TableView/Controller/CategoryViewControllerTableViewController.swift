//
//  CategoryViewControllerTableViewController.swift
//  TableView
//
//  Created by Kukuh on 16/10/18.
//  Copyright © 2018 Kukuh. All rights reserved.
//

import UIKit
import CoreData
class CategoryViewControllerTableViewController: UITableViewController {
    
    var catArray = [Category]()
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    //Jumlah data yang ditampilkan dalam tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArray.count
    }
    
    //tampilan cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell",for: indexPath)
        let item = catArray[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        return cell
        
    }
    
    // MARK: - Add Category
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "tambahin kategori baru cuy", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (UIAlertAction) in
            // Saat user meng-klik didalam alert
            
            let newItem = Category(context: self.ctx)
            
            newItem.name = textField.text!
            self.catArray.append(newItem)
            
            self.saveData()
            
        }
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "Create New Category"
            
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
    
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        
        do{
            catArray = try ctx.fetch(request)
        }catch{
            print("Error fetch Request : \(error)")
        }
    }
    
    //MARK: - Delete Data
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let act = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, selesai) in
            
            self.ctx.delete(self.catArray[indexPath.row])
            self.catArray.remove(at: indexPath.row)
            
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
    
    //MARK: - Table view delegate method
    
    // Data tabel diklik
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            dest.selectedCategory = catArray[indexPath.row]
        }
    }
}
