create database Project1
use Project1


CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NULL,
    nationality VARCHAR(50) NULL,
    phone VARCHAR(20) NULL,
    address VARCHAR(255) NULL,
    user_type VARCHAR(20) NOT NULL
        CHECK (user_type IN ('traveler','tour_operator','service_provider','admin')),
    profile_pic VARCHAR(255) NULL,
    joined_date DATETIME NOT NULL DEFAULT GETDATE(),
    is_active BIT NOT NULL DEFAULT 1,
    is_approved BIT NOT NULL DEFAULT 0
);

CREATE TABLE tour_operators (
    id INT PRIMARY KEY
        REFERENCES users(id),
    company_name VARCHAR(100) NOT NULL,
    license VARCHAR(50) NULL,
    years_active INT NULL,
    description TEXT NULL,
    website VARCHAR(255) NULL
);

CREATE TABLE service_types (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NULL
);

CREATE TABLE service_providers (
    id INT PRIMARY KEY
        REFERENCES users(id),
    company_name VARCHAR(100) NOT NULL,
    service_type_id INT NULL
        REFERENCES service_types(id),
    license VARCHAR(50) NULL,
    description TEXT NULL,
    website VARCHAR(255) NULL
);

CREATE TABLE transport_providers (
    provider_id INT PRIMARY KEY
        REFERENCES service_providers(id),
    vehicle_type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    license_plate VARCHAR(50) NOT NULL
);

CREATE TABLE tickets (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL
        REFERENCES users(id),
    related_id INT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('support','inquiry')),
    subject VARCHAR(255) NULL,
    description TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open','in progress','resolved','closed')),
    priority VARCHAR(10) NOT NULL DEFAULT 'medium'
        CHECK (priority IN ('low','medium','high')),
    resolved_at DATETIME NULL,
    response_time AS (DATEDIFF(MINUTE, created_at, resolved_at))
);

CREATE TABLE destinations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    description TEXT NULL,
    climate TEXT NULL,
    best_time VARCHAR(100) NULL,
    popularity DECIMAL(3,2) NULL
        CHECK (popularity BETWEEN 0 AND 5),
    image VARCHAR(255) NULL
);

CREATE TABLE trip_categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NULL
);

CREATE TABLE trips (
    id INT IDENTITY(1,1) PRIMARY KEY,
    operator_id INT NOT NULL
        REFERENCES tour_operators(id),
    category_id INT NOT NULL
        REFERENCES trip_categories(id),
    destination_id INT NOT NULL
        REFERENCES destinations(id),
    name VARCHAR(100) NOT NULL,
    days INT NOT NULL,
    capacity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT NULL,
    inclusions TEXT NULL,
    exclusions TEXT NULL,
    cancel_policy TEXT NULL,
    eco_score DECIMAL(3,2) NULL
        CHECK (eco_score BETWEEN 0 AND 5),
    is_active BIT NOT NULL DEFAULT 1,
    image VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE itineraries (
    id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT NOT NULL
        REFERENCES trips(id),
    day_number INT NOT NULL,
    activities TEXT NOT NULL
);

CREATE TABLE bookings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT NOT NULL
        REFERENCES trips(id),
    user_id INT NOT NULL
        REFERENCES users(id),
    booked_on DATETIME NOT NULL DEFAULT GETDATE(),
    travel_date DATE NOT NULL,
    traveler_count INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('pending','confirmed','cancelled','completed')),
    cancellation_reason TEXT NULL
);

CREATE TABLE payments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL
        REFERENCES bookings(id),
    amount DECIMAL(10,2) NOT NULL,
    paid_at DATETIME NOT NULL DEFAULT GETDATE(),
    method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('pending','successful','failed','refunded')),
    is_chargeback BIT NOT NULL DEFAULT 0,
    refund_amount DECIMAL(10,2) NULL,
    refund_date DATETIME NULL
);

CREATE TABLE reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL
        REFERENCES users(id),
    review_type VARCHAR(20) NOT NULL
        CHECK (review_type IN ('trip','hotel','service','guide')),
    reference_id INT NOT NULL,
    rating INT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NULL,
    posted_at DATETIME NOT NULL DEFAULT GETDATE(),
    is_moderated BIT NOT NULL DEFAULT 0
);

CREATE TABLE trip_schedules (
    id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT NOT NULL
        REFERENCES trips(id),
    transport_provider_id INT NOT NULL
        REFERENCES transport_providers(provider_id),
    planned_departure DATETIME NULL,
    actual_departure DATETIME NULL,
    planned_arrival DATETIME NULL,
    actual_arrival DATETIME NULL
);

CREATE TABLE digital_travel_passes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL
        REFERENCES bookings(id),
    issue_date DATETIME NOT NULL DEFAULT GETDATE(),
    expiry_date DATETIME NULL
);

CREATE TABLE digital_pass_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    pass_id INT NOT NULL
        REFERENCES digital_travel_passes(id),
    service_type VARCHAR(20) NOT NULL
        CHECK (service_type IN ('hotel','transport','guide')),
    details VARCHAR(255) NULL
);

CREATE TABLE system_logs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL
        REFERENCES users(id),
    log_type VARCHAR(20) NOT NULL
        CHECK (log_type IN ('activity','audit')),
    activity_type VARCHAR(50) NULL,
    action VARCHAR(100) NULL,
    description TEXT NULL,
    ip_address VARCHAR(50) NULL,
    user_agent VARCHAR(255) NULL,
    timestamp DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE trip_assignments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT NOT NULL
        REFERENCES trips(id),
    provider_id INT NOT NULL
        REFERENCES service_providers(id),
    assignment_type VARCHAR(20) NOT NULL
        CHECK (assignment_type IN ('hotel','service','guide')),
    service_date DATETIME NULL,
    cost DECIMAL(10,2) NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('assigned','accepted','rejected','completed'))
);

CREATE TABLE wishlists (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL
        REFERENCES users(id),
    trip_id INT NOT NULL
        REFERENCES trips(id),
    added_on DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_user_trip UNIQUE (user_id, trip_id)
);

CREATE TABLE trip_images (
    id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT NOT NULL
        REFERENCES trips(id),
    image VARCHAR(255) NOT NULL,
    description VARCHAR(255) NULL,
    is_primary BIT NOT NULL DEFAULT 0
);







--------insertion 

--select * from service_types

-- services type table.
INSERT INTO service_types (name, description) VALUES 
('Hotel Accommodation', 'Lodging services including budget and luxury hotel stays'),
('Airport Shuttle', 'Transport service between airport and accommodation'),
('City Tour Guide', 'Certified guides for city sightseeing tours'),
('Adventure Guide', 'Guides for hiking, trekking, rafting etc.'),
('Boat Rentals', 'Small boats or yachts available for private booking'),
('Private Driver', 'Chauffeured vehicle service for trips'),
('Local Transport', 'Public transport pass or ride booking'),
('Food & Dining', 'Pre-paid meals or restaurant vouchers'),
('Spa & Wellness', 'Access to spas, massages, and wellness centers'),
('Cultural Experience', 'Cooking classes, traditional events, or village tours'),
('Baggage Services', 'Luggage transport or storage'),
('Bike Rentals', 'Cycle rentals for city/local tours'),
('Photography', 'Professional trip photography service'),
('Translator', 'Language assistance during trip'),
('Medical Support', 'On-call medical assistant or clinic access'),
('Airport Lounge Access', 'Passes to premium lounges'),
('SIM Card/Internet', 'Local SIMs or portable Wi-Fi devices'),
('Travel Insurance', 'Short-term trip insurance plans'),
('Personal Concierge', '24/7 dedicated assistance for the traveler'),
('Resort Activities', 'Jet skiing, scuba diving, or resort-based fun'),
('Cab Booking', 'Taxi bookings for intercity or local use'),
('Pet Accommodation', 'Pet lodging and services while traveling'),
('Room Service', 'On-demand meals and cleaning in hotel rooms'),
('Event Tickets', 'Pre-booked access to concerts, shows, or sports'),
('Visa Assistance', 'Help with visa application and documentation'),
('Childcare', 'Babysitting or nanny services during trip'),
('Laundry Services', 'Washing and ironing of clothes'),
('Fitness Center Access', 'Gym or training facility passes'),
('Camping Equipment Rental', 'Tent, sleeping bag and related gear'),
('Souvenir Shops', 'Discounts or vouchers for souvenir stores'),
('Airport Pickup', 'Scheduled pickup service from airports'),
('Train Pass', 'Rail passes for inter-city travel'),
('Luxury Vehicle Rental', 'High-end car services for local use'),
('Boat Cruise', 'Short cruises or ferry services'),
('Local Sim Activation', 'Assistance with SIM and mobile setup'),
('Desert Safari', '4x4 rides and camel tours in deserts'),
('Snorkeling Equipment', 'Rental of mask, fins and snorkel'),
('Ski Pass', 'Access to ski slopes and gear rental'),
('Ziplining', 'Adventure ropeway access'),
('Paragliding', 'Service for safe tandem flights'),
('Travel Accessories', 'On-the-go gear like neck pillows or luggage locks'),
('Hiking Guide', 'Person with expertise in trails and survival'),
('Trekking Permit Help', 'Assistance with route and trail permissions'),
('Eco Lodge', 'Environmentally conscious lodging'),
('Helicopter Ride', 'Aerial sightseeing or mountain transport'),
('Emergency Helpline', '24/7 trip issue response team'),
('Welcome Package', 'Gifts and local snacks on arrival'),
('Drone Photography', 'Drone-based media coverage of trip'),
('Festival Entry', 'Priority entry to local cultural or national festivals'),
('Volunteer Opportunities', 'Organized short-term social work options'),
('Gastronomy Tour', 'Local food exploration with chefs or foodies');




--select * from users
-- Insert 50 real-world users into the users table
INSERT INTO users (email, password, first_name, last_name, birth_date, nationality, phone, address, user_type, profile_pic)
VALUES
('emma.johnson@example.com', 'hash123', 'Emma', 'Johnson', '1990-04-15', 'USA', '+1-555-0001', '123 Maple Street, New York', 'traveler', 'profile1.jpg'),
('liam.smith@example.com', 'hash124', 'Liam', 'Smith', '1985-03-22', 'Canada', '+1-555-0002', '456 Oak Avenue, Toronto', 'traveler', 'profile2.jpg'),
('olivia.brown@example.com', 'hash125', 'Olivia', 'Brown', '1992-07-09', 'UK', '+1-555-0003', '789 Pine Lane, London', 'traveler', 'profile3.jpg'),
('noah.jones@example.com', 'hash126', 'Noah', 'Jones', '1988-10-11', 'Australia', '+1-555-0004', '321 Cedar Street, Sydney', 'traveler', 'profile4.jpg'),
('ava.miller@example.com', 'hash127', 'Ava', 'Miller', '1993-12-05', 'India', '+1-555-0005', '654 Birch Road, Delhi', 'traveler', 'profile5.jpg'),
('isabella.davis@example.com', 'hash128', 'Isabella', 'Davis', '1991-05-17', 'USA', '+1-555-0006', '111 Spruce Blvd, Chicago', 'traveler', 'profile6.jpg'),
('sophia.garcia@example.com', 'hash129', 'Sophia', 'Garcia', '1994-11-30', 'Canada', '+1-555-0007', '222 Elm Drive, Vancouver', 'traveler', 'profile7.jpg'),
('william.martinez@example.com', 'hash130', 'William', 'Martinez', '1986-08-19', 'UK', '+1-555-0008', '333 Ash Way, Birmingham', 'traveler', 'profile8.jpg'),
('james.rodriguez@example.com', 'hash131', 'James', 'Rodriguez', '1987-06-14', 'Australia', '+1-555-0009', '444 Beech Street, Melbourne', 'traveler', 'profile9.jpg'),
('mia.hernandez@example.com', 'hash132', 'Mia', 'Hernandez', '1990-02-27', 'India', '+1-555-0010', '555 Fir Avenue, Mumbai', 'traveler', 'profile10.jpg'),
('lucas.white@example.com', 'hash133', 'Lucas', 'White', '1980-01-20', 'USA', '+1-555-0011', '678 Walnut Rd, Boston', 'tour_operator', 'profile11.jpg'),
('amelia.harris@example.com', 'hash134', 'Amelia', 'Harris', '1982-09-15', 'Canada', '+1-555-0012', '789 Chestnut Ave, Calgary', 'tour_operator', 'profile12.jpg'),
('benjamin.clark@example.com', 'hash135', 'Benjamin', 'Clark', '1979-04-10', 'UK', '+1-555-0013', '890 Redwood St, Manchester', 'tour_operator', 'profile13.jpg'),
('harper.lewis@example.com', 'hash136', 'Harper', 'Lewis', '1983-06-18', 'Australia', '+1-555-0014', '901 Cypress Rd, Perth', 'tour_operator', 'profile14.jpg'),
('ethan.walker@example.com', 'hash137', 'Ethan', 'Walker', '1981-12-23', 'India', '+1-555-0015', '112 Maple Grove, Chennai', 'tour_operator', 'profile15.jpg'),
('evelyn.young@example.com', 'hash138', 'Evelyn', 'Young', '1978-08-05', 'USA', '+1-555-0016', '131 Poplar Ct, Denver', 'tour_operator', 'profile16.jpg'),
('henry.hall@example.com', 'hash139', 'Henry', 'Hall', '1985-03-29', 'Canada', '+1-555-0017', '141 Tamarack Ave, Montreal', 'tour_operator', 'profile17.jpg'),
('scarlett.adams@example.com', 'hash140', 'Scarlett', 'Adams', '1984-07-07', 'UK', '+1-555-0018', '151 Willow St, Liverpool', 'tour_operator', 'profile18.jpg'),
('jackson.baker@example.com', 'hash141', 'Jackson', 'Baker', '1977-02-14', 'Australia', '+1-555-0019', '161 Magnolia Blvd, Brisbane', 'tour_operator', 'profile19.jpg'),
('victoria.nelson@example.com', 'hash142', 'Victoria', 'Nelson', '1986-11-01', 'India', '+1-555-0020', '171 Acacia Dr, Pune', 'tour_operator', 'profile20.jpg'),
('logan.campbell@example.com', 'hash143', 'Logan', 'Campbell', '1990-09-10', 'USA', '+1-555-0021', '181 Pineview Rd, Phoenix', 'service_provider', 'profile21.jpg'),
('grace.mitchell@example.com', 'hash144', 'Grace', 'Mitchell', '1992-06-20', 'Canada', '+1-555-0022', '191 Larch St, Edmonton', 'service_provider', 'profile22.jpg'),
('sebastian.carter@example.com', 'hash145', 'Sebastian', 'Carter', '1993-04-01', 'UK', '+1-555-0023', '201 Spruce Grove, Leeds', 'service_provider', 'profile23.jpg'),
('zoey.rivera@example.com', 'hash146', 'Zoey', 'Rivera', '1991-03-25', 'Australia', '+1-555-0024', '211 Fir Circle, Adelaide', 'service_provider', 'profile24.jpg'),
('matthew.gray@example.com', 'hash147', 'Matthew', 'Gray', '1989-01-30', 'India', '+1-555-0025', '221 Redwood Path, Jaipur', 'service_provider', 'profile25.jpg'),
('riley.ward@example.com', 'hash148', 'Riley', 'Ward', '1990-08-12', 'USA', '+1-555-0026', '231 Pine Hollow, Seattle', 'service_provider', 'profile26.jpg'),
('nathan.turner@example.com', 'hash149', 'Nathan', 'Turner', '1988-10-05', 'Canada', '+1-555-0027', '241 Sycamore Way, Ottawa', 'service_provider', 'profile27.jpg'),
('lily.parker@example.com', 'hash150', 'Lily', 'Parker', '1994-11-03', 'UK', '+1-555-0028', '251 Oakleaf Rd, Bristol', 'service_provider', 'profile28.jpg'),
('daniel.morris@example.com', 'hash151', 'Daniel', 'Morris', '1987-09-13', 'Australia', '+1-555-0029', '261 Mapleview Dr, Hobart', 'service_provider', 'profile29.jpg'),
('ellie.reed@example.com', 'hash152', 'Ellie', 'Reed', '1995-05-15', 'India', '+1-555-0030', '271 Garden Rd, Hyderabad', 'service_provider', 'profile30.jpg'),
('julian.cook@example.com', 'hash153', 'Julian', 'Cook', '1986-03-11', 'USA', '+1-555-0031', '281 Horizon Lane, Miami', 'service_provider', 'profile31.jpg'),
('nora.bell@example.com', 'hash154', 'Nora', 'Bell', '1992-01-01', 'Canada', '+1-555-0032', '291 Misty Ridge, Halifax', 'service_provider', 'profile32.jpg'),
('leonard.cox@example.com', 'hash155', 'Leonard', 'Cox', '1984-04-04', 'UK', '+1-555-0033', '301 Brookside, Sheffield', 'service_provider', 'profile33.jpg'),
('hannah.woods@example.com', 'hash156', 'Hannah', 'Woods', '1983-07-22', 'Australia', '+1-555-0034', '311 Fieldstone Ct, Canberra', 'service_provider', 'profile34.jpg'),
('isaac.bailey@example.com', 'hash157', 'Isaac', 'Bailey', '1989-05-28', 'India', '+1-555-0035', '321 Lakeview Blvd, Kolkata', 'service_provider', 'profile35.jpg'),
('madison.brooks@example.com', 'hash158', 'Madison', 'Brooks', '1990-06-15', 'USA', '+1-555-0036', '331 Evergreen Ave, San Jose', 'service_provider', 'profile36.jpg'),
('theo.murphy@example.com', 'hash159', 'Theo', 'Murphy', '1991-10-08', 'Canada', '+1-555-0037', '341 Highland Trail, Winnipeg', 'service_provider', 'profile37.jpg'),
('penelope.patterson@example.com', 'hash160', 'Penelope', 'Patterson', '1988-12-02', 'UK', '+1-555-0038', '351 Ashford Road, Glasgow', 'service_provider', 'profile38.jpg'),
('christopher.richards@example.com', 'hash161', 'Christopher', 'Richards', '1985-09-18', 'Australia', '+1-555-0039', '361 Sunridge Way, Darwin', 'service_provider', 'profile39.jpg'),
('stella.price@example.com', 'hash162', 'Stella', 'Price', '1993-03-10', 'India', '+1-555-0040', '371 Blossom St, Ahmedabad', 'service_provider', 'profile40.jpg'),
('admin01@example.com', 'hash163', 'System', 'Admin1', '1980-01-01', 'USA', '+1-555-0041', 'Admin HQ 1', 'admin', NULL),
('admin02@example.com', 'hash164', 'System', 'Admin2', '1981-01-01', 'Canada', '+1-555-0042', 'Admin HQ 2', 'admin', NULL),
('admin03@example.com', 'hash165', 'System', 'Admin3', '1982-01-01', 'UK', '+1-555-0043', 'Admin HQ 3', 'admin', NULL),
('admin04@example.com', 'hash166', 'System', 'Admin4', '1983-01-01', 'Australia', '+1-555-0044', 'Admin HQ 4', 'admin', NULL),
('admin05@example.com', 'hash167', 'System', 'Admin5', '1984-01-01', 'India', '+1-555-0045', 'Admin HQ 5', 'admin', NULL),
('admin06@example.com', 'hash168', 'System', 'Admin6', '1985-01-01', 'USA', '+1-555-0046', 'Admin HQ 6', 'admin', NULL),
('admin07@example.com', 'hash169', 'System', 'Admin7', '1986-01-01', 'Canada', '+1-555-0047', 'Admin HQ 7', 'admin', NULL),
('admin08@example.com', 'hash170', 'System', 'Admin8', '1987-01-01', 'UK', '+1-555-0048', 'Admin HQ 8', 'admin', NULL),
('admin09@example.com', 'hash171', 'System', 'Admin9', '1988-01-01', 'Australia', '+1-555-0049', 'Admin HQ 9', 'admin', NULL),
('admin10@example.com', 'hash172', 'System', 'Admin10', '1989-01-01', 'India', '+1-555-0050', 'Admin HQ 10', 'admin', NULL);

