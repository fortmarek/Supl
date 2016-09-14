//
//  PageVC.swift
//  Supl
//
//  Created by Marek Fořt on 08.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController {
    
    var pageArray = [UIViewController]()
    
    var pageDelegate: PageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        dataSource = self
        delegate = self
        
        self.view.backgroundColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
        
        pageArray = [newVC("WalkthroughVC"), newVC("NotificationVC"), newVC("SafariVC"), newVC("SetUpVC")]
        
        if let initialViewController = pageArray.first {
            scrollToViewController(initialViewController)
        }
        
        pageDelegate?.pageVC(self, didUpdatePageCount: pageArray.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func newVC (_ name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        return vc
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                viewControllerAfter: visibleViewController) {
                    scrollToViewController(nextViewController)
        }
    }
    
    fileprivate func scrollToViewController(_ viewController: UIViewController) {
        setViewControllers([viewController],
            direction: .forward,
            animated: true,
            completion: { (finished) -> Void in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = pageArray.index(of: firstViewController) {
                pageDelegate?.pageVC(self, didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension PageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pageArray.index(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard pageArray.count > previousIndex else {
                return nil
            }
            
            return pageArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pageArray.index(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = pageArray.count
            
            guard orderedViewControllersCount != nextIndex else {
                return pageArray[0]
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return pageArray[nextIndex]
    }

}



extension PageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            notifyTutorialDelegateOfNewIndex()
    }
}
protocol PageVCDelegate {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func pageVC(_ tutorialPageViewController: PageVC,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageVC(_ tutorialPageViewController: PageVC,
        didUpdatePageIndex index: Int)
    
}


