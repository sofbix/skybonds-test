import Foundation

func sum(from values: [Double]) -> Double
{
    return values.reduce(0, { $0 + $1 })
}

let maxValuesCount = 10_000

/// Алгоритм. Если значение values не подходящее, то вернет nil. Параметром hasCheckPositive можно включать проверку на положительные значения долей
/// Вычислительная сложность, если исключить проверки O(2N), 16 Байт на каждый элемент входного массива требуется по памяти.
/// Рациональные числа имеют свою точность, для наибольшей был выбран Double, поэтому обеспечить абсолютную точность вычислений невозможно и это будет отражено ниже в подсчете контрольной суммы
func percents(from values: [Double], hasCheckPositive: Bool = false) -> [Double]?
{
    guard values.count > 0 else {
        return []
    }
    if values.count > maxValuesCount {
        print("Максимальное количество значений во входном массиве не должно превышать \(maxValuesCount)")
        return nil
    }
    // Знаю, тут лишний цикл, я решил разделить циклы, так как первичный отсев может иногда ускорить работу, в некоторых случаях его можно вообще убрать, например если в условиях будет стоять что числа не могут быть меньше нуля
    if hasCheckPositive {
        for value in values {
            guard value > 0 else {
                print("Значения входного массива должны быть не меньше нуля")
                return nil
            }
        }
    }
    let divider = sum(from: values)
    guard divider > 0 else {
        print("Сумма долей не может быть меньше нуля")
        return nil
    }
    // именуем значения массива, так как более сложное выражение
    return values.map{ value in
        return value / divider * 100.0
    }
}

guard let percentValues = percents(from: [ 1.5, 3, 6, 1.5 ]) else {
    print("Не верные входные значения")
    throw NSError()
}

// В задании не понятно в каком виде необходимо вывести, вывожу в массив строк
let result = percentValues.map{ String(format: "%2.3f", $0) }

print("Result: \(result)")
// Проверка результата:
let controlSum = sum(from: percentValues)
print("Control sum: \(controlSum)")



// Далее идут тесты

/// Критерий проверки контрольной суммы процентов чтобы до 3-го знака после запятой она было 100% без погрешностей
func assertControlSum(_ percentValues: [Double]){
    let actualValue = sum(from: percentValues)
    let result = Int(round(actualValue * 1000.0))
    assert(result == 100_000, "Сумма процентов должна быть равна 100.000. Актуальное значение: \(actualValue)")
}

func testSimple() {
    guard let percentValues = percents(from: [ 1.5123, 3, 6, 1.5, 0.333, 1.893]) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}

func testZeroValues() {
    guard let percentValues = percents(from: []) else {
        assertionFailure()
        return
    }
    assert(percentValues.count == 0, "Массив на выходе должен быть пустым")
    assert(sum(from: percentValues) == 0.0, "Сумма процентов должна быть равна 0")
}

func testMaxValuesCount() {
    var values = Array<Double>.init(repeating: 1.0, count: maxValuesCount)
    guard let percentValues = percents(from: values) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
    
    // добавим лишнее значение
    values.append(5.0)
    let nilPercentValues = percents(from: values)
    assert(nilPercentValues == nil, "Массив не ограничивается")
}

func testPositiveSequenceValues() {
    let sequence = 0 ..< maxValuesCount
    let shuffledSequence = sequence.shuffled().map{ Double($0) }
    guard let percentValues = percents(from: shuffledSequence) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}

func testNegativeSequenceValues() {
    let sequence = -maxValuesCount ..< 0
    let shuffledSequence = sequence.shuffled().map{ Double($0) }
    assert(percents(from: shuffledSequence) == nil, "Сумма отрицательна, это не допустимо")
}

func testAllSequenceValues() {
    let sequence = -maxValuesCount / 2 + 10 ..< maxValuesCount / 2
    let shuffledSequence = sequence.map{ Double($0) }
    guard let percentValues = percents(from: shuffledSequence) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}

func testShuffledSequenceValues() {
    let sequence = -maxValuesCount / 2 + 10 ..< maxValuesCount / 2
    let shuffledSequence = sequence.shuffled().map{ Double($0) }
    guard let percentValues = percents(from: shuffledSequence) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}

func testRandomPositiveValues() {
    let sequence = 0 ..< maxValuesCount
    let randomValues = sequence.map{ _ in Double.random(in: 0 ..< 1) }
    guard let percentValues = percents(from: randomValues) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}

func testRandomBigPositiveValues() {
    let sequence = 0 ..< maxValuesCount
    let randomValues = sequence.map{ _ in Double.random(in: 0 ..< 10000) }
    guard let percentValues = percents(from: randomValues) else {
        assertionFailure()
        return
    }
    assertControlSum(percentValues)
}


testSimple()
testZeroValues()
testMaxValuesCount()
testPositiveSequenceValues()
testNegativeSequenceValues()
testAllSequenceValues()
testShuffledSequenceValues()
testRandomPositiveValues()
testRandomBigPositiveValues()
print("Все тесты прошли успешно")

