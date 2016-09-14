//
//  MasterVC.swift
//  Supl
//
//  Created by Marek Fořt on 08.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class MasterVC: UIViewController {

    @IBOutlet weak var pageController: UIPageControl!
    
    var pageVC: PageVC? {
        didSet {
            pageVC?.pageDelegate = self
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? PageVC {
            self.pageVC = pageVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        pageVC?.scrollToNextViewController()
    }

}

extension MasterVC: PageVCDelegate {
    
    func pageVC(_ tutorialPageViewController: PageVC,
        didUpdatePageCount count: Int) {
            pageController.numberOfPages = count
    }
    
    func pageVC(_ tutorialPageViewController: PageVC,
        didUpdatePageIndex index: Int) {
            pageController.currentPage = index
    }
    
}

