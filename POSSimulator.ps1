# USER INPUT

# Server IP
$serverIp = Read-Host "Enter the server IP address (default: Omid's KDS)"
if (-not $serverIp) {
    $serverIp = "http://localhost:5000/api/orders"
    #$serverIp = "https://c9ec778d-e00f-47a8-b8fd-7ec7300ce5d5-00-28ypixclcbw7e.picard.replit.dev/api/test-escpos"
}   
$serverIp = $serverIp.Trim()
# Ensure the IP address is valid
if (-not $serverIp -match '^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$') {
    Write-Host "Invalid IP address format. Using default." -ForegroundColor Red
    $serverIp = "127.0.0.1"
}

# Order Number 
$orderNumber = Read-Host "Enter the order number (default: 12345)"
if (-not $orderNumber) {
    $orderNumber = "12345"
}   
$orderNumber = $orderNumber.Trim()

# Table 
$table = Read-Host "Enter the table number (default: Table 8)"
if (-not $table) {
    $table = "Table 8"
}   
$table = $table.Trim()

# Priority
$priority = Read-Host "Enter the priority (normal / rush) (default: normal)"
if (-not $priority) {
    $priority = "normal"
}       
$priority = $priority.Trim().ToLower()
if ($priority -notin @("normal", "rush")) {
    Write-Host "Invalid priority. Using default: normal" -ForegroundColor Red
    $priority = "normal"
}

# Items
$items = @()
while ($true) {
    Write-Host ""
    $itemName = Read-Host "Enter item name (or press Enter to finish)"
    if (-not $itemName) {
        break
    }
    $itemName = $itemName.Trim()
    
    $itemQuantity = Read-Host "Enter quantity for '$itemName' (default: 1)"
    if (-not $itemQuantity) {
        $itemQuantity = 1
    } else {
        $itemQuantity = [int]$itemQuantity
    }
    
    $itemNotes = Read-Host "Enter notes for '$itemName' (optional)"

    $items += @{
        name = $itemName
        quantity = $itemQuantity
        notes = $itemNotes
    }
}

# ORDER
$body = @{
    orderNumber = $orderNumber
    table = $table
    priority = $priority
    items = $items
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri $serverIp -Method POST -Body $body -ContentType "application/json"