
import Foundation
import UIKit

enum Color: Int, CaseIterable {
    case blue
    case purple
    case indigo
    case orange
}


extension MainScreenViewController1 {

    @objc func LightMode(sender: UIAction) {
        UIApplication.shared.windows
            .forEach { $0.overrideUserInterfaceStyle = .light }
        reload()
    }

    @objc func DarkMode(sender: UIAction) {
        UIApplication.shared.windows
            .forEach { $0.overrideUserInterfaceStyle = .dark }
        reload()
    }

    
    @objc func changeBlue(sender: UIAction) {
        self.color = .blue
        reload()
    }

    @objc func changeOrange(sender: UIAction) {
        self.color = .orange
        reload()
    }
    @objc func changePurple(sender: UIAction) {
        self.color = .purple
        reload()
    }
    @objc func changeIndigo(sender: UIAction) {
        self.color = .indigo
        reload()
    }

    func reload() {
        if (running % 2 == 1) {
            stopAndRun()
        }
        navigationItems.rightBarButtonItem = setupMenu()
        navigationItems.leftBarButtonItem?.tintColor = getColor()
        toolBar.setItems(makeToolBarItems(), animated: true)
        self.drawState()
    }


    @objc func changeShape(sender: UIAction) {
        shapeOfCell = shapeOfCell == "Circles" ? "Square" : "Circles"
        navigationItems.rightBarButtonItem = setupMenu()
        
        self.drawState()
    }

}
