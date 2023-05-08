//
//  ViewController.swift
//  ChatBoard
//
//  Created by daryl on 2023/4/25.
//  Copyright © 2023 daryl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var commitButton: UIButton!
    @IBOutlet var inputApiKeyText: UITextField!
    
    var apiKey = ""
    var userDefault = UserDefaults(suiteName: "group.com.chat.gtp")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        commitButton.layer.cornerRadius = 8
    }
    
    
    // 主页面键入apiKey
    @IBAction func commitButtonTapped(_ sender: UIButton) {
        self.apiKey = inputApiKeyText.text!
        guard apiKey != "" else {
            return
        }
        
        // save
        ///Write Data:
        userDefault.set(apiKey, forKey: "chatGTP")
        userDefault.synchronize() //save to disk
        ///Read Data:
        let data = userDefault.object(forKey: "chatGTP")
        print("chatGTP: \(data)")
        
    }
}

