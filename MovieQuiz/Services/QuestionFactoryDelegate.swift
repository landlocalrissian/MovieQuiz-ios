//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 13.01.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
