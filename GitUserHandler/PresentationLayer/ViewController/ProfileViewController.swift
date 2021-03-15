//
//  ProfileViewController.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 14/03/21.
//

import Foundation
import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    private var gitHubViewModel : GitHubUserViewModel?
    var inputId : Int32?
    
    private var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gitHubViewModel = GitHubUserViewModel(inputId)
        noteTextView?.layer.borderColor = UIColor.lightGray.cgColor
        
        imageView?.startShimmeringEffect()
        startUIShimmerAnimation()
        
        gitHubViewModel?.setGitHubUserViewModelDelegate(self)
        gitHubViewModel?.load()
        if let url = gitHubViewModel?.gitHubUser.avatar_url {
            gitHubViewModel?.loadImage(urlString: url, completionHandler: { (downloadedUrl, userName, data)  in
                if (url == downloadedUrl) {
                    self.imageView?.stopShimmeringEffect()
                    self.imageView?.image = UIImage(data: data ?? Data())
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.gitHubViewModel?.cleanup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gitHubViewModel?.setup()
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        gitHubViewModel?.saveNote(note: noteTextView.text)
    }
    
    private func startUIShimmerAnimation() {
        followersLabel?.startShimmeringEffect()
        followingLabel?.startShimmeringEffect()
        companyLabel?.startShimmeringEffect()
        nameLabel?.startShimmeringEffect()
        blogLabel?.startShimmeringEffect()
        noteTextView?.startShimmeringEffect()
    }
    
    private func stopUIShimmerAnimation() {
        followersLabel?.stopShimmeringEffect()
        followingLabel?.stopShimmeringEffect()
        companyLabel?.stopShimmeringEffect()
        nameLabel?.stopShimmeringEffect()
        blogLabel?.stopShimmeringEffect()
        noteTextView?.stopShimmeringEffect()
    }
    
}

extension ProfileViewController : GitHubUserViewModelProtocol {
    func userFound() {
        stopUIShimmerAnimation()
        
        followersLabel.text = "Followers: \(gitHubViewModel?.gitHubUser.followers ?? 0)"
        followingLabel.text = "Following: \(gitHubViewModel?.gitHubUser.following ?? 0)"
        companyLabel.text = "\(gitHubViewModel?.gitHubUser.company ?? "")"
        nameLabel.text = "\(gitHubViewModel?.gitHubUser.name ?? "")"
        blogLabel.text = "\(gitHubViewModel?.gitHubUser.blog ?? "")"
        noteTextView.text = "\(gitHubViewModel?.gitHubUser.note ?? "")"
    }
    
    func userSaved() {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-(self.view.frame.size.height/5), width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.darkGray
        toastLabel.textAlignment = .center;
        toastLabel.text = "Saved"
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.75, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showNoInternetConenctionUI() {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-(self.view.frame.size.height/5), width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.darkGray
        toastLabel.textAlignment = .center;
        toastLabel.text = "No internet"
        toastLabel.alpha = 1.0
        toastLabel.tag = 98
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
    }
    
    func hideNoInternetConenction() {
        UIView.animate(withDuration: 1.0, delay: 0.50, options: .curveEaseOut, animations: {
            self.view.viewWithTag(98)?.alpha = 0.0
        }, completion: {(isCompleted) in
            self.view.viewWithTag(98)?.removeFromSuperview()
        })
    }
    
    func showErrorUIPopover(errorText: String) {
        alert = UIAlertController(title: "", message: errorText, preferredStyle: UIAlertController.Style.alert)
        alert?.addAction(UIAlertAction(title: "Reload", style: UIAlertAction.Style.default, handler: { (action) in
            self.gitHubViewModel?.reloadAfterError()
        }))
        alert?.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert!, animated: true, completion: nil)
    }
    
    func userLoadingInitaited() {
        alert?.dismiss(animated: true, completion: nil)
        hideNoInternetConenction()
    }
}
