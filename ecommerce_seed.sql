USE ECommerceDB;

START TRANSACTION;

INSERT INTO Customers (id, name, email, phoneNumber) VALUES
(1, 'Ahmad Ali', 'ahmad.ali@example.com', '0599000001'),
(2, 'Sara Khaled', 'sara.khaled@example.com', '0599000002'),
(3, 'Omar Hassan', 'omar.hassan@example.com', '0599000003'),
(4, 'Lina Yousef', 'lina.yousef@example.com', '0599000004'),
(5, 'Noor Salem', 'noor.salem@example.com', '0599000005'),
(6, 'Adam Nasser', 'adam.nasser@example.com', '0599000006');

INSERT INTO CustomerAddresses (id, idCustomer, country, city, street) VALUES
(1, 1, 'Palestine', 'Ramallah', 'Main Street'),
(2, 1, 'Palestine', 'Al-Bireh', 'School Street'),
(3, 2, 'Palestine', 'Nablus', 'Market Street'),
(4, 3, 'Palestine', 'Hebron', 'University Street'),
(5, 4, 'Palestine', 'Bethlehem', 'Church Street'),
(6, 5, 'Palestine', 'Jenin', 'City Center'),
(7, 6, 'Palestine', 'Tulkarm', 'Garden Street');

INSERT INTO CustomerProfiles (id, dateOfBirth, profileImage) VALUES
(1, '2000-03-12', 'ahmad.jpg'),
(2, '1999-07-08', 'sara.jpg'),
(4, '2001-11-20', 'lina.jpg');

INSERT INTO Vendors (id, name, phoneNumber, email) VALUES
(1, 'TechHub', '0599111101', 'sales@techhub.example'),
(2, 'MobilePoint', '0599111102', 'support@mobilepoint.example'),
(3, 'HomeStore', '0599111103', 'info@homestore.example'),
(4, 'BookCorner', '0599111104', 'contact@bookcorner.example');

INSERT INTO Products (id, idVendor, name, price, quantity) VALUES
(1, 1, 'Wireless Mouse', 25.00, 60),
(2, 1, 'Mechanical Keyboard', 80.00, 35),
(3, 1, 'USB-C Hub', 40.00, 50),
(4, 2, 'Android Phone', 450.00, 12),
(5, 2, 'Bluetooth Earbuds', 60.00, 80),
(6, 2, 'Phone Case', 15.00, 120),
(7, 3, 'Desk Lamp', 35.00, 28),
(8, 3, 'Office Chair', 180.00, 15),
(9, 3, 'Water Bottle', 20.00, 90),
(10, 4, 'SQL Basics', 30.00, 40),
(11, 4, 'Python Guide', 45.00, 25),
(12, 4, 'Notebook', 8.00, 150);

INSERT INTO Categories (id, name, description) VALUES
(1, 'Electronics', 'Electronic devices'),
(2, 'Accessories', 'Device accessories'),
(3, 'Office', 'Office equipment'),
(4, 'Furniture', 'Home and office furniture'),
(5, 'Books', 'Educational books'),
(6, 'Stationery', 'Paper and writing supplies');

INSERT INTO ProductCategories (idCategories, idProducts) VALUES
(1, 1), (2, 1),
(1, 2), (3, 2),
(1, 3), (2, 3),
(1, 4),
(1, 5), (2, 5),
(2, 6),
(3, 7),
(3, 8), (4, 8),
(3, 9),
(5, 10),
(5, 11),
(6, 12);

INSERT INTO Orders (id, idCustomer, orderDate, status) VALUES
(1, 1, '2026-09-10 10:30:00', 'Delivered'),
(2, 2, '2026-09-13 14:20:00', 'Delivered'),
(3, 3, '2026-09-20 09:15:00', 'Delivered'),
(4, 4, '2026-09-26 17:00:00', 'Shipped'),
(5, 5, '2026-10-01 12:40:00', 'Processing'),
(6, 1, '2026-10-03 18:10:00', 'Pending'),
(7, 6, '2026-10-04 11:20:00', 'Delivered'),
(8, 2, '2026-10-06 16:45:00', 'Cancelled'),
(9, 3, '2026-10-12 13:30:00', 'Delivered'),
(10, 4, '2026-10-20 15:00:00', 'Delivered');

