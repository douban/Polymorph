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

  private var commits: [Commit]?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Commits";
    tableView.rowHeight = 60

    NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: "https://api.github.com/repos/douban/Polymorph/commits")!)) {
      (data, _, _) -> Void in
      guard let data = data,
        let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [AnyObject]
        else { return }
      self.commits = json.map { Commit(dictionary: $0 as? [NSObject : AnyObject]) }
      self.tableView.performSelectorOnMainThread("reloadData", withObject: nil, waitUntilDone: false)
    }.resume()
  }

}

extension CommitsViewController {

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commits?.count ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let commit = commits?[indexPath.row] else { return UITableViewCell() }

    var cell = tableView.dequeueReusableCellWithIdentifier("cell")
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
    }
    cell?.textLabel?.text = commit.message
    cell?.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(commit.date,
      dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    return cell!
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let commit = commits?[indexPath.row] else { return }
    presentViewController(SFSafariViewController(URL: commit.diffURL), animated: true, completion: nil)
  }
  
}
