# SYOS Billing System

## Overview

The SYOS Billing System is a comprehensive Java-based web application designed for supermarket billing and inventory management. It implements asynchronous processing to handle high-concurrency scenarios, ensuring efficient bill processing even under load. The system supports user authentication, product management, discount strategies, inventory tracking, and detailed reporting.

## Architecture Design

### System Architecture Overview

The SYOS Billing System implements Clean Architecture principles with a multi-tier client-server design, ensuring scalability, maintainability, and testability.

#### Architectural Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  ┌─────────────────────────────────┐ │
│  │   Web Layer (HTTP Interface)   │ │
│  │  • Servlets (Controllers)      │ │
│  │  • JSP Pages (Views)           │ │
│  │  • Filters                     │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│       Application Layer             │
│  ┌─────────────────────────────────┐ │
│  │   Use Cases & Business Logic    │ │
│  │  • Services (Orchestrators)    │ │
│  │  • DTOs (Data Transfer)        │ │
│  │  • Strategies (Business Rules) │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│         Domain Layer                │
│  ┌─────────────────────────────────┐ │
│  │   Core Business Entities       │ │
│  │  • Model Classes - Define core business entities │ │
│  │    such as Bill, BillItem, Product, and User │ │
│  │  • Enums - Contain well-defined constant sets │ │
│  │    like DiscountType, TransactionType, and UserType, │ │
│  │    improving code readability and integrity │ │
│  │  • Strategy Implementations - Define business logic │ │
│  │    variations, such as different pricing or discount │ │
│  │    strategies (PricingStrategy, DiscountStrategy) │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│       Infrastructure Layer          │
│  ┌─────────────────────────────────┐ │
│  │   External Interfaces           │ │
│  │  • Repositories (Data Access)  │ │
│  │  • Database Manager            │ │
│  │  • Configuration Loader        │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Component Allocation Matrix

| Layer | Components | Responsibilities | Dependencies |
|-------|------------|------------------|--------------|
| **Presentation** | Servlets, JSP, Filters | HTTP handling, UI rendering, request routing | Application Layer |
| **Application** | Services, DTOs, Strategies | Business orchestration, data transformation, rule application | Domain Layer |

#### Service Classes - Core Business Logic Components

Service classes contain the core business workflows and logic for various business domains. The system implements a comprehensive service layer with the following components:

**Core Business Services:**
- **StoreBillingService** — Handles billing transactions, invoice creation, payment processing, bill management, and receipt generation
- **ReportService** — Generates financial reports, sales analytics, transaction history, inventory reports, and performance metrics
- **ProductService** — Manages product catalog, pricing updates, product search functionality, and inventory integration

**Inventory & Stock Management Services:**
- **StockService** — Manages shelf stock operations, batch tracking, expiry monitoring, stock level calculations, and inventory reconciliation
- **StockAlertService** — Implements observer pattern for stock level monitoring, low-stock alerts, and automated inventory notifications

**User Management & Security Services:**
- **AuthenticationService** — Handles user authentication, password validation, session management, and security token generation
- **RegistrationService** (Abstract Base Class) — Provides framework for user registration workflows with validation and data persistence
- **CustomerRegistrationService** — Manages customer account creation, profile management, and customer-specific business rules

**Promotional & Pricing Services:**
- **DiscountService** — Manages discount configurations, promotional pricing strategies, discount application logic, and campaign management

**Service Layer Architecture:**
- **Dependency Injection**: Services receive dependencies through constructor injection
- **Single Responsibility**: Each service handles one business domain
- **Interface Segregation**: Service methods are focused and purpose-specific
- **Transaction Management**: Services coordinate database transactions
- **Exception Handling**: Comprehensive error handling with meaningful messages

#### Domain Layer Components - Complete Inventory