INSERT INTO OrderItems (id, idOrder, productId, quantity, unitPrice) VALUES
(1, 1, 1, 2, 22.00),
(2, 1, 2, 1, 75.00),
(3, 2, 4, 1, 480.00),
(4, 2, 6, 2, 12.00),
(5, 3, 8, 1, 170.00),
(6, 3, 7, 2, 30.00),
(7, 4, 5, 2, 55.00),
(8, 4, 3, 1, 38.00),
(9, 5, 11, 1, 45.00),
(10, 5, 10, 2, 30.00),
(11, 6, 4, 1, 450.00),
(12, 6, 6, 1, 15.00),
(13, 7, 10, 1, 30.00),
(14, 7, 12, 3, 8.00),
(15, 8, 2, 1, 80.00),
(16, 9, 1, 1, 25.00),
(17, 9, 9, 2, 20.00),
(18, 10, 7, 1, 35.00),
(19, 10, 11, 1, 45.00);

INSERT INTO Payments (id, idOrders, amount, status) VALUES
(1, 1, 119.00, 'Completed'),
(2, 2, 504.00, 'Completed'),
(3, 3, 230.00, 'Completed'),
(4, 4, 148.00, 'Completed'),
(5, 5, 105.00, 'Pending'),
(6, 6, 465.00, 'Pending'),
(7, 7, 54.00, 'Completed'),
(8, 8, 80.00, 'Failed'),
(9, 9, 65.00, 'Completed'),
(10, 10, 80.00, 'Completed');

INSERT INTO Shipments (id, idOrders, carrier, status, shippedAt, deliveredAt) VALUES
(1, 1, 'DHL', 'Delivered', '2026-09-11 08:00:00', '2026-09-13 15:20:00'),
(2, 2, 'Aramex', 'Delivered', '2026-09-14 09:00:00', '2026-09-16 13:30:00'),
(3, 3, 'DHL', 'Delivered', '2026-09-21 10:00:00', '2026-09-23 16:00:00'),
(4, 4, 'Aramex', 'Shipped', '2026-09-27 11:00:00', NULL),
(5, 7, 'DHL', 'Delivered', '2026-10-05 09:00:00', '2026-10-07 14:40:00'),
(6, 9, 'Aramex', 'Delivered', '2026-10-13 10:00:00', '2026-10-15 12:00:00'),
(7, 10, 'DHL', 'Delivered', '2026-10-21 08:30:00', '2026-10-23 17:15:00');

INSERT INTO Reviews (id, idProducts, idCustomer, comment, reviewDate, rating) VALUES
(1, 1, 1, 'Good mouse for daily use', '2026-09-15 12:00:00', 5),
(2, 2, 1, 'Nice keyboard', '2026-09-16 10:00:00', 4),
(3, 4, 2, 'Good phone', '2026-09-18 09:00:00', 5),
(4, 6, 2, 'Fits my phone', '2026-09-18 10:00:00', 4),
(5, 8, 3, 'Comfortable chair', '2026-09-25 11:00:00', 4),
(6, 7, 3, 'Useful desk lamp', '2026-09-26 15:00:00', 5),
(7, 10, 6, 'Easy to understand', '2026-10-09 13:00:00', 5),
(8, 1, 3, 'Works well', '2026-10-17 14:00:00', 4),
(9, 11, 4, 'Helpful examples', '2026-10-25 11:00:00', 5);

INSERT INTO PriceHistory (id, idProducts, price, changedAt) VALUES
(1, 1, 22.00, '2026-08-01 00:00:00'),
(2, 1, 25.00, '2026-10-01 00:00:00'),
(3, 2, 75.00, '2026-08-01 00:00:00'),
(4, 2, 80.00, '2026-10-01 00:00:00'),
(5, 3, 38.00, '2026-08-01 00:00:00'),
(6, 3, 40.00, '2026-10-01 00:00:00'),
(7, 4, 480.00, '2026-08-01 00:00:00'),
(8, 4, 450.00, '2026-10-01 00:00:00'),
(9, 5, 55.00, '2026-08-01 00:00:00'),
(10, 5, 60.00, '2026-10-01 00:00:00'),
(11, 6, 12.00, '2026-08-01 00:00:00'),
(12, 6, 15.00, '2026-10-01 00:00:00'),
(13, 7, 30.00, '2026-08-01 00:00:00'),
(14, 7, 35.00, '2026-10-01 00:00:00'),
(15, 8, 170.00, '2026-08-01 00:00:00'),
(16, 8, 180.00, '2026-10-01 00:00:00'),
(17, 9, 20.00, '2026-08-01 00:00:00'),
(18, 10, 28.00, '2026-08-01 00:00:00'),
(19, 10, 30.00, '2026-10-01 00:00:00'),
(20, 11, 42.00, '2026-08-01 00:00:00'),
(21, 11, 45.00, '2026-10-01 00:00:00'),
(22, 12, 8.00, '2026-08-01 00:00:00');

COMMIT;
