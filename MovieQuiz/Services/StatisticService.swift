//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 18.01.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: BestGame? { get }
    
    func store(correct: Int, total: Int)
}

final class StatisticServiceImpl {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults: UserDefaults = .standard
    private let decoder: JSONDecoder = JSONDecoder()
    private let encoder: JSONEncoder = JSONEncoder()
    private let dateProvider: () -> Date = { Date() }
}

extension StatisticServiceImpl: StatisticService {
    
    var gamesCount: Int {
        
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
            
        }
    }
    
    var total: Int {
        
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
            
        }
    }
    var correct: Int{
        
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
            
        }
    }
    
    var bestGame: BestGame? {
        
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let bestGame = try? decoder.decode(BestGame.self, from: data) else {
                return nil
            }
            return bestGame
        }
        
        set {
            let data = try? encoder.encode(newValue)
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = BestGame(correct: correct, total: total, date: date)
        
        if let previousBestGame = bestGame {
            if currentBestGame >  previousBestGame {
                bestGame = currentBestGame
            }
        } else {
            bestGame = currentBestGame
        }
    }
    
    var totalAccuracy: Double {
        Double(correct) / Double(total)  * 100
    }
}