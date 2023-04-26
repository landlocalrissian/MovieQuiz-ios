//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Zhulasov Pavel on 21.01.2023.
//

import Foundation
    
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let buttonAction: () -> Void
}
    
