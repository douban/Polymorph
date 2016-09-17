//
//  ViewController.swift
//  Polymorph
//
//  Created by Tony Li on 1/22/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

import UIKit
import SafariServices

class MoviesViewController: UITableViewController {

  var inTheaterMovies: MovieResult?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "正在热映";
    tableView.rowHeight = 60

    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://api.douban.com/v2/movie/in_theaters")!), completionHandler: {
      (data, _, _) in
      guard let data = data,
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
        else {
          return
      }

      self.inTheaterMovies = MovieResult(dictionary: json)
      self.tableView .performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
    }) .resume()
  }

}

extension MoviesViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return inTheaterMovies?.movies.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let movie = inTheaterMovies?.movies[(indexPath as NSIndexPath).row] else { return UITableViewCell() }

    var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    }
    cell?.textLabel?.text = movie.title
    cell?.detailTextLabel?.text = String(format: "评分：%.1f", movie.rating)
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let movie = inTheaterMovies?.movies[(indexPath as NSIndexPath).row],
      let url = URL(string: "https://m.douban.com/movie/subject/")?.appendingPathComponent(movie.identifier)
      else { return }

    if #available(iOS 9.0, *) {
      present(SFSafariViewController(url: url), animated: true, completion: nil)
    } else {
      // Fallback on earlier versions
    }
  }

}
