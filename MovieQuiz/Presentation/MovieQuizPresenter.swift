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
    private let questionsCount = 10
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
        )
    }
}
