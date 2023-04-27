import UIKit
    
final class MovieQuizViewController: UIViewController {
    
    private let presenter = MovieQuizPresenter(viewController: QuestionFactoryDelegatez)

    
    

    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        presenter.viewController = self
        presenter.imageView.layer.cornerRadius = 20
        presenter.imageView.layer.borderWidth = 8
//        presenter.questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)

        showLoadingIndicator()
        presenter.questionFactory?.loadData()
        presenter.alertPresenter = AlertPresenterImpl(viewController: self)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    struct QuizResultAnswerViewModel {
      let answer: Bool
    }
    
    func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        
        let alertModel = AlertModel(
            title: "Ошибка!",
            message: presenter.makeResultsMessage(),
            buttonText: "Попробовать еще раз") { [weak self ] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.presenter.questionFactory?.loadData()
                self.presenter.questionFactory?.requestNextQuestion()
                self.presenter.restartGame()

            }
        presenter.alertPresenter?.show(alertModel: alertModel)
        }
    
    func show(quiz result: QuizResultsViewModel) {
            let message = presenter.makeResultsMessage()
            
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        presenter.imageView.layer.masksToBounds = true
        presenter.imageView.layer.borderWidth = 8
        presenter.imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
   
}


