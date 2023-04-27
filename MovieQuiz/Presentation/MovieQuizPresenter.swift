//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 26.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
        
        
    var currentQuestion: QuizQuestion?
    var alertPresenter: AlertPresenter?
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    
    
    @IBAction internal func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { // ОШИБКА КОМПИЛЯЦИИ 1: `currentQuestion` не определён
            return
        }
        
        let givenAnswer = true
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction internal func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(String(describing: bestGame?.correct))\\\(String(describing: bestGame?.total))"
        + " (\(String(describing: bestGame?.date.dateTimeString)))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }



    
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
        )
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            makeResultsMessage()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = self.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isYes: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
    func noButtonClicked() {
            didAnswer(isYes: false)
    }
        
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

extension MovieQuizPresenter {
    func didRecieveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        self.show(quiz: viewModel)
    }
}
