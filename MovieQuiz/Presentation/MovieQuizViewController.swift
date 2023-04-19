import UIKit
    
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // для состояния "Результат ответа"
    struct QuizResultAnswerViewModel {
      let answer: Bool
    }
    
    private var correctAnswers: Int = 0
    
    private var currentQuestionIndex: Int = 0
    
    private let questionsCount = 10
    private var questionFactory: QuestionFactory?
    private var alertPresenter: AlertPresenter?
//    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactoryImpl(delegate: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        statisticService = StatisticServiceImpl()
        
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 5
        questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
            let givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
        }
    

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
   
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor(red: 0.376, green: 0.761, blue: 0.557, alpha: 1).cgColor : UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        // здесь мы заполняем нашу картинку, текст и счётчик данными
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsCount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionsCount)
        
        let alertModel = AlertModel(
            title: "Игра окончена!",
            message: makeResultMessage(),
            buttonText: "ОК",
            buttonAction: { [weak self ] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
    }
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            fatalError("message error")
        }
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат:\(correctAnswers)\\\(questionsCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let components: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ]
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
    }
}

extension MovieQuizViewController: QuestionFactoryDelagate {
    func didRecieveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        
        self.show(quiz: viewModel)
    }
}
