open util/boolean


enum CarStatus {
	available,
	reserved,
	inUse
}

sig Position{}




sig ChargingStation{
	capacity :Int,
	availablePlugs : Int,
	parkedCars : set Car,
	position:Position
}
{
	capacity >0
	#parkedCars <= capacity
	availablePlugs = capacity - #parkedCars
}


sig ActiveRents{
	rents : set  Rent
}


sig Rent {
	reservation : Reservation,
	client : Client,
	car : Car
}
{
	reservation.client=client
	reservation.car = car
}


sig Reservation{
	client: Client,
	car : Car
}


sig Car {
	status : CarStatus,
	remainingCharge:Int,
	plugged:Bool,
	position:Position,
}
{
	remainingCharge>=0
	remainingCharge <=100
	status = inUse implies plugged = False
}


sig Client{}

 


//all rents are in Active Rents
fact allRentAreInActiveRents{
	all rent:Rent | rent in ActiveRents.rents
}


//a client cannot have more than one active rent
fact noRentMadeByTheSameClient{
	all r1,r2 : Rent | r1 != r2 implies r1.client != r2.client
}


//for each rent there is a reservation and it's unique
fact  noRentWithTheSameReservation{
	all r1,r2:Rent | r1!=r2 implies r1.reservation != r2.reservation
}


//a car cannot be rented by 2 clients or more 
fact  noRentOnTheSameCar{
	all r1,r2:Rent | r1!=r2 implies r1.car != r2.car
}


//a car cannot have more than one active reservation
fact noReservationOnTheSameCar{
		all r1,r2:Reservation | r1!=r2 implies r1.car != r2.car
}

//a client cannot reserve more than one car
fact noReservationByTheSameClient{
		all r1,r2 : Reservation | r1 != r2 implies r1.client != r2.client
}





//all cars parked inside charging stations are plugged
fact {
	all c:Car | c in ChargingStation.parkedCars implies c.plugged = True
}


//cars parked in che charging station have the same position of the charging station
fact chargingCarsInTheSameStation{
	all c:Car , cs :ChargingStation | c in cs.parkedCars implies c.position = cs.position
}


//if a car is not rented or reserved its state is available
fact availableCarCondition{
	all c:Car | not (c in Rent.car or c in Reservation.car) implies c.status=available
}


//if a car is not rented but is reserved its state is reserved
fact reservedCarCondition{
	all c:Car | c in Reservation.car and not ( c in Rent.car ) implies c.status = reserved 
}


//if a car is rented his state is inUse
fact inUseCarCondition{
	all c:Car | c in Rent.car implies c.status = inUse
}


//Each charging station is locaded in a different position
fact noChargingStationsInTheSamePlace{
	all cs1,cs2: ChargingStation | cs1 != cs2 implies cs1.position!=cs2.position
}




//predicate to end a rent
pred endRent(activeRents,activeRents' :ActiveRents, rent:Rent ){
	activeRents'.rents = activeRents.rents-rent
}


//predicate to init a rent
pred initRent(activeRents , activeRents':ActiveRents , rent:Rent ){
	activeRents'.rents = activeRents.rents+rent
}


pred show{

}




//check that there are no more charging car than car in that position
assert noMoreChargingThanParked {
	all cs :ChargingStation , p:Position | p=cs.position implies #cs.parkedCars <= #{c : Car | c.position = p}
}


//check that a client has not more than one rent active
assert atMostOneRentPerClient{
	all c:Client | lone rent:Rent | rent.client = c
}


//check that there is no more than an active rent for each car
assert atMostOneRentPerCar{
	all c:Car | lone rent:Rent | rent.car = c
}


//check that there is no more than an active reservation for each client
assert atMostOneReservationPerClient{
	all c:Client | lone res:Reservation | res.client = c
}


//check there is no more than one active reservation for each car
assert atMostOneReservationPerCar{
	all c:Car | lone res:Reservation | res.car = c
}


//check the conditions that must be satisfied after an end of a rent
assert conditionEndedRent{
	all activeRents, activeRents' : ActiveRents , rent:Rent ,c1:Car | 
	endRent[activeRents, activeRents',rent] and c1=rent.car implies
	not c1 in activeRents'.rents.car
	
}


//check the conditions that must be satisfied after a start of a rent
assert conditionInitRent{
	all activeRents, activeRents' : ActiveRents , rent:Rent ,c1:Car| 
	initRent[activeRents, activeRents',rent] and c1=rent.car implies
	c1 in activeRents'.rents.car
}






check conditionInitRent for 3
run initRent for 5 but exactly 2 Rent 
check conditionEndedRent for 5
run endRent for 5
check noMoreChargingThanParked for 3
check atMostOneRentPerClient for 5
check atMostOneReservationPerCar for 5 
check atMostOneReservationPerClient for 5 
check atMostOneRentPerCar for 5 
run show for 5
