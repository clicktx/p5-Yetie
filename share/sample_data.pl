(
    # Payment Method
    'PaymentMethod' => [
        [qw/id name/],
        [ 1, 'Bank Transfer Payment' ],
        [ 2, 'Paypal' ],
        [ 3, 'Cash On Delivery Payment' ],
        [ 4, 'Credit Card' ],
    ],

    # Category
    'Category' => [
        [qw/id root_id lft rgt level title/],
        [ 1,  1,  1,  6,  0, 'Sports' ],
        [ 2,  2,  1,  22, 0, 'Fashion' ],
        [ 3,  1,  2,  3,  1, 'Golf' ],
        [ 4,  1,  4,  5,  1, 'Soccer' ],
        [ 5,  2,  2,  13, 1, 'Women' ],
        [ 6,  2,  14, 15, 1, 'Men' ],
        [ 7,  2,  16, 17, 1, 'Girls' ],
        [ 8,  2,  18, 19, 1, 'Boys' ],
        [ 9,  2,  20, 21, 1, 'Baby' ],
        [ 10, 2,  3,  12, 2, 'Clothing' ],
        [ 11, 2,  4,  9,  3, 'Dresses' ],
        [ 12, 2,  10, 11, 3, 'Tops & Tees' ],
        [ 13, 2,  5,  6,  4, 'Casual' ],
        [ 14, 2,  7,  8,  4, 'Formal' ],
        [ 15, 15, 1, 10,  0, 'Foods' ],
        [ 16, 15, 2,  5,  1, 'Drinks' ],
        [ 17, 15, 3,  4,  2, 'Milk' ],
        [ 18, 15, 6,  9,  1, 'Alcoholic Drinks' ],
        [ 19, 15, 7,  8,  2, 'Beer' ],
    ],

    # Product
    'Product' => [
        [qw/id title description price created_at updated_at/],
        [ 1,  'test product1',  'product description1', 100, '2017-08-23 23:47:04', '2017-08-23 23:47:04' ],
        [ 2,  'test product2',  'product description2', 200, '2017-08-23 23:55:12', '2017-08-23 23:55:12' ],
        [ 3,  'test product3',  'product description',  300, '2017-08-23 23:59:35', '2017-08-23 23:59:35' ],
        [ 4,  'test product4',  'product description',  333, '2017-08-24 01:01:11', '2017-08-24 01:01:11' ],
        [ 5,  'test product5',  'product description',  333, '2017-08-24 01:01:35', '2017-08-24 01:01:35' ],
        [ 6,  'test product6',  'product description',  333, '2017-08-24 01:02:02', '2017-08-24 01:02:02' ],
        [ 7,  'test product7',  'product description',  333, '2017-08-24 01:02:21', '2017-08-24 01:02:21' ],
        [ 8,  'test product8',  'product description',  333, '2017-08-24 01:02:34', '2017-08-24 01:02:34' ],
        [ 9,  'test product9',  'product description',  333, '2017-08-24 01:02:45', '2017-08-24 01:02:45' ],
        [ 10, 'test product10', 'product description',  2.50, '2017-08-24 01:02:56', '2017-08-24 01:02:56' ],
    ],

    # Product Category
    'ProductCategory' => [
        [qw/product_id category_id is_primary/],
        [ 1, 3,  1 ],
        [ 1, 5,  0 ],
        [ 2, 17, 1 ],
        [ 3, 19, 1 ],
        [ 4, 4,  1 ],
        [ 5, 4,  1 ],
    ],

    # Tax rules
    'TaxRule' => [
        [ qw/id title tax_rate/],
        [ 2, 'Tax 3.141%', 3.141 ],
        [ 3, 'Tax 5%', 5 ],
        [ 4, 'Tax 8%', 8 ],
        [ 5, 'Reduced Tax 8%', 8 ],
        [ 6, 'Tax 10%', 10 ],
    ],

    # Default tax rules
    'CommonTaxRule' => [
        [qw/tax_rule_id start_at/],
        [ 2, '1990-04-01 00:00:00' ],
        [ 3, '1997-04-01 00:00:00' ],
        [ 6, '2100-04-01 00:00:00' ],
    ],

    # Category tax rules
    'CategoryTaxRule' => [
        [qw/category_id tax_rule_id start_at/],
        [ 15, 3, '1990-04-01 00:00:00' ],
        [ 15, 4, '1997-04-01 00:00:00' ],
        [ 15, 5, '2014-04-01 00:00:00' ],
        [ 15, 6, '2019-10-01 00:00:00' ],
        [ 18, 4, '1997-04-01 00:00:00' ],
        [ 18, 6, '2014-04-01 00:00:00' ],
    ],

    # For Accounts
    'Email' => [
        [qw/id address is_verified/],
        [ 1, 'a@example.org', 1 ],
        [ 2, 'b@example.org', 1 ],
        [ 3, 'c@example.org', 1 ],
        [ 4, 'd@example.org', 1 ],
        [ 5, 'e@example.org', 1 ],
        [ 6, 'f@example.org', 0 ],
        [ 7, 'g@example.org', 0 ],
    ],
    'Address' => [
        [qw/id country_code line1 line2 city state postal_code personal_name organization phone hash/],
        [ 1, 'us', '42 Pendergast St.', '', 'Piedmont', 'SC', '29673', 'Elizabeth T. Peoples', 'Eli Moore Inc', '3059398498', '0b90c0a64c2707e1800496c19c0c9ac9007e43a4' ],
        [ 2, 'us', '7004 Tunnel St.', '', 'New Brunswick', 'NJ', '08901', 'Craig M. Hise', 'Big Apple', '8037671849', '0906eeef01993c1d8ba6139bd4ac158f5e2d07db' ],
        [ 3, 'us', '803 Wild Rose St.', '', 'Woodstock', 'GA', '30188', 'Mary R. Johnson', '', '8047441468', 'd8baab85056cc63e3f1bfa732fd89c4a88bb1bee' ],
        [ 4, 'us', '906 Pearl Ave.', '', 'Patchogue', 'NY', '11772', 'Albert B. Hastings', 'Twin Food Stores', '7089871400', '795c42ec23f5e0830a0918bc43de02da854c56d8' ],
        [ 5, 'jp', '北多久町 4-2-4', 'リバーサイド室瀬212', '多久市', '佐賀県', '8460001', '沢井 咲', '株式会社 フィーデザイン', '09054172962', '74a801e45ce2d7048138e733232177ab0f1d71e8' ],
    ],

    # Password
    'Password' => [
        [qw/id hash created_at/],
        # Staff
        # 12345678
        [ 1, 'SCRYPT:16384:8:1:+u8IxV+imJ1wVnZqwMQn8lO5NWozQZJesUTI8P+LGNQ=:FxG/e03NIEGMaEoF5qWNCPeR1ULu+UTfhYrJ2cbIPp4=', '2017-05-01 20:50:25' ],
        # 44556677
        [ 2, 'SCRYPT:16384:8:1:waCmMNvB2R8Al+WUeJmVxRqn32RfcyZaG0QHoqB+Sjs=:N11GEz66NK2xOmsE6imxtQmHxaKV8c32hgL1mTvWJnY=', '2017-05-02 22:31:17' ],
        # 12345678
        [ 3, 'SCRYPT:16384:8:1:+u8IxV+imJ1wVnZqwMQn8lO5NWozQZJesUTI8P+LGNQ=:FxG/e03NIEGMaEoF5qWNCPeR1ULu+UTfhYrJ2cbIPp4=', '2017-05-03 20:50:25' ],

        # Customer
        # 44556677
        [ 4, 'SCRYPT:16384:8:1:waCmMNvB2R8Al+WUeJmVxRqn32RfcyZaG0QHoqB+Sjs=:N11GEz66NK2xOmsE6imxtQmHxaKV8c32hgL1mTvWJnY=', '2017-07-07 08:01:02' ],
        # 22334455
        [ 5, 'SCRYPT:16384:8:1:VGcabum1/mW1UQ207AZL4Abdj96TtHYtFWJRjBIuYv8=:5lLK4OF1oG9mdI9G89hgh4kvcXJ8jVnCqIAy8QXwluE=', '2017-07-08 07:02:15' ],
        # 12345678
        [ 6, 'SCRYPT:16384:8:1:+u8IxV+imJ1wVnZqwMQn8lO5NWozQZJesUTI8P+LGNQ=:FxG/e03NIEGMaEoF5qWNCPeR1ULu+UTfhYrJ2cbIPp4=', '2017-07-09 19:50:05' ],
    ],

    # Staffs
    'Staff' => [
        [qw/id login_id created_at updated_at/],
        [ 222, 'default', '2017-05-01 20:50:25', '2017-05-01 20:50:25' ],
        [ 223, 'staff',   '2017-05-02 22:31:17', '2017-05-02 22:31:17' ],
    ],
    'StaffPassword' => [
        [qw/staff_id password_id/],
        [ 222, 1 ],
        [ 223, 2 ],
        [ 223, 3 ],
    ],

    # Customers
    # ---------------------------------------------------------------------------------------
    # customer_id     email           is_verified     is_primary    password login
    # ---------------------------------------------------------------------------------------
    # 111             a@example.org       1               0             yes
    #                 b@example.org       1               0             yes
    #                 c@example.org       1               1             yes
    # 112             d@example.org       1               1             yes
    # 113             e@example.org       1               1             no(has not password)
    # ---             f@example.org       0               -
    # ---             g@example.org       0               -

    'Customer' => [
        [qw/id cart_id created_at updated_at/],
        [ 111, 't8e3acvxwu9y49aw34b43rtn52nff61vhbogx2vn', '2017-06-06 19:50:05', '2017-06-16 18:30:12' ],
        [ 112, '9jmedumbbyzq23n2nfkmknt9gr89qx5zy71bosr3', '2017-07-07 07:02:15', '2017-07-07 07:02:15' ],
        [ 113, 'usy4bjf00p8bf85fqu9stup87jf3kaxbs0qn0jmf', '2017-07-08 08:01:02', '2017-07-08 08:01:02' ],
    ],
    'CustomerPassword' => [
        [qw/customer_id password_id/],
        [ 111, 4 ],
        [ 112, 5 ],
        [ 111, 6 ],
    ],
    'CustomerEmail' => [
        [qw/customer_id email_id is_primary/],
        [ 111, 1, 0 ],
        [ 111, 2, 0 ],
        [ 111, 3, 1 ],
        [ 112, 4, 1 ],
        [ 113, 5, 1 ],
    ],
    'CustomerAddress' => [
        [qw/customer_id address_id/],
        [qw/111 1/],
        [qw/111 2/],
        [qw/112 2/],
        [qw/113 3/],
        [qw/113 4/],
    ],

    # Orders
    'Sales' => [
        [qw/id token customer_id billing_address_id payment_method_id created_at updated_at/],
        [ 1, 'aaa', 111, 1, 1, '2017-06-06 20:01:35', '2017-06-06 20:01:35' ],
        [ 2, 'bbb', 112, 2, 2, '2017-07-07 07:02:15', '2017-07-07 07:02:15' ],
        [ 3, 'ccc', 113, 4, 3, '2017-07-07 07:08:05', '2017-07-07 07:08:05' ],
        [ 4, 'ddd', 113, 4, 4, '2017-07-07 07:10:03', '2017-07-07 07:10:03' ],
        [ 5, 'eee', 113, 4, 1, '2017-07-07 07:12:15', '2017-07-07 07:12:15' ],
        [ 6, 'fff', 113, 4, 1, '2017-07-07 07:14:45', '2017-07-07 07:14:45' ],
        [ 7, 'ggg', 113, 4, 1, '2017-07-07 07:15:01', '2017-07-07 07:15:01' ],
    ],
    'SalesOrder' => [
        [qw/id sales_id shipping_address_id trashed_at/],
        [ 1, 1, 1, undef ],
        [ 2, 1, 3, undef ],
        [ 3, 2, 2, undef ],
        [ 4, 3, 3, undef ],
        [ 5, 3, 4, undef ],
        [ 6, 4, 3, undef ],
        [ 7, 4, 4, undef ],
        [ 8, 5, 3, undef ],
        [ 9, 5, 4, '2017-10-10 09:10:10' ], # trashed on test
        [ 10, 6, 3, undef ],
        [ 11, 6, 4, undef ],
        [ 12, 7, 5, undef ], # trashed on test
    ],
    'SalesPrice' => [
        [qw/id tax_rule_id value currency_code is_tax_included/],
        [ 91, 1, 300, 'USD', 0 ],
        [ 92, 2, 101, 'USD', 0 ],
        [ 93, 5, 200, 'USD', 0 ],
        [ 94, 5, 333, 'USD', 0 ],
        [ 95, 5, 101, 'USD', 0 ],
        [ 96, 5, 200, 'USD', 0 ],
    ],
    'SalesOrderItem' => [
        [qw/id order_id product_id quantity product_title price_id/],
        [ 1001, 1, 3, 3, 'product 3', 91 ],
        [ 1002, 1, 1, 1, 'product 1', 92 ], # change price
        [ 1003, 2, 2, 2, 'product 2', 93 ],
        [ 1004, 3, 4, 4, 'product 4', 94 ],
        [ 1005, 12, 1, 4, 'product 1', 95 ], # trashed on test
        [ 1006, 12, 2, 4, 'product 2', 96 ], # trashed on test
    ],
    'Shipment' => [
        [qw/id order_id tracking_number completed_at/],
        [ 33, 1, 'S111222333444', '2017-06-07 17:13:20' ],  # Ship partial, 2/3
        [ 34, 2, 'S222333444555', '2017-07-08 15:10:35' ],  # Shipped all items
        [ 35, 3, undef, undef ],
        [ 36, 4, undef, undef ],
        [ 37, 5, undef, undef ],
        [ 38, 6, undef, undef ],
        [ 39, 7, undef, undef ],
        [ 40, 8, undef, undef ],
        [ 41, 9, undef, undef ],
        [ 42, 10, undef, undef ],
        [ 43, 11, undef, undef ],
        [ 44, 12, undef, undef ],
    ],
    'ShipmentItem' => [
        [qw/shipment_id order_item_id quantity/],
        [ 33, 1001, 2 ],    # Ship partial, 2/3
        [ 33, 1002, 1 ],
        [ 34, 1003, 2 ],    # Shipped all items
    ],
)
