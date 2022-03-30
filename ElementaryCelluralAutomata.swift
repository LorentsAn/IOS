import Foundation

 class ElementaryAutomata: CellularAutomata {
     
     let rule: UInt8
     
     init(rule: UInt8){
         self.rule = rule
     }

    
    public func simulate(_ state: State, generations: UInt) throws -> State {
        var state = state

        for _ in 0 ..< generations {
            guard let y = state.viewport.verticalIndices.last, state.viewport.area != 0 else {return state}

            state.viewport = state.viewport
                .resizing(toInclude: Point(
                    x: state.viewport.origin.x,
                    y: state.viewport.origin.y + state.viewport.size.height)
                          + Point(x: -1, y:0))
                .resizing(toInclude: Point(
                    x: state.viewport.origin.x + state.viewport.size.width,
                    y: state.viewport.origin.y)
                          + Point(x: 1, y:0))
            
            for x in state.viewport.horizontalIndices {
                let left = state[Point(x: x - 1, y: y)].rawValue
                let middle = state[Point(x: x, y: y)].rawValue
                let right = state[Point(x: x + 1, y: y)].rawValue
                state[Point(x: x, y: y + 1)] = BinaryCell(rawValue: self.rule >> (left << 2 | middle << 1 | right << 0) & 1)!
            }
        }
        return state
    }
}
    



extension ElementaryAutomata {
    struct State : CellularAutomataState, CustomStringConvertible {
        
        typealias Cell = BinaryCell
        typealias SubState = Self
        var cells : [Cell]
        private var _viewport: Rect
        var viewport: Rect{
            get{
                self._viewport
            }
            set{
                self.cells = Self.resize(self.cells, from: self.viewport, to: newValue)
                self._viewport = newValue
            }
        }
        
        var description: String{
            self.viewport.verticalIndices.map {
                y in self.viewport.horizontalIndices.map {self[Point(x: $0, y: y)] == .inactive ? " " : "+"}.joined()
            }.joined(separator: "\n")
        }
        
        init() {
            self._viewport = .zero
            self.cells = []
        }
        
        
        subscript(_ point: Point) -> BinaryCell {
            get {
                guard let index = Self.arrayIndex(at: point, in: self.viewport) else {return .inactive}
                return self.cells[index]
            }
            set {
                let newViewport = self.viewport.resizing(toInclude: point)
                self.cells = Self.resize(self.cells, from: self.viewport, to: newViewport)
                self._viewport = newViewport
                guard let index = Self.arrayIndex(at: point, in: self.viewport) else {fatalError("Internal Inconsisency")}
                return self.cells[index] = newValue
            }
        }
        
        subscript(_: Rect) -> ElementaryAutomata.State {
            get {
                fatalError("Nonimplement")
            }
            set {
                fatalError("Nonimplement")
            }
        }
        
        mutating func translate(to newOrigin: Point) {
            self._viewport = Rect(origin: newOrigin, size: self._viewport.size)
        }
        
        private static func arrayIndex(at point: Point, in viewport: Rect) -> Int?{
            guard viewport.contains(point: point) else {return nil}
            let localPoint = point - viewport.origin
            return localPoint.x + localPoint.y * viewport.size.width
        }
        
        private static func resize(_ oldArray: [Cell],from oldViewport : Rect ,to newViewport : Rect) -> [Cell] {
            var newArray = Array<Cell>(repeating: .inactive, count: newViewport.size.area)
            
            for x in oldViewport.horizontalIndices {
                for y in oldViewport.verticalIndices {
                    let point = Point(x: x, y: y)
                    guard let oldArrayIndex = Self.arrayIndex(at:  point, in: oldViewport) else {continue}
                    guard let newArrayIndex = Self.arrayIndex(at: point, in: newViewport) else {continue}
                    newArray[newArrayIndex] = oldArray[oldArrayIndex]
                }
            }
            return newArray
        }
    }

}

