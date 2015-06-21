//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

extension Double {
    var km: Double { return self * 1_000.0 }
    var m: Double { return self }
    func cm() -> Double {
        return self / 100.0
    }
}

let oneInch = 25.4.km
oneInch.m
oneInch.cm()

extension Int {
    func repetitions(task: () -> ()) {
        for i in 0..<self {
            task()
        }
    }
}

3.repetitions{ println("Hello!") }

protocol pro {
    init(someParameter:Int)
    var mustBeSettable: Int {get set}
    var fullName: String {get}
    func do_what()
}


class hello {
    
}

class hi : hello, pro {
    
    required init(someParameter: Int) {
        
    }
    
    var mustBeSettable: Int = 0
    
    var fullName: String{
        return "\(mustBeSettable)"
    }
    
    func do_what() {
        
    }
}

protocol Togglable {
    mutating func toggle()
}

enum OnOffSwitch: Togglable {
    case On, Off
    mutating func toggle() {
        switch self{
        case Off:
            self = On
        case On:
            self = Off
        }
    }
}

var lightSwitch = OnOffSwitch.On
lightSwitch.toggle()

protocol RandomNumberGenerator: class {
    func random() -> Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c) % m)
        return lastRandom / m
    }
}

class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

var d6 = Dice(sides: 6,generator: LinearCongruentialGenerator())
for _ in 1...5 {
    println("Random dice roll is \(d6.roll())")
}

protocol TextRepresentable {
    func asText() -> String
}

extension Dice : TextRepresentable {
    func asText() -> String {
        return "A \(sides)-sided dice"
    }
}
let d12 = Dice(sides: 12,generator: LinearCongruentialGenerator())
println(d12.asText())

struct Hamster {
    var name: String
    func asText() -> String {
        return "A hamster named \(name)"
    }
}
extension Hamster: TextRepresentable {}
var hamster: TextRepresentable = Hamster(name: "Hamster!")
hamster.asText()

let things: [TextRepresentable] = [d12,hamster]
for thing in things {
    thing.asText()
    if let dice = thing as? Dice {
        dice.sides
    }
}

// 协议合成
protocol Named {
    var name: String { get }
}
protocol Aged {
    var age: Int { get }
}
struct Person: Named, Aged {
    var name: String
    var age: Int
}
func wishHappyBirthday(celebrator: protocol<Named, Aged>) {
    println("Happy birthday \(celebrator.name) - you're \(celebrator.age)!")
}
let birthdayPerson = Person(name: "mks", age: 21)
wishHappyBirthday(birthdayPerson)

// 可选协议
@objc protocol CounterDataSource {
    optional func incrementForCount(count: Int) -> Int
    optional var fixedIncrement: Int { get }
}
// 泛型
func swapTwoInts(inout a: Int, inout b: Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}
var someInt = 3
var anotherInt = 107
swapTwoInts(&someInt, &anotherInt)
println("someInt is now \(someInt), and anotherInt is now \(anotherInt)")

func swapTwoValues<T>(inout a: T, inout b: T) {
    let temporaryA = a
    a = b
    b = temporaryA
}
swapTwoValues(&someInt, &anotherInt)

struct IntStack {
    var items = [Int]()
    mutating func push(item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
}
struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
}

var stackItems = Stack(items: [1,2,3])
stackItems.pop()

var arr = [Int:String]()
for (index, value) in enumerate(arr) {

}

func foundIndex <T: Equatable>(array: [T], valueToFind: T) -> Int? {
    return nil
}

protocol Container {
    typealias ItemType
    mutating func append(item: ItemType)
    var count: Int { get }
    subscript(i: Int) -> ItemType { get }
}
struct IntsStack:Container {
    var items = [Int]()
    mutating func push(item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
    
    // Container
    typealias ItemType = Int
    mutating func append(item: Int) {
        items.append(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Int {
        return items[i]
    }
}

extension Array: Container{}
// 元祖
let http200Status = (statusCode: 200, desc: "OK")

let one: UInt16 = 0b00001111
let onef = ~one

class A {
    let b: B
    init() {
        b = B()
        b.a = self
    }
    
    deinit {
        println("A deinit")
    }
}

class B {
    weak var a: A? = nil
    deinit {
        println("B deinit")
    }
}

var obj: A? = A()
obj = nil


