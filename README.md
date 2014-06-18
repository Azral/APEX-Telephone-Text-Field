APEX-Telephone-Text-Field
=========================

Описание
=========================

Плагин предназначен для форматированного ввода номеров телефонов.

Доступные параметры
=========================

1) Mask Enable - Определяет какого типа будет текстовое поле: с одной маской (вводится в поле Input mask) или несколькими (поле Type).
2.a) Type - Вводится тип маски телефона. ru - Города России, codes - Страны мира, us - США.
Для добавления новой страны необходимо добавить в плагин файл формата json с названием: phone-[сокращенное обозначение страны]
2.b) Input mask - определяет маску ввода.
Например: Input mask = +[####################], тогда отображаемая маска будет: +____________________
2) Show mask hover - Если установлено TRUE, то маска показывается при наведении на элемент.
3) Autounmask - Если установлено FALSE, то значение сохраняется вместе с маской.

Инициализация плагина Jquery
=========================

Использование чистого jquery плагина.
Инициализация плагина с одной маской:

var maskOpts = {
                               inputmask: {
                                   definitions: {
                                       '#': {
                                           validator: "[0-9]",
                                           cardinality: 1
                                       }
                                   },
                                   showMaskOnHover: false,
                                   autoUnmask: true
                               }
                           };
$('#P1_TEST2').inputmask("+[####################]", maskOpts.inputmask).attr("placeholder", $('#P1_TEST2').inputmask("getemptymask"));
Инициализация плагина с маской из файла:
var listRU = $.masksSort($.masksLoad("phones-ru.json"), ['#'], /[0-9]|#/, "mask");
var optsRU = {
                               inputmask: {
                                   definitions: {
                                       '#': {
                                           validator: "[0-9]",
                                           cardinality: 1
                                       }
                                   },
                                   //clearIncomplete: true,
                                   showMaskOnHover: false,
                                   autoUnmask: true
                               },
                               match: /[0-9]/,
                               replace: '#',
                               list: listRU,
                               listKey: "mask"
                           };
$('#P1_TEST2').inputmasks(optsRU);
P.S. Для работы jquery плагина необходимы следующие js файлы:
apex.jquery.bind-first-0.1.min.js
apex.jquery.inputmask-multi.js
apex.jquery.inputmask.js

Ссылки
=========================
https://github.com/andr-04/inputmask-multi - ссылка на Jquery версию.
