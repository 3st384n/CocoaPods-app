//
//  CPPodfileViewController.swift
//  CocoaPods
//
//  Created by Orta on 11/15/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

/// UIVIewController to represent the Podfile editor
/// It's scope is keeping track of the user project,
/// handling / exposing tabs and providing a central
/// access place for mutable state within the Podfile
/// section of CocoaPods.app

/// TODO:
///  setting tabs via the images
///  cmd + 1,2,3
///  add commands for `pod install` / `update`


class CPPodfileViewController: NSViewController {

  var userProject:CPUserProject!
  @IBOutlet var contentView:NSView!
  dynamic var installAction: CPInstallAction!
  var tabController: NSTabViewController!

  @IBOutlet weak var actionTitleLabel: NSTextField!
  @IBOutlet weak var documentIconContainer: NSView!

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let storyboard = self.storyboard else {
      return print("This VC needs a storyboard to set itself up.")
    }

    guard let tabViewController = storyboard.instantiateControllerWithIdentifier("Podfile Content Tab Controller") as? NSTabViewController else {
      return print("Could not get the Content Tab View Controller")
    }


    addChildViewController(tabViewController)
    tabViewController.view.frame = contentView.bounds
    contentView.addSubview(tabViewController.view)

    // This just aligns the contentview at 0 to all edges
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":tabViewController.view]))
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":tabViewController.view]))
    tabController = tabViewController
  }

  override func viewWillAppear() {
    // The userProject is DI'd in after viewDidLoad

    installAction = CPInstallAction(userProject: userProject)

    // The view needs to be added to a window before we can
    guard let window = view.window as? CPModifiedDecorationsWindow, let documentIcon = window.documentIconButton else {
      return print("Window type is not CPModifiedDecorationsWindow")
    }
    documentIcon.frame = documentIcon.bounds
    documentIconContainer.addSubview(documentIcon)
  }

  @IBAction func install(obj: AnyObject) {
    installAction.performAction(.Install(verbose: false))
    showConsoleTab(self)
  }

  @IBAction func showEditorTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 0
  }

  @IBAction func showConsoleTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 2
  }

  @IBAction func showInformationTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 1
  }
}

extension NSViewController {

  /// Recurse the parentViewControllers till we find a CPPodfileViewController
  var podfileViewController: CPPodfileViewController? {

    guard let parent = self.parentViewController else { return nil }
    if let appVC = parent as? CPPodfileViewController {
      return appVC
    } else {
      return parent.podfileViewController
    }
  }
}