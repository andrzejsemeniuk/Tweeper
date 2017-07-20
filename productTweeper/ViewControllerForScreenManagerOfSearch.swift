//
//  ViewControllerForScreenManagerOfSearch.swift
//  productTweeper
//
//  Created by andrzej semeniuk on 7/4/17.
//  Copyright © 2017 Andrzej Semeniuk. All rights reserved.
//

import UIKit
import ASToolkit

class ViewControllerForScreenManagerOfSearch : UIViewController {
    
    @IBOutlet var label         : UILabel!
    
    @IBOutlet var buttonForBack : UIBarButtonItem!
    @IBOutlet var buttonForAdd  : UIBarButtonItem!
    @IBOutlet var buttonForEdit : UIBarButtonItem!

    @IBOutlet var table         : UITableView!
    
    var entries                 : [Search.Entry] = []
    
    var selected                : Int?
    
    static fileprivate let cellReuseIdentifier = "ViewForSearchEntry"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.buttonForBack.title    = "\u{21B0}"
//        self.buttonForBack.setTitleTextAttributes([NSFontAttributeName : UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], for: .normal)
        
        self.buttonForEdit.possibleTitles = ["Edit","Done"]
        self.buttonForEdit.title = "Edit"
        
        label.backgroundColor       = Preferences.current.colorOfScreenTitleBackground
        label.textColor             = .white
        
        table.delegate              = self
        table.dataSource            = self
        table.separatorStyle        = .singleLineEtched
        table.separatorColor        = Preferences.current.colorOfScreenSearchListSeparator
        
        entries = Search.getAllEntries()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapOnButtonAdd(_ sender: UIBarButtonItem) {
        let newEntry = Search.Entry(title:"NEW")
        Search.add(entry:newEntry)
        entries = Search.getAllEntries()
        table.reloadData()
        
        if let search = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerForScreenSearch") as? ViewControllerForScreenSearch {
            self.show(search, sender: sender)
            
            search.search.text = newEntry.title
            search.handleRefresh()
        }
    }
    
    @IBAction func tapOnButtonEdit(_ sender: UIBarButtonItem) {
        if table.isEditing {
            table.setEditing(false, animated: true)
            self.buttonForEdit.title = "Edit"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
                self.table.reloadData()
            }
        }
        else {
            table.setEditing(true, animated: true)
            self.buttonForEdit.title = "Done"
        }
    }

}

extension ViewControllerForScreenManagerOfSearch : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if 1 == Search.remove(entry:entries[indexPath.item]) {
                entries = Search.getAllEntries()
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            else {
                entries = Search.getAllEntries()
            }
        case .insert:
            self.entries.insert(Search.Entry(title:"??"), at: indexPath.item)
        case .none:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let entry = entries[safe:indexPath.item] {
            self.selected = indexPath.item
//            entry.title += "?"
//            Search.update(entry:entry)
//            entries = Search.getAll()
//            table.reloadData()
        }
    }
}

extension ViewControllerForScreenManagerOfSearch : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = indexPath.item
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if let entry = entries[safe:item] {
            
            cell.textLabel?.attributedText = entry.title | UIColor(white:170.0/255.0)
            
            let created = entry.created.components(separatedBy: ".")[safe:0] ?? entry.created
            
            cell.detailTextLabel?.attributedText = created | UIColor(white:210.0/255.0)
        }
        
        cell.backgroundColor = item.isOdd ? UIColor(white:0.97) : UIColor.white
        
//        cell.indentationLevel = item
        
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
