//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 12.01.2023.
//

import Foundation

protocol  QuestionFactoryDelagate: AnyObject {
    func didRecieveQuestion(_ question: QuizQuestion)
}

protocol QuestionFactory {
    func requestNextQuestion()
    
}

final class QuestionFactoryImpl: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelagate?
    
    init(delegate: QuestionFactoryDelagate?) {
        self.delegate = delegate
    }

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
}

extension  QuestionFactoryImpl: QuestionFactory {
    func requestNextQuestion() {
        guard let question = questions.randomElement() else {
            assertionFailure("qestion is empty")
            return
        }
        delegate?.didRecieveQuestion(question)
    }
}

