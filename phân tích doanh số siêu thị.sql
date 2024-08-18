--tao bang de nhap du lieu tu file csv--
CREATE TABLE supermarket_sales (
    Invoice_ID VARCHAR(20),
    Branch VARCHAR(10),
    City VARCHAR(50),
    Customer_Type VARCHAR(50),
    Gender VARCHAR(10),
    Product_Line VARCHAR(50),
    Unit_Price DECIMAL(10, 2),
    Quantity INT,
    Tax DECIMAL(10, 2),
    Total DECIMAL(10, 2),
    Date DATE,
    Time TIME,
    Payment VARCHAR(20),
    COGS DECIMAL(10, 2),
    Gross_Margin_Percentage DECIMAL(5, 2),
    Gross_Income DECIMAL(10, 2),
    Rating DECIMAL(3, 1)
);
Create table customer(
	Customer_ID VARCHAR(100),
	Customer_Type VARCHAR(50),
	Gender VARCHAR(10)
);

create table products(
	Product_ID VARCHAR(50),
	Product_Line VARCHAR(50),
	Unit_price DECIMAL(10,2)
);

create table Branch (
	Branch_ID VARCHAR(10),
	Branch VARCHAR(10),
	City VARCHAR(50)
);

create table dates(
	Date date,
	Day int,
	month int,
	year int,
	weekday int
);

create table fact_sales(
	Invoice_ID VARCHAR(20),
	Unit_Price DECIMAL(10,2),
	Quantity int,
	Tax DECIMAL(10,2),
	Total DECIMAL(10,2),
	Date date,
	Times time,
	Payment VARCHAR(20),
	COGS DECIMAL(10,2),
	Gross_Margin_Percentage DECIMAL(5,2),
	Gross_Incomes DECIMAL(10,2),
	Rating DECIMAL(3,1),
	Customer_ID VARCHAR(100),
	Customer_Type VARCHAR(50),
	Gender VARCHAR(10),
	Product_ID VARCHAR(50),
	Branch_ID VARCHAR(10)
);

create table times(
	Time time,
	Hour int,
	minute int
);

--clean data--
--kiểm tra các gia trị null--
--kiểm tra các giá trị dương--
--chuyển đổi ngày,giờ về đúng định dạng--
SELECT *
FROM fact_sales;

UPDATE fact_sales
SET Rating = (SELECT AVG(Rating) FROM fact_sales)
WHERE Rating IS NULL;

UPDATE fact_sales
SET Total = ABS(Total) --Hàm ABS trả về trị tuyệt đối của 1 số--
WHERE Total < 0;

UPDATE fact_sales 
SET Date = DATE(date, 'YYYY-MM-DD');

UPDATE fact_sales
SET Time = TIMESTAMP(Time, 'HH24:MI:SS')::TIME;

--Business Case: Phân tích doanh số siêu thị--
/* Mục tiêu: Phân tích dữ liệu bán hàng để 
	+) xác định xu hướng bán hàng
	+) hiểu hành vi của khách hàng
	+) tối ưu hóa hàng tồn kho và chiến lược tiếp thị 
*/
/* 
Invoice_ID: Mã số nhận dạng hóa đơn bán hàng do máy tính tạo ra.
Branch: Chi nhánh của siêu thị (có 3 chi nhánh được xác định bằng A, B và C).
City: Vị trí của siêu thị.
Customer_type: 
	- Không phải là thành viên(Normal)
	- Là thành viên(Member)
Gender: Loại khách hàng theo giới tính.
Product_line: Nhóm phân loại mặt hàng chung 
	- Phụ kiện điện tử, 
	- Phụ kiện thời trang, 
	- Thực phẩm và đồ uống, 
	- Sức khỏe và sắc đẹp, 
	- Nhà cửa và phong cách sống, 
	- Thể thao và du lịch.
Unit_price: Giá của từng sản phẩm tính bằng đô la.
Quantity: Số lượng sản phẩm mà khách hàng đã mua.
Tax: Phí thuế 5% cho khách hàng mua.
Total: Tổng giá đã bao gồm thuế.
Date: Ngày mua (Có thể ghi lại từ tháng 1 năm 2019 đến tháng 3 năm 2019).
Times: Thời gian mua hàng (10 giờ sáng đến 9 giờ tối).
Payment: Khách hàng sử dụng phương thức thanh toán để mua hàng 
(có 3 phương thức thanh toán 
	– Tiền mặt, 
	- Thẻ tín dụng 
	- Ví điện tử).
COGS: Giá vốn hàng bán.
Đây là chi phí trực tiếp liên quan đến việc sản xuất hàng hóa mà công ty đã bán trong một khoảng thời gian nhất định. 
COGS bao gồm chi phí nguyên liệu, lao động và các chi phí trực tiếp khác liên quan đến sản xuất hàng hóa.

Gross_Margin_Pencntage: Tỷ lệ biên lợi nhuận gộp.
Đây là tỷ lệ phần trăm của Gross Income so với tổng doanh thu. 
Nó cho thấy mức độ hiệu quả của công ty trong việc tạo ra lợi nhuận từ doanh thu bán hàng. 
Tỷ lệ này càng cao, công ty càng có khả năng tạo ra lợi nhuận cao từ doanh thu.

Gross_incomes: Thu nhập gộp.Đây là lợi nhuận còn lại sau khi trừ đi COGS từ doanh thu. 
Gross Income cho thấy mức độ hiệu quả của công ty trong việc quản lý chi phí sản xuất và bán hàng.

Rating: Xếp hạng phân tầng khách hàng về trải nghiệm mua sắm tổng thể của họ 
(Theo thang điểm từ 1 đến 10).
*/