**Model Classes (Business Entities):**
- **Bill** - Represents a complete sales transaction with items, totals, and payment details
- **BillItem** - Individual line items in a bill with product, quantity, and pricing
- **Product** - Core product entity with code, name, price, and category information
- **User** - Base user entity with authentication and role information
- **Admin** - Administrator user type extending User with admin-specific attributes
- **Staff** - Staff user type extending User with staff-specific attributes
- **Customer** - Customer user type extending User with customer-specific attributes
- **Discount** - Discount entity defining promotional offers and pricing rules
- **StockBatch** - Inventory batch entity tracking purchase, expiry, and quantity details
- **ShelfStock** - Current shelf inventory levels and product availability

**Enums (Business Constants):**
- **DiscountType** - Defines discount calculation types (PERCENTAGE, FIXED_AMOUNT)
- **TransactionType** - Categorizes transaction operations (SALE, RETURN, ADJUSTMENT)
- **UserType** - Defines user role types (ADMIN, STAFF, CUSTOMER)

**Strategy Implementations (Business Logic Variations):**
- **PricingStrategy** - Interface for different pricing calculation approaches
- **DiscountStrategy** - Interface for discount application logic
- **DiscountPricingStrategy** - Implements discount-aware pricing calculations
- **NoDiscountStrategy** - Implements standard pricing without discounts
- **ExpiryAwareFifoStrategy** - Implements first-in-first-out inventory management with expiry awareness
- **ShelfStrategy** - Defines shelf stocking and inventory placement logic

**Business Rules & Validation:**
- Entity validation logic embedded in model classes
- Business constraints enforced at domain level
- Calculation logic for totals, taxes, and discounts
- Inventory management rules and constraints

| **Domain** | Models, Enums, Business Rules | Core business logic, entity validation, invariants | None (Independent) |
| **Infrastructure** | Repositories, DB Manager, Config | Data persistence, external APIs, configuration | Domain Layer |

### Asynchronous Processing Architecture

The system implements a sophisticated producer-consumer pattern for handling high-concurrency scenarios:

#### Async Processing Flow

```
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │───▶│   AsyncServlet  │───▶│ RequestQueue │───▶│ WorkerPool │
│  Requests   │    │                 │    │ (BlockingQ)  │    │            │
└─────────────┘    └─────────────────┘    └─────────────┘    └─────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │ RequestProcessor│
                                               │ (Business Logic)│
                                               └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │   AsyncResponse │
                                               │ (CompletableFuture)│
                                               └─────────────────┘
```

#### Async Components Details

**1. AsyncServlet (Producer)**
- Receives HTTP requests
- Initiates async context
- Submits requests to AsyncProcessorManager
- Handles response callbacks

**2. AsyncProcessorManager (Coordinator)**
- Singleton instance management
- Request submission orchestration
- Queue statistics monitoring
- Timeout handling

**3. RequestQueue (Buffer)**
- Bounded BlockingQueue (capacity: 1000)
- Thread-safe enqueue/dequeue operations
- Configurable capacity limits
- Backpressure mechanism

**4. WorkerPool (Consumer)**
- Dynamic thread pool sizing
- Continuous request processing loop
- Exception handling and recovery
- Graceful shutdown support

**5. RequestProcessor (Handler)**
- Type-specific request processing
- Business logic execution
- Response generation
- Error handling

### Concurrency Model

#### Thread Management Strategy

```
HTTP Threads (Container) → Async Context → Worker Threads → Response Callback
     │                           │                │
     └─ Return immediately ─────┘                │
                                                │
                                                └─ Process asynchronously
```

#### Resource Management

- **HTTP Threads**: Returned to container pool immediately
- **Worker Threads**: Dedicated pool for business processing
- **Database Connections**: Connection pooling with reuse
- **Memory**: Bounded queues prevent memory exhaustion

#### Concurrency Mechanisms Used

**1. Servlet 3.0 Asynchronous Processing**
```java
// AsyncContext for non-blocking request processing
AsyncContext asyncContext = request.startAsync();
asyncContext.setTimeout(30000); // 30-second timeout
```

