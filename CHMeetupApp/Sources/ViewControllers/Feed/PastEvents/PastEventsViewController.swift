//
//  PastEventsViewController.swift
//  CHMeetupApp
//
//  Created by Alexander Zimin on 22/02/2017.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import UIKit

class PastEventsViewController: UIViewController, PastEventsDisplayCollectionDelegate {
  @IBOutlet fileprivate var tableView: UITableView! {
    didSet {
      tableView.registerNib(for: EventPreviewTableViewCell.self)
      tableView.estimatedRowHeight = 100
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.backgroundColor = UIColor.clear
      tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

      // FIXME: - Delete before PR merge
      tableView.registerNib(for: OptionTableViewCell.self)
      tableView.allowsMultipleSelection = true
    }
  }

  // FIXME: - Make it back
  fileprivate var dataCollection = OptionsDisplayCollection()
  // fileprivate var dataCollection: PastEventsDisplayCollection!

  override func viewDidLoad() {
    super.viewDidLoad()

    // FIXME: - Make it back
//    dataCollection = PastEventsDisplayCollection()
//    dataCollection.delegate = self

    view.backgroundColor = UIColor(.lightGray)

    title = "Past".localized

    fetchEvents()
  }

  override func customTabBarItemContentView() -> CustomTabBarItemView {
    return TabBarItemView.create(with: .past)
  }

  func shouldPresent(viewController: UIViewController) {
    navigationController?.pushViewController(viewController, animated: true)
  }
}

extension PastEventsViewController: UITableViewDataSource, UITableViewDelegate {

  func numberOfSections(in tableView: UITableView) -> Int {
    return dataCollection.numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataCollection.numberOfRows(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = dataCollection.model(for: indexPath)
    let cell = tableView.dequeueReusableCell(for: indexPath, with: model)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Ваш стаж" : "Ваши языки"
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // FIXME: - Remove option cells
    // tableView.deselectRow(at: indexPath, animated: true)
    
    dataCollection.didSelect(indexPath: indexPath)

    // Early return if selected second section
    if indexPath.section == 1 {
      return
    }
    // deselect other radio cells
    for (index, _) in dataCollection.modelCollection.first!.enumerated() {
      // Do not touch just selected row
      if index == indexPath.row {
        continue
      }
      tableView.deselectRow(at: IndexPath.init(row: index, section: indexPath.section), animated: true)
    }
  }

}

// FIXME: - Remove this
fileprivate extension PastEventsViewController {

  func fetchEvents() {

    // FIXME: - Remove option cells
    dataCollection.modelCollection =
    [
      [
        OptionTableViewCellModel.init(id: "0", text: "Меньше года", type: .radio, isFirst: true, isLast: false),
        OptionTableViewCellModel.init(id: "1", text: "1-2 года", type: .radio, isFirst: false, isLast: false),
        OptionTableViewCellModel.init(id: "2", text: "Больше 3 лет", type: .radio, isFirst: false, isLast: false),
        OptionTableViewCellModel.init(id: "3", text: "Прогаю лучше Зимина", type: .radio, isFirst: false, isLast: true)
      ],
      [
        OptionTableViewCellModel.init(id: "4", text: "Swift", type: .check, isFirst: true, isLast: false),
        OptionTableViewCellModel.init(id: "5", text: "Objective-C", type: .check, isFirst: false, isLast: false),
        OptionTableViewCellModel.init(id: "6", text: "C++", type: .check, isFirst: false, isLast: false),
        OptionTableViewCellModel.init(id: "7", text: "Java… помогите.", type: .check, isFirst: false, isLast: true)
      ]
    ]
    return;


    let numberOfDemoEvents = 10
    for eventIndex in 1...numberOfDemoEvents {
      //Create past event
      let oneDayTimeInterval = 3600 * 24
      let eventTime = Date().addingTimeInterval(-TimeInterval(oneDayTimeInterval * eventIndex))
      let eventDuration: TimeInterval = 3600 * 4

      let event = EventEntity()
      event.id = eventIndex
      event.title = "CocoaHeads в апреле"
      event.startDate = eventTime
      event.endDate = eventTime.addingTimeInterval(eventDuration)
      event.title += " \(numberOfDemoEvents - eventIndex)"

      let place = PlaceEntity()
      place.id = eventIndex
      place.title = "Офис Avito"
      place.address = "ул. Лесная, д. 7 (БЦ Белые Сады, здание «А», 15 этаж)"
      place.city = "Москва"

      event.place = place

      realmWrite {
        mainRealm.add(place, update: true)
        mainRealm.add(event, update: true)
      }
    }

    tableView.reloadData()
  }
}
