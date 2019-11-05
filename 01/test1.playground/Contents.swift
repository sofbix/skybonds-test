import Foundation

// исходный массив рациональных чисел
var values = [ 1.5, 3, 6, 1.5]

// можно попробывать более сложный вариант
//var values = [ 1.5123, 3, 6, 1.5, 0.333, 1.893]

// алгоритм
func percents(from values: [Double]) -> [Double]
{
    let sum = values.reduce(0, { $0 + $1 })
    // именуем значения массива, так как более сложное выражение
    return values.map{ value in
        return round(value * 100_000.0 / sum) / 1000.0
    }
}

let percentValues = percents(from: values)

// в задании не понятно в каком виде необходимо вывести, вывожу в массив строк
let result = percentValues.map{ String(format: "%2.3f", $0) }

print("Result: \(result)")

// можно и так получить сумму
let controlSum = percentValues.reduce(0, { x, y in
    x + y
})

print("Control sum: \(controlSum)")