-- Total: 50 user insertions (10 travelers, 10 tour operators, 20 service providers, 10 admins)



---tour_operators:

-- 50 INSERTs for tour_operators (IDs 1–50)
--select * from tour_operators
INSERT INTO tour_operators (id, company_name, license, years_active, description, website) VALUES
(1,  'SkyHigh Adventures',    'LIC1001', 8,  'Adventure tours in mountainous regions.',                      'https://skyhighadventures.com'),
(2,  'Wanderlust Treks',      'LIC1002', 5,  'Group trekking packages across Asia.',                         'https://wanderlusttreks.org'),
(3,  'EcoGlobe Travel',       'LIC1003', 7,  'Eco-friendly tours and educational trips.',                     'https://ecoglobetravel.net'),
(4,  'CultureConnect Tours',  'LIC1004', 10, 'Specializes in cultural experiences and heritage tours.',       'https://cultureconnect.com'),
(5,  'Desert Safari Masters', 'LIC1005', 4,  'Expertise in desert expeditions and safaris.',                  'https://safarimasters.co'),
(6,  'BlueWave Voyages',      'LIC1006', 6,  'Ocean and coastal tourism experts.',                            'https://bluewavevoyages.com'),
(7,  'CityPulse Tours',       'LIC1007', 3,  'Urban tours with local guides.',                                'https://citypulsetours.com'),
(8,  'GlobalPath Travel',     'LIC1008', 12, 'Large-scale international travel operator.',                    'https://globalpath.travel'),
(9,  'MysticLand Getaways',   'LIC1009', 2,  'Spiritual and meditation-focused journeys.',                    'https://mysticlandgetaways.org'),
(10, 'NatureNest Adventures', 'LIC1010', 9,  'Jungle trekking and nature exploration.',                       'https://naturenestadventures.com'),

(11, 'Alpine Journeys',       'LIC1011', 6,  'Specializes in Alpine hiking and mountaineering.',              'https://alpinejourneys.com'),
(12, 'TropicTide Tours',      'LIC1012', 5,  'Tropical island packages and scuba diving.',                    'https://tropictide.com'),
(13, 'Backpack World',        'LIC1013', 7,  'Budget travel for backpackers across Europe.',                  'https://backpackworld.net'),
(14, 'Ride&Roam',             'LIC1014', 3,  'Motorbike tours across continents.',                            'https://rideandroam.com'),
(15, 'Nomad Planet',          'LIC1015', 8,  'Remote work & travel arrangements for nomads.',                 'https://nomadplanet.org'),
(16, 'Frozen Trails',         'LIC1016', 10, 'Polar expeditions and northern lights hunting.',                'https://frozentrails.com'),
(17, 'Vibe Tours',            'LIC1017', 4,  'Party tourism and nightlife exploration.',                      'https://vibetours.io'),
(18, 'Safari Sphere',         'LIC1018', 6,  'Wildlife safaris and jungle camps.',                            'https://safarisphere.com'),
(19, 'EduTrips',              'LIC1019', 9,  'Student-focused international educational trips.',              'https://edutrips.org'),
(20, 'Healing Horizons',      'LIC1020', 5,  'Retreats focused on healing, yoga, and peace.',                 'https://healinghorizons.com'),

(21, 'Artisan Voyages',       'LIC1021', 7,  'Craft, art, and cultural tourism.',                             'https://artisanvoyages.com'),
(22, 'Majestic Miles',        'LIC1022', 8,  'Luxury travel experiences globally.',                           'https://majesticmiles.com'),
(23, 'Island Hoppers',        'LIC1023', 4,  'Travel across island chains and beaches.',                      'https://islandhoppers.org'),
(24, 'Epic Journeys Co.',     'LIC1024', 6,  'Themed adventure and mystery tours.',                           'https://epicjourneys.co'),
(25, 'Pioneer Paths',         'LIC1025', 5,  'Historical route discovery tours.',                             'https://pioneerpaths.net'),
(26, 'Footloose Travels',     'LIC1026', 3,  'Backpacking and hosteling trips.',                              'https://footloosetravels.com'),
(27, 'TrailBlaze',            'LIC1027', 2,  'Beginner treks and soft adventure.',                            'https://trailblaze.io'),
(28, 'ChillVentures',         'LIC1028', 6,  'Leisure and relaxation travel.',                                'https://chillventures.com'),
(29, 'AltitudeX',             'LIC1029', 7,  'High-altitude expeditions and climbing.',                       'https://altitudex.net'),
(30, 'Soul Trek',             'LIC1030', 8,  'Retreats focused on personal growth.',                          'https://soultrek.org'),

(31, 'HistoryNexus',          'LIC1031', 6,  'Archaeological tours and ancient cities.',                      'https://historynexus.com'),
(32, 'FarmRoute Experiences', 'LIC1032', 4,  'Agro-tourism and farm stays.',                                  'https://farmroute.com'),
(33, 'Velocity Travel',       'LIC1033', 3,  'Sports-themed travel packages.',                                'https://velocitytravel.org'),
(34, 'Urban Safari',          'LIC1034', 5,  'Metropolitan cultural immersion tours.',                        'https://urbansafari.com'),
(35, 'Skyline Expeditions',   'LIC1035', 7,  'Extreme altitude and skydiving tours.',                         'https://skylineexpeditions.net'),
(36, 'FestTrack',             'LIC1036', 4,  'Festival-hopping travel experiences.',                          'https://festtrack.com'),
(37, 'Wellness Routes',       'LIC1037', 6,  'Health tourism with spa and detox programs.',                   'https://wellnessroutes.com'),
(38, 'Roamer’s League',       'LIC1038', 9,  'Custom travel curation for groups.',                            'https://roamersleague.com'),
(39, 'PhotoWalks Inc.',       'LIC1039', 2,  'Photography-focused travel.',                                   'https://photowalks.com'),
(40, 'CulinaryQuest',         'LIC1040', 5,  'Food tourism and tasting experiences.',                         'https://culinaryquest.org'),

(41, 'CrossGlobe Paths',      'LIC1041', 11, 'Worldwide, full-service travel agency.',                        'https://crossglobepaths.com'),
(42, 'ZenTrails',             'LIC1042', 6,  'Mindfulness and nature walks.',                                 'https://zentrails.org'),
(43, 'Beyond Borders',        'LIC1043', 10, 'International peace and culture missions.',                     'https://beyondborders.com'),
(44, 'Offbeat Tracks',        'LIC1044', 3,  'Hidden gems and local life experiences.',                       'https://offbeattracks.org'),
(45, 'EcoNomads',             'LIC1045', 7,  'Sustainable and low-impact tours.',                             'https://economads.travel'),
(46, 'Luxura Expeditions',    'LIC1046', 12, 'Top-tier luxury destination experts.',                          'https://luxuraexpeditions.com'),
(47, 'Tribal Ties',           'LIC1047', 5,  'Trips to learn about tribal life and culture.',                 'https://tribalties.net'),
(48, 'MindScape',             'LIC1048', 4,  'Therapeutic and reflective travel.',                            'https://mindscape.org'),
(49, 'SeaBridge Cruises',     'LIC1049', 6,  'Small cruise ships with exclusive routes.',                     'https://seabridgecruises.com'),
(50, 'OrbitOne',              'LIC1050', 9,  'Tech-enhanced smart tourism.',                                  'https://orbitone.tech');




-- 50 INSERTs for service_providers
--select * from service_providers

INSERT INTO service_providers (id, company_name, service_type_id, license, description, website) VALUES
(1,  'Global Stays Ltd',           1,  'LIC-SP-001', 'International hotel and resort group',                'https://globalstays.example.com'),
(2,  'CityLink Transit',           2,  'LIC-SP-002', 'Reliable airport and city shuttle service',           'https://citylinktransit.com'),
(3,  'Heritage Guides Inc.',       3,  'LIC-SP-003', 'Expert cultural tour guides in historic cities',        'https://heritageguides.org'),
(4,  'Peak Adventure Co.',         4,  'LIC-SP-004', 'Mountain trekking and adventure guiding',               'https://peakadventure.co'),
(5,  'AquaCraft Rentals',          5,  'LIC-SP-005', 'Boat and yacht rental services for coastal trips',       'https://aquacraftrentals.com'),
(6,  'DrivePro Chauffeurs',        6,  'LIC-SP-006', 'Professional private driver services',                  'https://driveprochauffeurs.net'),
(7,  'MetroRide Pass',             7,  'LIC-SP-007', 'Prepaid local transport passes',                        'https://metroridepass.com'),
(8,  'Gourmet Eats Voucher',       8,  'LIC-SP-008', 'Prepaid restaurant and dining vouchers',                'https://gourmeteatsvoucher.com'),
(9,  'Serene Spa Retreats',        9,  'LIC-SP-009', 'Spa, massage, and wellness center access',              'https://serenespa.com'),
(10, 'CultureCraft Experiences',  10, 'LIC-SP-010', 'Hands-on cultural workshops and classes',                'https://culturecraftexp.com'),

(11, 'BagEase Logistics',         11, 'LIC-SP-011', 'Luggage transport and secure storage services',          'https://bageaselogistics.com'),
(12, 'Pedal City Bikes',          12, 'LIC-SP-012', 'City bike rental and guided cycling tours',              'https://pedalcitybikes.org'),
(13, 'Snapshot Memories',         13, 'LIC-SP-013', 'Professional photography services during your trip',     'https://snapshotmemories.com'),
(14, 'LinguaLink Translators',    14, 'LIC-SP-014', 'On-the-ground translation and interpreter services',    'https://lingualink.com'),
(15, 'HealthGuard Medical',       15, 'LIC-SP-015', 'Travel health assistance and on-call clinics',           'https://healthguardmedical.net'),
(16, 'LoungeLux Airport',         16, 'LIC-SP-016', 'Premium airport lounge access passes',                   'https://loungeluxairport.com'),
(17, 'StayConnected SIMs',        17, 'LIC-SP-017', 'Local SIM cards and portable Wi‑Fi device rentals',      'https://stayconnectedsims.com'),
(18, 'SafeTravel Insurance',      18, 'LIC-SP-018', 'Short-term travel insurance plans',                      'https://safetravelinsurance.org'),
(19, 'Concierge 24/7',            19, 'LIC-SP-019', 'Dedicated personal concierge service',                   'https://concierge247.com'),
(20, 'ResortSplash Activities',   20, 'LIC-SP-020', 'Water sports and resort activity bookings',               'https://resortsplashactivities.com'),

(21, 'QuickCab Booking',          21, 'LIC-SP-021', 'On-demand taxi and cab booking service',                 'https://quickcabbooking.com'),
(22, 'PetBnB Services',           22, 'LIC-SP-022', 'Pet boarding and care while you travel',                 'https://petbnbservices.org'),
(23, 'RoomDelight Service',       23, 'LIC-SP-023', 'In-room dining and housekeeping on demand',              'https://roomdelightservice.com'),
(24, 'EventPasses Online',        24, 'LIC-SP-024', 'Pre-booked tickets to concerts, shows, and sports',      'https://eventpassesonline.com'),
(25, 'VisaAssist Hub',            25, 'LIC-SP-025', 'End-to-end visa application and document handling',      'https://visaassisthub.net'),
(26, 'Tiny Tots Care',            26, 'LIC-SP-026', 'Certified childcare and babysitting services',            'https://tinytotscare.com'),
(27, 'FreshThreads Laundry',      27, 'LIC-SP-027', 'Laundry pickup, washing, and ironing services',          'https://freshthreadslaundry.com'),
(28, 'FitPass Gyms',              28, 'LIC-SP-028', 'Day passes to local gyms and fitness centers',           'https://fitpassgyms.org'),
(29, 'CampGear Rentals',          29, 'LIC-SP-029', 'Tents, sleeping bags, and camping equipment rentals',    'https://campgearrentals.com'),
(30, 'Souvenir Corner',           30, 'LIC-SP-030', 'Discount vouchers for gift shops and local crafts',       'https://souvenircorner.com'),

