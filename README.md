# Выполненое задание для компании Skybonds

- [x] Full Stack Swift : VAPOR + iOS
- [x] Writed on SDK iOS 13.1 
- [x] iOS 11+ supporting

## Оглавление

* [Общие сведения](README.md#common)
* [Выполнение задач](README.md#letter)
* [Настройка сервиса на VAPOR](README.md#settings)
* [Текст задания](README.md#tests)
* [Лицензия](LICENSE)

## <a name="common"></a>Общие сведения

### Тестовое задание на позицию iOS-разработчика в Skybonds

В рамках тестового задания предлагается решить две задачи, приведенные ниже.

К решению каждой задачи необходимо приложить:
* субъективную оценку сложности задачи по шкале от 1 до 10,
* предварительную оценку трудозатрат,
* фактические трудозатраты.

При оценке выполненных задач мы обращаем внимание на следующие факторы:
* сопроводительное письмо,
* время выполнения,
* решение задачи,
* наличие/качество тестов,
* технологии использованные при решении задач.

## <a name="letter"></a>Выполнение задач

### Фактическое выполнение задач

**Первое задание**  - 4 часа. Написал подобие TestCases прям в Playground со своим критерием проверки точности.

**Второе задание** - 7,5 часов. Сейчас архитектура следующая: компонент представляет собой контейнер UIViewController, весь UI компонента сосредочен в коде, хотя можно было бы его организовать в xib (это бы ускорило работу еще больше). Для работы сервисов использую PromiseKit, чтобы отменять операции написал свою надстройку над ним. Дизайн изменил в сторону максимального использования стандартных цветов и компонентов, обратите внимание что поддерживается DarkMode из iOS 13. Кроме того есть настройки компонента, которые можно менять в Interface Builder. На дальнейшую доробоку пока планирую потратить не более 12 часов, как и предполагал + подумаю над более интересными UnitTests и UITestCases.

**Дополнительно** - 4 часа потратил на разработку сервисов, возвращающих котировки, на технологии VAPOR с использованием Swift. В качестве БД использовал SQLite, чтобы запомнить случайно сгенерированные значения. Для упрощения работы с проектом на VAPOR написал скрипт skybonds-vapor/run.sh

## <a name="settings"></a>Настройка сервиса на VAPOR

### Запуск из под XCode (работает только на симуляторе)

* зайти в консоли в папку skybonds-vapor
* выполнить *sh run.sh update* для подтягивания зависимостей и генерации проекта для xCode
* запустить таргет run из под xCodе

### Запуск из под консоли (работает так же на девайсах)

* Выяснить локальный адрес макбука
* прописать его в файле skybonds-vapor/run.sh
* зайти в консоле в папку skybonds-vapor
* выполнить *sh run.sh*, он соберет сервис и запустит под указанным IP
* В iOS проекте надо поменять адрес с localhost на ваш IP тоже, в файле Services

## <a name="tests"></a>Текст заданий

[Первое задание](01/README.md)

[Второе задание](02/README.md)

## <a name="license"></a>Лицензия

[MIT Лицензия](LICENSE)
