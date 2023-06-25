// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelRoomReservation {
    // Struct to represent a room reservation
    struct Reservation {
        address buyer;
        uint256 roomId;
        uint256 checkInDate;
        uint256 checkOutDate;
        uint256 price;
        bool isActive;
        bool isRefunded;
    }

    // Struct to represent a full holiday plan
    struct HolidayPlan {
        string name;
        uint256[] roomIds;
        uint256 price;
    }

    // Arrays to store all reservations and holiday plans
    Reservation[] private reservations;
    HolidayPlan[] private holidayPlans;

    // Mapping to track the owner of each reservation
    mapping(uint256 => address) private reservationToOwner;

    // Mapping to track the number of reservations owned by each address
    mapping(address => uint256) private ownerReservationCount;

    // Event emitted when a new reservation is created
    event ReservationCreated(uint256 reservationId);

    // Event emitted when a reservation is transferred
    event ReservationTransferred(uint256 reservationId, address previousOwner, address newOwner);

    modifier onlyReservationOwner(uint256 _reservationId) {
        require(reservationToOwner[_reservationId] == msg.sender, "Only the reservation owner can call this function");
        _;
    }

    modifier onlyActiveReservation(uint256 _reservationId) {
        require(reservations[_reservationId].isActive, "Reservation is not active");
        _;
    }

    modifier onlyNonRefundedReservation(uint256 _reservationId) {
        require(!reservations[_reservationId].isRefunded, "Reservation has already been refunded");
        _;
    }

    function createReservation(
        uint256 _roomId,
        uint256 _checkInDate,
        uint256 _checkOutDate,
        uint256 _price
    ) external {
        require(_checkInDate < _checkOutDate, "Invalid check-in and check-out dates");
        require(_price > 0, "Price must be greater than zero");

        Reservation memory newReservation = Reservation({
            buyer: msg.sender,
            roomId: _roomId,
            checkInDate: _checkInDate,
            checkOutDate: _checkOutDate,
            price: _price,
            isActive: true,
            isRefunded: false
        });

        uint256 reservationId = reservations.length;
        reservations.push(newReservation);
        reservationToOwner[reservationId] = msg.sender;
        ownerReservationCount[msg.sender]++;

        emit ReservationCreated(reservationId);
    }

    // Function to get the details of a reservation
    function getReservation(uint256 _reservationId)
        external
        view
        returns (
            address buyer,
            uint256 roomId,
            uint256 checkInDate,
            uint256 checkOutDate,
            uint256 price,
            bool isActive,
            bool isRefunded
        )
    {
        require(_reservationId < reservations.length, "Invalid reservation ID");

        Reservation memory reservation = reservations[_reservationId];
        return (
            reservation.buyer,
            reservation.roomId,
            reservation.checkInDate,
            reservation.checkOutDate,
            reservation.price,
            reservation.isActive,
            reservation.isRefunded
        );
    }

    // Function to transfer ownership of a reservation
    function transferReservation(uint256 _reservationId, address _newOwner)
        external
        onlyReservationOwner(_reservationId)
        onlyActiveReservation(_reservationId)
        onlyNonRefundedReservation(_reservationId)
    {
        require(_newOwner != address(0), "Invalid new owner address");
        require(_newOwner != msg.sender, "New owner address cannot be the same as the current owner");

        address previousOwner = msg.sender;
        reservationToOwner[_reservationId] = _newOwner;
        ownerReservationCount[previousOwner]--;
        ownerReservationCount[_newOwner]++;

        emit ReservationTransferred(_reservationId, previousOwner, _newOwner);
    }

    // Function to create a new holiday plan
    function createHolidayPlan(string memory _name, uint256[] memory _roomIds, uint256 _price) external {
        require(bytes(_name).length > 0, "Holiday plan name must not be empty");
        require(_roomIds.length > 0, "Holiday plan must include at least one room");
        require(_price > 0, "Holiday plan price must be greater than zero");

        HolidayPlan memory newHolidayPlan = HolidayPlan({
            name: _name,
            roomIds: _roomIds,
            price: _price
        });

        holidayPlans.push(newHolidayPlan);
    }

    // Function to get the details of a holiday plan
    function getHolidayPlan(uint256 _planId)
        external
        view
        returns (
            string memory name,
            uint256[] memory roomIds,
            uint256 price
        )
    {
        require(_planId < holidayPlans.length, "Invalid holiday plan ID");

        HolidayPlan memory holidayPlan = holidayPlans[_planId];
        return (holidayPlan.name, holidayPlan.roomIds, holidayPlan.price);
    }

    // Function to get the number of reservations owned by an address
    function getReservationCount(address _owner) external view returns (uint256) {
        return ownerReservationCount[_owner];
    }
}