**2. BlockingQueue (Producer-Consumer Pattern)**
```java
// Thread-safe queue for request buffering
private final BlockingQueue<AsyncRequest> queue = new LinkedBlockingQueue<>(capacity);

// Producer: Non-blocking offer
public boolean offer(AsyncRequest request) {
    return queue.offer(request);
}

// Consumer: Blocking poll with timeout
AsyncRequest request = requestQueue.poll(1000, TimeUnit.MILLISECONDS);
```

**3. ExecutorService (Thread Pool Management)**
```java
// Fixed thread pool for worker management
private final ExecutorService executorService = Executors.newFixedThreadPool(poolSize);

// Task submission
executorService.submit(new Worker(workerId));
```

**4. CompletableFuture (Asynchronous Computation)**
```java
// Non-blocking response handling
CompletableFuture<AsyncResponse> future = asyncManager.submitRequest("BILLING", params);
future.thenAccept(response -> {
    // Handle successful response
    asyncContext.complete();
}).exceptionally(throwable -> {
    // Handle errors
    asyncContext.complete();
    return null;
});
```

**5. Atomic Variables (Thread-Safe Counters)**
```java
// Thread-safe statistics tracking
private final AtomicInteger totalRequests = new AtomicInteger(0);
private final AtomicInteger successfulRequests = new AtomicInteger(0);
private final AtomicInteger failedRequests = new AtomicInteger(0);
```

**6. Synchronized Methods (Critical Section Protection)**
```java
// Singleton pattern with thread safety
public static synchronized AsyncProcessorManager getInstance() {
    if (instance == null) {
        instance = new AsyncProcessorManager();
    }
    return instance;
}
```

**7. Volatile Variables (Memory Visibility)**
```java
// Thread-safe shutdown signaling
private volatile boolean running = true;
```

**8. Lock-Free Data Structures**
```java
// Concurrent collections for statistics
private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
```

### Design Patterns Implementation

#### Creational Patterns
- **Singleton**: DatabaseManager, AsyncProcessorManager, InventoryManager
  ```java
  public static synchronized DatabaseManager getInstance() {
      if (instance == null) {
          instance = new DatabaseManager();
      }
      return instance;
  }
  ```

- **Factory Method**: BillItemFactory, UserFactory
  ```java
  // BillItemFactory - Creates bill items with pricing strategies
  public BillItem create(Product product, int quantity) {
      return new BillItem(product, quantity, pricingStrategy);
  }

  // UserFactory - Creates different user types polymorphically
  public static User createUser(String type, String email, String password) {
      return switch (type.toUpperCase()) {
          case "ADMIN" -> new Admin(email, password);
          case "STAFF" -> new Staff(email, password);
          case "CUSTOMER" -> new Customer(email, password);
          default -> throw new IllegalArgumentException("Unknown user type");
      };
  }
  ```

- **Abstract Factory**: RegistrationService framework for user creation

- **Builder Pattern**: Complex object construction with fluent interface
  ```java
  // BillItem Builder - Step-by-step construction with validation
  public static class BillItemBuilder {
      public BillItemBuilder(Product product, int quantity, PricingStrategy strategy) {
          // Validation and calculation logic
          this.totalPrice = strategy.calculate(product, quantity);
      }

      public BillItem build() {
          return new BillItem(this);
      }
  }

  // Usage
  BillItem item = new BillItem.BillItemBuilder(product, 5, pricingStrategy).build();
  ```

#### Structural Patterns
- **Adapter**: Repository implementations adapt data access interfaces
- **Bridge**: Strategy pattern separates pricing abstraction from implementation
- **Composite**: Bill contains multiple BillItems (part-whole hierarchy)
- **Decorator**: Pricing strategies can be layered (discounts on base prices)
- **Facade**: Service classes provide simplified interfaces to complex subsystems

#### Behavioral Patterns
- **Strategy**: PricingStrategy, DiscountStrategy for interchangeable algorithms
  ```java
  public interface PricingStrategy {
      double calculatePrice(double basePrice, int quantity);
  }

  // Implementation
  public class DiscountPricingStrategy implements PricingStrategy {
      @Override
      public double calculatePrice(double basePrice, int quantity) {
          // Apply discount logic
          return basePrice * quantity * (1 - discountRate);
      }
  }
  ```

