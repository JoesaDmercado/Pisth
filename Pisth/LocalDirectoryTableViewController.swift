//
//  LocalDirectoryTableViewController.swift
//  Pisth
//
//  Created by Adrian on 26.12.17.
//

import UIKit

class LocalDirectoryTableViewController: UITableViewController {
    
    // MARK: - LocalDirectoryTableViewController
    
    var directory: URL
    var files = [URL]()
    var error: Error?
    
    init(directory: URL) {
        
        self.directory = directory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            for file in files {
                self.files.append(directory.appendingPathComponent(file))
            }
        } catch let error {
            self.error = error
        }
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = directory.lastPathComponent
        
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(UINib(nibName: "FileTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "file")
        tableView.backgroundColor = .black
        clearsSelectionOnViewWillAppear = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        if let error = error {
            let errorAlert = UIAlertController(title: "Error removing file!", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return files.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "file") as! FileTableViewCell
        
        // Configure the cell...
        
        cell.filename.text = files[indexPath.row].lastPathComponent
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: files[indexPath.row].path, isDirectory: &isDir) {
            if isDir.boolValue { // Is directory
                cell.iconView.image = #imageLiteral(resourceName: "folder")
            } else { // Is file
                cell.iconView.image = #imageLiteral(resourceName: "file")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try FileManager.default.removeItem(at: files[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error {
                let errorAlert = UIAlertController(title: "Error removing file!", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? FileTableViewCell else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
            tableView.deselectRow(at: indexPath, animated: true)
            
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                if cell.iconView.image == #imageLiteral(resourceName: "folder") { // Open folder
                    self.navigationController?.pushViewController(LocalDirectoryTableViewController(directory: self.files[indexPath.row]), animated: true)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
        })
    }
    
}


