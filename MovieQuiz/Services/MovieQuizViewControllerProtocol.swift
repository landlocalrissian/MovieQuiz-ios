//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 02.05.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showFinalResults()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(alertModel: AlertModel)
}
