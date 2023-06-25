// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelRoomReservation {
    // Struct to represent a reservation
    struct Reservation {
        address buyer;
        uint256 roomId;
        uint256 checkInDate;
        uint256 checkOutDate;
        uint256 price;
        bool isActive;
        bool isRefunded;
    }

    // Array to store all reservations
    Reservation[] private reservations;

    // Mapping to track the owner of each reservation
    mapping(uint256 => address) private reservationToOwner;

    // Mapping to track the number of reservations owned by each address
    mapping(address => uint256) private ownerReservationCount;

    // Event emitted when a new reservation is created
    event ReservationCreated(uint256 reservationId);

    // Event emitted when a reservation is transferred
    event ReservationTransferred(uint256 reservationId, address previousOwner, address newOwner);

    // Modifier to check if the reservation exists and is owned by the caller
    modifier onlyReservationOwner(uint256 _reservationId) {
        require(reservationToOwner[_reservationId] == msg.sender, "Only the reservation owner can call this function");
        _;
    }

    // Modifier to check if the reservation is active
    modifier onlyActiveReservation(uint256 _reservationId) {
        require(reservations[_reservationId].isActive, "Reservation is not active");
        _;
    }

    // Modifier to check if the reservation is not refunded
    modifier onlyNonRefundedReservation(uint256 _reservationId) {
        require(!reservations[_reservationId].isRefunded, "Reservation has already been refunded");
        _;
    }

    // Function to create a new reservation
    function createReservation(
        uint256 _roomId,
        uint256 _checkInDate,
        uint256 _checkOutDate,
        uint256 _price
    ) external {
        require(_checkInDate < _checkOutDate, "Invalid check-in and check-out dates");

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

        address previousOwner = msg.sender;
        reservationToOwner[_reservationId] = _newOwner;
        ownerReservationCount[previousOwner]--;
        ownerReservationCount[_newOwner]++;

        emit ReservationTransferred(_reservationId, previousOwner, _newOwner);
    }
}