(31, 'AirPick Transfers',         31, 'LIC-SP-031', 'Private airport pickup and drop‑off service',            'https://airpicktransfers.com'),
(32, 'RailPass Global',           32, 'LIC-SP-032', 'Unlimited train pass for inter-city travel',             'https://railpassglobal.net'),
(33, 'EliteDrive Rent-A-Car',     33, 'LIC-SP-033', 'Luxury car rental services',                             'https://elitedriverentacar.com'),
(34, 'CruiseLine Excursions',     34, 'LIC-SP-034', 'Short cruises and ferry services',                       'https://cruiselineexcursions.com'),
(35, 'Desert Quest Safari',       35, 'LIC-SP-035', 'Guided desert safaris and camel tours',                  'https://desertquestsafari.com'),
(36, 'SnorkelPro Gear',           36, 'LIC-SP-036', 'Professional snorkeling equipment rentals',              'https://snorkelprogear.org'),
(37, 'SkiWorld Passes',           37, 'LIC-SP-037', 'All-day ski slope access and gear hire',                 'https://skiworldpasses.com'),
(38, 'ZipLine Adventures',        38, 'LIC-SP-038', 'High‑wire and zip‑line thrill experiences',               'https://ziplineadventures.net'),
(39, 'ParaGlide Flights',         39, 'LIC-SP-039', 'Safe tandem paragliding for beginners',                  'https://paraglideflights.com'),
(40, 'TravelerGear Shop',         40, 'LIC-SP-040', 'On-the-go travel accessories and essentials',            'https://travelergearshop.com'),

(41, 'TrailGuide Experts',        41, 'LIC-SP-041', 'Professional hiking and trail guide services',           'https://trailguideexperts.org'),
(42, 'PermitAssist Tours',        42, 'LIC-SP-042', 'Help obtaining trekking permits and trail access',       'https://permitassisttours.com'),
(43, 'EcoLodge Network',          43, 'LIC-SP-043', 'Collection of eco‑friendly lodging options',             'https://ecolodgenetwork.com'),
(44, 'HeliSight Flights',         44, 'LIC-SP-044', 'Helicopter sightseeing and remote transport',            'https://helisightflights.com'),
(45, 'MediHelp Emergency',        45, 'LIC-SP-045', '24/7 emergency helpline and support team',               'https://medihelpemergency.org'),
(46, 'WelcomePack Gifts',         46, 'LIC-SP-046', 'Arrival welcome kits with snacks and local items',       'https://welcomepackgifts.com'),
(47, 'DroneView Media',           47, 'LIC-SP-047', 'Aerial drone photography and videography',               'https://droneviewmedia.net'),
(48, 'FestivalFast Pass',         48, 'LIC-SP-048', 'Priority entry to cultural and music festivals',         'https://festivalfastpass.com'),
(49, 'Volunteer Connect',         49, 'LIC-SP-049', 'Coordinated volunteer and community service options',    'https://volunteerconnect.org'),
(50, 'FoodieTrail Tours',         50, 'LIC-SP-050', 'Guided gastronomy tours and local food tastings',        'https://foodietrail.com');






-- 50 INSERTs for transport_providers
-- Assumes service_providers.id = 1–50 exist

select * from transport_providers

INSERT INTO transport_providers (provider_id, vehicle_type, capacity, license_plate) VALUES
(1,  'Airport Shuttle Bus',       50, 'TPL-0001'),
(2,  'City Tour Van',             15, 'TPL-0002'),
(3,  'Executive Sedan',           4,  'TPL-0003'),
(4,  'Minibus',                   20, 'TPL-0004'),
(5,  'Luxury SUV',                6,  'TPL-0005'),
(6,  'Private Limousine',         4,  'TPL-0006'),
(7,  'Electric City Car',         2,  'TPL-0007'),
(8,  'Double‑Decker Bus',         60, 'TPL-0008'),
(9,  'Standard Taxi',             4,  'TPL-0009'),
(10, 'Eco‑Friendly Van',          8,  'TPL-0010'),

(11, 'Airport Coach Bus',         45, 'TPL-0011'),
(12, 'Family SUV',                7,  'TPL-0012'),
(13, 'Shuttle Van',               12, 'TPL-0013'),
(14, 'Electric Minivan',          8,  'TPL-0014'),
(15, 'Convertible Sedan',         2,  'TPL-0015'),
(16, 'Tourist Tram',              30, 'TPL-0016'),
(17, 'Vintage Coach',             25, 'TPL-0017'),
(18, 'Luxury Sprinter Van',       12, 'TPL-0018'),
(19, 'Camper Van',                6,  'TPL-0019'),
(20, 'Off‑Road 4×4',              5,  'TPL-0020'),

(21, 'Helicopter',                6,  'TPL-0021'),
(22, 'River Ferry',               100,'TPL-0022'),
(23, 'Seaside Water Taxi',        20, 'TPL-0023'),
(24, 'City Bicycle Rental',       1,  'TPL-0024'),
(25, 'Electric Scooter',          1,  'TPL-0025'),
(26, 'Touring Motorcycle',        2,  'TPL-0026'),
(27, 'Autonomous Shuttle',        10, 'TPL-0027'),
(28, 'Night‑Safety Taxi',         4,  'TPL-0028'),
(29, 'VIP Executive Bus',         40, 'TPL-0029'),
(30, 'Medical Transport Van',     4,  'TPL-0030'),

(31, 'Snowcat',                   8,  'TPL-0031'),
(32, 'Mountain Cable Car',        30, 'TPL-0032'),
(33, 'Tourist Tram (Heritage)',   20, 'TPL-0033'),
(34, 'Park Sightseeing Train',    50, 'TPL-0034'),
(35, 'Desert Jeep',               5,  'TPL-0035'),
(36, 'Beach Buggy',               2,  'TPL-0036'),
(37, 'Airport Electric Shuttle',  25, 'TPL-0037'),
(38, 'River Cruise Boat',         80, 'TPL-0038'),
(39, 'City Minibus',              18, 'TPL-0039'),
(40, 'Vintage Trolley',           30, 'TPL-0040'),

(41, 'Safari Land Rover',         7,  'TPL-0041'),
(42, 'Jungle Expedition Truck',   10, 'TPL-0042'),
(43, 'All‑Terrain Tram',          15, 'TPL-0043'),
(44, 'Coastal Cruise Ship',       200,'TPL-0044'),
(45, 'Harbor Ferry',              120,'TPL-0045'),
(46, 'Urban Cable Car',           25, 'TPL-0046'),
(47, 'Island Water Taxi',         30, 'TPL-0047'),
(48, 'Heli‑Taxi',                 4,  'TPL-0048'),
(49, 'Luxury River Yacht',        12, 'TPL-0049'),
(50, 'Sightseeing Hot Air Balloon', 8, 'TPL-0050');








-- 50 INSERTs for destinations

--select * from destinations

INSERT INTO destinations (name, city, country, description, climate, best_time, popularity, image) VALUES
('Eiffel Tower',           'Paris',        'France',       'Iconic wrought-iron tower with panoramic city views.',                     'Temperate',      'Spring-Summer',    4.85, 'https://example.com/images/paris_eiffel.jpg'),
('Central Park',           'New York',     'USA',          'Urban park featuring lakes, meadows, and cultural events.',               'Continental',    'Spring-Fall',      4.75, 'https://example.com/images/nyc_centralpark.jpg'),
('Mount Fuji',             'Fujiyoshida',  'Japan',        'Sacred volcano offering climbing routes and scenic vistas.',             'Temperate',      'Summer',           4.65, 'https://example.com/images/mount_fuji.jpg'),
('Sydney Opera House',     'Sydney',       'Australia',    'Famous performing-arts center on the harbour.',                          'Temperate',      'Spring-Summer',    4.70, 'https://example.com/images/sydney_opera.jpg'),
('Colosseum',              'Rome',         'Italy',        'Ancient amphitheater central to Roman culture and history.',             'Mediterranean',  'Spring-Fall',      4.60, 'https://example.com/images/rome_colosseum.jpg'),
('Great Wall',             'Beijing',      'China',        'Historic defensive fortification stretching thousands of miles.',         'Continental',    'Spring-Autumn',    4.80, 'https://example.com/images/great_wall.jpg'),
('Bali Beaches',           'Kuta',         'Indonesia',    'Popular coastal area known for surf spots and vibrant nightlife.',       'Tropical',       'May-September',    4.50, 'https://example.com/images/bali_kuta.jpg'),
('Grand Canyon',           'Grand Canyon', 'USA',          'Vast gorge carved by the Colorado River, ideal for hiking and rafting.',  'Arid',           'Spring-Fall',      4.90, 'https://example.com/images/grand_canyon.jpg'),
('Machu Picchu',           'Cusco',        'Peru',         'Incan citadel set high in the Andes Mountains.',                         'Temperate',      'April-October',    4.95, 'https://example.com/images/machu_picchu.jpg'),
('Santorini Cliffs',       'Fira',         'Greece',       'Picturesque white-washed villages overlooking the caldera.',             'Mediterranean',  'May-October',      4.55, 'https://example.com/images/santorini_fira.jpg'),
('Serengeti National Park','Serengeti',    'Tanzania',     'Wildlife reserve famed for great wildebeest migration.',                 'Tropical',       'June-October',     4.70, 'https://example.com/images/serengeti.jpg'),
('Banff National Park',    'Banff',        'Canada',       'Scenic park in the Rockies with turquoise lakes and glaciers.',           'Continental',    'June-September',   4.65, 'https://example.com/images/banff.jpg'),
('Petra Archaeological Site','Wadi Musa',  'Jordan',       'Historic rock-cut architecture of the Nabatean kingdom.',                'Arid',           'March-May',        4.60, 'https://example.com/images/petra.jpg'),
('Galápagos Islands',      'Puerto Baquerizo Moreno','Ecuador','Unique archipelago with diverse endemic wildlife.',                    'Tropical',       'June-November',    4.75, 'https://example.com/images/galapagos.jpg'),
('Niagara Falls',          'Niagara Falls','Canada/USA',   'Powerful waterfalls straddling the US–Canada border.',                   'Continental',    'June-August',      4.55, 'https://example.com/images/niagara.jpg'),
('Victoria Falls',         'Victoria',     'Zambia/Zimbabwe','One of the largest and most famous waterfalls in the world.',            'Tropical',       'February-May',     4.60, 'https://example.com/images/victoria_falls.jpg'),
('Angkor Wat',             'Siem Reap',    'Cambodia',     'Vast temple complex and UNESCO World Heritage site.',                    'Tropical',       'November-February',4.70, 'https://example.com/images/angkor_wat.jpg'),
('Times Square',           'New York',     'USA',          'Bustling commercial intersection famed for bright lights and theaters.',  'Continental',    'Year-Round',       4.40, 'https://example.com/images/times_square.jpg'),
('Buckingham Palace',      'London',       'UK',           'Official London residence of the British monarch.',                      'Temperate',      'Summer',           4.30, 'https://example.com/images/buckingham.jpg'),
('Chichen Itza',           'Yucatán',      'Mexico',       'Pre-Columbian Mayan city and major archaeological site.',               'Tropical',       'December-April',   4.50, 'https://example.com/images/chichen_itza.jpg'),
('Table Mountain',         'Cape Town',    'South Africa', 'Flat-topped mountain overlooking the city and Atlantic Ocean.',           'Mediterranean',  'October-April',    4.55, 'https://example.com/images/table_mountain.jpg'),
('Iguazu Falls',           'Puerto Iguazú','Argentina/Brazil','Impressive waterfall system on the Paraná River.',                    'Subtropical',    'August-October',   4.65, 'https://example.com/images/iguazu.jpg'),
('Great Barrier Reef',     'Cairns',       'Australia',    'Worlds largest coral reef system with rich marine biodiversity.',      'Tropical',       'June-November',    4.85, 'https://example.com/images/great_barrier.jpg'),
('Sahara Desert Safari',   'Merzouga',     'Morocco',      'Desert tours including camel treks and overnight camps.',               'Arid',           'October-April',    4.45, 'https://example.com/images/sahara.jpg'),
('Blue Lagoon',            'Reykjavík',    'Iceland',      'Geothermal spa known for its mineral-rich blue waters.',                'Polar',          'Year-Round',       4.80, 'https://example.com/images/blue_lagoon.jpg'),
('Alhambra',               'Granada',      'Spain',        'Moorish palace and gardens atop the hills of Granada.',                  'Mediterranean',  'Spring-Fall',      4.60, 'https://example.com/images/alhambra.jpg'),
('Petronas Towers',        'Kuala Lumpur','Malaysia',     'Twin skyscrapers with an iconic skybridge and observation deck.',       'Tropical',       'June-September',   4.35, 'https://example.com/images/petronas.jpg'),
('Yellowstone NP',         'Wyoming',      'USA',          'First US national park, featuring geysers and diverse wildlife.',       'Continental',    'April-October',    4.90, 'https://example.com/images/yellowstone.jpg'),
('Dubrovnik Old Town',     'Dubrovnik',    'Croatia',      'Walled city on the Adriatic Sea famed for its red roofs.',               'Mediterranean',  'May-September',    4.50, 'https://example.com/images/dubrovnik.jpg'),
('Cinque Terre',           'Liguria',      'Italy',        'Five colorful seaside villages linked by scenic hiking trails.',        'Mediterranean',  'May-September',    4.55, 'https://example.com/images/cinque_terre.jpg'),
('Moraine Lake',           'Banff',        'Canada',       'Stunning glacially-fed lake with vivid blue waters.',                   'Continental',    'June-September',   4.75, 'https://example.com/images/moraine_lake.jpg'),
('Dubai Marina',           'Dubai',        'UAE',          'Modern waterfront district with skyscrapers and yachts.',               'Arid',           'November-March',   4.40, 'https://example.com/images/dubai_marina.jpg'),
('Christ the Redeemer',    'Rio de Janeiro','Brazil',      'Iconic statue atop Corcovado Mountain overlooking the city.',            'Tropical',       'December-March',   4.70, 'https://example.com/images/christ_redeemer.jpg'),
('Antelope Canyon',        'Page',         'USA',          'Slot canyon known for its wave-like structure and light beams.',         'Semi-Arid',      'March-May',        4.65, 'https://example.com/images/antelope_canyon.jpg'),
('Grand Bazaar',           'Istanbul',     'Turkey',       'Historic covered market with thousands of shops and eateries.',         'Mediterranean',  'Spring-Fall',      4.45, 'https://example.com/images/grand_bazaar.jpg'),
('Great Ocean Road',       'Victoria',     'Australia',    'Scenic coastal drive with limestone stacks and rainforests.',           'Temperate',      'October-April',    4.60, 'https://example.com/images/great_ocean_road.jpg'),
('Matterhorn',             'Zermatt',      'Switzerland',  'Iconic pyramidal peak of the Alps popular with climbers.',              'Alpine',         'June-September',   4.80, 'https://example.com/images/matterhorn.jpg'),
('Cinque Terre',           'Liguria',      'Italy',        'Five colorful seaside villages linked by scenic hiking trails.',        'Mediterranean',  'May-September',    4.55, 'https://example.com/images/cinque_terre.jpg'),
('Blue Mountains',         'Katoomba',     'Australia',    'Escarpment area with eucalyptus forests and waterfalls.',               'Temperate',      'March-May',        4.50, 'https://example.com/images/blue_mountains.jpg'),
('Neuschwanstein Castle',  'Schwangau',    'Germany',      'Fairy-tale castle overlooking the Alps and lakes.',                     'Continental',    'June-September',   4.70, 'https://example.com/images/neuschwanstein.jpg'),
('Salar de Uyuni',         'Uyuni',        'Bolivia',      'World’s largest salt flat, a mirror during rainy season.',             'High-Altitude',  'June-November',    4.65, 'https://example.com/images/salar_uyuni.jpg'),
('Forbidden City',         'Beijing',      'China',        'Imperial palace complex at the heart of Beijing.',                      'Continental',    'Spring-Autumn',    4.75, 'https://example.com/images/forbidden_city.jpg'),
('Yellowknife Aurora',     'Yellowknife',  'Canada',       'Prime spot for viewing the northern lights in winter.',                'Polar',          'December-March',   4.80, 'https://example.com/images/northern_lights.jpg'),
('Taj Mahal',              'Agra',         'India',        '17th-century mausoleum and UNESCO World Heritage site.',               'Subtropical',    'October-March',    4.85, 'https://example.com/images/taj_mahal.jpg'),
('Oia Sunset',             'Oia',          'Greece',       'Famous sunset viewpoint over white buildings and the Aegean Sea.',      'Mediterranean',  'May-September',    4.90, 'https://example.com/images/oia_sunset.jpg'),
('Hagia Sophia',           'Istanbul',     'Turkey',       'Historic basilica and mosque known for its dome and mosaics.',          'Mediterranean',  'Spring-Fall',      4.65, 'https://example.com/images/hagia_sophia.jpg'),
('Big Ben',                'London',       'UK',           'Iconic clock tower at the north end of the Palace of Westminster.',    'Temperate',      'Year-Round',       4.40, 'https://example.com/images/big_ben.jpg'),
('Mount Kilimanjaro',      'Moshi',        'Tanzania',     'Africa’s highest peak popular with summit climbers.',                   'Tropical',       'January-March',    4.75, 'https://example.com/images/kilimanjaro.jpg'),
('Great Smoky Mountains',  'Tennessee',    'USA',          'Mountain range known for misty peaks and biodiversity.',              'Temperate',      'April-June',       4.70, 'https://example.com/images/smoky_mountains.jpg'),
('Cinque Terre',           'Liguria',      'Italy',        'Five colorful seaside villages linked by scenic hiking trails.',        'Mediterranean',  'May-September',    4.55, 'https://example.com/images/cinque_terre.jpg');





