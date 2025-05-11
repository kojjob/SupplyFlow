# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Starting seed data creation..."

# Helper method to print sections more visibly
def print_section(section_name)
  puts "\n=== #{section_name} ===\n"
end

print_section("Organizations")

# Create organizations
default_organizations = [
  {
    name: "SupplyFlow Demo",
    email: "demo@supplyflow.com",
    phone: "+233 20 1234567",
    address: "14 Independence Avenue",
    city: "Accra",
    state: "Greater Accra",
    postal_code: "GA-123-4567",
    country: "Ghana",
    website: "https://demo.supplyflow.com",
    tax_id: "GH123456789",
    registration_number: "REG123456",
    time_zone: "Africa/Accra"
  },
  {
    name: "Accra Distributors",
    email: "info@accradistributors.com",
    phone: "+233 20 7654321",
    address: "7 Ring Road Central",
    city: "Accra",
    state: "Greater Accra",
    postal_code: "GA-765-4321",
    country: "Ghana",
    website: "https://accradistributors.com",
    tax_id: "GH987654321",
    registration_number: "REG654321",
    time_zone: "Africa/Accra"
  },
  {
    name: "Kumasi Traders",
    email: "info@kumasitraders.com",
    phone: "+233 20 5555555",
    address: "23 Prempeh II Street",
    city: "Kumasi",
    state: "Ashanti",
    postal_code: "AS-555-5555",
    country: "Ghana",
    website: "https://kumasitraders.com",
    tax_id: "GH555555555",
    registration_number: "REG555555",
    time_zone: "Africa/Accra"
  },
  {
    name: "Takoradi Supplies",
    email: "info@takoradisupplies.com",
    phone: "+233 20 8888888",
    address: "15 Market Circle",
    city: "Takoradi",
    state: "Western",
    postal_code: "WS-888-8888",
    country: "Ghana",
    website: "https://takoradisupplies.com",
    tax_id: "GH888888888",
    registration_number: "REG888888",
    time_zone: "Africa/Accra"
  }
]

organizations = {}
default_organizations.each do |org_attrs|
  org = Organization.find_or_create_by!(name: org_attrs[:name]) do |o|
    o.attributes = org_attrs
    o.active = true
    puts "Created organization: #{o.name}"
  end
  organizations[org.name] = org
end

demo_org = organizations["SupplyFlow Demo"]
accra_org = organizations["Accra Distributors"]
kumasi_org = organizations["Kumasi Traders"]
takoradi_org = organizations["Takoradi Supplies"]

print_section("Locations")

# Create locations for each organization
location_data = {
  "SupplyFlow Demo" => [
    { name: "Main Warehouse", location_type: "warehouse", address: "123 Main St", city: "Accra", phone: "+233 20 1112222" },
    { name: "Downtown Store", location_type: "store", address: "45 Market Ave", city: "Accra", phone: "+233 20 3334444" },
    { name: "Airport Outlet", location_type: "store", address: "12 Airport Road", city: "Accra", phone: "+233 20 5556666" },
    { name: "North Warehouse", location_type: "warehouse", address: "78 Northern Ring Road", city: "Accra", phone: "+233 20 7778888" }
  ],
  "Accra Distributors" => [
    { name: "Central Warehouse", location_type: "warehouse", address: "56 Industrial Area", city: "Accra", phone: "+233 20 9990000" },
    { name: "Osu Branch", location_type: "store", address: "23 Oxford Street", city: "Accra", phone: "+233 20 1113333" }
  ],
  "Kumasi Traders" => [
    { name: "Kumasi Main Store", location_type: "store", address: "88 Bantama Road", city: "Kumasi", phone: "+233 20 2224444" },
    { name: "Adum Warehouse", location_type: "warehouse", address: "15 Adum Square", city: "Kumasi", phone: "+233 20 5557777" }
  ],
  "Takoradi Supplies" => [
    { name: "Takoradi Warehouse", location_type: "warehouse", address: "34 Harbor Road", city: "Takoradi", phone: "+233 20 6668888" }
  ]
}

