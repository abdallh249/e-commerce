CREATE DATABASE IF NOT EXISTS ECommerceDB;
USE ECommerceDB;

CREATE TABLE Customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phoneNumber VARCHAR(20)
);

CREATE TABLE CustomerAddresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCustomer INT NOT NULL,
    country VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    FOREIGN KEY (idCustomer) REFERENCES Customers(id)
);

CREATE TABLE CustomerProfiles (
    id INT PRIMARY KEY,
    dateOfBirth DATE,
    profileImage VARCHAR(255),
    FOREIGN KEY (id) REFERENCES Customers(id)
);

CREATE TABLE Vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phoneNumber VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idVendor INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (idVendor) REFERENCES Vendors(id),
    CHECK (price >= 0),
    CHECK (quantity >= 0)
);

CREATE TABLE Categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE ProductCategories (
    idCategories INT NOT NULL,
    idProducts INT NOT NULL,
    PRIMARY KEY (idCategories, idProducts),
    FOREIGN KEY (idCategories) REFERENCES Categories(id),
    FOREIGN KEY (idProducts) REFERENCES Products(id)
);

CREATE TABLE Orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCustomer INT NOT NULL,
    orderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (idCustomer) REFERENCES Customers(id),
    CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE OrderItems (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idOrder INT NOT NULL,
    productId INT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (idOrder) REFERENCES Orders(id),
    FOREIGN KEY (productId) REFERENCES Products(id),
    UNIQUE (idOrder, productId),
    CHECK (quantity > 0),
    CHECK (unitPrice >= 0)
);

CREATE TABLE Payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idOrders INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (idOrders) REFERENCES Orders(id),
    CHECK (amount > 0),
    CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);

CREATE TABLE Shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idOrders INT NOT NULL,
    carrier VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    shippedAt DATETIME,
    deliveredAt DATETIME,
    FOREIGN KEY (idOrders) REFERENCES Orders(id),
    CHECK (status IN ('Pending', 'Shipped', 'Delivered', 'Returned')),
    CHECK (deliveredAt IS NULL OR (shippedAt IS NOT NULL AND deliveredAt >= shippedAt))
);

CREATE TABLE Reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idProducts INT NOT NULL,
    idCustomer INT NOT NULL,
    comment TEXT,
    reviewDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rating INT NOT NULL,
    FOREIGN KEY (idProducts) REFERENCES Products(id),
    FOREIGN KEY (idCustomer) REFERENCES Customers(id),
    CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE PriceHistory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idProducts INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    changedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idProducts) REFERENCES Products(id),
    CHECK (price >= 0)
);

CREATE INDEX idx_orders_customer_date ON Orders(idCustomer, orderDate);
CREATE INDEX idx_products_vendor_name ON Products(idVendor, name);
CREATE INDEX idx_reviews_product_rating ON Reviews(idProducts, rating);
CREATE INDEX idx_pricehistory_product_date ON PriceHistory(idProducts, changedAt);
