package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Service struct {
	gorm.Model
	ID             uint
	Name           string
	Category       string
	PriceRubles    uint
	ImageHref      string
	Description    string
	AvailableCount int
	FavouriteItems []FavouriteItem `gorm:"foreignKey:ServiceID"`
	CartItems      []CartItem      `gorm:"foreignKey:ServiceID"`
}

type FavouriteItem struct {
	gorm.Model
	ID        uint
	UID       string
	ServiceID uint
	Service   Service `gorm:"foreignKey:ServiceID"`
}

type CartItem struct {
	gorm.Model
	ID        uint
	UID       string
	ServiceID uint
	Count     uint
	Service   Service `gorm:"foreignKey:ServiceID"`
}

type Order struct {
	gorm.Model
	ID         uint
	UID        string
	Total      uint
	OrderItems []OrderItem `gorm:"foreignKey:OrderID"`
}

type OrderItem struct {
	CartItem
	OrderID uint
	Order   Order `gorm:"foreignKey:OrderID"`
}

var db *gorm.DB

func connectToDatabase() *gorm.DB {
	connectionString := "host=localhost user=postgres dbname=barbershop_flutter password=postgres sslmode=disable"
	db, err := gorm.Open(postgres.Open(connectionString), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	return db
}

func initDatabase() {
	db.Migrator().DropTable(&Service{}, &FavouriteItem{}, &CartItem{}, &Order{}, &OrderItem{})
	err := db.AutoMigrate(&Service{}, &FavouriteItem{}, &CartItem{}, &Order{}, &OrderItem{})
	if err != nil {
		panic("faled to init database")
	}
}

func fillDatabaseWithTestData() {
	// user is now in firebase, so this is commented
	// daniilStolyarov := User{ID: 1, Email: "22T0318@gmail.com", Name: "Daniil Stolyarov", Password: "test_password", PhoneNumber: "89876543210"}
	// db.Create(&daniilStolyarov)

	services := []Service{
		{Name: "Боб", Category: "Стрижка и укладка", PriceRubles: 799, ImageHref: "https://i.imgur.com/pLhAUHv.jpeg", Description: "Боб — это классическая и универсальная стрижка, которая подходит для любого типа волос и формы лица. Она может быть выполнена различной длины и формы, от короткого, доходящего до подбородка боба до длинного, доходящего до плеч боба. Боб идеально подходит для тех, кто хочет добавить объем и текстуру своим волосам, а также скрыть недостатки лица и подчеркнуть скулы.", AvailableCount: 5},
		{Name: "Цезарь", Category: "Стрижка и укладка", PriceRubles: 699, ImageHref: "https://i.imgur.com/G8eOfAE.jpeg", Description: "Цезарь — это короткая мужская стрижка с ровной челкой и короткими, одинаковой длины волосами по бокам и сзади. Она идеально подходит для мужчин с прямыми или волнистыми волосами и квадратной или круглой формой лица. Стрижка Цезарь — это стильный и универсальный вариант, который легко укладывать и поддерживать.", AvailableCount: 5},
		{Name: "Гарсон", Category: "Стрижка и укладка", PriceRubles: 599, ImageHref: "https://i.imgur.com/Atfpw5S.jpeg", Description: "Гарсон — это короткая, женственная стрижка, которая добавляет образу дерзости и стиля. Она характеризуется короткими, филированными волосами, часто с челкой или асимметрией. Гарсон идеально подходит для тех, кто хочет добавить объем и текстуру тонким волосам, а также скрыть недостатки лица и подчеркнуть скулы.", AvailableCount: 5},
		{Name: "Полубокс", Category: "Стрижка и укладка", PriceRubles: 499, ImageHref: "https://i.imgur.com/rpKjovf.jpeg", Description: "Полубокс — это короткая, практичная и универсальная мужская стрижка, которая подходит для любого типа волос и формы лица. Она характеризуется короткими волосами на висках и затылке, переходящими в более длинные волосы на макушке. Полубокс — это стильный и неприхотливый вариант, который легко укладывать и поддерживать.", AvailableCount: 5},
		{Name: "Шапочка", Category: "Стрижка и укладка", PriceRubles: 599, ImageHref: "https://i.imgur.com/MiLOdAO.jpeg", Description: "Шапочка — это женственная и элегантная стрижка, которая подходит для любого типа волос и формы лица. Она характеризуется короткими, округлыми волосами, которые плавно обрамляют лицо, создавая эффект шапочки. Шапочка — это универсальный вариант, который легко укладывать и поддерживать, придавая образу утонченность и шарм.", AvailableCount: 5},
		{Name: "Маллет", Category: "Стрижка и укладка", PriceRubles: 699, ImageHref: "https://i.imgur.com/oAlIgc2.jpeg", Description: "Маллет — это дерзкая и экстравагантная стрижка, которая характеризуется короткими волосами на макушке и длинными волосами на затылке. Маллет — это стильный и необычный вариант, который подходит для тех, кто хочет выделиться и подчеркнуть свой индивидуальный стиль. Она требует особого ухода и укладки, придавая образу неповторимость и притягательность.", AvailableCount: 5},
		{Name: "Милитари", Category: "Стрижка и укладка", PriceRubles: 799, ImageHref: "https://i.imgur.com/RHjZ63I.jpeg", Description: "Милитари — это мужественная и практичная стрижка, которая характеризуется короткими волосами по всей голове. Милитари — это универсальный и неприхотливый вариант, который подходит для любого типа волос и формы лица. Она не требует сложной укладки и идеально подходит для тех, кто ценит удобство и аккуратный внешний вид.", AvailableCount: 5},
		{Name: "Пикси", Category: "Стрижка и укладка", PriceRubles: 999, ImageHref: "https://i.imgur.com/01Z9Sga.jpeg", Description: "Пикси - это дерзкая и стильная стрижка, которая характеризуется короткими волосами на висках и затылке, переходящими в более длинные волосы на макушке. Пикси — это женственный и многогранный вариант, который подходит для любого типа волос и формы лица. Она позволяет создавать различные укладки, от гладких и элегантных до текстурных и небрежных.", AvailableCount: 5},
		{Name: "Короткое Каре", Category: "Стрижка и укладка", PriceRubles: 899, ImageHref: "https://i.imgur.com/HroeZo2.jpeg", Description: "Короткое Каре — это элегантная и стильная стрижка, которая характеризуется прямыми волосами, подстриженными до уровня подбородка или чуть выше. Короткое каре — это универсальный и практичный вариант, который подходит для любого типа волос и формы лица. Оно легко укладывается и позволяет создавать различные образы, от классических и сдержанных до современных и авангардных.", AvailableCount: 5},
		{Name: "Звезда", Category: "Стрижка и укладка", PriceRubles: 1199, ImageHref: "https://i.imgur.com/dOnl5Vz.jpeg", Description: "Звезда — это смелая и дерзкая стрижка, которая характеризуется выбритыми висками и затылком в форме звезды. Звезда — это авангардный и экстравагантный вариант, который подходит для тех, кто не боится выделяться из толпы. Она требует особого ухода и укладки, но придает образу неповторимый и притягательный вид.", AvailableCount: 5},
		{Name: "Теннис", Category: "Стрижка и укладка", PriceRubles: 599, ImageHref: "https://i.imgur.com/1uNHwbK.jpeg", Description: "Теннис — это спортивная и практичная стрижка, которая характеризуется короткими волосами по всей голове, подстриженными машинкой. Теннис — это универсальный и неприхотливый вариант, который подходит для любого типа волос и формы лица. Она не требует сложной укладки и идеально подходит для тех, кто ценит удобство и аккуратный внешний вид.", AvailableCount: 5},
	}
	for _, service := range services {
		db.Create(&service)
	}
}

func getAllServices(writer http.ResponseWriter, request *http.Request) {
	var services []Service
	db.Find(&services)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(services)
}
func getFavouriteOfUser(writer http.ResponseWriter, request *http.Request) {
	requestUID := request.URL.Query().Get("uid")
	if requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	var favouriteItems []FavouriteItem
	db.Where(&FavouriteItem{UID: requestUID}).Preload("Service").Find(&favouriteItems)
	services := []Service{}
	for _, item := range favouriteItems {
		services = append(services, item.Service)
	}
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(services)
}
func getCartOfUser(writer http.ResponseWriter, request *http.Request) {
	requestUID := request.URL.Query().Get("uid")
	if requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	CartItems := []CartItem{}
	db.Where("uid=?", requestUID).Preload("Service").Find(&CartItems)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(CartItems)
}

//	func getUserData(writer http.ResponseWriter, request *http.Request) {
//		userId := request.URL.Query().Get("id")
//		user := User{}
//		db.First(&user, userId)
//		user.Password = ""
//		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
//		json.NewEncoder(writer).Encode(user)
//	}
func getService(writer http.ResponseWriter, request *http.Request) {
	serviceId := request.URL.Query().Get("id")
	service := Service{}
	db.First(&service, serviceId)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(service)
}

func addService(writer http.ResponseWriter, request *http.Request) {
	service := Service{}

	err := json.NewDecoder(request.Body).Decode(&service)
	if err != nil {
		fmt.Println(err)

	}
	db.Create(&service)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(service)
}

func addFavouriteOfUser(writer http.ResponseWriter, request *http.Request) {
	serviceId := request.URL.Query().Get("service_id")
	requestUID := request.URL.Query().Get("uid")
	serviceId_parsed, _ := strconv.Atoi(serviceId)

	if serviceId_parsed == 0 || requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	var similarCount int64
	db.Model(&FavouriteItem{}).Where(&FavouriteItem{ServiceID: uint(serviceId_parsed), UID: requestUID}).Count(&similarCount)
	if similarCount != 0 {
		// there's already cart item
		writer.WriteHeader(http.StatusConflict)
		writer.Write([]byte("Ошибка: товар уже есть в Избранном"))
		return
	}
	favouriteItem := FavouriteItem{ServiceID: uint(serviceId_parsed), UID: requestUID, ID: 0}
	db.Preload("Service").Create(&favouriteItem).First(&favouriteItem)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(favouriteItem)
}

func addCartOfUser(writer http.ResponseWriter, request *http.Request) {
	serviceId := request.URL.Query().Get("service_id")
	serviceId_parsed, _ := strconv.Atoi(serviceId)
	requestUID := request.URL.Query().Get("uid")
	if serviceId_parsed == 0 || requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	// check if there's no cart item for that service and user
	var similarCount int64
	db.Model(&CartItem{}).Where(&CartItem{ServiceID: uint(serviceId_parsed), UID: requestUID}).Count(&similarCount)
	if similarCount != 0 {
		// there's already cart item
		writer.WriteHeader(http.StatusConflict)
		writer.Write([]byte("Ошибка: товар уже есть в корзине"))
		return
	}
	// check if count is available
	service := Service{}
	db.First(&service, "id=?", serviceId_parsed)
	if service.AvailableCount < 1 {
		// not available
		writer.WriteHeader(http.StatusConflict)
		writer.Write([]byte("Ошибка: товар закончился."))
		return
	}
	CartItem := CartItem{ServiceID: uint(serviceId_parsed), UID: requestUID, Count: 1}
	db.Preload("Service").Create(&CartItem).First(&CartItem)
	service.AvailableCount -= 1
	db.Model(&Service{}).Where("id = ?", serviceId_parsed).Update("available_count", service.AvailableCount)

	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(CartItem)
}

func updateCartOfUser(writer http.ResponseWriter, request *http.Request) {
	serviceId := request.URL.Query().Get("service_id")
	serviceId_parsed, _ := strconv.Atoi(serviceId)
	requestUID := request.URL.Query().Get("uid")
	count := request.URL.Query().Get("count")
	count_parsed, _ := strconv.Atoi(count)
	if serviceId_parsed == 0 || count_parsed == 0 || requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	cartItem := CartItem{}
	db.Where("service_id=?", serviceId_parsed).Where("uid=?", requestUID).First(&cartItem)
	if cartItem.ID == 0 {
		writer.WriteHeader(http.StatusConflict)
		writer.Write([]byte("Ошибка: нет элемента корзины для обновления"))
		return
	}
	service := Service{}
	db.First(&service, "id = ?", serviceId_parsed)
	if count_parsed-int(cartItem.Count) > service.AvailableCount {
		writer.WriteHeader(http.StatusConflict)
		writer.Write([]byte("Ошибка: товар закончился."))
		return
	}
	service.AvailableCount -= (count_parsed - int(cartItem.Count))
	cartItem.Count = uint(count_parsed)
	db.Model(&CartItem{}).Where("service_id = ?", serviceId_parsed).Where("uid=?", requestUID).Updates(cartItem)
	db.Model(&Service{}).Where("id = ?", serviceId_parsed).Update("available_count", service.AvailableCount)

	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(cartItem)
}

// func updateUser(writer http.ResponseWriter, request *http.Request) {
// 	user := User{}
// 	json.NewDecoder(request.Body).Decode(&user)
// 	fmt.Println(user.Name + " " + strconv.Itoa(int(user.ID)) + " " + user.Password + " " + user.Email)
// 	result := db.Model(&User{}).Where("id = ?", int(user.ID)).Select("Name", "PhoneNumber", "Email").Updates(user)

// 	if result.Error != nil {
// 		fmt.Println(result.Error)
// 	}

//		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
//		json.NewEncoder(writer).Encode(user)
//	}
func updateService(writer http.ResponseWriter, request *http.Request) {
	service := Service{}
	json.NewDecoder(request.Body).Decode(&service)
	result := db.Model(&Service{}).Where("id = ?", int(service.ID)).Updates(service)
	if result.Error != nil {
		fmt.Println(result.Error)
	}

	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(service)
}
func removeCartItemOfUser(writer http.ResponseWriter, request *http.Request) {
	serviceId := request.URL.Query().Get("service_id")
	serviceId_parsed, _ := strconv.Atoi(serviceId)
	requestUID := request.URL.Query().Get("uid")
	if serviceId_parsed == 0 || requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	cartItem := CartItem{}
	var deletedCount int
	db.Where("service_id = ?", serviceId_parsed).Where("uid=?", requestUID).First(&cartItem)
	deletedCount = int(cartItem.Count)
	db.Where("service_id = ?", serviceId_parsed).Where("uid=?", requestUID).Unscoped().Delete(&cartItem)

	service := Service{}
	db.First(&service, "id = ?", serviceId_parsed)
	service.AvailableCount += deletedCount // probably a bug. need to be count of deleted service
	db.Model(&Service{}).Where("id = ?", serviceId_parsed).Updates(service)

	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(cartItem)
}
func removeFavouriteItemOfUser(writer http.ResponseWriter, request *http.Request) {
	requestUID := request.URL.Query().Get("uid")
	serviceId := request.URL.Query().Get("service_id")
	serviceId_parsed, _ := strconv.Atoi(serviceId)
	if serviceId_parsed == 0 || requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	favouriteItem := FavouriteItem{}
	fmt.Println(serviceId_parsed)
	db.Where("service_id = ?", serviceId_parsed).Where("uid=?", requestUID).Unscoped().Delete(&favouriteItem)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(favouriteItem)
}
func removeService(writer http.ResponseWriter, request *http.Request) {
	service := Service{}
	Id := request.URL.Query().Get("id")
	Id_parsed, _ := strconv.Atoi(Id)
	db.Where("id = ?", Id_parsed).Unscoped().Delete(&service)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(service)
}
func addOrderOfUser(writer http.ResponseWriter, request *http.Request) {
	requestUID := request.URL.Query().Get("uid")
	if requestUID == "" {
		writer.WriteHeader(http.StatusBadRequest)
		writer.Write([]byte("Ошибка: неправильные аргументы запроса"))
		return
	}
	cartItems := []CartItem{}
	var order_id uint
	db.Transaction(func(tx *gorm.DB) error {
		tx.Where("uid=?", requestUID).Preload("Service").Find(&cartItems)
		tx.Where("uid=?", requestUID).Unscoped().Delete(&CartItem{})
		var total uint = 0
		// calc total
		for _, cartItem := range cartItems {
			total += cartItem.Count * cartItem.Service.PriceRubles
		}
		order := Order{Total: total, UID: requestUID}
		tx.Create(&order)
		order_id = order.ID
		for _, cartItem := range cartItems {
			orderItem := OrderItem{CartItem: cartItem, OrderID: order.ID}
			tx.Create(&orderItem)
		}
		return nil
	})
	order := Order{}
	db.Find(&order, "id=?", order_id)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(order)
}

func getOrdersOfUser(writer http.ResponseWriter, request *http.Request) {
	requestUID := request.URL.Query().Get("uid")
	orders := []Order{}
	db.Where("uid=?", requestUID).Preload("OrderItems.Service").Find(&orders)
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(writer).Encode(orders)
}
func main() {
	db = connectToDatabase()
	initDatabase()
	fillDatabaseWithTestData()

	router := mux.NewRouter()
	router.HandleFunc("/services", getAllServices).Methods("GET")
	//router.HandleFunc("/user", getUserData).Methods("GET")
	router.HandleFunc("/favourite", getFavouriteOfUser).Methods("GET")
	router.HandleFunc("/cart", getCartOfUser).Methods("GET")
	router.HandleFunc("/service", addService).Methods("POST")
	router.HandleFunc("/favourite", addFavouriteOfUser).Methods("POST")
	router.HandleFunc("/cart", addCartOfUser).Methods("POST")
	router.HandleFunc("/cart", updateCartOfUser).Methods("PUT")
	//router.HandleFunc("/user", updateUser).Methods("PUT")
	router.HandleFunc("/cart", removeCartItemOfUser).Methods("DELETE")
	router.HandleFunc("/favourite", removeFavouriteItemOfUser).Methods("DELETE")
	router.HandleFunc("/service", removeService).Methods("DELETE")
	router.HandleFunc("/service", updateService).Methods("PUT")
	router.HandleFunc("/service", getService).Methods("GET")
	router.HandleFunc("/order", addOrderOfUser).Methods("POST")
	router.HandleFunc("/orders", getOrdersOfUser).Methods("GET")

	fmt.Println("running...")
	http.ListenAndServe(":8080", router)
}
