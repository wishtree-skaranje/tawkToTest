//
//  GitHubUserTableViewCell.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import UIKit

protocol GHUserTableViewCellDelegate {
    func setupUI(_ userVM : GitHubUserViewModel)
}

open class GitHubUserTableViewCell<T : GitHubUserViewModel>: UITableViewCell, GHUserTableViewCellDelegate, ImageLoaderProtocol {
    
    let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userImageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let holderView : UIView = {
        let holderV = UIView()
        holderV.translatesAutoresizingMaskIntoConstraints = false
        holderV.layer.cornerRadius = 25
        holderV.clipsToBounds = true
        return holderV
    }()
    
    private var gitHubUserViewModel : GitHubUserViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        holderView.addSubview(userImageView)
        addSubview(holderView)
        constraintActivate()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func constraintActivate() {
        NSLayoutConstraint.activate([
            holderView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            holderView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            holderView.widthAnchor.constraint(equalToConstant: 50),
            holderView.heightAnchor.constraint(equalToConstant: 50),

            label.leadingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: holderView.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            label.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            
//            userImageView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0),
//                       userImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
                       userImageView.widthAnchor.constraint(equalToConstant: 50),                    userImageView.heightAnchor.constraint(equalToConstant: 50),
//            holderView.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 0),
//                       holderView.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 0),
//                       holderView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0),
//                       holderView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
    
    func setupUI(_ userVM : GitHubUserViewModel) {
        gitHubUserViewModel = userVM
        if (gitHubUserViewModel?.gitHubUser.is_visited ?? false) {
            self.backgroundColor = UIColor(named: "rowVisited")
        } else {
            self.backgroundColor = UIColor(named: "rowNotVisited")
        }
        label.text = gitHubUserViewModel?.gitHubUser.login
        userImageView.image = nil
        userImageView.startShimmeringEffect()
        guard let url = gitHubUserViewModel?.gitHubUser.avatar_url else { return }
        gitHubUserViewModel?.setGitHubUserViewModelDelegate(self)
        gitHubUserViewModel?.loadImage(urlString: url)
    }
    
    func imageFound(_ urlString: String, _ data: Data?) {
        if (gitHubUserViewModel?.gitHubUser.avatar_url == urlString) {
            let image: UIImage = UIImage(data: data!)!
            userImageView.stopShimmeringEffect()
            setImage(image)
        }
    }
    
    func setImage(_ image: UIImage) {
        userImageView.image = image
    }
}

class NormalGitHubUserTableViewCell: GitHubUserTableViewCell<NoramlGitHubUserViewModel> {

}

class NoteGitHubUserTableViewCell: GitHubUserTableViewCell<NoteGitHubUserViewModel> {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 18))
        image.image = UIImage(named: "ic_note")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = UIColor.systemBlue
        self.accessoryView = image
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class InvertedGitHubUserTableViewCell: GitHubUserTableViewCell<InvertedGitHubUserViewModel>{
    override func setImage(_ image: UIImage) {
        if let filter = CIFilter(name: "CIColorInvert") {
            let img = CoreImage.CIImage(image:image)
            filter.setValue(img, forKey: kCIInputImageKey)
            let invertedImage = UIImage(ciImage: filter.outputImage!)
            userImageView.image = invertedImage
        } else {
            userImageView.image = image
        }
    }
}

class LoadingTableViewCell:  GitHubUserTableViewCell<GitHubUserViewModel>{
    func startShimmering() {
        self.userImageView.startShimmeringEffect()
        self.label.startShimmeringEffect()
    }
}
