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
  fileprivate let examples = [
    Example(name: "Commits", viewController: CommitsViewController.self),
    Example(name: "正在热映", viewController: MoviesViewController.self),
    ]

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let tableVC = UITableViewController()
    tableVC.title = "Examples"
    tableVC.tableView.delegate = self
    tableVC.tableView.dataSource = self
    tableVC.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.rootViewController = UINavigationController(rootViewController: tableVC)
    window?.makeKeyAndVisible()

    return true
  }

}

extension AppDelegate: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return examples.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = examples[(indexPath as NSIndexPath).row].name
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    (self.window?.rootViewController as? UINavigationController)?
      .pushViewController(examples[(indexPath as NSIndexPath).row].viewController.init(), animated: true)
  }
  
}
