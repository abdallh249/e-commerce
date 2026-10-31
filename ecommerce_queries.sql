USE ECommerceDB;


SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    COUNT(o.id) AS NumberOfOrders
FROM Customers c
JOIN Orders o ON o.idCustomer = c.id
GROUP BY c.id, c.name
ORDER BY NumberOfOrders DESC, c.id;


SELECT
    p.id AS ProductId,
    p.name AS ProductName,
    v.name AS VendorName
FROM Products p
JOIN Vendors v ON v.id = p.idVendor
WHERE NOT EXISTS (
    SELECT 1
    FROM OrderItems oi
    WHERE oi.productId = p.id
)
ORDER BY p.id;


WITH DeliveredLines AS (
    SELECT
        p.idVendor,
        oi.idOrder,
        oi.quantity,
        oi.quantity * oi.unitPrice AS LineRevenue
    FROM OrderItems oi
    JOIN Orders o ON o.id = oi.idOrder
    JOIN Products p ON p.id = oi.productId
    WHERE o.status = 'Delivered'
)
SELECT
    v.id AS VendorId,
    v.name AS VendorName,
    COUNT(DISTINCT dl.idOrder) AS TotalOrders,
    COALESCE(SUM(dl.quantity), 0) AS TotalItemsSold,
    COALESCE(SUM(dl.LineRevenue), 0) AS TotalRevenue
FROM Vendors v
LEFT JOIN DeliveredLines dl ON dl.idVendor = v.id
GROUP BY v.id, v.name
ORDER BY TotalRevenue DESC, v.id;


SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    COUNT(DISTINCT o.id) AS TotalOrders,
    SUM(oi.quantity * oi.unitPrice) AS TotalSpent
FROM Customers c
JOIN Orders o ON o.idCustomer = c.id
JOIN OrderItems oi ON oi.idOrder = o.id
WHERE o.status = 'Delivered'
GROUP BY c.id, c.name
ORDER BY TotalSpent DESC, c.id
LIMIT 10;


SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    MAX(o.orderDate) AS LastOrderDate
FROM Customers c
JOIN Orders o ON o.idCustomer = c.id
GROUP BY c.id, c.name
HAVING MAX(o.orderDate) < NOW() - INTERVAL 90 DAY
ORDER BY LastOrderDate;


WITH ProductSales AS (
    SELECT
        p.id AS ProductId,
        p.idVendor,
        p.name AS ProductName,
        COALESCE(SUM(CASE
            WHEN o.id IS NOT NULL THEN oi.quantity
            ELSE 0
        END), 0) AS UnitsSold
    FROM Products p
    LEFT JOIN OrderItems oi ON oi.productId = p.id
    LEFT JOIN Orders o
        ON o.id = oi.idOrder AND o.status = 'Delivered'
    GROUP BY p.id, p.idVendor, p.name
)
SELECT
    v.name AS VendorName,
    ps.ProductName,
    ps.UnitsSold
FROM ProductSales ps
JOIN Vendors v ON v.id = ps.idVendor
WHERE NOT EXISTS (
    SELECT 1
    FROM ProductSales higher
    WHERE higher.idVendor = ps.idVendor
      AND higher.UnitsSold > ps.UnitsSold
)
ORDER BY v.name, ps.ProductName;


SELECT
    c.name AS CategoryName,
    p.name AS ProductName,
    p.price AS Price
FROM Categories c
JOIN ProductCategories pc ON pc.idCategories = c.id
JOIN Products p ON p.id = pc.idProducts
WHERE (
    SELECT COUNT(DISTINCT p2.price)
    FROM ProductCategories pc2
    JOIN Products p2 ON p2.id = pc2.idProducts
    WHERE pc2.idCategories = c.id
      AND p2.price > p.price
) = 1
ORDER BY c.name, p.name;


SELECT
    p1.name AS ProductA,
    p2.name AS ProductB,
    COUNT(DISTINCT oi1.idOrder) AS TimesBoughtTogether
FROM OrderItems oi1
JOIN OrderItems oi2
    ON oi2.idOrder = oi1.idOrder
    AND oi1.productId < oi2.productId
