<nav class="navbar navbar-expand-lg navbar-dark bg-dark" style="margin-left: 250px; width: calc(100% - 250px);">
    <div class="container-fluid">
        <span class="navbar-brand">SYOS Billing System</span>
        <div class="d-flex">
            <span class="navbar-text me-3">
                Welcome, <%= session.getAttribute("userName") %> (<%= session.getAttribute("userRole") %>)
            </span>
            <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>