locations = {}
location_data.each do |org_name, locs|
  org = organizations[org_name]
  org_locations = []

  locs.each do |loc_attrs|
    loc = Location.find_or_create_by!(name: loc_attrs[:name], organization: org) do |l|
      l.attributes = loc_attrs
      l.country = "Ghana"
      l.active = true
      puts "Created location: #{l.name} for #{org.name}"
    end
    org_locations << loc
  end

  locations[org_name] = org_locations
end

print_section("Users")

# Create users for each organization
admin_password = "password123"
staff_password = "password456"
manager_password = "password789"

user_data = {
  "SupplyFlow Demo" => [
    { name: "Admin User", email: "admin@supplyflow.com", role: "admin", phone_number: "+233 20 1111111" },
    { name: "John Mensah", email: "john@supplyflow.com", role: "staff", phone_number: "+233 20 2222222" },
    { name: "Akua Darko", email: "akua@supplyflow.com", role: "manager", phone_number: "+233 20 3333333" },
    { name: "Emmanuel Kwame", email: "emmanuel@supplyflow.com", role: "staff", phone_number: "+233 20 4444444" }
  ],
  "Accra Distributors" => [
    { name: "Kofi Addo", email: "kofi@accradistributors.com", role: "admin", phone_number: "+233 20 5555555" },
    { name: "Ama Serwaa", email: "ama@accradistributors.com", role: "staff", phone_number: "+233 20 6666666" }
  ],
  "Kumasi Traders" => [
    { name: "Kwame Nkrumah", email: "kwame@kumasitraders.com", role: "admin", phone_number: "+233 20 7777777" },
    { name: "Abena Poku", email: "abena@kumasitraders.com", role: "staff", phone_number: "+233 20 8888888" }
  ],
  "Takoradi Supplies" => [
    { name: "Yaw Ofori", email: "yaw@takoradisupplies.com", role: "admin", phone_number: "+233 20 9999999" }
  ]
}

users = {}
user_data.each do |org_name, users_list|
  org = organizations[org_name]
  org_users = []
  default_location = locations[org_name].first

  users_list.each do |user_attrs|
    password = user_attrs[:role] == "admin" ? admin_password : (user_attrs[:role] == "manager" ? manager_password : staff_password)

    user = User.find_or_initialize_by(email: user_attrs[:email])
    if user.new_record?
      user.attributes = user_attrs
      user.organization = org
      user.password = password
      user.password_confirmation = password
      user.default_location = default_location
      user.confirmed_at = Time.current if user.respond_to?(:confirmed_at)

      if user.save
        puts "Created user: #{user.name} (#{user.email}) - #{user.role}"
      else
        puts "Failed to create user: #{user.errors.full_messages.join(', ')}"
      end
    else
      puts "User already exists: #{user.email}"
    end

    org_users << user
  end

  users[org_name] = org_users
end

print_section("Products")

# Create products for each organization
product_categories = [ "Electronics", "Office Supplies", "Furniture", "Food & Beverages", "Clothing", "Construction" ]