JOIN Products p1 ON p1.id = oi1.productId
JOIN Products p2 ON p2.id = oi2.productId
GROUP BY p1.id, p1.name, p2.id, p2.name
ORDER BY TimesBoughtTogether DESC, ProductA, ProductB;


WITH MonthlyRevenue AS (
    SELECT
        CAST(DATE_FORMAT(o.orderDate, '%Y-%m-01') AS DATE) AS MonthStart,
        SUM(oi.quantity * oi.unitPrice) AS Revenue
    FROM Orders o
    JOIN OrderItems oi ON oi.idOrder = o.id
    WHERE o.status = 'Delivered'
    GROUP BY CAST(DATE_FORMAT(o.orderDate, '%Y-%m-01') AS DATE)
)
SELECT
    YEAR(m.MonthStart) AS `Year`,
    MONTH(m.MonthStart) AS `Month`,
    m.Revenue,
    COALESCE(prev.Revenue, 0) AS PreviousMonthRevenue,
    CASE
        WHEN prev.Revenue IS NULL OR prev.Revenue = 0 THEN NULL
        ELSE ROUND(100 * (m.Revenue - prev.Revenue) / prev.Revenue, 2)
    END AS GrowthPercentage
FROM MonthlyRevenue m
LEFT JOIN MonthlyRevenue prev
    ON prev.MonthStart = DATE_SUB(m.MonthStart, INTERVAL 1 MONTH)
ORDER BY m.MonthStart;


WITH DeliveredLines AS (
    SELECT
        p.idVendor,
        oi.productId,
        oi.idOrder,
        oi.quantity * oi.unitPrice AS LineRevenue
    FROM OrderItems oi
    JOIN Orders o ON o.id = oi.idOrder AND o.status = 'Delivered'
    JOIN Products p ON p.id = oi.productId
),
VendorSales AS (
    SELECT
        idVendor,
        SUM(LineRevenue) AS TotalRevenue,
        COUNT(DISTINCT idOrder) AS OrderCount
    FROM DeliveredLines
    GROUP BY idVendor
),
UnsoldProducts AS (
    SELECT p.idVendor, COUNT(*) AS UnsoldProductCount
    FROM Products p
    LEFT JOIN (
        SELECT DISTINCT productId FROM DeliveredLines
    ) sold ON sold.productId = p.id
    WHERE sold.productId IS NULL
    GROUP BY p.idVendor
),
VendorRatings AS (
    SELECT p.idVendor, AVG(r.rating) AS AvgRating
    FROM Reviews r
    JOIN Products p ON p.id = r.idProducts
    GROUP BY p.idVendor
)
SELECT
    v.name AS VendorName,
    COALESCE(s.TotalRevenue, 0) AS TotalRevenue,
    COALESCE(ROUND(s.TotalRevenue / NULLIF(s.OrderCount, 0), 2), 0) AS AverageOrderValue,
    COALESCE(s.OrderCount, 0) AS OrderCount,
    ROUND(r.AvgRating, 2) AS AvgRating,
    COALESCE(u.UnsoldProductCount, 0) AS UnsoldProductCount
FROM Vendors v
LEFT JOIN VendorSales s ON s.idVendor = v.id
LEFT JOIN UnsoldProducts u ON u.idVendor = v.id
LEFT JOIN VendorRatings r ON r.idVendor = v.id
ORDER BY TotalRevenue DESC, v.name;


WITH CustomerSpending AS (
    SELECT
        c.id AS CustomerId,
        c.name AS CustomerName,
        COALESCE(SUM(oi.quantity * oi.unitPrice), 0) AS TotalSpent
    FROM Customers c
    LEFT JOIN Orders o
        ON o.idCustomer = c.id AND o.status = 'Delivered'
    LEFT JOIN OrderItems oi ON oi.idOrder = o.id
    GROUP BY c.id, c.name
)
SELECT
    cs.CustomerId,
    cs.CustomerName,
    cs.TotalSpent,
    1 + (
        SELECT COUNT(*)
        FROM CustomerSpending higher
        WHERE higher.TotalSpent > cs.TotalSpent
    ) AS CustomerRank
FROM CustomerSpending cs
ORDER BY CustomerRank, cs.CustomerId;


