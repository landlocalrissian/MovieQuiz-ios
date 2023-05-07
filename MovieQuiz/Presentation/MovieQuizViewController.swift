import UIKit
    
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    func showFinalResults() {
        
    }
    
    func showNetworkError(alertModel: AlertModel) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    

    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    struct QuizResultAnswerViewModel {
      let answer: Bool
    }
    
    // на удаление
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.yesButtonClicked()
        }

        @IBAction private func noButtonClicked(_ sender: UIButton) {
            presenter.noButtonClicked()
        }
    
    
    private var presenter: MovieQuizPresenter!


    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        presenter = MovieQuizPresenter(viewController: self)
        presenter.statisticService = StatisticServiceImpl()
        presenter.alertPresenter = AlertPresenterImpl(viewController: self)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)

    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        // здесь мы заполняем нашу картинку, текст и счётчик данными
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = makeResultMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    func makeResultMessage() -> String {
        
        guard let statisticService = presenter.statisticService, let bestGame = statisticService.bestGame else {
            fatalError("message error")
        }
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let components: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ]
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
    }
}