product_data = {
  "SupplyFlow Demo" => [
    { name: "Laptop Computer", sku: "ELEC-001", category: "Electronics", barcode: "1234567890123", description: "High-performance laptop for business use", brand: "TechPro", model: "X15", unit_of_measure: "unit", cost_price: 2000.00, selling_price: 2500.00, weight: 2.5, minimum_stock_level: 5, reorder_point: 10 },
    { name: "Office Desk", sku: "FURN-001", category: "Furniture", barcode: "2345678901234", description: "Standard office desk with drawers", brand: "OfficeMakers", model: "Classic", unit_of_measure: "unit", cost_price: 300.00, selling_price: 450.00, weight: 45.0, minimum_stock_level: 2, reorder_point: 5 },
    { name: "Printer Paper", sku: "SUPP-001", category: "Office Supplies", barcode: "3456789012345", description: "A4 printer paper, 500 sheets", brand: "PaperWorks", model: "A4-500", unit_of_measure: "package", cost_price: 5.00, selling_price: 8.50, weight: 2.2, minimum_stock_level: 20, reorder_point: 50 },
    { name: "Bottled Water", sku: "BEVR-001", category: "Food & Beverages", barcode: "4567890123456", description: "500ml bottled water", brand: "AquaPure", model: "500ml", unit_of_measure: "case", cost_price: 4.00, selling_price: 6.00, weight: 12.0, minimum_stock_level: 10, reorder_point: 20, perishable: true, expiry_date: Date.today + 180.days },
    { name: "Work Boots", sku: "CLTH-001", category: "Clothing", barcode: "5678901234567", description: "Steel toe work boots, size 42", brand: "SafeStep", model: "ST42", unit_of_measure: "pair", cost_price: 45.00, selling_price: 75.00, weight: 1.5, minimum_stock_level: 5, reorder_point: 10 },
    { name: "Cement Bags", sku: "CNST-001", category: "Construction", barcode: "6789012345678", description: "50kg bags of Portland cement", brand: "BuildWell", model: "Portland-50", unit_of_measure: "bag", cost_price: 25.00, selling_price: 35.00, weight: 50.0, minimum_stock_level: 100, reorder_point: 200 },
    { name: "Smartphone", sku: "ELEC-002", category: "Electronics", barcode: "7890123456789", description: "Latest model smartphone", brand: "MobileTech", model: "X5", unit_of_measure: "unit", cost_price: 500.00, selling_price: 700.00, weight: 0.3, minimum_stock_level: 10, reorder_point: 20 },
    { name: "Office Chair", sku: "FURN-002", category: "Furniture", barcode: "8901234567890", description: "Ergonomic office chair", brand: "ComfortSit", model: "Ergo-Pro", unit_of_measure: "unit", cost_price: 150.00, selling_price: 250.00, weight: 15.0, minimum_stock_level: 5, reorder_point: 10 },
    { name: "Notebooks", sku: "SUPP-002", category: "Office Supplies", barcode: "9012345678901", description: "Spiral bound notebooks, pack of 3", brand: "NotePro", model: "Spiral-3", unit_of_measure: "pack", cost_price: 3.50, selling_price: 6.00, weight: 0.5, minimum_stock_level: 15, reorder_point: 30 },
    { name: "Soft Drinks", sku: "BEVR-002", category: "Food & Beverages", barcode: "0123456789012", description: "330ml canned soft drinks, pack of 24", brand: "RefreshCola", model: "330ml-24", unit_of_measure: "case", cost_price: 10.00, selling_price: 16.00, weight: 8.0, minimum_stock_level: 10, reorder_point: 20, perishable: true, expiry_date: Date.today + 120.days }
  ],
  "Accra Distributors" => [
    { name: "Desktop Computer", sku: "ELEC-001", category: "Electronics", barcode: "1111222233334", description: "Standard office desktop computer", brand: "TechPro", model: "D10", unit_of_measure: "unit", cost_price: 700.00, selling_price: 1000.00, weight: 10.0, minimum_stock_level: 3, reorder_point: 7 },
    { name: "Conference Table", sku: "FURN-001", category: "Furniture", barcode: "2222333344445", description: "Large conference table", brand: "OfficeWorks", model: "Conference-XL", unit_of_measure: "unit", cost_price: 600.00, selling_price: 900.00, weight: 80.0, minimum_stock_level: 1, reorder_point: 2 }
  ],
  "Kumasi Traders" => [
    { name: "Printer", sku: "ELEC-001", category: "Electronics", barcode: "3333444455556", description: "Color laser printer", brand: "PrintTech", model: "ColorMax", unit_of_measure: "unit", cost_price: 350.00, selling_price: 500.00, weight: 15.0, minimum_stock_level: 2, reorder_point: 5 },
    { name: "Filing Cabinet", sku: "FURN-001", category: "Furniture", barcode: "4444555566667", description: "Metal filing cabinet with 4 drawers", brand: "StoragePro", model: "File-4D", unit_of_measure: "unit", cost_price: 120.00, selling_price: 200.00, weight: 30.0, minimum_stock_level: 3, reorder_point: 6 }
  ],
  "Takoradi Supplies" => [
    { name: "Safety Helmet", sku: "SAFE-001", category: "Construction", barcode: "5555666677778", description: "Construction safety helmet", brand: "SafeGuard", model: "Hard-Pro", unit_of_measure: "unit", cost_price: 15.00, selling_price: 25.00, weight: 0.5, minimum_stock_level: 20, reorder_point: 40 }
  ]
}

