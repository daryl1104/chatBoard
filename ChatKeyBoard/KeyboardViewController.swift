//
//  KeyboardViewController.swift
//  ChatKeyBoard
//
//  Created by daryl on 2023/4/25.
//  Copyright © 2023 daryl. All rights reserved.
//

import UIKit

protocol ChatDelegate {
    func dataFetched(_ response:String)
}

class KeyboardViewController: UIInputViewController, ChatDelegate {
    func dataFetched(_ response: String) {
        self.responseStr = response
        print(":\(responseStr)")
        
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        // delete previous text
        let previousText = proxy.documentContextBeforeInput
        guard previousText != nil else {
            return
        }
        for _ in 0..<previousText!.count {
            proxy.deleteBackward()
        }
        
        proxy.insertText(responseStr)
    }
    

    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var generatorButton: UIButton!
    
    var userDefault: UserDefaults = UserDefaults(suiteName: "group.com.chat.gtp")!
    var chatDelegate: ChatDelegate?
    var responseStr: String = ""
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.chatDelegate = self
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
//        if needsInputModeSwitchKey {
//                    advanceToNextInputMode()
//                } else {
//                    print("Open Settings")
//                }
        
        self.generatorButton = UIButton(type: .system)
        self.view.addSubview(self.generatorButton)

        self.generatorButton.backgroundColor = .red
        self.generatorButton.setTitle("生成", for: .normal)
        self.generatorButton.translatesAutoresizingMaskIntoConstraints = false
        self.generatorButton.layer.cornerRadius = 8
        self.generatorButton.titleLabel?.font = .boldSystemFont(ofSize: 19.0)
        self.generatorButton.setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 200.0),
            generatorButton.widthAnchor.constraint(equalToConstant: 250),
            generatorButton.heightAnchor.constraint(equalToConstant: 60),
            generatorButton.centerXAnchor.constraint(equalTo: inputView!.centerXAnchor),
            generatorButton.centerYAnchor.constraint(equalTo: inputView!.centerYAnchor)
        ])
        
        self.generatorButton.addTarget(self, action: #selector(generator), for: .touchUpInside)
    }
    
    @objc func generator() {
        // fetch
        let fetchedStr = fetchText()
//        guard fetchedStr != nil else {
//            return
//        }
        // chatGPT
        let responseStr = accessChatGTP(content: fetchedStr)
//        guard responseStr != "" else {
//            return
//        }
    }
    
    func fetchText() -> String {
        let inputStr = self.textDocumentProxy.documentContextBeforeInput
        
        return inputStr!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func accessChatGTP(content: String) -> String {
        let apiKey = userDefault.object(forKey: "chatGTP") as! String
        print("apiKey: \(apiKey)")
        
        // create Url request
        let url = URL(string: "https://api.openai.com/v1/chat/completions")
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer "+apiKey, forHTTPHeaderField: "Authorization")
//        let header = ["Content-type":"application/json",
//                      "Authorization":"Bearer \(apiKey)"
//        ]
//        request.allHTTPHeaderFields = header
        
        let body = ["model":"gpt-3.5-turbo",
                    "messages":[["role":"user","content":"\(content)"]]
        ] as [String : Any]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

        let session = URLSession.shared
        var resStr = ""
        let dataTask = session.dataTask(with: request) { data, response, error in
            if error == nil && data != nil {
                // parse
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
                    let choices = dictionary["choices"] as! [Any]
                    guard choices.count != 0 else {
                        return
                    }
                    let firstChoice = choices[0] as! [String: Any]
                    guard let message = firstChoice["message"] as? [String: Any] else {
                        return
                    }
                    resStr = message["content"] as! String
                    print(resStr)
                    DispatchQueue.main.async{
                        self.chatDelegate?.dataFetched(resStr)
                    }
                }
                catch {
                    print("error parse jsonObject")
                }
            }
        }
        dataTask.resume()

        return resStr
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
