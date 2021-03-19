//
//  GitUserListTableViewController.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import UIKit
 
class GitHubUserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorImageView: UIImageView!
    
    private var alert: UIAlertController?
    private var toastmsgs : [String] = []
    
    private var gitHubListViewModel = GitHubUserListViewModel()
    var resultSearchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            //                tableView.tableHeaderView = controller.searchBar
            self.navigationItem.titleView = controller.searchBar;
            return controller
        })()
        gitHubListViewModel.setProtocol(self)
        tableView.register(NormalGitHubUserTableViewCell.self, forCellReuseIdentifier: Constants.normalCellIdentifier)
        tableView.register(NoteGitHubUserTableViewCell.self, forCellReuseIdentifier: Constants.noteCellIdentifier)
        tableView.register(InvertedGitHubUserTableViewCell.self, forCellReuseIdentifier: Constants.invertedCellIdentifier)
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: Constants.LOADING_CELL_IDENTIFIER)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = 70
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gitHubListViewModel.load()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gitHubListViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gitHubUserViewModel = gitHubListViewModel.gitHubUserViewModelAt(index: indexPath.row)
        
        if let gitHubUserViewModel = gitHubUserViewModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: gitHubUserViewModel.cellIdentifier(), for: indexPath)
            (cell as! GHUserTableViewCellDelegate).setupUI(gitHubUserViewModel)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.LOADING_CELL_IDENTIFIER, for: indexPath) as! LoadingTableViewCell
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.startShimmering()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "details", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            let controller = segue.destination as! ProfileViewController
            let row = sender as! Int
            controller.inputId = gitHubListViewModel.gitHubUserViewModelAt(index: row)?.gitHubUser.id
        }
    }
}

extension GitHubUserTableViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        gitHubListViewModel.searchUpdated(text: searchController.searchBar.text!)
    }
}

extension GitHubUserTableViewController : UITableViewDataSourcePrefetching{
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= (gitHubListViewModel.numberOfRows() - 1)
      }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            gitHubListViewModel.loadNextPage()
        }
    }
}

extension GitHubUserTableViewController: GitHubUserListViewModelProtocol{
    func listLoaded() {
        self.tableView.reloadData()
    }
    
    func showErrorUI(errorText: String, imageName: String) {
        self.tableView.isHidden = true
        errorLabel.text = errorText
        errorImageView.image = UIImage(named: imageName)
        errorLabel.isHidden = false
        errorImageView.isHidden = false
    }
    
    func hideErrorUI() {
        self.tableView.isHidden = false
        errorLabel.isHidden = true
        errorImageView.isHidden = true
    }
    
    func showErrorUIPopover(errorText: String) {
        alert = UIAlertController(title: "", message: errorText, preferredStyle: UIAlertController.Style.alert)
        alert?.addAction(UIAlertAction(title: "Reload", style: UIAlertAction.Style.default, handler: { (action) in
            self.gitHubListViewModel.manualReloadAfterError()
        }))
        alert?.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert!, animated: true, completion: nil)
    }
    
    func loadingInitaited() {
        hideErrorUI()
        alert?.dismiss(animated: true, completion: nil)
    }
    
//    func offlineRedFlag() {
//        if let view = self.view.viewWithTag(101) {
//            view.removeFromSuperview()
//        }
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-(self.view.frame.size.height/5), width: 250, height: 35))
//        toastLabel.backgroundColor = UIColor.red
//        toastLabel.textAlignment = .center;
//        toastLabel.textColor = UIColor.white
//        toastLabel.text = "Offline"
//        toastLabel.alpha = 1.0
//        toastLabel.tag = 101
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.addSubview(toastLabel)
//    }
//
//    func onlineRedFlag() {
//        if let view = self.view.viewWithTag(101) {
//            view.removeFromSuperview()
//        }
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-(self.view.frame.size.height/5), width: 250, height: 35))
//        toastLabel.backgroundColor = UIColor.green
//        toastLabel.textAlignment = .center;
//        toastLabel.textColor = UIColor.black
//        toastLabel.text = "online"
//        toastLabel.alpha = 1.0
//        toastLabel.tag = 101
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.addSubview(toastLabel)
//    }
//
//    func showToast(_ msg: String) {
//        if let view = self.view.viewWithTag(111) {
//            (view as! UILabel).text = "\((view as! UILabel).text ?? "") ::: \(msg)"
//        } else {
//            let toastLabel = UILabel(frame: CGRect(x:0, y: self.view.frame.size.height-(self.view.frame.size.height/5), width: self.view.frame.size.width, height: 60))
//            toastLabel.backgroundColor = UIColor.darkGray
//            toastLabel.textAlignment = .center;
//            toastLabel.tag = 111
//            toastLabel.alpha = 1.0
//            toastLabel.text = msg
//            toastLabel.layer.cornerRadius = 10;
//            toastLabel.clipsToBounds  =  true
//            self.view.addSubview(toastLabel)
//            UIView.animate(withDuration: 2.0, delay: 5.00, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//            }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//            })
//        }
//    }
    
}