-- 50 INSERTs for trip_categories

--select * from trip_categories

INSERT INTO trip_categories (name, description) VALUES
('Adventure', 'High-energy activities including trekking, climbing, and rafting'),
('Cultural', 'Heritage, history, and local traditions-focused travel experiences'),
('Leisure', 'Relaxing holidays including beach resorts and scenic stays'),
('Wildlife', 'Safaris, birdwatching, and jungle exploration trips'),
('Pilgrimage', 'Spiritual journeys to holy sites and religious centers'),
('Culinary', 'Food tasting tours and cooking experiences'),
('Luxury', 'Premium-class tours with 5-star accommodations and services'),
('Backpacking', 'Budget trips for solo or group travelers across multiple regions'),
('Eco-Tourism', 'Environmentally responsible travel to natural areas'),
('Photography', 'Trips focused on capturing landscapes, culture, and wildlife'),
('Festival Tours', 'Experiences around cultural, religious, or music festivals'),
('Wellness', 'Yoga, meditation, spa, and health retreats'),
('Marine', 'Scuba diving, snorkeling, or coastal/island adventures'),
('Historical', 'Exploration of ancient cities, ruins, and museums'),
('Honeymoon', 'Romantic destinations and couples retreats'),
('Desert Expeditions', 'Dune bashing, camel rides, and desert camping'),
('Winter Sports', 'Skiing, snowboarding, and ice-climbing tours'),
('City Breaks', 'Short getaways to explore urban destinations'),
('Island Hopping', 'Multi-island beach hopping tours'),
('Volunteer Travel', 'Trips that combine travel with social work opportunities'),
('Jungle Safari', 'Wildlife tours and deep forest adventures'),
('Arctic/Polar', 'Extreme expeditions to polar landscapes'),
('Art & Architecture', 'Tours exploring landmarks, galleries, and designs'),
('Agritourism', 'Farm stays and agricultural experiences'),
('Spiritual Retreats', 'Peaceful environments for healing and reflection'),
('Extreme Sports', 'Bungee jumping, ziplining, and paragliding activities'),
('Bike Tours', 'Bicycle-based travel across regions or cities'),
('Cruise', 'Ocean or river cruises through scenic destinations'),
('Nomad Experience', 'Living and traveling like a local nomad'),
('Language Immersion', 'Learning a new language through local travel'),
('Train Journeys', 'Scenic multi-day train travel experiences'),
('Classic Heritage', 'Old cities and civilizations exploration'),
('Beach Holidays', 'Sun, sand, and relaxation on the coastline'),
('Rural Escapes', 'Tranquil, countryside lifestyle experiences'),
('Wild Camping', 'Off-grid adventures in nature'),
('Tech Tourism', 'Exploring innovative and futuristic cities'),
('Festive Shopping', 'Shopping-focused tours near festive seasons'),
('Gastronomic Trails', 'Regional food and drink trails'),
('Religious Circuits', 'Multi-site religious journey packages'),
('Student Exchange', 'International student travel programs'),
('Family-Friendly', 'Kid-safe, inclusive travel plans for families'),
('Event-Based', 'Travel around sports, concerts, or conferences'),
('Island Retreat', 'Remote, exotic private island stays'),
('Mystery Tours', 'Surprise locations and hidden destination adventures'),
('Eco Lodges', 'Nature-respecting stays in environmentally designed housing'),
('Offbeat Trails', 'Exploring lesser-known villages and terrains'),
('Friendly one', 'Inclusive and supportive destinations and guides'),
('Snow Treks', 'Winter hikes and snowy trail journeys'),
('Gondola & Boat Rides', 'Venetian and other cultural water-based trips'),
('Safari & Stars', 'Night safaris and stargazing in remote areas'),
('Nomadic Culture', 'Learning and living with nomadic tribes');