- **Observer**: StockObserver pattern for inventory monitoring
  ```java
  public interface StockObserver {
      void onStockLevelChanged(String productCode, int newQuantity);
  }

  // Implementation in StockAlertService
  public class StockAlertService implements StockObserver {
      @Override
      public void onStockLevelChanged(String productCode, int newQuantity) {
          if (newQuantity <= threshold) {
              sendAlert(productCode, newQuantity);
          }
      }
  }
  ```

- **Command**: AsyncRequest encapsulates executable operations with parameters
- **Template Method**: Repository base classes define common database operation workflows
- **Chain of Responsibility**: Request processing through layered validation and business logic
- **Iterator**: StockBatchIterator for traversing inventory batches

#### Concurrency Patterns
- **Producer-Consumer**: AsyncServlet producers → RequestQueue → WorkerPool consumers
- **Thread Pool**: WorkerPool manages fixed-size thread pool for request processing
- **Monitor**: Synchronized access to shared resources in concurrent environments
- **Active Object**: AsyncRequestProcessor handles requests asynchronously
- **Guarded Suspension**: BlockingQueue provides thread-safe waiting for work items

#### Data Transfer Patterns
- **Data Transfer Object (DTO)**: BillReportDTO, ProductStockReportItemDTO for clean data exchange
  ```java
  public class BillReportDTO {
      private Long billId;
      private LocalDate date;
      private double totalAmount;
      private List<BillItemReportDTO> items;

      // Getters and setters
  }
  ```

- **Mapper**: ReportDTOMapper converts domain objects to DTOs
  ```java
  public class ReportDTOMapper {
      public static BillReportDTO toBillReportDTO(Bill bill, List<BillItemReportDTO> items) {
          return new BillReportDTO(bill.getId(), bill.getDate(), bill.getTotalAmount(), items);
      }
  }
  ```

#### Architectural Patterns
- **Layered Architecture**: Clear separation of Presentation, Application, Domain, Infrastructure
- **Clean Architecture**: Dependency inversion with domain at center
- **Repository Pattern**: Data access abstraction
- **Service Layer Pattern**: Business logic orchestration
- **MVC Pattern**: Servlet controllers, JSP views, Service models

### Use Case Architecture

#### Primary Use Cases

**1. User Authentication**
```
Actor: User
Preconditions: User has valid credentials
Main Flow:
1. User submits login form
2. System validates credentials
3. System creates session
4. System redirects to dashboard
Alternate Flows:
- Invalid credentials: Show error message
- Account locked: Display lockout message
Postconditions: User authenticated and session established
```

**2. Product Billing (Synchronous)**
```
Actor: Staff/Customer
Preconditions: User authenticated, products available
Main Flow:
1. User adds products to cart
2. System validates stock availability
3. User initiates payment
4. System processes payment
5. System generates receipt
6. System updates inventory
Alternate Flows:
- Insufficient stock: Show availability warning
- Payment failure: Rollback transaction
Postconditions: Bill created, inventory updated, receipt generated
```

**3. Product Billing (Asynchronous)**
```
Actor: Automated Client
Preconditions: Valid API credentials, system operational
Main Flow:
1. Client sends billing request
2. System validates request
3. System queues request for processing
4. System returns acceptance confirmation
5. System processes request asynchronously
6. System sends completion callback
Alternate Flows:
- Queue full: Return queue full error
- Processing failure: Send failure notification
Postconditions: Request processed, results delivered via callback
```

**4. Inventory Management**
```
Actor: Admin/Staff
Preconditions: User has management permissions
Main Flow:
1. User accesses inventory interface
2. System displays current stock levels
3. User performs CRUD operations
4. System validates operations
5. System updates database
Alternate Flows:
- Validation failure: Show error messages
- Concurrent modification: Handle conflicts
Postconditions: Inventory accurately reflects changes
```

