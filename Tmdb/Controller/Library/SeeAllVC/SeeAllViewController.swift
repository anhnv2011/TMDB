//
//  SeeAllViewController.swift
//  Tmdb
//
//  Created by MAC on 10/1/22.
//

import UIKit
enum CompositionalLayoutGroupAlignment {
    case vertical
    case horizontal
}
struct CompositionalLayout {
    static func createItem(width: NSCollectionLayoutDimension,
                           height: NSCollectionLayoutDimension,
                           spacing: CGFloat
    ) -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                             heightDimension: height))
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        return item
        
    }
    
    static func createGroup (alignment: CompositionalLayoutGroupAlignment,
                             width: NSCollectionLayoutDimension,
                             height: NSCollectionLayoutDimension,
                             items: [NSCollectionLayoutItem])
    -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize:NSCollectionLayoutSize(widthDimension: width,                                                                              heightDimension: height),                                         subitems: items)
            
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize:NSCollectionLayoutSize(widthDimension: width,                                                                              heightDimension: height),                                         subitems: items)
        }
    }
    static func createGroup (alignment: CompositionalLayoutGroupAlignment,
                             width: NSCollectionLayoutDimension,
                             height: NSCollectionLayoutDimension,
                             item: NSCollectionLayoutItem,
                             count: Int)
    -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize:NSCollectionLayoutSize(widthDimension: width,                                                                              heightDimension: height),subitem: item,
                                                    count: count)
            
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize:NSCollectionLayoutSize(widthDimension: width,                                                                              heightDimension: height),                                         subitem: item,
                                                      count: count)
        }
    }
}

class SeeAllViewController: UIViewController {
    //MARK:- Outlet
    @IBOutlet weak var seeAllCollectionView: UICollectionView!
   
    
    //MARK:- Property
    var cellAimationFlag = [Int]()
    var films = [Film]()
    var isLanscape = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.setupUI()
            }
        }
    }

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    
    //MARK:- UI
    func setupUI (){
        view.backgroundColor = UIColor.backgroundColor()
        setupCollectionView()
    }
    //MARK:- Landscape, portrait
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            configUIForLandscape()
        } else {
            configUIForPortrait()
        }
        
        self.view.setNeedsUpdateConstraints()
    }
    override func updateViewConstraints() {
    
        super.updateViewConstraints()
    }
    private func configUIForLandscape(){
        isLanscape = true
        view.layoutIfNeeded()
    }
    
    private func configUIForPortrait (){
        isLanscape = false
        view.layoutIfNeeded()

    }
    
    func setupCollectionView(){
        seeAllCollectionView.delegate = self
        seeAllCollectionView.dataSource = self
        seeAllCollectionView.register(UINib(nibName: "SeeAllCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SeeAllCollectionViewCell.identifier)
        if isLanscape == false {
            seeAllCollectionView.collectionViewLayout = creatViewLayout(heightRatio: 0.3)
        } else {
            seeAllCollectionView.collectionViewLayout = creatViewLayout(heightRatio: 1)
        }
        seeAllCollectionView.backgroundColor = UIColor.popupBackground()
    }

    func creatViewLayout(heightRatio: Float) -> UICollectionViewCompositionalLayout {
        //item
        let item = CompositionalLayout.createItem(width: .fractionalWidth(0.5), height: .fractionalHeight(1), spacing: 1)
        
        let horizontaltem = CompositionalLayout.createItem(width: .fractionalWidth(0.5), height: .fractionalHeight(1), spacing: 1)
        let horizontalGroup = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(1), item: horizontaltem, count: 2)
        
//        let verticalitem = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 1)
        let verticalgroup = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(0.5), height: .fractionalHeight(1), item: horizontalGroup, count: 2)
        
        //group
        let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(CGFloat(heightRatio)), items: [item, verticalgroup])
        //section
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func showFilmPopupDetail(film: Film){
        let vc = FilmDetailPopUpViewController()
        vc.completionDownload = {
            if let tabItems = self.tabBarController?.tabBar.items {
                // In this case we want to modify the badge number of the third tab:
                let tabItem = tabItems[2]
                tabItem.badgeValue = "New"
            }
        }
        vc.film = film
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

//MARK:- CollectionView
extension SeeAllViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        films.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = seeAllCollectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCollectionViewCell.identifier, for: indexPath) as! SeeAllCollectionViewCell
        cell.film = films[indexPath.row]
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let film = films[indexPath.row]
        showFilmPopupDetail(film: film)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
        }
    }
    
}
