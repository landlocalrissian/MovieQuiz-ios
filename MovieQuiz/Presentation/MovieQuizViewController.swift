import UIKit
    
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    struct QuizResultAnswerViewModel {
      let answer: Bool
    }
    
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactory?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImpl()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenterImpl(viewController: self)

    }

    // MARK: - QuestionFactoryDelegate

    private func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка!",
            message: makeResultMessage(),
            buttonText: "Попробовать еще раз") { [weak self ] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData()
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.show(alertModel: alertModel)
        }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
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
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        // здесь мы заполняем нашу картинку, текст и счётчик данными
    }

    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)

        let alertModel = AlertModel(
            title: "Игра окончена!",
            message: makeResultMessage(),
            buttonText: "ОК",
            buttonAction: { [weak self ] in
                self?.presenter.resetQuestionIndex()
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
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let components: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ]
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
    }
}

extension MovieQuizViewController {
    func didRecieveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        self.show(quiz: viewModel)
    }
}