**5. Report Generation**
```
Actor: Admin/Staff
Preconditions: User has report access permissions
Main Flow:
1. User selects report type and parameters
2. System validates permissions
3. System queries database
4. System formats results
5. System presents report
Alternate Flows:
- No data: Show empty report message
- Permission denied: Redirect with error
Postconditions: Report generated and displayed
```

#### Secondary Use Cases

**6. Session Management**
**7. Error Handling and Recovery**
**8. Audit Trail Maintenance**
**9. System Monitoring**
**10. Configuration Management**

### Database Architecture

#### Schema Design

```
┌─────────────────┐       ┌─────────────────┐
│     users       │       │    products     │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │
│ username        │       │ name            │
│ password_hash   │       │ code (UK)       │
│ role            │       │ price           │
│ created_at      │       │ category        │
└─────────────────┘       └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐       ┌─────────────────┐
│     bills       │       │ stock_batches   │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │
│ serial_number   │       │ product_id (FK) │
│ user_id (FK)    │       │ quantity        │
│ total_amount    │       │ expiry_date     │
│ cash_tendered   │       │ batch_number    │
│ change_returned │       └─────────────────┘
│ created_at      │
└─────────────────┘
         │
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│   bill_items    │       │   shelf_stock   │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ product_code    │
│ bill_id (FK)    │       │ quantity        │
│ product_id (FK) │       │ last_updated    │
│ quantity        │       └─────────────────┘
│ unit_price      │
│ total_price     │
└─────────────────┘
```

#### Data Access Patterns

- **Repository Pattern**: Interface-based data access
- **Unit of Work**: Transaction management for bill processing
- **Query Objects**: Complex report queries
- **Connection Pooling**: Efficient database connection management

### Security Architecture

#### Authentication & Authorization
- **Session-based Authentication**: HTTP sessions with timeout
- **Role-based Access Control**: Admin, Staff, Customer roles
- **Password Hashing**: BCrypt for secure storage

#### Data Protection
- **Input Validation**: Server-side validation for all inputs
- **SQL Injection Prevention**: Prepared statements
- **XSS Protection**: Output encoding in JSP

### Performance Architecture

#### Caching Strategy
- **Application Cache**: Frequently accessed products
- **Database Indexes**: Optimized query performance
- **Connection Pooling**: Database connection reuse

#### Monitoring Points
- **Queue Statistics**: Request queue monitoring
- **Thread Pool Metrics**: Worker utilization
- **Response Times**: Performance tracking
- **Error Rates**: System health monitoring

### Deployment Architecture

#### Development Environment
```
┌─────────────────┐
│   IDE (VSCode)  │
├─────────────────┤
│   Maven Build   │
├─────────────────┤
│ Tomcat (Embedded)│
├─────────────────┤
│   PostgreSQL    │
│   (Local)       │
└─────────────────┘
```

#### Production Environment
```
┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Application   │
│     (nginx)     │────│     Servers     │
├─────────────────┤    │  ┌────────────┐ │
│                 │    │  │  Tomcat    │ │
└─────────────────┘    │  │  Cluster   │ │
                       │  └────────────┘ │
                       │  ┌────────────┐ │
                       │  │ PostgreSQL │ │
                       │  │  Cluster   │ │
                       │  └────────────┘ │
                       └─────────────────┘
```

### Scalability Considerations

#### Horizontal Scaling
- **Stateless Design**: Application servers can be added/removed
- **Database Sharding**: Data distribution across multiple nodes
- **Load Balancing**: Request distribution across server instances

#### Vertical Scaling
- **Resource Optimization**: Efficient thread and memory usage
- **Caching Layers**: Redis for session and data caching
- **Async Processing**: Non-blocking request handling

### Quality Attributes

#### Performance
- **Throughput**: 28+ requests/second (load test validated)
- **Latency**: < 200ms average response time
- **Scalability**: Linear scaling with server resources

#### Reliability
- **Fault Tolerance**: Graceful error handling
- **Data Consistency**: Transaction management
- **Monitoring**: Comprehensive logging and metrics

#### Maintainability
- **Modular Design**: Clean separation of concerns
- **Test Coverage**: Unit and integration tests
- **Documentation**: Comprehensive code documentation

