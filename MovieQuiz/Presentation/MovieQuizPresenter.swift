//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 27.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex: Int = 0
    let questionsCount = 10
    private var correctAnswers: Int = 0

    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactory?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    
    @IBAction internal func yesButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: true)
    }
    
    @IBAction internal func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsCount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
        )
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.statisticService?.store(correct: correctAnswers, total: self.questionsCount)
            
            let alertModel = AlertModel(
                title: "Игра окончена!",
                message: (viewController?.makeResultMessage())!,
                buttonText: "ОК",
                buttonAction: { [weak self ] in
                    self?.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            alertPresenter?.show(alertModel: alertModel)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    
    
    
    
}
