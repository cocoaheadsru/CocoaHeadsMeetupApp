//
//  ImportResultHandler.swift
//  CHMeetupApp
//
//  Created by Егор Петров on 28/02/2017.
//  Copyright © 2017 CocoaHeads Comunity. All rights reserved.
//

import UIKit

class ImportResultHandler {

  static func result(type: Importer.Result, in viewController: UIViewController) {
    switch type {
    case .success:
      success(in: viewController)
    case .permissionError:
      permissionError(in: viewController)
    case .saveError:
      saveError(in: viewController)
    }
  }

  private static func success(in viewController: UIViewController) {
    // TODO: - think about message add or not
    let alert = AlertHandler.configure(title: "Added".localized, message: "".localized)

    viewController.present(alert, animated: true, completion: nil)
  }

  private static func permissionError(in viewController: UIViewController) {
    let openSettingsAction = UIAlertAction(title: "Open settings".localized, style: .default, handler: { _ in
      openSettings()
    })
    let closeAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

    let alert = UIAlertController(title: "Ошибка доступа".localized,
                                  message: "Мы не можем добавить потому что вы не дали разрешение :(".localized,
                                  preferredStyle: .alert)
    alert.addAction(openSettingsAction)
    alert.addAction(closeAction)

    viewController.present(alert, animated: true, completion: nil)
  }

  private static func saveError(in viewController: UIViewController) {
    let alert = AlertHandler.configure(title: "Не удалось сохранить".localized,
                                            message: "Что-то пошло не так :(".localized)

    viewController.present(alert, animated: true, completion: nil)
  }

  private static func openSettings() {
    let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
    UIApplication.shared.open(settingsURL, options: [:]) { (success) in
      print("Settings opened: \(success)")
    }
  }
}