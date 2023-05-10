//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 13.01.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    }