--tổng doanh số theo sản phẩm--
SELECT Product_Line, SUM(Total) AS Total_Sales
FROM Products
JOIN Fact_sales
ON Products.Product_ID = Fact_sales.Product_ID
GROUP BY Product_Line;

--doanh số theo chi nhánh--
SELECT Branch,City, SUM(Total) AS Total_sales
FROM Branch
JOIN Fact_sales
ON Branch.Branch_ID = Fact_sales.Branch_ID
GROUP BY Branch,City;

-- doanh số theo phương thức thanh toán--
SELECT Payment, SUM(Total) AS Total_Sales
FROM Fact_sales
GROUP BY Payment;

--doanh số theo tháng của các cửa hàng--
SELECT Branch, City, Month_date, SUM(Total_Month) 
FROM(SELECT Branch, City, DATE_PART('Month', date) AS Month_date, SUM(Total) AS Total_Month
FROM Fact_sales
JOIN Branch
ON Fact_sales.Branch_ID = Branch.Branch_ID
GROUP BY date, Branch, City
ORDER BY Month_date DESC)
WHERE Branch IN('A','B','C')
GROUP BY Month_date,Branch,City
ORDER BY Branch;
	
--Giờ và ngày bán hàng cao điểm--
SELECT date,SUM(Total) AS Total_date
From Fact_sales
GROUP BY date
ORDER BY total_date DESC;

SELECT times, SUM(Total) AS Total_time
FROM Fact_sales
GROUP BY times
ORDER BY Total_time DESC;
	
--đánh giá trung bình của khách hàng đối với mỗi chi nhánh--
SELECT Branch, City, AVG(Rating) AS AVG_Rating
FROM Branch
JOIN Fact_sales
ON Branch.Branch_ID = Fact_sales.Branch_ID
GROUP BY Branch,City;

SELECT month_date, SUM(SUM_Quantity)
FROM(SELECT DATE_PART('Month', date) as month_date, SUM(Quantity) AS SUM_Quantity
FROM supermarket_sales
GROUP BY date)
GROUP BY month_date

--lợi nhuận biên của các cửa hàng trong 3 tháng đầu--
SELECT Branch, SUM(SUM_gross_margin) AS SUM_gross_margin_ABC
FROM(SELECT Branch, DATE_PART('Month',date) AS Month_date, SUM(Gross_Margin_Percentage) AS SUM_gross_margin
FROM supermarket_sales
WHERE Branch IN('A','B','C')
GROUP BY Branch, date
ORDER BY Month_date)
GROUP BY Branch

--lợi nhuận sản phẩm trong 3 tháng đầu 2019 theo chi nhánh--
WITH T1 AS(
	SELECT 
		Products.Product_Line AS san_pham, 
		Branch.Branch AS chi_nhanh,
		Branch.City AS thanh_pho,
		SUM(fact_sales.gross_incomes) AS loi_nhuan
	FROM fact_sales
	JOIN Products
	ON Products.Product_ID = fact_sales.Product_ID
	JOIN Branch
	ON Branch.Branch_ID = fact_sales.Branch_ID
	GROUP BY san_pham,chi_nhanh,thanh_pho
)

