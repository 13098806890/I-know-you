//
//  IKYWordsManager.swift
//  I know you
//
//  Created by doxie on 5/29/18.
//  Copyright © 2018 Xie. All rights reserved.
//

import Foundation
import UIKit

class IKYWordsManager {
    open static let sharedInstance = IKYWordsManager()
    var words: [String] = [String]()
    
    func wordDataWithCount(_ count: Int) -> [Int: IKYWordData] {
        self.readFile()
        let unit = (count - 1) / 3
        var redTeamCount: Int = unit + 1
        var blueTeamCount: Int = unit
        var yellowTeamCount: Int = unit - 1
        var boom: Int = 1

        let randomNumber = Int(arc4random_uniform(2))
        if randomNumber == 0 {
            redTeamCount = unit
            blueTeamCount = unit + 1
        }

        let pickUpWords = self.pickUpWords(count)

        var dic = [Int: IKYWordData]()
        for i in 0..<count {
            let randomNumber = Int(arc4random_uniform(UInt32(redTeamCount + blueTeamCount + yellowTeamCount + boom)))
            var color: TeamColor
            if randomNumber >= 0 && randomNumber < boom  {
                boom -= 1
                color = .boomColor
            } else if randomNumber >= boom && randomNumber < boom + redTeamCount {
                redTeamCount -= 1
                color = .redTeamColor
            } else if randomNumber >= boom + redTeamCount && randomNumber < boom + redTeamCount + yellowTeamCount {
                yellowTeamCount -= 1
                color = .yellowTeamColor
            } else {
                blueTeamCount -= 1
                color = .blueTeamColor
            }
            let wordData = IKYWordData.init(teamColor: color, vocabulary: pickUpWords[i])
            dic[i] = wordData
        }

        return dic
    }

    func readFile() {
        if let fileUrl = self.dataSourceFileUrl() {
            do {
                let inString = try String(contentsOf: fileUrl)
                self.words = inString.components(separatedBy: ",").map{return $0.trimmingCharacters(in: CharacterSet.init(charactersIn: "\n"))}
                return
            } catch {
                print("Failed reading from URL: \(fileUrl), Error: " + error.localizedDescription)
            }
            if self.words.count == 0 {
                if let txtFile = Bundle.main.path(forResource: "datasource", ofType: "txt") {
                    let txtData = NSData(contentsOfFile: txtFile)
                    let myString: String = (NSString(data: txtData! as Data, encoding: String.Encoding.utf8.rawValue))! as String
                    let words = myString.components(separatedBy: ",").map{return $0.trimmingCharacters(in: CharacterSet.init(charactersIn: "\n"))}
                    self.addWords(words: words)
                }
            }

        }

    }

    func dataSourceFileUrl() -> URL? {
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = dir?.appendingPathComponent("datasource").appendingPathExtension("txt") {
            return fileURL
        }
        return nil
    }

    func pickUpWords(_ count: Int) -> [String]{
        var words = [String]()
        var originalWords = self.words
        for _ in 0..<count {
            let randomNumber = Int(arc4random_uniform(UInt32(originalWords.count)))
            words.append(originalWords[randomNumber])
            originalWords.remove(at: randomNumber)
        }

        return words
    }

    func addWords(words:[String]) {
        if words.count == 0 {
            return
        }
        self.words.append(contentsOf: words)
        let setWords = Set(self.words)
        let result = setWords.union(Set(words))
        let newData: NSMutableString = NSMutableString.init(string: Array(result)[0])
        for index in 1..<result.count {
            newData.append(",")
            newData.append(Array(result)[index])
        }
        let url = self.dataSourceFileUrl()
        do {
            try FileManager.default.removeItem(at: url!)
        }catch {
            print(error)
        }
        do {
            try newData.write(to: url!, atomically: true, encoding: String.Encoding.utf8.rawValue)
        }catch {
            print(error)
        }

    }

    func deleteWords(words:[String]) {
        if words.count == 0 {
            return
        }
        self.words.append(contentsOf: words)
        var setWords = Set(self.words)
        for index in 0..<words.count {
            setWords.remove(words[index])
        }
        let newData: NSMutableString = NSMutableString.init(string: Array(setWords)[0])
        for index in 1..<setWords.count {
            newData.append(",")
            newData.append(Array(setWords)[index])
        }
        let url = self.dataSourceFileUrl()
        do {
            try FileManager.default.removeItem(at: url!)

        }catch {
            print(error)
        }
        do {
            try newData.write(to: url!, atomically: true, encoding: String.Encoding.utf8.rawValue)
        }catch {
            print(error)
        }
    }

}
