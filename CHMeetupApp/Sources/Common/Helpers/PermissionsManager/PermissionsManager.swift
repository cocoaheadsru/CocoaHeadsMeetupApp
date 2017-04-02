//
//  PermissionsManager.swift
//  CHMeetupApp
//
//  Created by Michael Galperin on 28.02.17.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import UIKit
import Photos
import AVKit
import EventKit
import UserNotifications

/**
 Allows to check and request different permissions

 * Easily check

 `if PermissionsManager.isAllowed(type: .camera) { ... }`

 * Request required permission

 `PermissionsManager.requireAccess(forType: .camera) { granted in }`

 */

final class PermissionsManager {

  enum `Type`: String {
    case notifications, calendar, reminders, camera, photosLibrary
  }

  private enum PermissionConstants {
    static let askPhrases = [
      Type.calendar: "к календарю".localized,
      .camera: "к камере".localized,
      .notifications: "к отправке уведомлений".localized,
      .photosLibrary: "к библиотеке фотографий".localized,
      .reminders: "к напоминаниям".localized
    ]

    static let askForAccess = "Пожалуйста, предоставьте приложению доступ".localized
    static let accessError = "Ошибка доступа".localized
    static let cancel = "Отмена".localized
    static let settings = "Настройки".localized
  }

  /// Helps to perform any action only if required permission is granted.
  /// Displays an alert with invitation to the Settings app if first request was rejected by the user
  ///
  /// - parameter from: `UIViewController` for alert invitation to be presented on
  /// - parameter to: Type of required permission
  /// - parameter completion: `Bool` value describing whether was access granted or not
  static func requireAccess(from controller: UIViewController, to type: Type, completion: @escaping (Bool) -> Void) {
    if !PermissionsManager.isAllowed(type: type) {
      PermissionsManager.requestAccess(forType: type) { success in
        completion(success)
        if !success {
          DispatchQueue.main.async {
            PermissionsManager.alertForSettingsWith(type: type, on: controller)
          }
        }
      }
    } else {
      completion(true)
    }
  }

  /**
   Checks if user has granted access to `Type`

   - parameter type: Type of permission to check. Check out `Type` for possible values
   - returns: `Bool` describing if access is granted
   */
  static func isAllowed(type: Type) -> Bool {
    switch type {
    case .photosLibrary:
      return PHPhotoLibrary.authorizationStatus() == .authorized
    case .camera:
      return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    case .reminders:
      return EKEventStore.authorizationStatus(for: .reminder) == .authorized
    case .calendar:
      return EKEventStore.authorizationStatus(for: .event) == .authorized
    case .notifications:
      return UIApplication.shared.currentUserNotificationSettings?.types.contains(.alert) ?? false
    }
  }

  private static func requestAccess(forType: Type, completion: @escaping (Bool) -> Void) {
    if isAllowed(type: forType) {
      completion(true)
      return
    }

    switch forType {
    case .calendar:
      EKEventStore().requestAccess(to: .event) { result, _ in
        completion(result)
      }
    case .camera:
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { result in
        completion(result)
      }
    case .notifications:
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { result, _ in
        completion(result)
      }
    case .photosLibrary:
      PHPhotoLibrary.requestAuthorization { status in
        completion(status == .authorized)
      }
    case .reminders:
      EKEventStore().requestAccess(to: .reminder) { result, _ in
        completion(result)
      }
    }
  }

  private static func alertForSettingsWith(type: Type, on viewController: UIViewController) {
    let phrase = PermissionConstants.askPhrases[type]
    assert(phrase != nil, "[PermissionsManager] Unknown Type passed")
    let messageFull = "\(PermissionConstants.askForAccess) \(phrase!)"

    let actions: [UIAlertAction] = [
      UIAlertAction(title: PermissionConstants.cancel, style: .default, handler: nil),
      UIAlertAction(title: PermissionConstants.settings, style: .default, handler: { _ in
        self.openSettings()
      })
    ]
    AlertGlobal.showAlert(on: viewController,
                          title: PermissionConstants.accessError, message: messageFull, actions: actions)
  }

  /**
   Allows to easily open Settings app for editing granted permissions.

   Make sure to **inform user** before opening Settings, also don't open it without user's confirmation
   */
  static func openSettings() {
    guard let url = URL(string: UIApplicationOpenSettingsURLString),
      UIApplication.shared.canOpenURL(url) else {
      return
    }
    UIApplication.shared.open(url, options: [:])
  }
}
