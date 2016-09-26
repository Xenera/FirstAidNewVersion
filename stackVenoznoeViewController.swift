//
//  stackVenoznoeViewController.swift
//  FirstAidNewVersion
//
//  Created by Ернур Сункарбек on 03.09.16.
//  Copyright © 2016 ME. All rights reserved.
//

import UIKit

class stackVenoznoeViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var viewText: UITextView!
    
    
    var headerString: String? {
        didSet{
            configureView()
        }
    }
    var viewString : String? {
        didSet{
            configureText()
        }
    }
    func configureText() {
        viewText.text = viewString
    }
    
    
    func configureView() {
        headerLabel.text = headerString
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
