//
//  ProfileViewController.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 14/03/21.
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

    override func viewDidLoad() {
        super.viewDidLoad()
        gitHubViewModel = GitHubUserViewModel(inputId)
        noteTextView?.layer.borderColor = UIColor.lightGray.cgColor
        
        imageView?.startShimmeringEffect()
        followersLabel?.startShimmeringEffect()
        followingLabel?.startShimmeringEffect()
        companyLabel?.startShimmeringEffect()
        nameLabel?.startShimmeringEffect()
        blogLabel?.startShimmeringEffect()
        noteTextView?.startShimmeringEffect()
        
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
    
    @IBAction func saveClicked(_ sender: Any) {
        gitHubViewModel?.saveNote(note: noteTextView.text)
    }
    
}


extension ProfileViewController : GitHubUserViewModelProtocol {
    func userFound() {
        followersLabel?.stopShimmeringEffect()
        followingLabel?.stopShimmeringEffect()
        companyLabel?.stopShimmeringEffect()
        nameLabel?.stopShimmeringEffect()
        blogLabel?.stopShimmeringEffect()
        noteTextView?.stopShimmeringEffect()
        
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
}