products = {}
product_data.each do |org_name, prods|
  org = organizations[org_name]
  org_products = []

  prods.each do |prod_attrs|
    prod = Product.find_or_create_by!(name: prod_attrs[:name], organization: org) do |p|
      p.attributes = prod_attrs
      p.active = true
      puts "Created product: #{p.name} (#{p.sku}) for #{org.name}"
    end
    org_products << prod
  end

  products[org_name] = org_products
end

print_section("Inventory Items")

# Create inventory items (stock) for each product across different locations
organizations.each do |org_name, org|
  org_locations = locations[org_name]
  org_products = products[org_name]

  next if org_products.nil? || org_locations.nil?

  org_products.each do |product|
    org_locations.each do |location|
      quantity = rand(5..100)

      # 70% chance of having inventory in this location
      next if rand > 0.7

      inventory_item = InventoryItem.find_or_initialize_by(
        organization: org,
        product: product,
        location: location
      )

      if inventory_item.new_record?
        inventory_item.quantity = quantity
        inventory_item.reserved_quantity = rand(0..[ quantity/5, 1 ].max)
        inventory_item.status = "available"
        inventory_item.received_date = Date.today - rand(1..30).days

        if inventory_item.save
          puts "Created inventory: #{quantity} x #{product.name} at #{location.name}"
        else
          puts "Failed to create inventory: #{inventory_item.errors.full_messages.join(', ')}"
        end
      else
        puts "Inventory already exists for #{product.name} at #{location.name}"
      end
    end
  end
end

print_section("Suppliers")

# Create suppliers for each organization
supplier_data = {
  "SupplyFlow Demo" => [
    { name: "Tech Imports Ltd", contact_person: "Daniel Owusu", email: "daniel@techimports.com", phone: "+233 20 1112222", address: "15 Industrial Area", city: "Accra", country: "Ghana", payment_terms: "Net 30" },
    { name: "Office Essentials", contact_person: "Priscilla Nyarko", email: "priscilla@officeessentials.com", phone: "+233 20 3334444", address: "7 Commercial Street", city: "Accra", country: "Ghana", payment_terms: "Net 15" },
    { name: "Global Furnishings", contact_person: "Eric Boateng", email: "eric@globalfurnishings.com", phone: "+233 20 5556666", address: "22 Export Drive", city: "Tema", country: "Ghana", payment_terms: "Net 45" }
  ],
  "Accra Distributors" => [
    { name: "Digital Solutions", contact_person: "Sarah Mensah", email: "sarah@digitalsolutions.com", phone: "+233 20 7778888", address: "10 Tech Avenue", city: "Accra", country: "Ghana", payment_terms: "Net 30" }
  ],
  "Kumasi Traders" => [
    { name: "Ashanti Supplies", contact_person: "Kwabena Osei", email: "kwabena@ashantisupplies.com", phone: "+233 20 9990000", address: "5 Market Street", city: "Kumasi", country: "Ghana", payment_terms: "Net 15" }
  ],
  "Takoradi Supplies" => [
    { name: "Western Builders", contact_person: "Joseph Andoh", email: "joseph@westernbuilders.com", phone: "+233 20 1113333", address: "8 Harbor Road", city: "Takoradi", country: "Ghana", payment_terms: "COD" }
  ]
}

