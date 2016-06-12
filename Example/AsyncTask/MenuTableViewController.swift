//
//  MenuTableViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/24/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let demoViewControllers: [(String, UIViewController.Type)] = [
        ("Sleep", SleepDemoViewController.self),
        ("Chained Animation", ChainedAnimationDemoViewController.self),
        ("Image Download", DefaultDemoViewController.self),
        ("Image Picker", ImagePickerDemoViewController.self),
        ("Network Request", RequestDemoViewController.self),]
//        ("Parallel Requests", ParallelRequestDemoViewController.self),]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Async Demo"
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoViewControllers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = titleForRowAtIndexPath(indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let title = titleForRowAtIndexPath(indexPath)
        let vc = viewControllerForRowAtIndexPath(indexPath)
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }

    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        let (title, _) = demoViewControllers[indexPath.row]
        return title
    }

    func viewControllerForRowAtIndexPath(indexPath: NSIndexPath) -> UIViewController {
        let (_, vc) = demoViewControllers[indexPath.row]
        return vc.init()
    }

}