SELECT san_pham, chi_nhanh, thanh_pho, loi_nhuan
FROM T1
ORDER BY chi_nhanh, loi_nhuan;
/* insight: lợi nhuận theo sản phẩm tại các chi nhánh là khác nhau
	- Chi nhánh C(Tp.Naypyitaw): lợi nhuận của "Food and beverages" là cao nhất 
	trong khi đó lợi nhuận của "Home and lifestyle" lại thấp nhất. Sự chênh lệch lợi nhuận
	giữa các mặt hàng là khá lớn.
	- Chi nhánh B(Tp.Mandalay): lợi nhuận của "Sports and travel" là cao nhất 
	trong khi đó lợi nhuận của "Food and beverages" lại thấp nhất.Tuy nhiên, sự chênh lệch
	lợi nhuận giữa các mặt hàng là không quá lớn.
	- Chi nhánh A(Tp.Yangon): lợi nhuận của "Home and lifestyle" là cao nhất 
	trong khi đó lợi nhuận của "Health and beauty" lại thấp nhất.Tuy nhiên, sự chênh lệch
	lợi nhuận giữa các mặt hàng là không quá lớn nhưng lại có sự chênh lệch đáng kể giữa 2 nhóm
	hàng xếp cuối.

=> sự không đồng nhất về lợi nhuận theo sản phẩm này có thể là do vị trí địa lý của từng khu vực 
đặt chi nhánh dẫn đến nhu cầu mua hàng của khách hàng là khác nhau
*/

WITH T1 AS(
	SELECT 
		Products.Product_Line AS san_pham, 
		Branch.Branch AS chi_nhanh,
		Branch.City AS thanh_pho,
		DATE_PART('Month',fact_sales.date) AS thang,
		fact_sales.times AS thoi_gian,
		SUM(fact_sales.gross_incomes) AS loi_nhuan
	FROM fact_sales
	JOIN Products
	ON Products.Product_ID = fact_sales.Product_ID
	JOIN Branch
	ON Branch.Branch_ID = fact_sales.Branch_ID
	GROUP BY san_pham,chi_nhanh,thanh_pho, thoi_gian, thang
	ORDER BY loi_nhuan DESC
),

	T2 AS (
	SELECT 
		san_pham, 
		chi_nhanh, 
		thanh_pho,
		thang,
		thoi_gian,
		loi_nhuan,
		ROW_NUMBER() OVER (PARTITION BY chi_nhanh, thang ORDER BY loi_nhuan DESC) AS rn
	FROM T1
)

SELECT 
    T2.san_pham, 
    T2.chi_nhanh, 
    T2.thanh_pho, 
    T2.thang,
    T2.thoi_gian,
    T2.loi_nhuan
FROM T2
WHERE T2.rn = 1
ORDER BY T2.chi_nhanh, T2.thang;

WITH T1 AS (
    SELECT 
        Products.Product_Line AS san_pham, 
        Branch.Branch AS chi_nhanh,
        Branch.City AS thanh_pho,
        DATE_PART('Month', fact_sales.date) AS thang,
        fact_sales.times AS thoi_gian,
        SUM(fact_sales.gross_incomes) AS loi_nhuan
    FROM fact_sales
    JOIN Products ON Products.Product_ID = fact_sales.Product_ID
    JOIN Branch ON Branch.Branch_ID = fact_sales.Branch_ID
    GROUP BY san_pham, chi_nhanh, thanh_pho, thoi_gian, thang
),

T2 AS (
    SELECT 
        san_pham, 
        chi_nhanh, 
        thanh_pho, 
        CONCAT('Thang ', thang, ' ', thoi_gian) AS thang_thoigian, 
        loi_nhuan
    FROM T1
)

SELECT 
    T2.san_pham, 
    T2.chi_nhanh, 
    T2.thanh_pho, 
    T2.thang_thoigian, 
    T2.loi_nhuan
FROM T2
WHERE T2.thang_thoigian LIKE 'Thang 1%' 
  AND T2.chi_nhanh = 'A'
ORDER BY T2.thang_thoigian;



