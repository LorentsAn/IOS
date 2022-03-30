import Darwin
public protocol CellularAutomata {
    associatedtype State: CellularAutomataState

    /// Возвращает новое состояние поля после n поколений
    /// - Parameters:
    ///   - state: Исходное состояние поля
    ///   - generations: Количество симулирвемых поколений
    /// - Returns:
    ///   - Новое состояние после симуляции
    func simulate(_ state: State, generations: UInt) throws -> State
}

public protocol CellularAutomataState {
    associatedtype Cell
    associatedtype SubState: CellularAutomataState

    /// Конструктор пустого поля
    init()

    /// Квадрат представляемой области в глобальных координатах поля
    /// Присвоение нового значение обрезая/дополняя поле до нужного размера
    var viewport: Rect { get set }

    /// Значение конкретной ячейки в точке, заданной в глобальных координатах.
    subscript(_: Point) -> Cell { get set }
    /// Значение поля в прямоугольнике, заданном в глобальных координатах.
    subscript(_: Rect) -> SubState { get set }

    /// Меняет origin у viewport
    mutating func translate(to: Point)
}

public struct Size {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        guard width >= 0 && height >= 0 else { fatalError() }
        self.width = width
        self.height = height
    }
}

public struct Point {
    public let x: Int
    public let y: Int
}

public struct Rect {
    public let origin: Point
    public let size: Size
}

public enum BinaryCell: UInt8 {
    case inactive = 0
    case active = 1
}

extension Size: Hashable, CustomStringConvertible {
    static let zero = Self(width: 0, height: 0)
    
    public var description: String {
        "(w: \(self.width), h: \(self.height)"
    }
    
    var area: Int {
        self.height * self.width
    }
}
extension Point: Hashable {
    static let zero = Self(x: 0, y: 0)
    
    public var description: String {
        "(x: \(self.x), y: \(self.y)"
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
}
extension Rect: Hashable, CustomStringConvertible {
    static let zero = Self(origin: .zero, size: .zero)
    
    public var description: String {
        "{ \(self.origin) \(self.size) }"
    }
    
    var area: Int {
        self.size.area
    }
    
    var horizontalIndices: Range<Int> {
        self.origin.x ..< self.origin.x + self.size.width
    }
    
    
    var verticalIndices: Range<Int> {
        self.origin.y ..< self.origin.y + self.size.height
    }
    
    var verticalIndicesForPlane: Range<Int> {
        self.origin.y ..< self.origin.y + self.size.height
    }
    
    func contains(point: Point) -> Bool {
        self.horizontalIndices.contains(point.x) && self.verticalIndices.contains(point.y)
    }
    
    func mutateOrigin(value val: Int) -> Rect {
        let newOrigin = Point(x: self.origin.x - val, y: self.origin.y + val)
        let newSize = Size(width: self.size.width + 2 * val, height: self.size.height + 2 * val)
        return Rect(origin: newOrigin, size: newSize)
    }
    

    func resizing(toInclude point: Point) -> Rect {
        let newOrigin = Point(x: min(self.origin.x, point.x), y: min(self.origin.y, point.y))
        let newSize = Size(
            width: max(self.origin.x + self.size.width, point.x + 1) - newOrigin.x,
            height: max(self.origin.y + self.size.height, point.y + 1) - newOrigin.y)
        return Rect(origin: newOrigin, size: newSize)
    }
    
    func resizingInPlane(toInclude point: Point) -> Rect {
        var newOrigin = Point(x: 0, y: 0)
        if (self.size.width != 0 || self.size.height != 0) {
            newOrigin = Point(x: min(self.origin.x, point.x), y: min(self.origin.y, point.y))
        } else {
            newOrigin = Point(x: point.x, y: point.y)
        }

        var newWidth = -1

        if (self.size.width != 0 && (point.x < self.origin.x) ) {
            newWidth = self.size.width + abs(point.x - self.origin.x)
        } else if (self.size.width != 0 && point.x > self.origin.x + self.size.width - 1) {
            newWidth = abs(self.origin.x - point.x) + 1
        } else if (self.size.width == 0) {
            newWidth = 1
        } else {
            newWidth = self.size.width
        }
        var newHeight = -1
        if (self.size.height != 0 && (point.y < self.origin.y)) {
            newHeight = self.size.height + abs(point.y - self.origin.y)
        } else if (self.size.height != 0 && (self.origin.y + self.size.height - 1 < point.y)) {
            newHeight = abs(self.origin.y - point.y) + 1
        } else if (self.size.height == 0) {
            newHeight = 1
        } else {
            newHeight = self.size.height
        }
        let newSize = Size(
            width: newWidth,
            height: newHeight)
        return Rect(origin: newOrigin, size: newSize)
        
    }
    
    func extensionPlane(toInclude val: Int) -> Rect {
        let newOrigin = Point(x: self.origin.x - val, y: self.origin.y - val)
        let newSize = Size(width: self.size.width + 2 * val, height: self.size.height + val * 2)
        return Rect(origin: newOrigin, size: newSize)
    }
    
    
}