WITH ProductSales AS (
    SELECT
        oi.productId,
        SUM(oi.quantity) AS UnitsSold,
        SUM(oi.quantity * oi.unitPrice) AS Revenue
    FROM OrderItems oi
    JOIN Orders o ON o.id = oi.idOrder
    WHERE o.status = 'Delivered'
    GROUP BY oi.productId
)
SELECT
    c.id AS CategoryId,
    c.name AS CategoryName,
    COALESCE(SUM(ps.UnitsSold), 0) AS TotalItemsSold,
    COALESCE(SUM(ps.Revenue), 0) AS TotalRevenue
FROM Categories c
LEFT JOIN ProductCategories pc ON pc.idCategories = c.id
LEFT JOIN ProductSales ps ON ps.productId = pc.idProducts
GROUP BY c.id, c.name
ORDER BY c.id;


WITH ProductSales AS (
    SELECT
        p.id AS ProductId,
        p.idVendor,
        p.name AS ProductName,
        COALESCE(SUM(CASE
            WHEN o.id IS NOT NULL THEN oi.quantity
            ELSE 0
        END), 0) AS UnitsSold
    FROM Products p
    LEFT JOIN OrderItems oi ON oi.productId = p.id
    LEFT JOIN Orders o
        ON o.id = oi.idOrder AND o.status = 'Delivered'
    GROUP BY p.id, p.idVendor, p.name
)
SELECT
    v.name AS VendorName,
    ps.ProductName,
    ps.UnitsSold,
    1 + (
        SELECT COUNT(*)
        FROM ProductSales higher
        WHERE higher.idVendor = ps.idVendor
          AND higher.UnitsSold > ps.UnitsSold
    ) AS ProductRank
FROM ProductSales ps
JOIN Vendors v ON v.id = ps.idVendor
ORDER BY v.name, ProductRank, ps.ProductName;


SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    YEAR(o.orderDate) AS `Year`,
    MONTH(o.orderDate) AS `Month`,
    SUM(oi.quantity * oi.unitPrice) AS MonthlySpent
FROM Customers c
JOIN Orders o ON o.idCustomer = c.id
JOIN OrderItems oi ON oi.idOrder = o.id
WHERE o.status = 'Delivered'
GROUP BY c.id, c.name, YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY c.id, `Year`, `Month`;


WITH OriginalPrices AS (
    SELECT
        ph.idProducts AS ProductId,
        ph.price AS OriginalPrice
    FROM PriceHistory ph
    WHERE NOT EXISTS (
        SELECT 1
        FROM PriceHistory earlier
        WHERE earlier.idProducts = ph.idProducts
          AND (
              earlier.changedAt < ph.changedAt
              OR (earlier.changedAt = ph.changedAt AND earlier.id < ph.id)
          )
    )
)
SELECT
    p.id AS ProductId,
    p.name AS ProductName,
    op.OriginalPrice,
    p.price AS CurrentPrice,
    p.price - op.OriginalPrice AS PriceDifference
FROM Products p
JOIN OriginalPrices op ON op.ProductId = p.id
WHERE p.price <> op.OriginalPrice
   OR EXISTS (
       SELECT 1
       FROM PriceHistory ph
       WHERE ph.idProducts = p.id
         AND ph.price <> op.OriginalPrice
   )
ORDER BY p.id;


SELECT
    p.id AS ProductId,
    p.name AS ProductName,
    v.name AS VendorName,
    p.quantity AS CurrentStock
FROM Products p
JOIN Vendors v ON v.id = p.idVendor
WHERE p.quantity < 10
ORDER BY p.quantity, p.id;


SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    COUNT(DISTINCT DATE_FORMAT(o.orderDate, '%Y-%m')) AS NumberOfMonthsWithOrders
FROM Customers c
JOIN Orders o ON o.idCustomer = c.id
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT DATE_FORMAT(o.orderDate, '%Y-%m')) >= 2
ORDER BY NumberOfMonthsWithOrders DESC, c.id;


WITH CustomerMonths AS (
    SELECT DISTINCT
        o.idCustomer,
        CAST(DATE_FORMAT(o.orderDate, '%Y-%m-01') AS DATE) AS MonthStart
    FROM Orders o
    WHERE o.status = 'Delivered'
)
SELECT
    c.id AS CustomerId,
    c.name AS CustomerName,
    DATE_FORMAT(firstMonth.MonthStart, '%Y-%m') AS FirstMonth,
    DATE_FORMAT(secondMonth.MonthStart, '%Y-%m') AS SecondMonth
