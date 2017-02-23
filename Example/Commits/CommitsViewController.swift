//
//  CommitsViewController.swift
//  Polymorph
//
//  Created by Tony Li on 1/25/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

import UIKit
import SafariServices

class CommitsViewController: UITableViewController {

  fileprivate var commits: [Commit]?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Commits";
    tableView.rowHeight = 60

    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://api.github.com/repos/douban/Polymorph/commits")!), completionHandler: {
      (data, _, _) -> Void in
      guard let data = data,
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [AnyObject]
        else { return }
      self.commits = json.map { Commit(dictionary: $0 as? [AnyHashable: Any]) }
      self.tableView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
    }) .resume()
  }

}

extension CommitsViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commits?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let commit = commits?[(indexPath as NSIndexPath).row] else { return UITableViewCell() }

    var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    }
    cell?.textLabel?.text = commit.message
    cell?.detailTextLabel?.text = DateFormatter.localizedString(from: commit.date,
      dateStyle: .medium, timeStyle: .short)
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let commit = commits?[(indexPath as NSIndexPath).row] else { return }
    if #available(iOS 9.0, *) {
      present(SFSafariViewController(url: commit.diffURL), animated: true, completion: nil)
    } else {
      // Fallback on earlier versions
    }
  }
  
}
