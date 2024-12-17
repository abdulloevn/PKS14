Практика 14-15 Абдуллоев Наимжон Насимович ЭФБО-02-22

Задание:
Добавить чат с продавцом на страницу Профиль.

Шаг 1. Доработка API
Теперь пользователи хранятся в Firebase. В таблицы БД (Корзина, Избранное) добавлено поле UID, которое является уникальным токеном клиента. 

С учётом UID обновлены следующие запросы:

POST /favourite - теперь требует firebase UID  
GET /favourite - теперь требует firebase UID  
DELETE /favourite - теперь требует firebase UID  
GET /cart - теперь требует firebase UID  
POST /cart - теперь требует firebase UID  
PUT /cart - теперь требует firebase UID  
DELETE /cart - теперь требует firebase UID  
GET /orders - теперь требует firebase UID  
POST /order - теперь требует firebase UID  

Весь API описан в файле backend.go и протестирован с помощью Postman

Шаг 2. Доработка интерфейса
Исходя из предыдущего шага понятно, что никаких действий кроме просмотра стрижек неавторизованный пользователь выполнить не может.

Поэтому неавторизованному пользователю будет видна только страница авторизации.

Состояние: Неавторизован

![{9996BA51-DCD2-4389-906E-3BFAE735B704}](https://github.com/user-attachments/assets/dc53a4ee-ee8c-4281-9290-7f229b3c2720)

Состояние: Авторизован

![IMAGE 2024-12-16 13:47:19](https://github.com/user-attachments/assets/d0e51e0c-7374-4453-8582-c0b4095139aa)

Шаг 3.
Подключим Firestore Database.

Установим библиотеки: для работы с firestore и для отображения сообщений в пузырях.

```
flutter pub add cloud_firestore
flutter pub add flutter_chat_bubble
```
Шаг 4.
Пользователи не могут общаться с другими пользователями (только с продавцом), поэтому в сообщении нужно хранить только id покупателя.   Дополнительная переменная будет отвечать за то, отправлено ли оно от Администратора.

Добавим структуру данных - элемент списка чатов:
```
@JsonSerializable()
class ChatUser {
  ChatUser(this.email, this.uid, this.name, this.lastMessageContent);
  String email;
  String uid;
  String name;
  String lastMessageContent = "";
  factory ChatUser.fromJson(Map json) =>
      _$ChatUserFromJson(json);
  Map toJson() => _$ChatUserToJson(this);
}
```
И ещё одну структуру - для хранения данных сообщения
```
@JsonSerializable()
class Message {
  Message(this.customerUID, this.isFromAdmin, this.content, this.timestamp);
  String customerUID;
  bool isFromAdmin;
  String content;
  DateTime timestamp;
  factory Message.fromJson(Map json) =>
      _$MessageFromJson(json);
  Map toJson() => _$MessageToJson(this);
}
```
Администратор - это единственный пользователь с почтой admin@admin.com

На странице Профиль у обычного пользователя есть кнопка "Чат с продавцом", которая открывает страницу с чатом.   У администратора в этом же месте другая кнопка - "Чат с клиентами", которая открывает список чатов, в котором уже затем можно выбрать конкретного пользователя и ответить ему.



<img width="412" alt="Снимок экрана 2024-12-17 в 11 37 49" src="https://github.com/user-attachments/assets/c279623c-f45a-451c-9915-b58d0427f429" />
<img width="412" alt="Снимок экрана 2024-12-17 в 11 37 38" src="https://github.com/user-attachments/assets/a436ba90-a9c6-4963-ac07-50e03bc50261" />