suppliers = {}
supplier_data.each do |org_name, supps|
  org = organizations[org_name]
  org_suppliers = []

  supps.each do |supp_attrs|
    supplier = Supplier.find_or_create_by!(name: supp_attrs[:name], organization: org) do |s|
      s.attributes = supp_attrs
      s.active = true
      puts "Created supplier: #{s.name} for #{org.name}"
    end
    org_suppliers << supplier
  end

  suppliers[org_name] = org_suppliers
end

print_section("Customers")

# Create customers for each organization
customer_data = {
  "SupplyFlow Demo" => [
    { name: "Accra Public School", contact_person: "Grace Ayew", email: "grace@accrapublicschool.edu.gh", phone: "+233 20 2223333", address: "25 Education Road", city: "Accra", country: "Ghana" },
    { name: "Central Hospital", contact_person: "Dr. Michael Adu", email: "michael@centralhospital.com", phone: "+233 20 4445555", address: "10 Medical Avenue", city: "Accra", country: "Ghana" },
    { name: "Golden Hotel", contact_person: "Fatima Ibrahim", email: "fatima@goldenhotel.com", phone: "+233 20 6667777", address: "5 Hospitality Street", city: "Accra", country: "Ghana" }
  ],
  "Accra Distributors" => [
    { name: "First Bank Ghana", contact_person: "Richard Boateng", email: "richard@firstbank.com.gh", phone: "+233 20 8889999", address: "12 Financial Avenue", city: "Accra", country: "Ghana" }
  ],
  "Kumasi Traders" => [
    { name: "Kumasi Mall", contact_person: "Victoria Asante", email: "victoria@kumasimall.com", phone: "+233 20 1110000", address: "8 Retail Park", city: "Kumasi", country: "Ghana" }
  ],
  "Takoradi Supplies" => [
    { name: "Western Construction Co", contact_person: "Emmanuel Sekyi", email: "emmanuel@westernconstruction.com", phone: "+233 20 2224444", address: "15 Industrial Zone", city: "Takoradi", country: "Ghana" }
  ]
}

customers = {}
customer_data.each do |org_name, custs|
  org = organizations[org_name]
  org_customers = []

  custs.each do |cust_attrs|
    customer = Customer.find_or_create_by!(name: cust_attrs[:name], organization: org) do |c|
      c.attributes = cust_attrs
      c.active = true
      puts "Created customer: #{c.name} for #{org.name}"
    end
    org_customers << customer
  end

  customers[org_name] = org_customers
end

print_section("Purchase Orders")