FROM CustomerMonths firstMonth
JOIN CustomerMonths secondMonth
    ON secondMonth.idCustomer = firstMonth.idCustomer
   AND secondMonth.MonthStart = DATE_ADD(firstMonth.MonthStart, INTERVAL 1 MONTH)
JOIN Customers c ON c.id = firstMonth.idCustomer
ORDER BY c.id, FirstMonth;


WITH ProductSales AS (
    SELECT
        oi.productId,
        SUM(oi.quantity) AS UnitsSold,
        SUM(oi.quantity * oi.unitPrice) AS Revenue
    FROM OrderItems oi
    JOIN Orders o ON o.id = oi.idOrder AND o.status = 'Delivered'
    GROUP BY oi.productId
),
ProductRatings AS (
    SELECT idProducts AS ProductId, AVG(rating) AS AverageRating
    FROM Reviews
    GROUP BY idProducts
)
SELECT
    c.name AS CategoryName,
    COUNT(pc.idProducts) AS ProductCount,
    COALESCE(SUM(ps.UnitsSold), 0) AS UnitsSold,
    COALESCE(SUM(ps.Revenue), 0) AS Revenue,
    ROUND(AVG(pr.AverageRating), 2) AS AvgRating
FROM Categories c
LEFT JOIN ProductCategories pc ON pc.idCategories = c.id
LEFT JOIN ProductSales ps ON ps.productId = pc.idProducts
LEFT JOIN ProductRatings pr ON pr.ProductId = pc.idProducts
GROUP BY c.id, c.name
ORDER BY Revenue DESC, c.name;


WITH ProductSales AS (
    SELECT
        p.id AS ProductId,
        p.idVendor,
        COALESCE(SUM(CASE
            WHEN o.id IS NOT NULL THEN oi.quantity ELSE 0
        END), 0) AS UnitsSold,
        COALESCE(SUM(CASE
            WHEN o.id IS NOT NULL THEN oi.quantity * oi.unitPrice ELSE 0
        END), 0) AS Revenue
    FROM Products p
    LEFT JOIN OrderItems oi ON oi.productId = p.id
    LEFT JOIN Orders o
        ON o.id = oi.idOrder AND o.status = 'Delivered'
    GROUP BY p.id, p.idVendor
),
VendorProductTotals AS (
    SELECT
        idVendor,
        SUM(Revenue) AS TotalRevenue,
        SUM(UnitsSold) AS TotalUnits,
        SUM(CASE WHEN UnitsSold = 0 THEN 1 ELSE 0 END) AS UnsoldCount
    FROM ProductSales
    GROUP BY idVendor
),
VendorOrders AS (
    SELECT
        p.idVendor,
        COUNT(DISTINCT o.id) AS CompletedOrderCount
    FROM Products p
    JOIN OrderItems oi ON oi.productId = p.id
    JOIN Orders o ON o.id = oi.idOrder
    WHERE o.status = 'Delivered'
    GROUP BY p.idVendor
),
VendorRatings AS (
    SELECT p.idVendor, AVG(r.rating) AS AvgRating
    FROM Products p
    JOIN Reviews r ON r.idProducts = p.id
    GROUP BY p.idVendor
)
SELECT
    v.name AS VendorName,
    COALESCE(t.TotalRevenue, 0) AS TotalRevenue,
    COALESCE(ROUND(t.TotalRevenue / NULLIF(vo.CompletedOrderCount, 0), 2), 0) AS AvgOrderValue,
    COALESCE(vo.CompletedOrderCount, 0) AS CompletedOrderCount,
    COALESCE(t.TotalUnits, 0) AS TotalUnits,
    ROUND(vr.AvgRating, 2) AS AvgRating,
    COALESCE(t.UnsoldCount, 0) AS UnsoldCount
FROM Vendors v
LEFT JOIN VendorProductTotals t ON t.idVendor = v.id
LEFT JOIN VendorOrders vo ON vo.idVendor = v.id
LEFT JOIN VendorRatings vr ON vr.idVendor = v.id
ORDER BY TotalRevenue DESC, v.name;
