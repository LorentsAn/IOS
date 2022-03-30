# IOS
Главный экран состоит из редактируемого поля клеток, нижней панели инструментов и верхней панели навигации.
1. Поле поддерживает прокрутку по обеим осям и pinch-to-zoom
    - используйте CATiledLayer для отрисовки клеток
2. В панели навигации расположено подменю 􀍠, в нем доступны следующие действия:
    - 􀣋 - настроить текущий автомат, выбрать GoL или элементарный с кодом вольфрама 
    - 􀍳 - изменить размеры текущего поля
    - 􀒉 - очистить текущее поле (деструктивная операция с подтверждением)
3. В панели инструментов доступны следующие действия:
    - 􀎼 - сохранить снапшот текущего состояния
    - 􀊑 - откатить поле до последнего снепшота
    - 􀊃 / 􀊅 – запустить / остановить пошаговую симуляцию в нормальную скорость
    - 􀊏 - во время паузы, перейти на одно поколение вперед
    - 􀅼 - открыть библиотеку фигур. (по нажатию в отдельном окне открывается список фигур с превью; после выбора фигуры она помещается на поле и включается режим вставки)
4. Пока симуляция на паузе, поле должно редактироваться:
    - Вне режима выделения, однократное нажатие на клетку меняет ее состояние на противоположное
    - Долгое нажатие должно включать режим выделения
        - На экране в месте нажатия появляется рамка выделения
            - Перетаскивание углов изменяет размер рамки
        - В панели инструментов становятся доступны следующие действия:
            - 􀈈 - сохранить выделенное в библиотеку фигур
            - 􀣦 - очистить выделенную область
        - В панели навигации становится доступна кнопка "Done"

- В режиме выделения
        - 􀎮 / 􀎰 - повернуть выделенное на 90 градусов влево / право
        - 􀉃 - копировать выделенное в буфер обмена
        - 􀈽 - вставить фигуру из буфера обмена
        - 􀮐 - "вырезать" содержимое выделения из поля и включить режим вставки
    - В режиме вставки
        - 􀎮 / 􀎰 - повернуть выделенное на 90 градусов влево / право
        - 􀃤 - вставить с полной заменой
        - 􀃜 - вставить только живые клетки
    - В режиме редактирования
        - Поддержать разные скорости воспроизведения: 􀓑 / 􀓏 / 􀍾 - быстрая / медленная / сбалансированая
        - Хранить множество снапшотов
            - 􀎼 - при долгом нажатии показать на отдельном экране список снепшотов с превью
            - Должна быть возможность удалять снапшоты
            - После выбора снепшота он применяется - деструктивная операция с подтверждением

Поддержите следующие настройки отображения:
    - Форма клеток. 􀚈 - квадратики,  􀞿 - кружочки
    - Цвет клеток/фона. Должно работать с темной темой
