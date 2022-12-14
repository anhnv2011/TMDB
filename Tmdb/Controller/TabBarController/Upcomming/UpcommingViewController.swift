//
//  UpcommingViewController.swift
//  Tmdb
//
//  Created by MAC on 6/26/22.
//

import UIKit


class UpcommingViewController: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var upCommingTableView: UITableView!
    
    //MARK:- Property
    var movie = [Film]()
    var cellAimationFlag = [Int]()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fetchData()
        setupUI()
        
    }
    
    //MARK:- UI
    func setupUI(){
        setupTableView()
        setupNav()
        view.backgroundColor = UIColor.backgroundColor()
    }
    func setupNav(){
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    func fetchData(){
        APICaller.share.getUpcomming(mediaType: "movie") { (result) in
            switch result {
            case.success(let model):
                
                self.movie = model.results
                let dateTitle = "From: ".localized() + model.dates.minimum + "  to ".localized() + model.dates.maximum
                DispatchQueue.main.async {
                    self.navigationItem.title = dateTitle
                    self.upCommingTableView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        
    }
    
    func setupTableView(){
        upCommingTableView.register(UINib(nibName: "UpCommingTableViewCell", bundle: nil), forCellReuseIdentifier: "UpCommingTableViewCell")
        upCommingTableView.delegate = self
        upCommingTableView.dataSource = self
        
    }
    
    
}


    //MARK:- TableView Delegate, Datasource
extension UpcommingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = upCommingTableView.dequeueReusableCell(withIdentifier: "UpCommingTableViewCell", for: indexPath) as! UpCommingTableViewCell
        let currentmovie = movie[indexPath.row]
//        let path = currentmovie.poster_path
//        let name = (currentmovie.original_name ?? currentmovie.original_title) ?? "unknow"
//        cell.configDetailMovieTableCell(posterPath: path, name: name)
        cell.film = currentmovie
        cell.completionHandler = { [weak self]  in
            let transiton = TransitionDelegate()
            let vc = PlayerViewController(film: currentmovie)

            vc.transitioningDelegate = transiton
            vc.modalPresentationStyle = .fullScreen
            self!.present(vc, animated: true, completion: nil)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       
        if cellAimationFlag.contains(indexPath.row) == false {
            // initia state
            DisplayTableCell.displayTableCell(cell: cell, indexPath: indexPath)
            cellAimationFlag.append(indexPath.row)
        }
        
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FilmDetailPopUpViewController()
        
        var choseFilm = movie[indexPath.row]
        choseFilm.mediaType = "movie"
        vc.film = choseFilm
        vc.view.backgroundColor = .clear
        vc.completionDownload = {
            if let tabItems = self.tabBarController?.tabBar.items {
                // In this case we want to modify the badge number of the third tab:
                let tabItem = tabItems[2]
                tabItem.badgeValue = "New"
            }
        }
        
        present(vc, animated: true, completion: nil)
    }
}


