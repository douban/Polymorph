//
//  AppDelegate.swift
//  Polymorph
//
//  Created by Tony Li on 1/22/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

import UIKit

private struct Example {
  let name: String
  let viewController: UIViewController.Type
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private let examples = [
    Example(name: "Commits", viewController: CommitsViewController.self),
    Example(name: "正在热映", viewController: MoviesViewController.self),
  ]

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    let tableVC = UITableViewController()
    tableVC.title = "Examples"
    tableVC.tableView.delegate = self
    tableVC.tableView.dataSource = self
    tableVC.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = .whiteColor()
    window?.rootViewController = UINavigationController(rootViewController: tableVC)
    window?.makeKeyAndVisible()

    return true
  }

}

extension AppDelegate: UITableViewDataSource, UITableViewDelegate {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return examples.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    cell.accessoryType = .DisclosureIndicator
    cell.textLabel?.text = examples[indexPath.row].name
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    (self.window?.rootViewController as? UINavigationController)?
      .pushViewController(examples[indexPath.row].viewController.init(), animated: true)
  }

}