# Create purchase orders for the demo organization
if demo_org.present? && suppliers["SupplyFlow Demo"].present?
  admin_user = User.find_by(email: "admin@supplyflow.com")

  if admin_user.present?
    demo_suppliers = suppliers["SupplyFlow Demo"]
    demo_products = products["SupplyFlow Demo"]
    main_warehouse = Location.find_by(name: "Main Warehouse", organization: demo_org)

    if demo_suppliers.present? && demo_products.present? && main_warehouse.present?
      # Create 5 purchase orders
      5.times do |i|
        supplier = demo_suppliers.sample
        order_date = Date.today - rand(1..30).days
        expected_delivery = order_date + rand(3..15).days

        # Randomly select the status
        status = [ "draft", "submitted", "approved", "received", "cancelled" ].sample

        # If received, set the delivery date
        delivery_date = status == "received" ? expected_delivery - rand(0..3).days : nil

        po = PurchaseOrder.find_or_initialize_by(
          organization: demo_org,
          order_number: "PO-#{Date.today.year}-#{10000 + i}"
        )

        if po.new_record?
          po.supplier = supplier
          po.user = admin_user
          po.status = status
          po.order_date = order_date
          po.expected_delivery_date = expected_delivery
          po.delivery_date = delivery_date
          po.shipping_address = main_warehouse.address
          po.billing_address = demo_org.address
          po.notes = "Purchase order for #{supplier.name}"

          # Add 1-5 items to the purchase order
          subtotal = 0

          if po.save
            rand(1..5).times do
              product = demo_products.sample
              quantity = rand(5..50)
              unit_price = product.cost_price * (1 - rand(0..0.1)) # Random discount up to 10%
              total = quantity * unit_price
              subtotal += total

              po_item = PurchaseOrderItem.new(
                purchase_order: po,
                product: product,
                quantity: quantity,
                unit_price: unit_price,
                total_amount: total
              )

              # If received, set the received quantity
              if status == "received"
                po_item.received_quantity = rand(0..1) > 0.2 ? quantity : rand(quantity-5..quantity) # Sometimes less than ordered
              end

              if po_item.save
                puts "Added item to PO #{po.order_number}: #{quantity} x #{product.name}"
              else
                puts "Failed to add item to PO: #{po_item.errors.full_messages.join(', ')}"
              end
            end

            # Update purchase order totals
            tax_rate = 0.125 # 12.5% VAT in Ghana
            shipping = rand(10..50)
            tax_amount = subtotal * tax_rate

            po.subtotal = subtotal
            po.tax_amount = tax_amount
            po.shipping_amount = shipping
            po.total_amount = subtotal + tax_amount + shipping
            po.save

            puts "Created purchase order: #{po.order_number} for #{supplier.name}, total: GH₵#{po.total_amount.round(2)}"
          else
            puts "Failed to create purchase order: #{po.errors.full_messages.join(', ')}"
          end
        else
          puts "Purchase order #{po.order_number} already exists"
        end
      end
    end
  end
end

print_section("Sales Orders")

