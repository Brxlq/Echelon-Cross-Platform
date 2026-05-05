# Echelon App ERD - Chen Notation

```mermaid
flowchart LR
    %% Entities
    USER[USER]
    VEHICLE_CLASS[VEHICLE_CLASS]
    VEHICLE[VEHICLE]
    ADD_ON[ADD_ON]
    ORDER[ORDER]
    ORDER_ADD_ON[ORDER_ADD_ON]
    POST[POST]

    %% Relationships
    PLACES{PLACES}
    BOOKS{BOOKS}
    CATEGORIZES{CATEGORIZES}
    OFFERS{OFFERS}
    CONTAINS{CONTAINS}
    SELECTS{SELECTS}
    WRITES{WRITES}

    %% Main horizontal ERD
    USER ---|1| PLACES
    PLACES ---|0..N| ORDER
    ORDER ---|0..N| CONTAINS
    CONTAINS ---|1| ORDER_ADD_ON
    ORDER_ADD_ON ---|1| SELECTS
    SELECTS ---|1| ADD_ON
    ADD_ON ---|0..N| OFFERS
    OFFERS ---|1| VEHICLE
    VEHICLE ---|0..N| CATEGORIZES
    CATEGORIZES ---|1| VEHICLE_CLASS

    VEHICLE ---|1| BOOKS
    BOOKS ---|0..N| ORDER

    USER ---|1| WRITES
    WRITES ---|0..N| POST

    %% USER attributes
    user_id(("<u>user_id</u>"))
    user_name((name))
    user_role((role))

    user_id --- USER
    user_name --- USER
    user_role --- USER

    %% VEHICLE_CLASS attributes
    class_name(("<u>name</u>"))
    class_image((image_url))

    class_name --- VEHICLE_CLASS
    class_image --- VEHICLE_CLASS

    %% VEHICLE attributes
    vehicle_id(("<u>vehicle_id</u>"))
    vehicle_name((name))
    vehicle_address((address))
    hourly_rate((hourly_rate))

    vehicle_id --- VEHICLE
    vehicle_name --- VEHICLE
    vehicle_address --- VEHICLE
    hourly_rate --- VEHICLE

    %% ADD_ON attributes
    add_on_id(("<u>add_on_id</u>"))
    add_on_name((name))
    add_on_price((price))

    add_on_id --- ADD_ON
    add_on_name --- ADD_ON
    add_on_price --- ADD_ON

    %% ORDER attributes
    order_id(("<u>order_id</u>"))
    driver_name((driver_name))
    pickup_date((pickup_date))
    rental_length((rental_length))
    total_cost((total_cost))

    order_id --- ORDER
    driver_name --- ORDER
    pickup_date --- ORDER
    rental_length --- ORDER
    total_cost --- ORDER

    %% ORDER_ADD_ON attributes
    order_add_on_id(("<u>order_add_on_id</u>"))
    quantity((quantity))

    order_add_on_id --- ORDER_ADD_ON
    quantity --- ORDER_ADD_ON

    %% POST attributes
    post_id(("<u>post_id</u>"))
    comment((comment))
    timestamp((timestamp))

    post_id --- POST
    comment --- POST
    timestamp --- POST
```

## Notes

- `VEHICLE` is the app's current `Restaurant` model.
- `ADD_ON` is the app's current `Item` model.
- `ORDER_ADD_ON` stores selected add-ons and their quantities for each order.
