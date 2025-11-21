# Prompt the user for the server IP address used for POS requests
$serverIp = Read-Host "Enter the server IP address (default: Omid's KDS)"
# Assign the default local API endpoint when nothing is entered
if (-not $serverIp) {
    $serverIp = "http://localhost:5000/api/orders"
    # Example of an external endpoint kept for quick switching
    #$serverIp = "https://c9ec778d-e00f-47a8-b8fd-7ec7300ce5d5-00-28ypixclcbw7e.picard.replit.dev/api/test-escpos"
}
# Remove surrounding whitespace from the supplied server address
$serverIp = $serverIp.Trim()
# Ensure the provided value matches an IPv4 format; otherwise revert to localhost
if (-not $serverIp -match '^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$') {
    Write-Host "Invalid IP address format. Using default." -ForegroundColor Red
    $serverIp = "127.0.0.1"
}

# Ask for an order number while providing a sample default
$orderNumber = Read-Host "Enter the order number (default: 12345)"
# Insert the default order number if the user skips the prompt
if (-not $orderNumber) {
    $orderNumber = "12345"
}
# Normalize the entered order number by trimming whitespace
$orderNumber = $orderNumber.Trim()

# Request table information associated with the order
$table = Read-Host "Enter the table number (default: Table 8)"
# Fall back to the default table descriptor when empty
if (-not $table) {
    $table = "Table 8"
}
# Trim extra whitespace from the table description
$table = $table.Trim()

# Ask how urgent the order should be treated
$priority = Read-Host "Enter the priority (normal / rush) (default: normal)"
# Default to normal priority when no value is supplied
if (-not $priority) {
    $priority = "normal"
}
# Lowercase and trim the priority to simplify comparisons
$priority = $priority.Trim().ToLower()
# Clamp the priority to the supported options, warning when invalid
if ($priority -notin @("normal", "rush")) {
    Write-Host "Invalid priority. Using default: normal" -ForegroundColor Red
    $priority = "normal"
}

# Initialize the collection that will hold each menu item
$items = @()
# Loop until the user stops entering new items
while ($true) {
    # Print a blank line to space out prompts for readability
    Write-Host ""
    # Gather the name of the menu item, ending the loop when left empty
    $itemName = Read-Host "Enter item name (or press Enter to finish)"
    # Break out of the loop once the user signals they are done
    if (-not $itemName) {
        break
    }
    # Trim whitespace to keep the item name clean
    $itemName = $itemName.Trim()
    
    # Ask how many of the current item are needed and default to a single unit
    $itemQuantity = Read-Host "Enter quantity for '$itemName' (default: 1)"
    # Default item quantity to one when nothing is provided
    if (-not $itemQuantity) {
        $itemQuantity = 1
    } else {
        # Convert the quantity input to an integer to ensure proper typing
        $itemQuantity = [int]$itemQuantity
    }
    
    # Capture any optional notes that should accompany the item
    $itemNotes = Read-Host "Enter notes for '$itemName' (optional)"

    # Append the new item entry to the collection with its properties
    $items += @{
        name = $itemName
        quantity = $itemQuantity
        notes = $itemNotes
    }
}

# Compose the final order payload including metadata and item list
$body = @{
    orderNumber = $orderNumber
    table = $table
    priority = $priority
    items = $items
} | ConvertTo-Json -Depth 3

# Send the order to the configured server endpoint as JSON
Invoke-RestMethod -Uri $serverIp -Method POST -Body $body -ContentType "application/json"