# Create sales orders for the demo organization
if demo_org.present? && customers["SupplyFlow Demo"].present?
  admin_user = User.find_by(email: "admin@supplyflow.com")

  if admin_user.present?
    demo_customers = customers["SupplyFlow Demo"]
    demo_products = products["SupplyFlow Demo"]
    downtown_store = Location.find_by(name: "Downtown Store", organization: demo_org)

    if demo_customers.present? && demo_products.present? && downtown_store.present?
      # Create 8 sales orders
      8.times do |i|
        customer = demo_customers.sample
        order_date = Date.today - rand(1..30).days
        shipping_date = order_date + rand(1..5).days

        # Randomly select the status
        status = [ "draft", "confirmed", "processing", "shipped", "delivered", "cancelled" ].sample

        # If delivered, set the delivery date
        delivery_date = (status == "delivered" || status == "shipped") ? shipping_date + rand(1..3).days : nil

        # Determine payment status
        payment_status = [ "unpaid", "partially_paid", "paid" ].sample
        if status == "cancelled"
          payment_status = [ "unpaid", "refunded" ].sample
        elsif status == "delivered"
          payment_status = [ "partially_paid", "paid" ].sample
        end

        so = SalesOrder.find_or_initialize_by(
          organization: demo_org,
          order_number: "SO-#{Date.today.year}-#{20000 + i}"
        )

        if so.new_record?
          so.customer = customer
          so.user = admin_user
          so.status = status
          so.order_date = order_date
          so.shipping_date = shipping_date
          so.delivery_date = delivery_date
          so.shipping_address = customer.address
          so.billing_address = customer.address
          so.payment_status = payment_status
          so.notes = "Sales order for #{customer.name}"

          # Add 1-7 items to the sales order
          subtotal = 0

          if so.save
            rand(1..7).times do
              product = demo_products.sample
              quantity = rand(1..20)
              unit_price = product.selling_price * (1 - rand(0..0.05)) # Random discount up to 5%
              total = quantity * unit_price
              subtotal += total

              so_item = SalesOrderItem.new(
                sales_order: so,
                product: product,
                quantity: quantity,
                unit_price: unit_price,
                total_amount: total
              )

              # If shipped or delivered, set the shipped quantity
              if status == "shipped" || status == "delivered"
                # Sometimes ship less than ordered
                so_item.shipped_quantity = rand(0..1) > 0.1 ? quantity : rand(quantity-3..quantity-1)
              end

              if so_item.save
                puts "Added item to SO #{so.order_number}: #{quantity} x #{product.name}"
              else
                puts "Failed to add item to SO: #{so_item.errors.full_messages.join(', ')}"
              end
            end

            # Update sales order totals
            tax_rate = 0.125 # 12.5% VAT in Ghana
            shipping = rand(10..30)
            tax_amount = subtotal * tax_rate
            discount = subtotal * rand(0..0.05) # Random discount up to 5%

            so.subtotal = subtotal
            so.tax_amount = tax_amount
            so.shipping_amount = shipping
            so.discount_amount = discount
            so.total_amount = subtotal + tax_amount + shipping - discount
            so.save

            puts "Created sales order: #{so.order_number} for #{customer.name}, total: GH₵#{so.total_amount.round(2)}"

            # Create payment if partially paid or paid
            if payment_status == "partially_paid" || payment_status == "paid"
              amount = payment_status == "paid" ? so.total_amount : (so.total_amount * rand(0.3..0.8)).round(2)
              payment_date = [ order_date, Date.today ].min

              payment = Payment.new(
                organization: demo_org,
                payable: so,
                user: admin_user,
                payment_number: "PAY-#{Date.today.year}-#{30000 + i}",
                payment_date: payment_date,
                amount: amount,
                payment_method: [ "cash", "bank_transfer", "mobile_money", "credit_card" ].sample,
                reference_number: "REF#{rand(100000..999999)}",
                notes: "Payment for order #{so.order_number}"
              )

              if payment.save
                puts "Created payment: #{payment.payment_number} for #{so.order_number}, amount: GH₵#{amount.round(2)}"
              else
                puts "Failed to create payment: #{payment.errors.full_messages.join(', ')}"
              end
            end
          else
            puts "Failed to create sales order: #{so.errors.full_messages.join(', ')}"
          end
        else
          puts "Sales order #{so.order_number} already exists"
        end
      end
    end
  end
end

print_section("Inventory Transactions")

# Create inventory transactions for the demo organization
if demo_org.present?
  admin_user = User.find_by(email: "admin@supplyflow.com")

  if admin_user.present?
    demo_products = products["SupplyFlow Demo"]
    demo_locations = locations["SupplyFlow Demo"]

    if demo_products.present? && demo_locations.present? && demo_locations.length >= 2
      main_warehouse = Location.find_by(name: "Main Warehouse", organization: demo_org)
      downtown_store = Location.find_by(name: "Downtown Store", organization: demo_org)

      # Create 30 random inventory transactions
      30.times do |i|
        product = demo_products.sample
        transaction_date = Date.today - rand(1..60).days

        # Random transaction type
        transaction_type = [ "receive", "issue", "transfer", "adjust", "count" ].sample

        # Set source and destination based on transaction type
        source_location = nil
        destination_location = nil

        case transaction_type
        when "receive"
          destination_location = main_warehouse
        when "issue"
          source_location = [ main_warehouse, downtown_store ].sample
        when "transfer"
          # Make sure source and destination are different
          source_location = demo_locations.sample
          destination_location = (demo_locations - [ source_location ]).sample
        when "adjust", "count"
          source_location = demo_locations.sample
        end

        # Random quantity (positive for receive/in, negative for issue/out)
        quantity = if transaction_type == "receive"
                    rand(10..100)
        elsif transaction_type == "issue"
                    -rand(1..20)
        elsif transaction_type == "transfer"
                    rand(5..30)
        elsif transaction_type == "adjust"
                    rand(-10..10)
        else # count
                    rand(-5..15)
        end

        # Skip if quantity is zero
        next if quantity.zero?

        transaction = InventoryTransaction.new(
          organization: demo_org,
          product: product,
          source_location: source_location,
          destination_location: destination_location,
          user: admin_user,
          transaction_type: transaction_type,
          quantity: quantity.abs, # Store as positive
          reference_number: "INV-#{transaction_type.upcase[0..2]}-#{10000 + i}",
          notes: "#{transaction_type.capitalize} transaction for #{product.name}",
          unit_cost: product.cost_price,
          unit_price: product.selling_price,
          created_at: transaction_date,
          updated_at: transaction_date
        )

        if transaction.save
          action = case transaction_type
          when "receive"
                    "received at"
          when "issue"
                    "issued from"
          when "transfer"
                    "transferred from #{source_location.name} to"
          when "adjust"
                    quantity.positive? ? "adjusted up at" : "adjusted down at"
          else # count
                    quantity.positive? ? "counted up at" : "counted down at"
          end

          location_name = destination_location&.name || source_location&.name
          puts "Created inventory transaction: #{quantity.abs} x #{product.name} #{action} #{location_name}"
        else
          puts "Failed to create inventory transaction: #{transaction.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end

