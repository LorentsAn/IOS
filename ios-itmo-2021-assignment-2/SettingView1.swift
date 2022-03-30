
import Foundation
import UIKit


private let reuseIndentifier = "dropDownCell"

extension MainScreenViewController1 {

    @objc func enterRule() {
                let alert = UIAlertController(title: "Введите правило", message: nil, preferredStyle: .alert)
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = "Введите правило"})
                alert.addAction(UIAlertAction(title: "Ввод", style: .default, handler: {(_) in
                    if UInt8(alert.textFields![0].text!) != nil {
                        self.rule = UInt8(alert.textFields![0].text!)!
                        self.elementaryAutomata = ElementaryAutomata(rule: self.rule)
                    } else {
                        self.rule = 0
                    }
                }))
                self.present(alert, animated: true, completion: nil)
    }
    
    func removeField() {
                if (self.AutomataType == "TwoDimensionalCelluralAutomata") {
                    for i in 0 ..< mainState.cells.count {
                        self.mainState.cells[i] = .inactive
                    }
                } else {
                    var tmp = ElementaryAutomata.State()
                    tmp[.zero] = .inactive
                    secondaryState = tmp
                    resizePlane(w: 1, h: 1)
                }
        drawState()

    }
    
}

