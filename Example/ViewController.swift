//
//  ViewController.swift
//  Polymorph
//
//  Created by Tony Li on 1/22/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UITableViewController {

  var inTheaterMovies: MovieResult?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "正在热映";
    tableView.rowHeight = 60

    NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: "https://api.douban.com/v2/movie/in_theaters")!)) {
      (data, _, _) in
      guard let data = data,
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSObject: AnyObject]
        else {
          return
      }

      self.inTheaterMovies = MovieResult(dictionary: json)
      self.tableView .performSelectorOnMainThread("reloadData", withObject: nil, waitUntilDone: false)
    }.resume()
  }

}

extension ViewController {

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return inTheaterMovies?.movies.count ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let movie = inTheaterMovies?.movies[indexPath.row] else { return UITableViewCell() }

    var cell = tableView.dequeueReusableCellWithIdentifier("cell")
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
    }
    cell?.textLabel?.text = movie.title
    cell?.detailTextLabel?.text = String(format: "评分：%.1f", movie.rating)
    return cell!
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let movie = inTheaterMovies?.movies[indexPath.row],
      let url = NSURL(string: "https://m.douban.com/movie/subject/")?.URLByAppendingPathComponent(movie.identifier)
      else { return }

    presentViewController(SFSafariViewController(URL: url), animated: true, completion: nil)
  }

}