print_section("User Activities")

# Create user activities for audit trail
if demo_org.present?
  demo_users = users["SupplyFlow Demo"]

  if demo_users.present?
    activity_types = [
      "login", "logout", "view_product", "create_product", "update_product",
      "view_inventory", "update_inventory", "view_purchase_order", "create_purchase_order",
      "view_sales_order", "create_sales_order", "export_report"
    ]

    # Create 100 random user activities
    100.times do |i|
      user = demo_users.sample
      activity_date = DateTime.now - rand(1..30).days - rand(0..23).hours - rand(0..59).minutes
      action = activity_types.sample

      details = {}

      case action
      when "view_product", "update_product"
        details[:product_id] = products["SupplyFlow Demo"].sample.id if products["SupplyFlow Demo"].present?
      when "view_inventory", "update_inventory"
        details[:location_id] = locations["SupplyFlow Demo"].sample.id if locations["SupplyFlow Demo"].present?
      when "view_purchase_order", "create_purchase_order"
        details[:supplier_id] = suppliers["SupplyFlow Demo"].sample.id if suppliers["SupplyFlow Demo"].present?
      when "view_sales_order", "create_sales_order"
        details[:customer_id] = customers["SupplyFlow Demo"].sample.id if customers["SupplyFlow Demo"].present?
      end

      activity = UserActivity.new(
        user: user,
        organization: demo_org,
        action: action,
        details: details,
        ip_address: "192.168.1.#{rand(1..255)}",
        user_agent: [ "Mozilla/5.0 (Macintosh)", "Mozilla/5.0 (Windows)", "Mozilla/5.0 (Linux)" ].sample,
        created_at: activity_date,
        updated_at: activity_date
      )

      if activity.save
        puts "Created user activity: #{user.name} - #{action} at #{activity_date.strftime('%Y-%m-%d %H:%M')}"
      else
        puts "Failed to create user activity: #{activity.errors.full_messages.join(', ')}"
      end
    end
  end
end

puts "\nSeed data creation completed successfully!"
puts "====================================="
puts "Organizations: #{Organization.count}"
puts "Locations: #{Location.count}"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts "Inventory Items: #{InventoryItem.count}"
puts "Suppliers: #{Supplier.count}"
puts "Customers: #{Customer.count}"
puts "Purchase Orders: #{PurchaseOrder.count}"
puts "Purchase Order Items: #{PurchaseOrderItem.count}"
puts "Sales Orders: #{SalesOrder.count}"
puts "Sales Order Items: #{SalesOrderItem.count}"
puts "Payments: #{Payment.count}"
puts "Inventory Transactions: #{InventoryTransaction.count}"
puts "User Activities: #{UserActivity.count}"
puts "====================================="
