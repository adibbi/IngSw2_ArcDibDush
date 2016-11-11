open util/boolean


enum CarStatus {
	available,
	prenoted,
	inUse
}

sig Position{}

sig Car {
	status : CarStatus,
	model:String,
	remainingCharge:Int,
	plugged:Bool,
	position:Position,
	seats:Int
}
{
	remainingCharge>=0
	remainingCharge <=100
	seats>0
	seats<=5
}

pred vvv(){
	available in CarStatus
}

pred isAvailable(c:Car){
	c.status in CarStatus
}

pred show{}
run isAvailable for 10
