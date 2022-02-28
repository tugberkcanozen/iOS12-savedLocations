//
//  MapDetailList.swift
//  locationSaved
//
//  Created by Tuğberk Can Özen on 27.02.2022.
//

import UIKit
import CoreData

class MapDetailList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titleArray = [String]()
    var idArray = [UUID]()
    var sourceTitle = ""
    var sourceId: UUID?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Locations"
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(nextViewController))
        getData()
    }
    
    @objc func nextViewController() {
        sourceTitle = ""
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name.init(rawValue: "newMap"), object: nil)
    }
    
    @objc func getData() {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        
        do {
            
            idArray.removeAll(keepingCapacity: false)
            titleArray.removeAll(keepingCapacity: false)
            
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                
                if let title = result.value(forKey: "title") as? String {
                    self.titleArray.append(title)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
            }
            
            tableView.reloadData()
            
        } catch {
            print("Error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSecondVC" {
            
            let destinationVC = segue.destination as! ViewController
            destinationVC.targetId = sourceId
            destinationVC.targetTitle = sourceTitle
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sourceTitle = titleArray[indexPath.row]
        sourceId = idArray[indexPath.row]
        performSegue(withIdentifier: "toSecondVC", sender: nil)
        
    }
}