--select * from trips;
-- 50 INSERTs for trips
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (1, 'Tour Package #1', 1, 1, 9, 23, 682.18, '2025-10-09', '2025-10-18', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.97, 'https://example.com/images/trip1.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (2, 'Tour Package #2', 2, 2, 7, 25, 2111.22, '2025-07-26', '2025-08-02', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.01, 'https://example.com/images/trip2.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (3, 'Tour Package #3', 3, 3, 7, 14, 3901.12, '2025-11-06', '2025-11-13', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.6, 'https://example.com/images/trip3.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (4, 'Tour Package #4', 4, 4, 5, 19, 944.44, '2025-06-19', '2025-06-24', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.8, 'https://example.com/images/trip4.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (5, 'Tour Package #5', 5, 5, 8, 25, 3019.16, '2025-08-30', '2025-09-07', 'Standard 8-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.87, 'https://example.com/images/trip5.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (6, 'Tour Package #6', 6, 6, 6, 25, 2492.12, '2025-10-12', '2025-10-18', 'Standard 6-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.52, 'https://example.com/images/trip6.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (7, 'Tour Package #7', 7, 7, 3, 12, 3738.67, '2025-09-11', '2025-09-14', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.42, 'https://example.com/images/trip7.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (8, 'Tour Package #8', 8, 8, 3, 25, 4226.28, '2025-08-25', '2025-08-28', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.49, 'https://example.com/images/trip8.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (9, 'Tour Package #9', 9, 9, 8, 12, 1359.8, '2025-10-24', '2025-11-01', 'Standard 8-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.44, 'https://example.com/images/trip9.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (10, 'Tour Package #10', 10, 10, 5, 24, 910.47, '2025-08-21', '2025-08-26', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.75, 'https://example.com/images/trip10.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (11, 'Tour Package #11', 11, 11, 10, 13, 1856.51, '2025-08-14', '2025-08-24', 'Standard 10-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.41, 'https://example.com/images/trip11.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (12, 'Tour Package #12', 12, 12, 8, 16, 4837.27, '2025-11-02', '2025-11-10', 'Standard 8-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.09, 'https://example.com/images/trip12.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (13, 'Tour Package #13', 13, 13, 7, 24, 912.34, '2025-12-22', '2025-12-29', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.77, 'https://example.com/images/trip13.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (14, 'Tour Package #14', 14, 14, 6, 19, 1327.41, '2025-07-18', '2025-07-24', 'Standard 6-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.07, 'https://example.com/images/trip14.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (15, 'Tour Package #15', 15, 15, 7, 25, 810.88, '2025-11-21', '2025-11-28', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.52, 'https://example.com/images/trip15.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (16, 'Tour Package #16', 16, 16, 5, 11, 4291.07, '2025-11-27', '2025-12-02', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.85, 'https://example.com/images/trip16.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (17, 'Tour Package #17', 17, 17, 9, 18, 2848.06, '2025-07-31', '2025-08-09', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.7, 'https://example.com/images/trip17.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (18, 'Tour Package #18', 18, 18, 9, 18, 2527.53, '2025-11-17', '2025-11-26', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.28, 'https://example.com/images/trip18.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (19, 'Tour Package #19', 19, 19, 8, 12, 1959.46, '2025-06-30', '2025-07-08', 'Standard 8-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.97, 'https://example.com/images/trip19.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (20, 'Tour Package #20', 20, 20, 8, 16, 1593.66, '2025-12-05', '2025-12-13', 'Standard 8-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.54, 'https://example.com/images/trip20.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (21, 'Tour Package #21', 21, 21, 6, 21, 4075.62, '2025-08-25', '2025-08-31', 'Standard 6-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.85, 'https://example.com/images/trip21.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (22, 'Tour Package #22', 22, 22, 3, 13, 4024.03, '2025-11-26', '2025-11-29', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.44, 'https://example.com/images/trip22.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (23, 'Tour Package #23', 23, 23, 4, 10, 1060.0, '2025-07-19', '2025-07-23', 'Standard 4-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.21, 'https://example.com/images/trip23.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (24, 'Tour Package #24', 24, 24, 4, 22, 911.89, '2025-06-30', '2025-07-04', 'Standard 4-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.07, 'https://example.com/images/trip24.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (25, 'Tour Package #25', 25, 25, 3, 16, 4824.64, '2025-07-18', '2025-07-21', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.44, 'https://example.com/images/trip25.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (26, 'Tour Package #26', 26, 26, 10, 16, 3772.2, '2025-06-16', '2025-06-26', 'Standard 10-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.87, 'https://example.com/images/trip26.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (27, 'Tour Package #27', 27, 27, 3, 23, 3292.7, '2025-08-06', '2025-08-09', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.14, 'https://example.com/images/trip27.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (28, 'Tour Package #28', 28, 28, 4, 19, 2076.32, '2025-07-17', '2025-07-21', 'Standard 4-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.12, 'https://example.com/images/trip28.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (29, 'Tour Package #29', 29, 29, 10, 11, 3184.18, '2025-11-27', '2025-12-07', 'Standard 10-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.98, 'https://example.com/images/trip29.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (30, 'Tour Package #30', 30, 30, 6, 18, 2113.5, '2025-12-05', '2025-12-11', 'Standard 6-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.94, 'https://example.com/images/trip30.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (31, 'Tour Package #31', 31, 31, 5, 16, 4849.47, '2025-06-15', '2025-06-20', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.58, 'https://example.com/images/trip31.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (32, 'Tour Package #32', 32, 32, 5, 15, 2040.41, '2025-08-04', '2025-08-09', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.23, 'https://example.com/images/trip32.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (33, 'Tour Package #33', 33, 33, 10, 15, 559.42, '2025-11-22', '2025-12-02', 'Standard 10-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.82, 'https://example.com/images/trip33.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (34, 'Tour Package #34', 34, 34, 7, 21, 2248.89, '2025-11-16', '2025-11-23', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.5, 'https://example.com/images/trip34.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (35, 'Tour Package #35', 35, 35, 3, 24, 3837.08, '2025-08-25', '2025-08-28', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.48, 'https://example.com/images/trip35.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (36, 'Tour Package #36', 36, 36, 7, 14, 1580.59, '2025-10-02', '2025-10-09', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.7, 'https://example.com/images/trip36.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (37, 'Tour Package #37', 37, 37, 7, 21, 3156.25, '2025-11-10', '2025-11-17', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.71, 'https://example.com/images/trip37.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (38, 'Tour Package #38', 38, 38, 5, 19, 2246.08, '2025-09-15', '2025-09-20', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.66, 'https://example.com/images/trip38.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (39, 'Tour Package #39', 39, 39, 4, 10, 3175.6, '2025-11-26', '2025-11-30', 'Standard 4-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.67, 'https://example.com/images/trip39.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (40, 'Tour Package #40', 40, 40, 6, 17, 3368.3, '2025-09-05', '2025-09-11', 'Standard 6-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.42, 'https://example.com/images/trip40.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (41, 'Tour Package #41', 41, 41, 9, 11, 2310.2, '2025-11-27', '2025-12-06', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.13, 'https://example.com/images/trip41.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (42, 'Tour Package #42', 42, 42, 3, 15, 2504.08, '2025-08-06', '2025-08-09', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.4, 'https://example.com/images/trip42.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (43, 'Tour Package #43', 43, 43, 10, 25, 4586.18, '2025-11-02', '2025-11-12', 'Standard 10-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.51, 'https://example.com/images/trip43.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (44, 'Tour Package #44', 44, 44, 3, 25, 1966.75, '2025-09-28', '2025-10-01', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.1, 'https://example.com/images/trip44.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (45, 'Tour Package #45', 45, 45, 9, 16, 2968.53, '2025-11-10', '2025-11-19', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.96, 'https://example.com/images/trip45.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (46, 'Tour Package #46', 46, 46, 5, 10, 2308.18, '2025-11-21', '2025-11-26', 'Standard 5-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.83, 'https://example.com/images/trip46.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (47, 'Tour Package #47', 47, 47, 3, 16, 564.31, '2025-12-11', '2025-12-14', 'Standard 3-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.0, 'https://example.com/images/trip47.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (48, 'Tour Package #48', 48, 48, 4, 16, 1035.07, '2025-11-14', '2025-11-18', 'Standard 4-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.4, 'https://example.com/images/trip48.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (49, 'Tour Package #49', 49, 49, 7, 18, 3598.43, '2025-07-17', '2025-07-24', 'Standard 7-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 3.2, 'https://example.com/images/trip49.jpg');
INSERT INTO trips (operator_id, name, category_id, destination_id, days, capacity, price, start_date, end_date, description, inclusions, exclusions, cancel_policy, eco_score, image) VALUES (50, 'Tour Package #50', 50, 50, 9, 12, 598.3, '2025-09-24', '2025-10-03', 'Standard 9-day tour package covering key highlights.', 'Hotel, Breakfast, Guided tours', 'Airfare', 'Full refund if canceled 7 days prior', 4.6, 'https://example.com/images/trip50.jpg');





-- 50 INSERTs for itineraries
-- Assumes trips.id values 1–50 exist
--select * from itineraries
INSERT INTO itineraries (trip_id, day_number, activities) VALUES
(1,  1, 'Arrival in destination, hotel check‑in, welcome briefing and orientation.'),
(2,  1, 'Airport pickup, transfer to hotel, evening at leisure.'),
(3,  1, 'Meet guide, city overview tour, welcome dinner at local restaurant.'),
(4,  1, 'Check‑in, safety briefing, short introductory walk around town.'),
(5,  1, 'Arrival and settling in, explore hotel surroundings and amenities.'),
(6,  1, 'Hotel check‑in, orientation session, light city stroll.'),
(7,  1, 'Transfer from airport, evening cultural performance.'),
(8,  1, 'Welcome meeting, local market visit, dinner sampling street food.'),
(9,  1, 'Arrival, room assignment, optional spa relaxation.'),
(10, 1, 'Check‑in, safety & itinerary briefing, sunset viewing spot.'),
(11, 1, 'Meet at hotel lobby, short walking tour, welcome snacks.'),
(12, 1, 'Arrival, luggage drop, free afternoon to explore.'),
(13, 1, 'Hotel check‑in, orientation talk, local dance show.'),
(14, 1, 'Welcome drinks, city highlights brief, rest at leisure.'),
(15, 1, 'Transfer, check‑in, walking orientation around historic district.'),
(16, 1, 'Arrival, transfer, meet-and-greet with guide, dinner included.'),
(17, 1, 'Hotel check‑in, safety briefing, evening welcome party.'),
(18, 1, 'Arrival, check‑in, panoramic city viewpoint visit.'),
(19, 1, 'Meet host, check‑in, sample regional cuisine.'),
(20, 1, 'Arrival, orientation packet distribution, welcome meet.'),
(21, 1, 'Check‑in, leisure time, optional local market tour.'),
(22, 1, 'Arrival, hotel welcome, short riverbank walk.'),
(23, 1, 'Hotel check‑in, briefing, optional museum evening visit.'),
(24, 1, 'Transfer, room assignment, evening cultural show.'),
(25, 1, 'Arrival, orientation, free time to explore beachfront.'),
(26, 1, 'Welcome meeting, hotel check‑in, group icebreaker.'),
(27, 1, 'Check‑in, guided neighborhood stroll, welcome drinks.'),
(28, 1, 'Arrival, lounge rest, introductory city overview.'),
(29, 1, 'Hotel transfer, check‑in, short dockside walk.'),
(30, 1, 'Arrival, safety briefing, sunset boat cruise.'),
(31, 1, 'Arrival, room orientation, brief historical talk.'),
(32, 1, 'Hotel check‑in, city overview bus tour, dinner.'),
(33, 1, 'Meet guide, check‑in, local tasting session.'),
(34, 1, 'Arrival, orientation, evening at leisure near hotel.'),
(35, 1, 'Hotel check‑in, safety briefing, desert sunset experience.'),
(36, 1, 'Arrival, transfer, welcome dinner under the stars.'),
(37, 1, 'Check‑in, orientation, optional hot‑spring visit.'),
(38, 1, 'Arrival, hotel welcome, panoramic tram ride.'),
(39, 1, 'Transfer, check‑in, welcome show at hotel.'),
(40, 1, 'Arrival, meet guide, optional local festival visit.'),
(41, 1, 'Hotel check‑in, orientation, evening cultural performance.'),
(42, 1, 'Arrival, room allocation, free time in town square.'),
(43, 1, 'Transfer, check‑in, introductory museum tour.'),
(44, 1, 'Check‑in, safety talk, short art‑gallery visit.'),
(45, 1, 'Welcome meeting, hotel check‑in, local cuisine sampling.'),
(46, 1, 'Arrival, room orientation, evening at leisure.'),
(47, 1, 'Hotel check‑in, orientation, short historical walk.'),
(48, 1, 'Arrival, welcome briefing, optional city lights tour.'),
(49, 1, 'Check‑in, group introduction, local live music evening.'),
(50, 1, 'Arrival, orientation, welcome dinner with traditional music.');



--select * from trip_assignments
-- 50 INSERTs for trip_assignments
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (1, 9, 'guide', '2025-12-23 02:16:00', 206.13, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (2, 31, 'guide', '2025-09-06 06:06:00', 539.07, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (3, 28, 'guide', '2025-12-13 00:44:00', 500.85, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (4, 38, 'hotel', '2025-08-21 00:01:00', 122.9, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (5, 25, 'guide', '2025-07-26 13:46:00', 126.14, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (6, 49, 'service', '2025-10-05 17:14:00', 411.13, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (7, 49, 'service', '2025-08-14 00:26:00', 853.82, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (8, 12, 'guide', '2025-12-03 09:07:00', 768.83, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (9, 33, 'guide', '2025-07-19 09:18:00', 628.82, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (10, 33, 'service', '2025-10-29 01:30:00', 318.47, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (11, 27, 'guide', '2025-07-15 11:35:00', 894.46, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (12, 6, 'service', '2025-11-17 16:06:00', 800.6, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (13, 24, 'service', '2025-12-05 00:30:00', 139.14, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (14, 42, 'hotel', '2025-07-14 16:14:00', 983.87, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (15, 35, 'guide', '2025-07-30 12:32:00', 409.44, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (16, 30, 'service', '2025-11-16 17:38:00', 961.4, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (17, 25, 'guide', '2025-10-10 04:33:00', 799.66, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (18, 28, 'hotel', '2025-10-02 11:36:00', 598.96, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (19, 32, 'service', '2025-09-15 11:00:00', 584.63, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (20, 30, 'guide', '2025-06-08 07:40:00', 259.49, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (21, 6, 'guide', '2025-12-22 08:02:00', 857.57, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (22, 6, 'hotel', '2025-09-24 00:48:00', 780.03, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (23, 18, 'hotel', '2025-12-22 19:11:00', 409.98, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (24, 11, 'hotel', '2025-08-05 16:10:00', 690.99, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (25, 30, 'guide', '2025-08-22 15:30:00', 202.77, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (26, 25, 'service', '2025-09-16 06:16:00', 197.89, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (27, 39, 'service', '2025-12-27 00:14:00', 116.08, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (28, 3, 'guide', '2025-07-12 14:45:00', 555.68, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (29, 35, 'hotel', '2025-11-09 22:33:00', 505.76, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (30, 26, 'guide', '2025-10-26 10:42:00', 667.85, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (31, 48, 'service', '2025-07-03 06:56:00', 142.7, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (32, 5, 'service', '2025-08-16 23:10:00', 474.56, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (33, 9, 'hotel', '2025-10-22 01:37:00', 837.47, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (34, 11, 'guide', '2025-11-07 16:02:00', 440.17, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (35, 7, 'hotel', '2025-10-25 21:57:00', 489.66, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (36, 32, 'hotel', '2025-11-18 12:18:00', 553.7, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (37, 21, 'guide', '2025-09-11 09:01:00', 241.27, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (38, 37, 'hotel', '2025-08-26 13:13:00', 339.88, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (39, 25, 'guide', '2025-08-28 21:34:00', 536.05, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (40, 5, 'guide', '2025-06-11 02:08:00', 252.72, 'accepted');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (41, 18, 'service', '2025-11-01 16:53:00', 329.76, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (42, 22, 'hotel', '2025-08-14 07:55:00', 949.6, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (43, 9, 'guide', '2025-10-20 03:20:00', 135.22, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (44, 25, 'hotel', '2025-12-30 04:21:00', 203.22, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (45, 5, 'guide', '2025-10-19 07:36:00', 173.57, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (46, 24, 'service', '2025-10-23 17:59:00', 202.88, 'rejected');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (47, 7, 'hotel', '2025-12-29 09:00:00', 652.31, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (48, 6, 'service', '2025-06-30 01:12:00', 315.67, 'completed');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (49, 11, 'hotel', '2025-09-24 05:43:00', 317.28, 'assigned');
INSERT INTO trip_assignments (trip_id, provider_id, assignment_type, service_date, cost, status) VALUES (50, 28, 'service', '2025-12-24 17:58:00', 836.52, 'rejected');








-- 50 INSERTs for trip_images
--select * from trip_images

INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (1, 'https://example.com/images/trips/1_main.jpg', 'Main cover image for Tour Package #1', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (2, 'https://example.com/images/trips/2_main.jpg', 'Main cover image for Tour Package #2', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (3, 'https://example.com/images/trips/3_main.jpg', 'Main cover image for Tour Package #3', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (4, 'https://example.com/images/trips/4_main.jpg', 'Main cover image for Tour Package #4', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (5, 'https://example.com/images/trips/5_main.jpg', 'Main cover image for Tour Package #5', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (6, 'https://example.com/images/trips/6_main.jpg', 'Main cover image for Tour Package #6', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (7, 'https://example.com/images/trips/7_main.jpg', 'Main cover image for Tour Package #7', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (8, 'https://example.com/images/trips/8_main.jpg', 'Main cover image for Tour Package #8', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (9, 'https://example.com/images/trips/9_main.jpg', 'Main cover image for Tour Package #9', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (10, 'https://example.com/images/trips/10_main.jpg', 'Main cover image for Tour Package #10', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (11, 'https://example.com/images/trips/11_main.jpg', 'Main cover image for Tour Package #11', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (12, 'https://example.com/images/trips/12_main.jpg', 'Main cover image for Tour Package #12', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (13, 'https://example.com/images/trips/13_main.jpg', 'Main cover image for Tour Package #13', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (14, 'https://example.com/images/trips/14_main.jpg', 'Main cover image for Tour Package #14', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (15, 'https://example.com/images/trips/15_main.jpg', 'Main cover image for Tour Package #15', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (16, 'https://example.com/images/trips/16_main.jpg', 'Main cover image for Tour Package #16', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (17, 'https://example.com/images/trips/17_main.jpg', 'Main cover image for Tour Package #17', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (18, 'https://example.com/images/trips/18_main.jpg', 'Main cover image for Tour Package #18', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (19, 'https://example.com/images/trips/19_main.jpg', 'Main cover image for Tour Package #19', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (20, 'https://example.com/images/trips/20_main.jpg', 'Main cover image for Tour Package #20', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (21, 'https://example.com/images/trips/21_main.jpg', 'Main cover image for Tour Package #21', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (22, 'https://example.com/images/trips/22_main.jpg', 'Main cover image for Tour Package #22', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (23, 'https://example.com/images/trips/23_main.jpg', 'Main cover image for Tour Package #23', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (24, 'https://example.com/images/trips/24_main.jpg', 'Main cover image for Tour Package #24', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (25, 'https://example.com/images/trips/25_main.jpg', 'Main cover image for Tour Package #25', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (26, 'https://example.com/images/trips/26_main.jpg', 'Main cover image for Tour Package #26', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (27, 'https://example.com/images/trips/27_main.jpg', 'Main cover image for Tour Package #27', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (28, 'https://example.com/images/trips/28_main.jpg', 'Main cover image for Tour Package #28', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (29, 'https://example.com/images/trips/29_main.jpg', 'Main cover image for Tour Package #29', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (30, 'https://example.com/images/trips/30_main.jpg', 'Main cover image for Tour Package #30', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (31, 'https://example.com/images/trips/31_main.jpg', 'Main cover image for Tour Package #31', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (32, 'https://example.com/images/trips/32_main.jpg', 'Main cover image for Tour Package #32', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (33, 'https://example.com/images/trips/33_main.jpg', 'Main cover image for Tour Package #33', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (34, 'https://example.com/images/trips/34_main.jpg', 'Main cover image for Tour Package #34', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (35, 'https://example.com/images/trips/35_main.jpg', 'Main cover image for Tour Package #35', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (36, 'https://example.com/images/trips/36_main.jpg', 'Main cover image for Tour Package #36', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (37, 'https://example.com/images/trips/37_main.jpg', 'Main cover image for Tour Package #37', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (38, 'https://example.com/images/trips/38_main.jpg', 'Main cover image for Tour Package #38', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (39, 'https://example.com/images/trips/39_main.jpg', 'Main cover image for Tour Package #39', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (40, 'https://example.com/images/trips/40_main.jpg', 'Main cover image for Tour Package #40', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (41, 'https://example.com/images/trips/41_main.jpg', 'Main cover image for Tour Package #41', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (42, 'https://example.com/images/trips/42_main.jpg', 'Main cover image for Tour Package #42', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (43, 'https://example.com/images/trips/43_main.jpg', 'Main cover image for Tour Package #43', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (44, 'https://example.com/images/trips/44_main.jpg', 'Main cover image for Tour Package #44', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (45, 'https://example.com/images/trips/45_main.jpg', 'Main cover image for Tour Package #45', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (46, 'https://example.com/images/trips/46_main.jpg', 'Main cover image for Tour Package #46', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (47, 'https://example.com/images/trips/47_main.jpg', 'Main cover image for Tour Package #47', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (48, 'https://example.com/images/trips/48_main.jpg', 'Main cover image for Tour Package #48', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (49, 'https://example.com/images/trips/49_main.jpg', 'Main cover image for Tour Package #49', 1);
INSERT INTO trip_images (trip_id, image, description, is_primary) VALUES (50, 'https://example.com/images/trips/50_main.jpg', 'Main cover image for Tour Package #50', 1);








-- 50 INSERTs for wishlists

--select * from wishlists

INSERT INTO wishlists (user_id, trip_id) VALUES (1, 2);
INSERT INTO wishlists (user_id, trip_id) VALUES (2, 3);
INSERT INTO wishlists (user_id, trip_id) VALUES (3, 4);
INSERT INTO wishlists (user_id, trip_id) VALUES (4, 5);
INSERT INTO wishlists (user_id, trip_id) VALUES (5, 6);
INSERT INTO wishlists (user_id, trip_id) VALUES (6, 7);
INSERT INTO wishlists (user_id, trip_id) VALUES (7, 8);
INSERT INTO wishlists (user_id, trip_id) VALUES (8, 9);
INSERT INTO wishlists (user_id, trip_id) VALUES (9, 10);
INSERT INTO wishlists (user_id, trip_id) VALUES (10, 11);
INSERT INTO wishlists (user_id, trip_id) VALUES (11, 12);
INSERT INTO wishlists (user_id, trip_id) VALUES (12, 13);
INSERT INTO wishlists (user_id, trip_id) VALUES (13, 14);
INSERT INTO wishlists (user_id, trip_id) VALUES (14, 15);
INSERT INTO wishlists (user_id, trip_id) VALUES (15, 16);
INSERT INTO wishlists (user_id, trip_id) VALUES (16, 17);
INSERT INTO wishlists (user_id, trip_id) VALUES (17, 18);
INSERT INTO wishlists (user_id, trip_id) VALUES (18, 19);
INSERT INTO wishlists (user_id, trip_id) VALUES (19, 20);
INSERT INTO wishlists (user_id, trip_id) VALUES (20, 21);
INSERT INTO wishlists (user_id, trip_id) VALUES (21, 22);
INSERT INTO wishlists (user_id, trip_id) VALUES (22, 23);
INSERT INTO wishlists (user_id, trip_id) VALUES (23, 24);
INSERT INTO wishlists (user_id, trip_id) VALUES (24, 25);
INSERT INTO wishlists (user_id, trip_id) VALUES (25, 26);
INSERT INTO wishlists (user_id, trip_id) VALUES (26, 27);
INSERT INTO wishlists (user_id, trip_id) VALUES (27, 28);
INSERT INTO wishlists (user_id, trip_id) VALUES (28, 29);
INSERT INTO wishlists (user_id, trip_id) VALUES (29, 30);
INSERT INTO wishlists (user_id, trip_id) VALUES (30, 31);
INSERT INTO wishlists (user_id, trip_id) VALUES (31, 32);
INSERT INTO wishlists (user_id, trip_id) VALUES (32, 33);
INSERT INTO wishlists (user_id, trip_id) VALUES (33, 34);
INSERT INTO wishlists (user_id, trip_id) VALUES (34, 35);
INSERT INTO wishlists (user_id, trip_id) VALUES (35, 36);
INSERT INTO wishlists (user_id, trip_id) VALUES (36, 37);
INSERT INTO wishlists (user_id, trip_id) VALUES (37, 38);
INSERT INTO wishlists (user_id, trip_id) VALUES (38, 39);
INSERT INTO wishlists (user_id, trip_id) VALUES (39, 40);
INSERT INTO wishlists (user_id, trip_id) VALUES (40, 41);
INSERT INTO wishlists (user_id, trip_id) VALUES (41, 42);
INSERT INTO wishlists (user_id, trip_id) VALUES (42, 43);
INSERT INTO wishlists (user_id, trip_id) VALUES (43, 44);
INSERT INTO wishlists (user_id, trip_id) VALUES (44, 45);
INSERT INTO wishlists (user_id, trip_id) VALUES (45, 46);
INSERT INTO wishlists (user_id, trip_id) VALUES (46, 47);
INSERT INTO wishlists (user_id, trip_id) VALUES (47, 48);
INSERT INTO wishlists (user_id, trip_id) VALUES (48, 49);
INSERT INTO wishlists (user_id, trip_id) VALUES (49, 50);
INSERT INTO wishlists (user_id, trip_id) VALUES (50, 1);




-- 50 INSERTs for bookings

--select * from bookings

INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (4, 6, '2025-06-22', 3, 16792.23, 'cancelled', 'Weather issues');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (39, 14, '2025-11-03', 1, 11833.48, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (28, 41, '2025-09-09', 5, 19013.21, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (33, 18, '2025-06-10', 1, 7598.28, 'cancelled', 'Payment failure');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (28, 34, '2025-07-13', 5, 3960.01, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (2, 12, '2025-08-23', 2, 3165.6, 'cancelled', 'Personal emergency');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (44, 36, '2025-07-17', 4, 16036.82, 'cancelled', 'Personal emergency');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (23, 24, '2025-09-23', 2, 19121.2, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (46, 48, '2025-09-27', 5, 5373.08, 'cancelled', 'Payment failure');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (33, 33, '2025-12-30', 3, 13402.87, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (30, 23, '2025-10-24', 5, 14613.57, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (43, 15, '2025-08-23', 2, 17595.58, 'cancelled', 'Payment failure');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (20, 20, '2025-12-22', 5, 11462.68, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (20, 47, '2025-07-24', 4, 10481.89, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (22, 47, '2025-06-03', 2, 19942.84, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (4, 37, '2025-11-15', 1, 5825.44, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (44, 7, '2025-12-11', 5, 3161.75, 'cancelled', 'Operator cancellation');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (14, 4, '2025-09-17', 1, 1607.53, 'cancelled', 'Operator cancellation');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (16, 44, '2025-06-07', 1, 2746.85, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (2, 3, '2025-12-04', 1, 7775.4, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (11, 48, '2025-07-18', 5, 13984.16, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (38, 3, '2025-12-21', 2, 3452.69, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (1, 23, '2025-11-05', 1, 6077.52, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (2, 20, '2025-09-23', 5, 15436.41, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (17, 49, '2025-09-11', 5, 14254.23, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (15, 6, '2025-11-17', 3, 16848.83, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (29, 9, '2025-10-11', 5, 15730.66, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (33, 21, '2025-07-07', 3, 5552.38, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (42, 2, '2025-11-27', 5, 19200.5, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (17, 3, '2025-07-04', 2, 3828.86, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (41, 15, '2025-10-09', 1, 19893.24, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (46, 29, '2025-06-19', 3, 2068.37, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (40, 40, '2025-11-29', 3, 5503.88, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (18, 34, '2025-12-10', 1, 3446.75, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (27, 11, '2025-06-29', 5, 14613.51, 'confirmed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (7, 7, '2025-06-06', 2, 15136.41, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (14, 2, '2025-10-12', 4, 9350.23, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (14, 44, '2025-12-12', 2, 14714.16, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (28, 33, '2025-06-06', 5, 12031.19, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (34, 38, '2025-07-17', 1, 13434.2, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (24, 2, '2025-10-11', 1, 12404.95, 'cancelled', 'Weather issues');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (20, 2, '2025-11-23', 4, 2472.66, 'cancelled', 'Operator cancellation');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (50, 44, '2025-12-29', 1, 16335.18, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (27, 41, '2025-10-03', 4, 4560.81, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (1, 19, '2025-06-07', 3, 6463.52, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (15, 49, '2025-10-04', 2, 2757.48, 'cancelled', 'Payment failure');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (46, 30, '2025-07-06', 3, 8203.33, 'pending', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (17, 8, '2025-07-02', 1, 12522.56, 'cancelled', 'Payment failure');
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (14, 45, '2025-06-27', 1, 12554.55, 'completed', NULL);
INSERT INTO bookings (trip_id, user_id, travel_date, traveler_count, total, status, cancellation_reason) VALUES (50, 3, '2025-12-03', 4, 6169.68, 'completed', NULL);







-- 50 INSERTs for payments

--select * from payments

INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (1, 1266.03, '2025-12-29 16:35:02', 'Debit Card', 'TXN59654541', 'refunded', 1, 933.1, '2026-01-03 16:35:02');
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (2, 164.52, '2025-11-30 13:33:44', 'PayPal', 'TXN83925063', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (3, 4978.66, '2025-11-30 23:10:24', 'Cryptocurrency', 'TXN83770246', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (4, 3231.43, '2025-07-29 19:50:48', 'Debit Card', 'TXN95209555', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (5, 4636.59, '2025-10-30 18:28:25', 'Credit Card', 'TXN18594154', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (6, 4791.74, '2025-06-17 22:49:21', 'PayPal', 'TXN14162326', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (7, 1420.22, '2025-10-29 20:46:25', 'Bank Transfer', 'TXN63011090', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (8, 2926.86, '2025-07-23 10:21:37', 'PayPal', 'TXN23080096', 'pending', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (9, 2524.93, '2025-09-09 12:33:33', 'Bank Transfer', 'TXN94107309', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (10, 2163.63, '2025-10-29 04:32:03', 'Cryptocurrency', 'TXN57098408', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (11, 2097.12, '2025-08-30 13:59:56', 'PayPal', 'TXN13846729', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (12, 4955.85, '2025-08-03 16:11:55', 'PayPal', 'TXN82714593', 'refunded', 0, 3888.13, '2025-08-09 16:11:55');
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (13, 3201.58, '2025-09-13 01:24:42', 'PayPal', 'TXN26701361', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (14, 4284.32, '2025-12-06 02:37:41', 'Credit Card', 'TXN56181662', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (15, 2111.26, '2025-07-29 21:14:06', 'Credit Card', 'TXN49445415', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (16, 2134.47, '2025-07-17 12:23:20', 'Credit Card', 'TXN91200173', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (17, 320.21, '2025-10-07 20:42:58', 'Cryptocurrency', 'TXN47456610', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (18, 4992.69, '2025-09-29 14:20:02', 'Credit Card', 'TXN20330833', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (19, 2724.33, '2025-08-16 23:45:36', 'Bank Transfer', 'TXN49139553', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (20, 865.38, '2025-06-17 19:31:49', 'PayPal', 'TXN52121619', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (21, 777.8, '2025-10-26 01:15:03', 'Bank Transfer', 'TXN71795134', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (22, 1992.35, '2025-07-11 04:02:52', 'Cryptocurrency', 'TXN78051987', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (23, 3208.02, '2025-09-01 14:55:28', 'PayPal', 'TXN68712975', 'refunded', 0, 2439.9, '2025-09-06 14:55:28');
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (24, 3963.14, '2025-10-01 14:51:38', 'Credit Card', 'TXN60535197', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (25, 3197.68, '2025-06-24 15:59:27', 'PayPal', 'TXN72579073', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (26, 4594.96, '2025-09-17 15:45:50', 'Bank Transfer', 'TXN12977280', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (27, 4778.72, '2025-06-09 14:05:17', 'PayPal', 'TXN43705061', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (28, 1563.32, '2025-10-03 14:51:10', 'Debit Card', 'TXN58849225', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (29, 3814.72, '2025-09-11 21:56:15', 'PayPal', 'TXN60621604', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (30, 4083.98, '2025-07-22 08:55:49', 'PayPal', 'TXN77110302', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (31, 4038.66, '2025-09-02 00:48:01', 'PayPal', 'TXN35151642', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (32, 3282.74, '2025-07-09 00:18:51', 'Credit Card', 'TXN90627828', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (33, 1735.39, '2025-08-27 12:07:20', 'Bank Transfer', 'TXN32720945', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (34, 3736.14, '2025-08-25 00:05:28', 'Cryptocurrency', 'TXN70545910', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (35, 3956.33, '2025-06-14 12:03:14', 'Cryptocurrency', 'TXN35609253', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (36, 4197.4, '2025-08-11 15:08:54', 'PayPal', 'TXN55648746', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (37, 3245.49, '2025-10-13 10:16:08', 'Cryptocurrency', 'TXN27406581', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (38, 2640.15, '2025-09-14 15:31:46', 'Bank Transfer', 'TXN56486884', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (39, 1522.95, '2025-11-07 09:01:22', 'Credit Card', 'TXN65467574', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (40, 122.84, '2025-12-16 10:51:22', 'Bank Transfer', 'TXN85010462', 'refunded', 1, 118.38, '2025-12-18 10:51:22');
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (41, 2337.69, '2025-12-19 21:34:12', 'PayPal', 'TXN82995794', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (42, 1214.59, '2025-06-27 18:26:10', 'Cryptocurrency', 'TXN48521988', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (43, 1298.22, '2025-06-14 23:34:13', 'Cryptocurrency', 'TXN36637983', 'failed', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (44, 4508.41, '2025-06-20 12:02:21', 'Credit Card', 'TXN74565146', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (45, 941.93, '2025-09-25 19:09:33', 'Debit Card', 'TXN98972409', 'pending', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (46, 2731.28, '2025-06-22 00:17:40', 'Cryptocurrency', 'TXN25245430', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (47, 1337.13, '2025-12-28 10:18:20', 'Bank Transfer', 'TXN18236690', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (48, 1066.93, '2025-12-25 23:10:42', 'Credit Card', 'TXN32991800', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (49, 1441.42, '2025-07-21 05:34:11', 'Credit Card', 'TXN75431322', 'successful', 0, NULL, NULL);
INSERT INTO payments (booking_id, amount, paid_at, method, transaction_id, status, is_chargeback, refund_amount, refund_date) VALUES (50, 4326.52, '2025-06-20 17:23:54', 'PayPal', 'TXN43320711', 'successful', 0, NULL, NULL);





-- 50 INSERTs for digital_travel_passes

--select * from digital_travel_passes

INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (1, '2025-09-01 01:07:39', '2025-09-11 01:07:39');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (2, '2025-07-11 10:34:37', '2025-08-04 10:34:37');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (3, '2025-11-02 04:31:49', '2025-11-18 04:31:49');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (4, '2025-07-31 13:26:46', '2025-08-03 13:26:46');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (5, '2025-06-27 04:57:56', '2025-06-28 04:57:56');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (6, '2025-11-04 08:05:58', '2025-11-22 08:05:58');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (7, '2025-09-21 18:10:38', '2025-10-17 18:10:38');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (8, '2025-06-24 05:29:39', '2025-07-02 05:29:39');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (9, '2025-12-20 10:54:48', '2026-01-07 10:54:48');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (10, '2025-10-19 06:43:33', '2025-10-28 06:43:33');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (11, '2025-08-07 10:21:00', '2025-09-03 10:21:00');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (12, '2025-07-12 14:42:00', '2025-07-21 14:42:00');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (13, '2025-08-23 15:21:24', '2025-09-22 15:21:24');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (14, '2025-06-11 07:58:44', '2025-07-08 07:58:44');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (15, '2025-09-10 10:44:40', '2025-10-06 10:44:40');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (16, '2025-09-14 21:52:21', '2025-09-21 21:52:21');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (17, '2025-08-04 09:13:03', '2025-08-14 09:13:03');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (18, '2025-09-21 20:38:48', '2025-10-12 20:38:48');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (19, '2025-10-23 23:57:18', '2025-10-26 23:57:18');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (20, '2025-10-10 09:49:08', '2025-11-01 09:49:08');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (21, '2025-10-30 00:47:12', '2025-11-16 00:47:12');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (22, '2025-09-06 00:40:10', '2025-09-12 00:40:10');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (23, '2025-09-05 10:12:36', '2025-09-21 10:12:36');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (24, '2025-09-18 02:46:00', '2025-09-21 02:46:00');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (25, '2025-12-31 01:21:51', '2026-01-27 01:21:51');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (26, '2025-09-25 23:29:35', '2025-09-26 23:29:35');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (27, '2025-09-22 18:05:36', '2025-10-11 18:05:36');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (28, '2025-09-30 10:50:03', '2025-10-28 10:50:03');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (29, '2025-12-15 19:22:26', '2025-12-22 19:22:26');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (30, '2025-11-09 03:15:24', '2025-11-23 03:15:24');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (31, '2025-09-21 07:15:07', '2025-10-05 07:15:07');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (32, '2025-11-23 16:05:44', '2025-11-29 16:05:44');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (33, '2025-08-30 22:48:58', '2025-09-09 22:48:58');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (34, '2025-09-10 05:09:40', '2025-10-07 05:09:40');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (35, '2025-06-18 04:00:42', '2025-06-21 04:00:42');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (36, '2025-06-19 08:45:08', '2025-07-04 08:45:08');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (37, '2025-09-18 06:49:37', '2025-10-05 06:49:37');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (38, '2025-12-26 00:02:10', '2026-01-16 00:02:10');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (39, '2025-12-01 09:16:33', '2025-12-24 09:16:33');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (40, '2025-10-12 12:31:51', '2025-10-17 12:31:51');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (41, '2025-08-16 07:52:37', '2025-08-19 07:52:37');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (42, '2025-11-08 16:31:30', '2025-12-08 16:31:30');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (43, '2025-08-19 02:01:37', '2025-09-09 02:01:37');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (44, '2025-11-19 16:50:03', '2025-11-28 16:50:03');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (45, '2025-08-11 17:14:31', '2025-08-23 17:14:31');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (46, '2025-11-17 16:06:33', '2025-12-11 16:06:33');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (47, '2025-10-03 21:51:02', '2025-10-24 21:51:02');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (48, '2025-08-17 13:07:54', '2025-09-15 13:07:54');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (49, '2025-10-05 00:33:26', '2025-10-09 00:33:26');
INSERT INTO digital_travel_passes (booking_id, issue_date, expiry_date) VALUES (50, '2025-06-25 07:14:56', '2025-07-18 07:14:56');







-- 50 INSERTs for digital_pass_items

--select * from digital_pass_items

INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (1, 'hotel', 'Hotel Voucher Code: VCHR0001');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (2, 'transport', 'Transport Voucher Code: VCHR0002');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (3, 'guide', 'Guide Voucher Code: VCHR0003');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (4, 'guide', 'Guide Voucher Code: VCHR0004');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (5, 'hotel', 'Hotel Voucher Code: VCHR0005');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (6, 'hotel', 'Hotel Voucher Code: VCHR0006');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (7, 'transport', 'Transport Voucher Code: VCHR0007');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (8, 'hotel', 'Hotel Voucher Code: VCHR0008');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (9, 'transport', 'Transport Voucher Code: VCHR0009');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (10, 'transport', 'Transport Voucher Code: VCHR0010');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (11, 'hotel', 'Hotel Voucher Code: VCHR0011');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (12, 'hotel', 'Hotel Voucher Code: VCHR0012');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (13, 'transport', 'Transport Voucher Code: VCHR0013');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (14, 'guide', 'Guide Voucher Code: VCHR0014');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (15, 'hotel', 'Hotel Voucher Code: VCHR0015');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (16, 'transport', 'Transport Voucher Code: VCHR0016');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (17, 'guide', 'Guide Voucher Code: VCHR0017');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (18, 'guide', 'Guide Voucher Code: VCHR0018');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (19, 'transport', 'Transport Voucher Code: VCHR0019');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (20, 'hotel', 'Hotel Voucher Code: VCHR0020');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (21, 'transport', 'Transport Voucher Code: VCHR0021');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (22, 'transport', 'Transport Voucher Code: VCHR0022');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (23, 'transport', 'Transport Voucher Code: VCHR0023');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (24, 'hotel', 'Hotel Voucher Code: VCHR0024');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (25, 'guide', 'Guide Voucher Code: VCHR0025');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (26, 'transport', 'Transport Voucher Code: VCHR0026');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (27, 'guide', 'Guide Voucher Code: VCHR0027');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (28, 'guide', 'Guide Voucher Code: VCHR0028');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (29, 'hotel', 'Hotel Voucher Code: VCHR0029');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (30, 'transport', 'Transport Voucher Code: VCHR0030');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (31, 'guide', 'Guide Voucher Code: VCHR0031');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (32, 'hotel', 'Hotel Voucher Code: VCHR0032');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (33, 'transport', 'Transport Voucher Code: VCHR0033');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (34, 'transport', 'Transport Voucher Code: VCHR0034');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (35, 'hotel', 'Hotel Voucher Code: VCHR0035');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (36, 'transport', 'Transport Voucher Code: VCHR0036');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (37, 'transport', 'Transport Voucher Code: VCHR0037');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (38, 'guide', 'Guide Voucher Code: VCHR0038');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (39, 'hotel', 'Hotel Voucher Code: VCHR0039');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (40, 'transport', 'Transport Voucher Code: VCHR0040');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (41, 'guide', 'Guide Voucher Code: VCHR0041');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (42, 'hotel', 'Hotel Voucher Code: VCHR0042');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (43, 'transport', 'Transport Voucher Code: VCHR0043');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (44, 'hotel', 'Hotel Voucher Code: VCHR0044');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (45, 'transport', 'Transport Voucher Code: VCHR0045');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (46, 'hotel', 'Hotel Voucher Code: VCHR0046');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (47, 'transport', 'Transport Voucher Code: VCHR0047');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (48, 'transport', 'Transport Voucher Code: VCHR0048');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (49, 'transport', 'Transport Voucher Code: VCHR0049');
INSERT INTO digital_pass_items (pass_id, service_type, details) VALUES (50, 'guide', 'Guide Voucher Code: VCHR0050');






-- 50 INSERTs for trip_schedules

--select * from trip_schedules

INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (1, 40, '2025-09-08 10:55:12', '2025-09-08 11:26:12', '2025-09-08 19:56:12', '2025-09-08 20:25:12');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (2, 50, '2025-09-05 23:20:20', '2025-09-06 01:06:20', '2025-09-06 01:17:20', '2025-09-06 01:07:20');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (3, 8, '2025-10-23 15:21:54', '2025-10-23 16:21:54', '2025-10-23 19:45:54', '2025-10-23 20:24:54');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (4, 7, '2025-09-06 01:55:50', '2025-09-06 00:58:50', '2025-09-06 06:21:50', '2025-09-06 06:26:50');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (5, 12, '2025-10-30 11:49:07', '2025-10-30 11:29:07', '2025-10-30 13:57:07', '2025-10-30 14:46:07');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (6, 40, '2025-11-21 00:10:08', '2025-11-20 23:42:08', '2025-11-21 03:10:08', '2025-11-21 02:40:08');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (7, 14, '2025-08-23 22:25:48', '2025-08-23 22:07:48', '2025-08-24 01:43:48', '2025-08-24 01:53:48');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (8, 13, '2025-12-27 15:55:37', '2025-12-27 17:48:37', '2025-12-27 20:06:37', '2025-12-27 21:04:37');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (9, 13, '2025-10-28 01:54:06', '2025-10-28 02:10:06', '2025-10-28 03:17:06', '2025-10-28 03:40:06');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (10, 11, '2025-07-27 20:02:24', '2025-07-27 20:09:24', '2025-07-27 22:23:24', '2025-07-27 22:31:24');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (11, 39, '2025-06-02 13:31:58', '2025-06-02 15:03:58', '2025-06-02 19:35:58', '2025-06-02 19:44:58');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (12, 23, '2025-09-28 02:43:32', '2025-09-28 03:46:32', '2025-09-28 08:54:32', '2025-09-28 09:25:32');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (13, 31, '2025-08-08 15:33:29', '2025-08-08 14:47:29', '2025-08-08 20:34:29', '2025-08-08 20:49:29');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (14, 26, '2025-06-08 06:24:05', '2025-06-08 07:44:05', '2025-06-08 13:47:05', '2025-06-08 14:05:05');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (15, 38, '2025-06-04 18:37:00', '2025-06-04 19:32:00', '2025-06-04 20:22:00', '2025-06-04 20:15:00');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (16, 40, '2025-08-16 13:42:53', '2025-08-16 13:12:53', '2025-08-16 18:41:53', '2025-08-16 19:10:53');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (17, 23, '2025-12-17 06:48:32', '2025-12-17 07:18:32', '2025-12-17 16:04:32', '2025-12-17 16:33:32');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (18, 7, '2025-10-21 21:27:29', '2025-10-21 21:42:29', '2025-10-21 22:54:29', '2025-10-21 22:35:29');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (19, 14, '2025-10-11 13:55:55', '2025-10-11 15:06:55', '2025-10-12 00:18:55', '2025-10-12 00:06:55');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (20, 22, '2025-09-16 07:29:24', '2025-09-16 09:28:24', '2025-09-16 16:34:24', '2025-09-16 16:43:24');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (21, 44, '2025-10-02 06:47:23', '2025-10-02 07:05:23', '2025-10-02 10:38:23', '2025-10-02 10:18:23');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (22, 41, '2025-07-29 01:33:02', '2025-07-29 03:29:02', '2025-07-29 07:03:02', '2025-07-29 06:53:02');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (23, 47, '2025-06-20 02:32:20', '2025-06-20 01:52:20', '2025-06-20 13:06:20', '2025-06-20 13:27:20');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (24, 3, '2025-09-01 10:08:14', '2025-09-01 11:40:14', '2025-09-01 17:00:14', '2025-09-01 17:02:14');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (25, 30, '2025-11-12 01:03:46', '2025-11-12 00:40:46', '2025-11-12 03:01:46', '2025-11-12 03:52:46');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (26, 3, '2025-12-09 22:21:06', '2025-12-09 22:46:06', '2025-12-10 02:29:06', '2025-12-10 03:11:06');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (27, 9, '2025-11-08 23:06:16', '2025-11-08 22:33:16', '2025-11-09 02:33:16', '2025-11-09 02:50:16');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (28, 10, '2025-06-24 01:46:54', '2025-06-24 02:33:54', '2025-06-24 06:55:54', '2025-06-24 07:23:54');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (29, 40, '2025-08-05 23:53:46', '2025-08-06 01:06:46', '2025-08-06 08:24:46', '2025-08-06 09:22:46');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (30, 47, '2025-10-02 15:11:58', '2025-10-02 16:13:58', '2025-10-02 20:29:58', '2025-10-02 20:59:58');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (31, 26, '2025-07-28 03:32:17', '2025-07-28 03:00:17', '2025-07-28 11:24:17', '2025-07-28 12:02:17');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (32, 12, '2025-12-12 04:01:21', '2025-12-12 04:27:21', '2025-12-12 07:06:21', '2025-12-12 07:38:21');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (33, 18, '2025-12-18 07:48:54', '2025-12-18 09:08:54', '2025-12-18 17:11:54', '2025-12-18 16:49:54');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (34, 50, '2025-10-17 09:21:11', '2025-10-17 11:18:11', '2025-10-17 20:03:11', '2025-10-17 19:37:11');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (35, 49, '2025-09-27 23:19:19', '2025-09-27 23:52:19', '2025-09-28 09:04:19', '2025-09-28 09:59:19');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (36, 18, '2025-12-06 20:54:51', '2025-12-06 21:01:51', '2025-12-07 02:15:51', '2025-12-07 03:08:51');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (37, 12, '2025-06-05 17:56:22', '2025-06-05 18:57:22', '2025-06-06 03:45:22', '2025-06-06 03:47:22');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (38, 21, '2025-09-15 12:55:48', '2025-09-15 13:53:48', '2025-09-15 18:47:48', '2025-09-15 19:21:48');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (39, 42, '2025-10-17 17:28:45', '2025-10-17 17:57:45', '2025-10-17 23:09:45', '2025-10-17 23:23:45');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (40, 48, '2025-11-06 21:12:26', '2025-11-06 21:41:26', '2025-11-07 01:07:26', '2025-11-07 02:05:26');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (41, 29, '2025-10-20 17:17:10', '2025-10-20 17:42:10', '2025-10-21 02:26:10', '2025-10-21 03:03:10');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (42, 11, '2025-08-17 09:34:55', '2025-08-17 10:06:55', '2025-08-17 17:52:55', '2025-08-17 18:50:55');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (43, 6, '2025-11-10 01:18:16', '2025-11-10 01:01:16', '2025-11-10 12:07:16', '2025-11-10 12:51:16');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (44, 34, '2025-11-11 16:03:57', '2025-11-11 16:20:57', '2025-11-12 02:38:57', '2025-11-12 03:29:57');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (45, 18, '2025-06-11 23:27:21', '2025-06-11 23:17:21', '2025-06-12 03:04:21', '2025-06-12 03:30:21');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (46, 40, '2025-08-10 10:38:40', '2025-08-10 10:34:40', '2025-08-10 14:18:40', '2025-08-10 13:53:40');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (47, 31, '2025-08-28 02:44:01', '2025-08-28 02:26:01', '2025-08-28 04:41:01', '2025-08-28 04:28:01');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (48, 8, '2025-10-02 11:55:27', '2025-10-02 11:41:27', '2025-10-02 20:07:27', '2025-10-02 20:47:27');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (49, 3, '2025-11-09 14:38:43', '2025-11-09 15:37:43', '2025-11-09 21:02:43', '2025-11-09 21:56:43');
INSERT INTO trip_schedules (trip_id, transport_provider_id, planned_departure, actual_departure, planned_arrival, actual_arrival) VALUES (50, 40, '2025-06-29 04:52:26', '2025-06-29 06:23:26', '2025-06-29 09:07:26', '2025-06-29 09:24:26');







-- 50 INSERTs for tickets

select * from tickets

INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (37, 32, 'inquiry', 'Booking Confirmation Issue', 'User #37 reports issue: booking confirmation issue.', '2025-06-01 13:42:00', 'closed', 'high', '2025-06-03 13:42:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (21, 18, 'inquiry', 'App Crash on Payment', 'User #21 reports issue: app crash on payment.', '2025-12-04 22:58:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (37, 47, 'inquiry', 'General Feedback', 'User #37 reports issue: general feedback.', '2025-11-23 11:54:00', 'closed', 'medium', '2025-11-23 23:54:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (24, 17, 'inquiry', 'Trip Change Request', 'User #24 reports issue: trip change request.', '2025-12-11 15:44:00', 'resolved', 'low', '2025-12-11 21:44:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (38, 42, 'inquiry', 'Travel Dates Clarification', 'User #38 reports issue: travel dates clarification.', '2025-12-31 15:32:00', 'open', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (24, NULL, 'inquiry', 'Login Not Working', 'User #24 reports issue: login not working.', '2025-09-01 03:07:00', 'open', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (44, 8, 'inquiry', 'Login Not Working', 'User #44 reports issue: login not working.', '2025-12-02 15:24:00', 'closed', 'low', '2025-12-03 09:24:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (39, NULL, 'support', 'App Crash on Payment', 'User #39 reports issue: app crash on payment.', '2025-12-17 14:01:00', 'resolved', 'high', '2025-12-19 06:01:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (24, 25, 'inquiry', 'Need Refund Details', 'User #24 reports issue: need refund details.', '2025-11-22 00:03:00', 'in progress', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (39, 26, 'support', 'Travel Dates Clarification', 'User #39 reports issue: travel dates clarification.', '2025-08-02 11:57:00', 'closed', 'medium', '2025-08-04 12:57:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (5, 31, 'inquiry', 'Voucher Code Invalid', 'User #5 reports issue: voucher code invalid.', '2025-06-22 15:47:00', 'resolved', 'medium', '2025-06-25 06:47:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (47, 12, 'support', 'Booking Confirmation Issue', 'User #47 reports issue: booking confirmation issue.', '2025-10-16 12:16:00', 'resolved', 'low', '2025-10-17 21:16:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (33, 34, 'inquiry', 'Voucher Code Invalid', 'User #33 reports issue: voucher code invalid.', '2025-09-17 04:31:00', 'resolved', 'high', '2025-09-19 17:31:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (43, 10, 'inquiry', 'Travel Dates Clarification', 'User #43 reports issue: travel dates clarification.', '2025-08-19 05:51:00', 'closed', 'medium', '2025-08-21 04:51:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (43, NULL, 'inquiry', 'General Feedback', 'User #43 reports issue: general feedback.', '2025-08-08 19:41:00', 'closed', 'medium', '2025-08-09 16:41:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (19, 40, 'inquiry', 'Booking Confirmation Issue', 'User #19 reports issue: booking confirmation issue.', '2025-07-17 09:39:00', 'open', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (46, 32, 'support', 'App Crash on Payment', 'User #46 reports issue: app crash on payment.', '2025-07-10 17:39:00', 'open', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (34, 31, 'support', 'Trip Change Request', 'User #34 reports issue: trip change request.', '2025-09-03 20:09:00', 'in progress', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (21, NULL, 'support', 'Trip Change Request', 'User #21 reports issue: trip change request.', '2025-06-13 05:30:00', 'closed', 'high', '2025-06-13 14:30:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (41, NULL, 'support', 'General Feedback', 'User #41 reports issue: general feedback.', '2025-12-31 11:10:00', 'resolved', 'high', '2026-01-02 21:10:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (32, 41, 'support', 'App Crash on Payment', 'User #32 reports issue: app crash on payment.', '2025-09-22 00:49:00', 'closed', 'medium', '2025-09-25 00:49:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (18, 38, 'support', 'Login Not Working', 'User #18 reports issue: login not working.', '2025-09-02 18:23:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (33, 18, 'inquiry', 'Travel Dates Clarification', 'User #33 reports issue: travel dates clarification.', '2025-09-19 23:59:00', 'resolved', 'low', '2025-09-20 10:59:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (16, 41, 'support', 'Help With Digital Pass', 'User #16 reports issue: help with digital pass.', '2025-12-08 10:47:00', 'in progress', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (24, NULL, 'support', 'Voucher Code Invalid', 'User #24 reports issue: voucher code invalid.', '2025-08-27 11:10:00', 'open', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (36, NULL, 'inquiry', 'Trip Change Request', 'User #36 reports issue: trip change request.', '2025-07-03 11:22:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (34, 12, 'inquiry', 'Need Refund Details', 'User #34 reports issue: need refund details.', '2025-10-09 03:54:00', 'closed', 'low', '2025-10-10 08:54:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (45, 9, 'inquiry', 'Need Refund Details', 'User #45 reports issue: need refund details.', '2025-12-11 19:15:00', 'open', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (25, NULL, 'inquiry', 'Voucher Code Invalid', 'User #25 reports issue: voucher code invalid.', '2025-10-13 23:00:00', 'closed', 'high', '2025-10-16 22:00:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (43, NULL, 'support', 'Help With Digital Pass', 'User #43 reports issue: help with digital pass.', '2025-12-25 08:23:00', 'resolved', 'high', '2025-12-26 08:23:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (10, NULL, 'support', 'Voucher Code Invalid', 'User #10 reports issue: voucher code invalid.', '2025-06-20 10:00:00', 'open', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (49, NULL, 'support', 'Inquiry About Destination', 'User #49 reports issue: inquiry about destination.', '2025-10-31 10:03:00', 'in progress', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (15, 45, 'inquiry', 'Trip Change Request', 'User #15 reports issue: trip change request.', '2025-09-29 11:46:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (43, 8, 'support', 'Booking Confirmation Issue', 'User #43 reports issue: booking confirmation issue.', '2025-11-23 09:48:00', 'closed', 'high', '2025-11-24 22:48:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (17, 13, 'support', 'Login Not Working', 'User #17 reports issue: login not working.', '2025-10-30 09:16:00', 'resolved', 'high', '2025-10-30 21:16:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (38, 3, 'inquiry', 'Inquiry About Destination', 'User #38 reports issue: inquiry about destination.', '2025-11-24 12:14:00', 'open', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (45, 28, 'support', 'Inquiry About Destination', 'User #45 reports issue: inquiry about destination.', '2025-07-06 09:00:00', 'resolved', 'low', '2025-07-09 00:00:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (1, 17, 'support', 'General Feedback', 'User #1 reports issue: general feedback.', '2025-11-05 17:14:00', 'in progress', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (27, 16, 'inquiry', 'General Feedback', 'User #27 reports issue: general feedback.', '2025-09-19 03:33:00', 'closed', 'medium', '2025-09-20 12:33:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (9, NULL, 'support', 'App Crash on Payment', 'User #9 reports issue: app crash on payment.', '2025-12-12 23:06:00', 'in progress', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (7, 1, 'support', 'Trip Change Request', 'User #7 reports issue: trip change request.', '2025-07-10 03:25:00', 'closed', 'medium', '2025-07-12 23:25:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (50, 31, 'support', 'Voucher Code Invalid', 'User #50 reports issue: voucher code invalid.', '2025-07-10 23:55:00', 'open', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (27, NULL, 'support', 'Login Not Working', 'User #27 reports issue: login not working.', '2025-09-04 03:54:00', 'resolved', 'low', '2025-09-04 04:54:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (50, 6, 'inquiry', 'General Feedback', 'User #50 reports issue: general feedback.', '2025-11-06 16:59:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (25, 49, 'support', 'Help With Digital Pass', 'User #25 reports issue: help with digital pass.', '2025-06-14 01:33:00', 'closed', 'medium', '2025-06-15 20:33:00');
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (46, 18, 'support', 'Login Not Working', 'User #46 reports issue: login not working.', '2025-07-04 10:07:00', 'in progress', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (33, NULL, 'support', 'Trip Change Request', 'User #33 reports issue: trip change request.', '2026-01-01 06:48:00', 'open', 'low', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (23, 47, 'support', 'Need Refund Details', 'User #23 reports issue: need refund details.', '2025-07-18 16:40:00', 'in progress', 'medium', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (48, 40, 'support', 'General Feedback', 'User #48 reports issue: general feedback.', '2025-07-05 23:51:00', 'in progress', 'high', NULL);
INSERT INTO tickets (user_id, related_id, type, subject, description, created_at, status, priority, resolved_at) VALUES (24, 22, 'inquiry', 'Trip Change Request', 'User #24 reports issue: trip change request.', '2025-08-10 09:03:00', 'open', 'medium', NULL);




-- 50 INSERTs for reviews

select * from reviews

INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (21, 'hotel', 26, 1, 'Very well organized.', '2025-12-29 03:06:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (38, 'trip', 33, 2, 'Amazing experience!', '2025-06-23 23:26:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (16, 'trip', 36, 4, 'Amazing experience!', '2025-12-30 04:07:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (41, 'trip', 37, 5, 'Too expensive.', '2025-06-13 17:02:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (19, 'guide', 10, 5, 'Very well organized.', '2025-10-25 19:35:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (7, 'hotel', 24, 1, 'Service was top-notch!', '2025-11-30 12:36:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (40, 'hotel', 32, 5, 'Too expensive.', '2025-12-16 20:29:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (24, 'service', 16, 2, 'Would recommend.', '2025-06-22 04:19:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (22, 'guide', 19, 5, 'Very well organized.', '2025-07-02 02:26:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (49, 'service', 10, 4, 'Too expensive.', '2025-06-12 07:04:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (22, 'service', 39, 4, 'Not what I expected.', '2025-12-23 00:04:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (18, 'guide', 45, 1, 'Amazing experience!', '2025-12-06 08:19:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (19, 'guide', 43, 3, 'Amazing experience!', '2025-09-27 21:10:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (32, 'trip', 14, 3, 'Could be better.', '2025-12-07 17:25:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (32, 'trip', 11, 4, 'Too expensive.', '2025-10-19 18:56:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (28, 'service', 46, 4, 'Lovely accommodation.', '2025-11-22 22:14:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (6, 'hotel', 10, 2, 'Would recommend.', '2025-06-05 01:53:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (17, 'service', 1, 2, 'Too expensive.', '2025-10-15 21:39:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (9, 'trip', 30, 5, 'Too expensive.', '2025-09-10 22:25:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (31, 'guide', 4, 2, 'Very well organized.', '2025-07-25 00:10:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (22, 'trip', 7, 1, 'Not what I expected.', '2025-07-10 03:06:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (40, 'trip', 5, 2, 'Not what I expected.', '2025-09-05 14:40:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (23, 'service', 31, 1, 'Very well organized.', '2025-10-04 00:30:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (20, 'trip', 10, 1, 'Lovely accommodation.', '2025-12-07 18:30:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (34, 'trip', 14, 5, 'Lovely accommodation.', '2025-07-09 08:34:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (49, 'service', 42, 1, 'Excellent guide service.', '2025-10-11 21:58:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (23, 'hotel', 35, 5, 'Service was top-notch!', '2025-08-25 06:14:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (16, 'guide', 48, 2, 'Would recommend.', '2025-10-12 01:22:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (2, 'service', 31, 3, 'Would recommend.', '2025-11-26 05:22:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (47, 'service', 24, 1, 'Would recommend.', '2025-06-27 17:30:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (22, 'hotel', 31, 5, 'Not what I expected.', '2025-06-02 01:58:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (42, 'trip', 43, 1, 'Too expensive.', '2025-12-19 08:48:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (31, 'hotel', 28, 3, 'Very well organized.', '2025-12-24 09:25:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (26, 'trip', 47, 2, 'Could be better.', '2025-07-03 10:09:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (42, 'hotel', 40, 5, 'Great value for money.', '2025-11-16 21:09:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (2, 'trip', 47, 1, 'Service was top-notch!', '2025-12-09 14:27:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (14, 'trip', 17, 2, 'Excellent guide service.', '2025-10-07 17:48:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (17, 'guide', 9, 1, 'Lovely accommodation.', '2025-09-27 07:37:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (33, 'hotel', 35, 2, 'Service was top-notch!', '2025-10-09 10:55:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (50, 'hotel', 39, 1, 'Could be better.', '2025-07-15 14:30:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (36, 'trip', 21, 5, 'Service was top-notch!', '2025-10-22 01:50:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (36, 'trip', 16, 2, 'Excellent guide service.', '2025-06-11 13:32:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (36, 'trip', 49, 1, 'Great value for money.', '2025-08-24 05:32:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (45, 'service', 29, 5, 'Service was top-notch!', '2025-12-25 01:32:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (45, 'service', 36, 2, 'Great value for money.', '2025-07-06 23:07:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (29, 'service', 5, 2, 'Too expensive.', '2025-06-19 16:42:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (8, 'hotel', 46, 3, 'Could be better.', '2025-08-04 14:29:00', 0);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (48, 'trip', 26, 4, 'Could be better.', '2025-11-18 17:10:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (33, 'guide', 22, 4, 'Would recommend.', '2025-08-31 20:05:00', 1);
INSERT INTO reviews (user_id, review_type, reference_id, rating, comment, posted_at, is_moderated) VALUES (2, 'service', 36, 4, 'Great value for money.', '2025-11-28 10:24:00', 1);





-- 50 INSERTs for system_logs

select * from system_logs


INSERT INTO system_logs (user_id, log_type, activity_type, action, description, ip_address, user_agent, timestamp) VALUES
(1,  'activity', 'login',          NULL,               'User #1 logged in.',                       '192.168.0.1',  'Mozilla/5.0',    '2025-01-02 08:15:00'),
(2,  'audit',    NULL,             'User Approved',    'Admin approved user #2.',                  '192.168.0.2',  'Chrome/110.0',   '2025-01-03 09:30:00'),
(3,  'activity', 'search',         NULL,               'User #3 searched for "beach trips".',      '192.168.0.3',  'Safari/15.0',    '2025-01-04 10:45:00'),
(4,  'audit',    NULL,             'Category Added',   'Admin added category "Adventure".',        '192.168.0.4',  'Edge/91.0',      '2025-01-05 11:00:00'),
(5,  'activity', 'booking',        NULL,               'User #5 created booking #7.',             '192.168.0.5',  'Mozilla/5.0',    '2025-01-06 12:10:00'),
(6,  'audit',    NULL,             'Trip Created',     'Operator #6 created trip #12.',           '192.168.0.6',  'Chrome/110.0',   '2025-01-07 13:20:00'),
(7,  'activity', 'review',         NULL,               'User #7 posted a review.',                '192.168.0.7',  'Safari/15.0',    '2025-01-08 14:30:00'),
(8,  'audit',    NULL,             'Booking Deleted',  'Admin deleted booking #8.',               '192.168.0.8',  'Edge/91.0',      '2025-01-09 15:40:00'),
(9,  'activity', 'logout',         NULL,               'User #9 logged out.',                      '192.168.0.9',  'Mozilla/5.0',    '2025-01-10 16:50:00'),
(10, 'audit',    NULL,             'Refund Processed', 'System processed refund for booking #10.', '192.168.0.10', 'Chrome/110.0',   '2025-01-11 17:00:00'),
(11, 'activity', 'search',         NULL,               'User #11 searched for "mountain tours".',  '192.168.0.11', 'Safari/15.0',    '2025-01-12 08:05:00'),
(12, 'audit',    NULL,             'User Approved',    'Admin approved user #12.',                 '192.168.0.12', 'Edge/91.0',      '2025-01-13 09:15:00'),
(13, 'activity', 'booking',        NULL,               'User #13 created booking #15.',            '192.168.0.13', 'Mozilla/5.0',    '2025-01-14 10:25:00'),
(14, 'audit',    NULL,             'Trip Created',     'Operator #14 created trip #20.',           '192.168.0.14', 'Chrome/110.0',   '2025-01-15 11:35:00'),
(15, 'activity', 'review',         NULL,               'User #15 posted a review.',                '192.168.0.15', 'Safari/15.0',    '2025-01-16 12:45:00'),
(16, 'audit',    NULL,             'Category Added',   'Admin added category "Cultural".',         '192.168.0.16', 'Edge/91.0',      '2025-01-17 13:55:00'),
(17, 'activity', 'search',         NULL,               'User #17 searched for "desert safari".',   '192.168.0.17', 'Mozilla/5.0',    '2025-01-18 14:05:00'),
(18, 'audit',    NULL,             'Booking Deleted',  'Admin deleted booking #18.',               '192.168.0.18', 'Chrome/110.0',   '2025-01-19 15:15:00'),
(19, 'activity', 'logout',         NULL,               'User #19 logged out.',                     '192.168.0.19', 'Safari/15.0',    '2025-01-20 16:25:00'),
(20, 'audit',    NULL,             'Refund Processed', 'System processed refund for booking #20.', '192.168.0.20', 'Edge/91.0',      '2025-01-21 17:35:00'),
(21, 'activity', 'booking',        NULL,               'User #21 created booking #22.',            '192.168.0.21', 'Mozilla/5.0',    '2025-01-22 08:45:00'),
(22, 'audit',    NULL,             'User Approved',    'Admin approved user #22.',                 '192.168.0.22', 'Chrome/110.0',   '2025-01-23 09:55:00'),
(23, 'activity', 'search',         NULL,               'User #23 searched for "city tour".',       '192.168.0.23', 'Safari/15.0',    '2025-01-24 10:05:00'),
(24, 'audit',    NULL,             'Trip Created',     'Operator #24 created trip #28.',           '192.168.0.24', 'Edge/91.0',      '2025-01-25 11:15:00'),
(25, 'activity', 'review',         NULL,               'User #25 posted a review.',                '192.168.0.25', 'Mozilla/5.0',    '2025-01-26 12:25:00'),
(26, 'audit',    NULL,             'Category Added',   'Admin added category "Leisure".',          '192.168.0.26', 'Chrome/110.0',   '2025-01-27 13:35:00'),
(27, 'activity', 'logout',         NULL,               'User #27 logged out.',                     '192.168.0.27', 'Safari/15.0',    '2025-01-28 14:45:00'),
(28, 'audit',    NULL,             'Booking Deleted',  'Admin deleted booking #28.',               '192.168.0.28', 'Edge/91.0',      '2025-01-29 15:55:00'),
(29, 'activity', 'search',         NULL,               'User #29 searched for "jungle safari".',   '192.168.0.29', 'Mozilla/5.0',    '2025-01-30 16:05:00'),
(30, 'audit',    NULL,             'Refund Processed', 'System processed refund for booking #30.', '192.168.0.30', 'Chrome/110.0',   '2025-01-31 17:15:00'),
(31, 'activity', 'booking',        NULL,               'User #31 created booking #35.',            '192.168.0.31', 'Safari/15.0',    '2025-02-01 08:25:00'),
(32, 'audit',    NULL,             'User Approved',    'Admin approved user #32.',                 '192.168.0.32', 'Edge/91.0',      '2025-02-02 09:35:00'),
(33, 'activity', 'review',         NULL,               'User #33 posted a review.',                '192.168.0.33', 'Mozilla/5.0',    '2025-02-03 10:45:00'),
(34, 'audit',    NULL,             'Category Added',   'Admin added category "Wildlife".',         '192.168.0.34', 'Chrome/110.0',   '2025-02-04 11:55:00'),
(35, 'activity', 'search',         NULL,               'User #35 searched for "pilgrimage tour".', '192.168.0.35', 'Safari/15.0',    '2025-02-05 12:05:00'),
(36, 'audit',    NULL,             'Trip Created',     'Operator #36 created trip #40.',           '192.168.0.36', 'Edge/91.0',      '2025-02-06 13:15:00'),
(37, 'activity', 'logout',         NULL,               'User #37 logged out.',                     '192.168.0.37', 'Mozilla/5.0',    '2025-02-07 14:25:00'),
(38, 'audit',    NULL,             'Booking Deleted',  'Admin deleted booking #38.',               '192.168.0.38', 'Chrome/110.0',   '2025-02-08 15:35:00'),
(39, 'activity', 'booking',        NULL,               'User #39 created booking #42.',            '192.168.0.39', 'Safari/15.0',    '2025-02-09 16:45:00'),
(40, 'audit',    NULL,             'Refund Processed', 'System processed refund for booking #40.', '192.168.0.40', 'Edge/91.0',      '2025-02-10 17:55:00'),
(41, 'activity', 'search',         NULL,               'User #41 searched for "art tour".',        '192.168.0.41', 'Mozilla/5.0',    '2025-02-11 08:05:00'),
(42, 'audit',    NULL,             'User Approved',    'Admin approved user #42.',                 '192.168.0.42', 'Chrome/110.0',   '2025-02-12 09:15:00'),
(43, 'activity', 'review',         NULL,               'User #43 posted a review.',                '192.168.0.43', 'Safari/15.0',    '2025-02-13 10:25:00'),
(44, 'audit',    NULL,             'Category Added',   'Admin added category "Cuisine".',          '192.168.0.44', 'Edge/91.0',      '2025-02-14 11:35:00'),
(45, 'activity', 'logout',         NULL,               'User #45 logged out.',                     '192.168.0.45', 'Mozilla/5.0',    '2025-02-15 12:45:00'),
(46, 'audit',    NULL,             'Trip Created',     'Operator #46 created trip #48.',           '192.168.0.46', 'Chrome/110.0',   '2025-02-16 13:55:00'),
(47, 'activity', 'search',         NULL,               'User #47 searched for "ski trip".',        '192.168.0.47', 'Safari/15.0',    '2025-02-17 14:05:00'),
(48, 'audit',    NULL,             'Booking Deleted',  'Admin deleted booking #48.',               '192.168.0.48', 'Edge/91.0',      '2025-02-18 15:15:00'),
(49, 'activity', 'booking',        NULL,               'User #49 created booking #50.',            '192.168.0.49', 'Mozilla/5.0',    '2025-02-19 16:25:00'),
(50, 'audit',    NULL,             'Refund Processed', 'System processed refund for booking #50.', '192.168.0.50', 'Chrome/110.0',   '2025-02-20 17:35:00');