#### Security
- **Authentication**: Secure login mechanisms
- **Authorization**: Role-based access control
- **Data Protection**: Encryption and validation

## Technologies Used

- **Language**: Java 17
- **Build Tool**: Maven 3.x
- **Web Server**: Apache Tomcat 9 (embedded via Maven plugin)
- **Database**: PostgreSQL
- **JDBC Driver**: PostgreSQL JDBC Driver 42.6.0
- **Web Technologies**:
  - Servlet API 3.1
  - JSP 2.2
  - JSTL 1.2
- **Testing**: JUnit 5, Mockito
- **Async Processing**: Java CompletableFuture, ExecutorService
- **Frontend**: Bootstrap 5.3, Chart.js

## Key Features

### Core Functionality
- **User Management**: Authentication and authorization (Admin, Staff, Customer roles)
- **Product Management**: CRUD operations for products with categories
- **Inventory Management**: Shelf stock tracking, batch management, expiry monitoring
- **Billing System**:
  - Synchronous billing via web interface
  - Asynchronous billing for high-throughput scenarios
  - Discount application (percentage, fixed amount)
  - Tax calculations
- **Reporting**: Daily sales, transaction history, product stock reports

### Advanced Features
- **Asynchronous Processing**: Queue-based request processing with worker pools
- **Real-time Inventory Updates**: Automatic stock deduction on billing
- **Discount Strategies**: Configurable pricing rules
- **Audit Trail**: Complete transaction logging
- **Load Balancing Ready**: Stateless design supports horizontal scaling

## Database Design

### Key Tables
- `users`: User accounts with roles
- `products`: Product catalog
- `stock_batches`: Inventory batches with expiry dates
- `shelf_stock`: Current shelf quantities
- `bills`: Transaction records
- `bill_items`: Line items for bills
- `discounts`: Discount configurations

### Relationships
- Users can be Admin, Staff, or Customer
- Products have multiple stock batches
- Bills contain multiple bill items
- Discounts can be applied at product or bill level

## Implementation Details

### Async Processing Implementation

```java
// Servlet async handling
AsyncContext asyncContext = request.startAsync();
asyncContext.setTimeout(30000);

CompletableFuture<AsyncResponse> future = asyncManager.submitRequest("BILLING", params);
future.thenAccept(response -> {
    // Handle response
    asyncContext.complete();
});
```

### Queue Management

```java
// RequestQueue with blocking operations
private final BlockingQueue<AsyncRequest> queue = new LinkedBlockingQueue<>(capacity);

// Worker processing loop
while (running) {
    AsyncRequest request = requestQueue.poll(1000);
    if (request != null) {
        processRequest(request);
    }
}
```

### Database Connection Management

```java
// Singleton pattern for connection management
public static synchronized DatabaseManager getInstance() throws SQLException {
    if (instance == null || instance.connection.isClosed()) {
        instance = new DatabaseManager();
    }
    return instance;
}
```

## Configuration

### application.properties
```properties
# Database Configuration
db.url=jdbc:postgresql://localhost:5432/syos-billing-system
db.username=your_username
db.password=your_password

# Application Settings
app.name=SYOS Billing System
app.version=1.0.0
```

## API Documentation

### REST Endpoints

#### Authentication
- `POST /login` - User login
- `POST /logout` - User logout

#### Billing
- `GET /billing` - Display billing interface
- `POST /billing` - Process synchronous bill
- `POST /async-billing` - Process asynchronous bill

#### Reports
- `GET /reports` - Reports dashboard
- `POST /reports` - Generate specific reports

#### Inventory
- `GET /inventory` - Inventory management
- `POST /inventory` - Update stock

### Async Billing API

**Endpoint**: `POST /async-billing`

**Parameters**:
- `action`: "processBill" or "getBillHistory"
- `billData`: JSON string for bill data
- `userId`: User identifier

**Response**:
```json
{
  "status": "success",
  "data": {...},
  "processingTime": 150
}
```


---

