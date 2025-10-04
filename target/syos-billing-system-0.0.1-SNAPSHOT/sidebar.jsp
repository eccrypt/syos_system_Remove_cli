<div class="bg-dark text-white" style="width: 250px; min-height: 100vh; position: fixed; left: 0; top: 0;">
    <div class="p-3">
        <h5 class="text-center mb-4">SYOS System</h5>
        <ul class="nav flex-column">
            <li class="nav-item mb-2">
                <a href="index.jsp" class="nav-link text-white">
                    <i class="bi bi-house"></i> Dashboard
                </a>
            </li>
            <li class="nav-item mb-2">
                <a class="nav-link text-white" href="#inventory" data-bs-toggle="collapse" aria-expanded="false">
                    <i class="bi bi-box-seam"></i> Inventory Management
                    </a>
                <div class="collapse" id="inventory">
                    <ul class="nav flex-column ms-3">
                        <li class="nav-item">
                            <a href="productManagement.jsp" class="nav-link text-white-50">
                                <i class="bi bi-tag"></i> Product Management
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="stockManagement.jsp" class="nav-link text-white-50">
                                <i class="bi bi-boxes"></i> Stock Management
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="discountManagement.jsp" class="nav-link text-white-50">
                                <i class="bi bi-percent"></i> Discounts
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="productsWithDiscounts.jsp" class="nav-link text-white-50">
                                <i class="bi bi-tags"></i> Products with Discounts
                            </a>
                        </li>
                    </ul>
                </div>
            </li>
            <li class="nav-item mb-2">
                <a href="billing" class="nav-link text-white">
                    <i class="bi bi-receipt"></i> Billing
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="reports.jsp" class="nav-link text-white">
                    <i class="bi bi-graph-up"></i> Reports
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="logout" class="nav-link text-white">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </li>
        </ul>
    </div>
</div>