//
//  ViewController.swift
//  I know you
//
//  Created by doxie on 5/29/18.
//  Copyright © 2018 Xie. All rights reserved.
//

import UIKit

enum UIMode {
    case talker
    case gusser
}

enum TeamColor: Int {
    case boomColor = 0
    case redTeamColor = 1
    case blueTeamColor = 2
    case yellowTeamColor = 3
}

class ViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    var mode: UIMode = .talker
    let wordSize = 5
    let cellIdentifier = "IKYCollectionViewCell"
    let pastedboardPrefix = "iky512~"
    var pasteboardContent = ""
    let guessedColor = UIColor.gray.withAlphaComponent(0.2)
    var words: [Int: IKYWordData] = [Int: IKYWordData]()
    var guessedIndex: [Int] = [Int]()
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var changeModeButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lockSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lockSwitch.isOn = false
        words = IKYWordsManager.sharedInstance.wordDataWithCount(wordSize * wordSize)
        self.collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.inputTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeMode(_ sender: Any) {
        if self.mode == .talker {
            self.mode = .gusser
            self.changeModeButton.setTitle("change to talker", for: .normal)
            self.refreshButton.isHidden = true
        } else {
            self.mode = .talker
            self.changeModeButton.setTitle("change to gusser", for: .normal)
            self.refreshButton.isHidden = false
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.words = IKYWordsManager.sharedInstance.wordDataWithCount(wordSize * wordSize)
        self.guessedIndex = [Int]()
        self.collectionView.reloadData()
    }

    @IBAction func submit(_ sender: Any) {
        self.dismissKeyboard()
        let words = self.getInputWords()
        self.inputTextField.text = ""
        if words == nil {
            return
        }
        IKYWordsManager.sharedInstance.addWords(words: words!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        self.dismissKeyboard()
        let words = self.getInputWords()
        self.inputTextField.text = ""
        if words == nil {
            return
        }
        IKYWordsManager.sharedInstance.deleteWords(words: words!)
    }

    @IBAction func copyToPasterBoard(_ sender: Any) {
        let string = self.generateStatusString()
        let pastboard = UIPasteboard.general
        pastboard.string = string
        print(string)
    }
    @IBAction func readPasteBoard(_ sender: Any) {
        self.self.detectPasteBoard()
    }

    @IBAction func lockStatusChange(_ sender: Any) {
        self.changeModeButton.isHidden = self.lockSwitch.isOn
        self.refreshButton.isHidden = self.lockSwitch.isOn
    }

    func getInputWords() -> [String]? {
        let input = self.inputTextField.text
        if input == "" {
            return nil
        }
        return (input?.components(separatedBy: CharacterSet.init(charactersIn: ",.，")))!
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //TextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }

    //UICollectionViewDataSource and UICollectionViewDelegate and UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: IKYCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IKYCollectionViewCell
        let word: IKYWordData = self.words[indexPath.row]!
        cell.teamColor = word.teamColor()
        cell.wordLabel.text = word.vocabulary
        cell.guessedColor = self.guessedColor
        self.updateCellColor(cell, index: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: IKYCollectionViewCell = collectionView.cellForItem(at: indexPath) as! IKYCollectionViewCell
        let block = {
            if self.guessedIndex.contains(indexPath.row) {
                let index = self.guessedIndex.index(of: indexPath.row)
                self.guessedIndex.remove(at: index!)
            } else {
                self.guessedIndex.append(indexPath.row)
            }
            self.updateCellColor(cell, index: indexPath.row)
        }
        if mode == .gusser && !self.guessedIndex.contains(indexPath.row) && self.lockSwitch.isOn {
            self.displayGuessAlert(block)
        } else {
            block()
        }


    }

    func updateCellColor(_ cell: IKYCollectionViewCell, index: Int) {
        let isTalker = mode == .talker
        if self.guessedIndex.contains(index) {
            cell.setColorIfGuessed(true, isTalker: isTalker)
        } else {
            cell.setColorIfGuessed(false, isTalker: isTalker)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordSize * wordSize;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width - CGFloat(wordSize) + 1) / CGFloat(wordSize)

        return CGSize.init(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // other function

    func displayGuessAlert(_ block: @escaping ()->()) {
        let alert = UIAlertController(title: "Are You Sure", message: "你是认真的吗？", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler:{ action in
            block()
            }))
        alert.addAction(UIAlertAction(title: "我再想想", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }

    func generateStatusString() -> String {
        let str: NSMutableString = NSMutableString.init(string: pastedboardPrefix)

        let wordsContent = NSMutableString()
        for index in 0..<words.count {
            wordsContent.append(words[index]!.encode())
            if index != words.count - 1 {
                wordsContent.append(",")
            }
        }
        str.append((wordsContent.data(using: String.Encoding.utf8.rawValue)?.base64EncodedString())!)
        if guessedIndex.count > 0 {
            str.append("~")
            let indexContent = NSMutableString()
            for index in 0..<guessedIndex.count {
                indexContent.append(String(guessedIndex[index]))
                if index != guessedIndex.count - 1 {
                    indexContent.append(",")
                }
            }
            str.append((indexContent.data(using: String.Encoding.utf8.rawValue)?.base64EncodedString())!)
        }

        return str as String
    }

    func decodeStatusString(str: String) {
        let strs = str.components(separatedBy: "~")
        if strs.count > 1 {
            let wordsContent = String.init(data: Data.init(base64Encoded: strs[1] as String)!, encoding: String.Encoding.utf8)
            let words = wordsContent?.components(separatedBy: CharacterSet.init(charactersIn: ","))
            if words!.count == wordSize * wordSize {
                self.words = [Int: IKYWordData]()
                for index in 0..<words!.count {
                    self.words[index] = IKYWordData.init(string: words![index])
                }
                self.guessedIndex = [Int]()
            }
            if strs.count > 2 {
                let indexContent = String.init(data: Data.init(base64Encoded: strs[2] as String)!, encoding: String.Encoding.utf8)
                let indexes = indexContent?.components(separatedBy: CharacterSet.init(charactersIn: ","))
                self.guessedIndex = [Int]()
                for index in 0..<indexes!.count {
                    self.guessedIndex.append(Int(indexes![index])!)
                }
            }
            if mode == .talker {
                self.changeMode(1)
            }
            self.collectionView.reloadData()
        }
    }

    func detectPasteBoard() {
        if let paste = UIPasteboard.general.string {
            if paste.hasPrefix(pastedboardPrefix) {
                self.pasteboardContent = paste.trimmingCharacters(in: CharacterSet.init(charactersIn: " \n\r"))
                self.disPlayUpdataStatusAlert({self.decodeStatusString(str: self.pasteboardContent)})
            }
        }
    }

    func disPlayUpdataStatusAlert(_ block: @escaping ()->()) {
        let alert = UIAlertController(title: "更新来自剪贴板的信息", message: "更新游戏状态？", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "更新", style: .destructive, handler:{ action in
            block()
            self.lockSwitch.isOn = true
            self.lockStatusChange(1)
        }))
        alert.addAction(UIAlertAction(title: "算了", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }

}

