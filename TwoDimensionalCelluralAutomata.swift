import Foundation

 struct TwoDimensionalCelluralAutomata: CellularAutomata {
     
     var rule: ([BinaryCell]) -> UInt
     
     init(rule: @escaping ([BinaryCell]) -> UInt) {
         self.rule = rule
     }
     
     func inTheRect(x xPoint: Int, y yPoint: Int, state state: State) -> Bool {
         if (xPoint < state.viewport.origin.x || xPoint > state.viewport.origin.y + state.viewport.size.width - 1) {
             return false
         }
         if (yPoint > state.viewport.origin.y || yPoint < state.viewport.origin.y - state.viewport.size.height + 1) {
             return false
         }
         return true
     }
     
     
     private func findNeighborhood(point: Point, state: State) -> [BinaryCell] {
         let x = point.x
         let y = point.y
         
         var arr = Array(repeating: BinaryCell(rawValue: 0)!, count: 9)
         if (state.viewport.contains(point: Point(x: x - 1, y: y - 1))) {
             arr[0] = (state[Point(x: x - 1, y: y - 1)])
         }
         if (state.viewport.contains(point: Point(x: x, y: y - 1))) {
             arr[1] = (state[Point(x: x, y: y - 1)])
         }
         if (state.viewport.contains(point: Point(x: x + 1, y: y - 1))) {
             arr[2] = (state[Point(x: x + 1, y: y - 1)])
         }
         if (state.viewport.contains(point: Point(x: x - 1, y: y))) {
             arr[3] = state[Point(x: x - 1, y: y)]
         }
         
         arr[4] = state[Point(x: x, y: y)]
         
         if (state.viewport.contains(point: Point(x: x + 1, y: y))) {
             arr[5] = state[Point(x: x + 1, y: y)]
         }
         if (state.viewport.contains(point: Point(x: x - 1, y: y + 1))) {
             arr[6] = state[Point(x: x - 1, y: y + 1)]
         }
         if (state.viewport.contains(point: Point(x: x, y: y + 1))) {
             arr[7] = state[Point(x: x, y: y + 1)]
         }
         if (state.viewport.contains(point: Point(x: x + 1, y: y + 1))) {
             arr[8] = state[Point(x: x + 1, y: y + 1)]
         }
         return arr
         
     }
     
     func simulate(_ state: State, generations: UInt) throws -> State {
         var newState = state
         var mainState = state

         // Если на границе есть клетки то надо расширяться
         for _ in 1 ..< generations {
             // есть ли живые клетки на верхней вертикальной границе
             var thereAre = false
             for i in mainState.viewport.horizontalIndices {
                 if (mainState[Point(x: i, y: mainState.viewport.origin.y)].rawValue == 1) {
                     thereAre = true
                     break
                 }
             }
             // есть ли живые клетки на нижней горизонтальной границе
             for i in mainState.viewport.horizontalIndices {
                 if ((mainState[Point(x: i, y: mainState.viewport.origin.y + mainState.viewport.size.height - 1)].rawValue == 1)) {
                     thereAre = true
                     break
                 }
             }
             // есть ли живые клетки на первом левом столбце
             for i in mainState.viewport.verticalIndices {
                 if (mainState[Point(x: mainState.viewport.origin.x, y: i)].rawValue == 1) {
                     thereAre = true
                     break
                 }
             }
             // есть ли живые клетки на последнем правом столбце
             for i in mainState.viewport.verticalIndices {
                 if (mainState[Point(x: mainState.viewport.origin.x + mainState.viewport.size.width - 1, y: i)].rawValue == 1) {
                     thereAre = true
                     break
                 }
             }
             if (thereAre) {
                let val = 1
                 newState.viewport = newState.viewport.extensionPlane(toInclude: val)
                 mainState.viewport = newState.viewport
             }
             
            // обновление поколения
             for y in mainState.viewport.verticalIndices {
                 for x in mainState.viewport.horizontalIndices {
                     let neiberhood = findNeighborhood(point: Point(x: x, y: y), state: mainState)
                     let cellState = rule(neiberhood)
                     newState[Point(x: x, y: y)] = BinaryCell(rawValue: UInt8(cellState))!
                 }
             }
             mainState.cells = newState.cells
         }
        return newState
     }
    
    
}

extension TwoDimensionalCelluralAutomata {

    
    struct State: CellularAutomataState {
        typealias Cell = BinaryCell
        typealias SubState = Self

        var _viewport: Rect
        var cells = [Cell]()
        var viewport: Rect{
            get{
                self._viewport
            }
            set{
                self.cells = Self.resize(self.cells, from: self.viewport, to: newValue)
                self._viewport = newValue
            }
        }
        
        subscript(_ point: Point) -> BinaryCell {
            get {
                guard let index = Self.arrayIndex(at: point, in: self.viewport) else {return .inactive}
                return self.cells[index]
            }
            set {
                let newViewport = self.viewport.resizingInPlane(toInclude: point)
                self.cells = Self.resize(self.cells, from: self.viewport, to: newViewport)
                self._viewport = newViewport
                guard let index = Self.arrayIndex(at: point, in: self.viewport) else {fatalError("Internal Inconsisency")}
                return self.cells[index] = newValue
            }
        }
        
        subscript(_: Rect) -> TwoDimensionalCelluralAutomata.State {
            get {
                fatalError()
            }
            set {
                fatalError()
            }
        }
        
        mutating func translate(to newOrigin: Point) {
            self._viewport = Rect(origin: newOrigin, size: self._viewport.size)

        }
        
        init() {
            self._viewport = .zero
            self.cells = []
        }
        
        var description: String{
            self.viewport.verticalIndicesForPlane.map {
                y in self.viewport.horizontalIndices.map {self[Point(x: $0, y: y)] == .inactive ? " " : "*"}.joined()
            }.joined(separator: "\n")
        }
        
        private static func arrayIndex(at point: Point, in viewport: Rect) -> Int? {
            guard viewport.contains(point: point) else {return nil}
            let localPoint = point - viewport.origin
            return abs(localPoint.y) * viewport.size.width + abs(localPoint.x)
        }
        
        private static func resize(_ oldArray: [Cell], from oldViewport : Rect ,to newViewport : Rect) -> [Cell] {
            var newArray = Array<Cell>(repeating: .inactive, count: newViewport.size.area)
            for y in oldViewport.verticalIndicesForPlane {
                for x in oldViewport.horizontalIndices {
                    let point = Point(x: x, y: y)
                    guard let oldArrayIndex = Self.arrayIndex(at: point, in: oldViewport) else {continue}
                    guard let newArrayIndex = Self.arrayIndex(at: point, in: newViewport) else {continue}
                    newArray[newArrayIndex] = oldArray[oldArrayIndex]
                }
            }

            return newArray
        }
    }
}

