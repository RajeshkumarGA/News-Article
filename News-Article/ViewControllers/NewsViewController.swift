//
//  ViewController.swift
//  News-Article
//
//  Created by Apple on 19/09/20.
//

import UIKit
import CoreData

let defUrl = "http://techcrunch.com/2020/02/10/equity-monday-cherre-raises-16m-lyfts-critical-earnings-and-weworks-profit-hopes/"

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var sortSwitch: UISwitch!
    @IBOutlet weak var sortLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataSaved = false
    
    @IBAction func switchAction(_ sender: Any) {
        if sortSwitch.isOn {
            sortArticlesAndReload(ascending: false)
            DispatchQueue.main.async {
                self.sortLabel.text = "Newest to oldest"
            }
            return
        }
        sortArticlesAndReload(ascending: true)
        DispatchQueue.main.async {
            self.sortLabel.text = "Oldest to newest"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newsTable.setNoDataPlaceholder("No News Yet.. :(")
        
        self.setupTableView()
        self.setupSearchBar()
//        self.setupGesture()
        
        self.fetchDataFromManager()
    }
    
    func fetchDataFromManager() {
        let dict:[NewsArticle] = DataManager.shared.getArticlesFromCoreData(entityName: EntityName.article.getEntityName())
        if dict.count != 0 {
            DataManager.shared.news = dict
            DataManager.shared.newsCopy = DataManager.shared.news
            self.sortArticlesAndReload(ascending: false)
        } else {
            DataManager.shared.getArticlesFromApi { (data) in
                self.saveToCoreData(news: data)
                self.sortArticlesAndReload(ascending: false)
            }
        }
    }
    
    func saveToCoreData(news:[NewsArticle]) {
        guard dataSaved == false else {
            return
        }
        DataManager.shared.newsCopy = DataManager.shared.news
        var dict:[String:String] = [:]
        for article in news {
            dict = [:]
            dict["author"] = article.author
            dict["title"] = article.title
            dict["articleDescription"] = article.description
            dict["url"] = article.url
            dict["urlToImage"] = article.urlToImage
            dict["publishedAt"] = article.publishedAt
            CoreDataManager.shared.createRecord(records: dict, entityName: EntityName.article.getEntityName())
        }
        dataSaved = true
    }
    
    func sortArticlesAndReload(ascending:Bool) {
        if ascending {
            DataManager.shared.news = DataManager.shared.news.sorted { $0.publishedAt! < $1.publishedAt! }
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
            return
        }
        DataManager.shared.news = DataManager.shared.news.sorted { $0.publishedAt! > $1.publishedAt! }
        DispatchQueue.main.async {
            self.newsTable.reloadData()
        }
        self.newsTable.removeNoDataPlaceholder()
    }
    
    func setupTableView() {
        newsTable.delegate = self
        newsTable.dataSource = self
        newsTable.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(_:_:)))
        gesture.minimumPressDuration = 2.0
        gesture.delegate = self
        self.newsTable.addGestureRecognizer(gesture)
    }
    
    @objc func longTapGesture(_ sender:UILongPressGestureRecognizer,_ indexPath:IndexPath){
        let point = sender.location(in: self.newsTable)
        let indexPath = self.newsTable.indexPathForRow(at: point)
        if let index = indexPath {
            self.showAlert()
            print("index tapped: \(index.row)")
        }
    }
    
    func showAlert() {
        DispatchQueue.main.async {
            let alertVc:UIAlertController = UIAlertController(title: "Want to save this news?", message: "Tap yes to save this news article.", preferredStyle: .alert)
            let yesAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in }
            let noAlertAction = UIAlertAction(title: "No", style: .default) { (action) in }
            alertVc.addAction(yesAlertAction)
            alertVc.addAction(noAlertAction)
            self.present(alertVc, animated: true, completion: nil)
        }
    }
    
    func loadArticlesOnSearchKeyword(keyword:String) {
        DataManager.shared.news = DataManager.shared.newsCopy
        if keyword.count != 0 {
            DataManager.shared.news = DataManager.shared.news.filter({ (article) -> Bool in
                (article.author?.contains(keyword) ?? false)
            })
        }
        self.sortArticlesAndReload(ascending: false)
    }
}

extension NewsViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadArticlesOnSearchKeyword(keyword: searchBar.text ?? "")
    }
}

extension NewsViewController:UIGestureRecognizerDelegate {}

extension NewsViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        cell.setupCell(news: DataManager.shared.news[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310
    }
}

extension NewsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        articleVc.webViewUrl = DataManager.shared.news[indexPath.row].url ?? defUrl
        self.navigationController?.pushViewController(articleVc, animated: true)
    }
}

extension UITableView {
    func setNoDataPlaceholder(_ message: String) {
        DispatchQueue.main.async {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            label.text = message
            label.sizeToFit()

            self.isScrollEnabled = false
            self.backgroundView = label
            self.separatorStyle = .none
        }
    }
}

extension UITableView {
    func removeNoDataPlaceholder() {
        DispatchQueue.main.async {
            self.isScrollEnabled = true
            self.backgroundView = nil
            self.separatorStyle = .singleLine
        }
    }
}
