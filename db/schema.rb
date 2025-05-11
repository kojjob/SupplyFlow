# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_11_205441) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "contact_person"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "Ghana"
    t.string "tax_id"
    t.decimal "credit_limit", precision: 10, scale: 2
    t.boolean "active", default: true
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_customers_on_active"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["organization_id", "name"], name: "index_customers_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_customers_on_organization_id"
    t.index ["phone"], name: "index_customers_on_phone"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "product_id", null: false
    t.bigint "location_id", null: false
    t.integer "quantity", default: 0
    t.integer "reserved_quantity", default: 0
    t.string "lot_number"
    t.string "serial_number"
    t.date "expiry_date"
    t.date "manufactured_date"
    t.date "received_date"
    t.string "status", default: "available"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_inventory_items_on_location_id"
    t.index ["lot_number"], name: "index_inventory_items_on_lot_number"
    t.index ["organization_id"], name: "index_inventory_items_on_organization_id"
    t.index ["product_id", "location_id"], name: "index_inventory_items_on_product_id_and_location_id", unique: true
    t.index ["product_id"], name: "index_inventory_items_on_product_id"
    t.index ["serial_number"], name: "index_inventory_items_on_serial_number"
    t.index ["status"], name: "index_inventory_items_on_status"
  end

  create_table "inventory_transactions", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "product_id", null: false
    t.bigint "source_location_id"
    t.bigint "destination_location_id"
    t.bigint "user_id", null: false
    t.string "transaction_type", null: false
    t.integer "quantity", null: false
    t.string "reference_number"
    t.string "reference_type"
    t.bigint "reference_id"
    t.text "notes"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "unit_price", precision: 10, scale: 2
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_location_id"], name: "index_inventory_transactions_on_destination_location_id"
    t.index ["organization_id"], name: "index_inventory_transactions_on_organization_id"
    t.index ["product_id"], name: "index_inventory_transactions_on_product_id"
    t.index ["reference_number"], name: "index_inventory_transactions_on_reference_number"
    t.index ["reference_type", "reference_id"], name: "index_inventory_transactions_on_reference"
    t.index ["source_location_id"], name: "index_inventory_transactions_on_source_location_id"
    t.index ["transaction_type"], name: "index_inventory_transactions_on_transaction_type"
    t.index ["user_id"], name: "index_inventory_transactions_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "Ghana"
    t.string "phone"
    t.string "email"
    t.text "notes"
    t.boolean "active", default: true
    t.string "location_type", default: "warehouse"
    t.bigint "parent_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_locations_on_active"
    t.index ["organization_id", "name"], name: "index_locations_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_locations_on_organization_id"
    t.index ["parent_location_id"], name: "index_locations_on_parent_location_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "action"
    t.text "message"
    t.datetime "read_at"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.integer "notification_type", default: 8
    t.integer "priority", default: 1
    t.jsonb "data", default: {}
    t.bigint "organization_id", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "shipped_quantity", default: 0
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_order_items_on_order_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "draft"
    t.date "order_date"
    t.date "shipping_date"
    t.date "delivery_date"
    t.text "shipping_address"
    t.text "billing_address"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.string "payment_status", default: "unpaid"
    t.string "shipping_method"
    t.string "tracking_number"
    t.string "currency", default: "GHS"
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["delivery_date"], name: "index_orders_on_delivery_date"
    t.index ["order_date"], name: "index_orders_on_order_date"
    t.index ["organization_id", "order_number"], name: "index_orders_on_organization_id_and_order_number", unique: true
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["shipping_date"], name: "index_orders_on_shipping_date"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "Ghana"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.string "tax_id"
    t.string "registration_number"
    t.text "notes"
    t.boolean "active", default: true
    t.string "time_zone", default: "Africa/Accra"
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fiscal_year_start", default: "1"
    t.index ["active"], name: "index_organizations_on_active"
    t.index ["email"], name: "index_organizations_on_email"
    t.index ["name"], name: "index_organizations_on_name"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "payable_type", null: false
    t.bigint "payable_id", null: false
    t.bigint "user_id", null: false
    t.string "payment_number", null: false
    t.date "payment_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "payment_method", null: false
    t.string "reference_number"
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "payment_number"], name: "index_payments_on_organization_id_and_payment_number", unique: true
    t.index ["organization_id"], name: "index_payments_on_organization_id"
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
    t.index ["payment_date"], name: "index_payments_on_payment_date"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "sku", null: false
    t.text "description"
    t.string "barcode"
    t.string "category"
    t.string "brand"
    t.string "model"
    t.string "unit_of_measure", default: "unit"
    t.decimal "cost_price", precision: 10, scale: 2
    t.decimal "selling_price", precision: 10, scale: 2
    t.decimal "weight", precision: 8, scale: 2
    t.decimal "length", precision: 8, scale: 2
    t.decimal "width", precision: 8, scale: 2
    t.decimal "height", precision: 8, scale: 2
    t.integer "minimum_stock_level", default: 0
    t.integer "reorder_point", default: 0
    t.boolean "active", default: true
    t.boolean "perishable", default: false
    t.date "expiry_date"
    t.jsonb "custom_fields", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["barcode"], name: "index_products_on_barcode"
    t.index ["category"], name: "index_products_on_category"
    t.index ["organization_id", "name"], name: "index_products_on_organization_id_and_name"
    t.index ["organization_id", "sku"], name: "index_products_on_organization_id_and_sku", unique: true
    t.index ["organization_id"], name: "index_products_on_organization_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "received_quantity", default: 0
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id", "product_id"], name: "index_purchase_order_items_on_purchase_order_id_and_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "supplier_id", null: false
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "draft"
    t.date "order_date"
    t.date "expected_delivery_date"
    t.date "delivery_date"
    t.text "shipping_address"
    t.text "billing_address"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_date"], name: "index_purchase_orders_on_delivery_date"
    t.index ["expected_delivery_date"], name: "index_purchase_orders_on_expected_delivery_date"
    t.index ["order_date"], name: "index_purchase_orders_on_order_date"
    t.index ["organization_id", "order_number"], name: "index_purchase_orders_on_organization_id_and_order_number", unique: true
    t.index ["organization_id"], name: "index_purchase_orders_on_organization_id"
    t.index ["status"], name: "index_purchase_orders_on_status"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "sales_order_items", force: :cascade do |t|
    t.bigint "sales_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "shipped_quantity", default: 0
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sales_order_items_on_product_id"
    t.index ["sales_order_id", "product_id"], name: "index_sales_order_items_on_sales_order_id_and_product_id"
    t.index ["sales_order_id"], name: "index_sales_order_items_on_sales_order_id"
  end

  create_table "sales_orders", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "draft"
    t.date "order_date"
    t.date "shipping_date"
    t.date "delivery_date"
    t.text "shipping_address"
    t.text "billing_address"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.string "payment_status", default: "unpaid"
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_sales_orders_on_customer_id"
    t.index ["delivery_date"], name: "index_sales_orders_on_delivery_date"
    t.index ["order_date"], name: "index_sales_orders_on_order_date"
    t.index ["organization_id", "order_number"], name: "index_sales_orders_on_organization_id_and_order_number", unique: true
    t.index ["organization_id"], name: "index_sales_orders_on_organization_id"
    t.index ["payment_status"], name: "index_sales_orders_on_payment_status"
    t.index ["shipping_date"], name: "index_sales_orders_on_shipping_date"
    t.index ["status"], name: "index_sales_orders_on_status"
    t.index ["user_id"], name: "index_sales_orders_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "contact_person"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "Ghana"
    t.string "tax_id"
    t.string "registration_number"
    t.string "payment_terms"
    t.decimal "credit_limit", precision: 10, scale: 2
    t.boolean "active", default: true
    t.text "notes"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_suppliers_on_active"
    t.index ["email"], name: "index_suppliers_on_email"
    t.index ["organization_id", "name"], name: "index_suppliers_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_suppliers_on_organization_id"
    t.index ["phone"], name: "index_suppliers_on_phone"
  end

  create_table "user_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "action", null: false
    t.jsonb "details", default: {}
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_user_activities_on_action"
    t.index ["organization_id", "created_at"], name: "index_user_activities_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_user_activities_on_organization_id"
    t.index ["user_id", "created_at"], name: "index_user_activities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone_number"
    t.bigint "organization_id", null: false
    t.string "role", default: "staff"
    t.boolean "active", default: true
    t.datetime "last_login_at"
    t.bigint "default_location_id"
    t.jsonb "notification_preferences", default: {"email" => true, "in_app" => true}
    t.jsonb "ui_preferences", default: {}
    t.boolean "offline_access_enabled", default: false
    t.datetime "last_sync_at"
    t.jsonb "device_tokens", default: []
    t.datetime "last_activity_at"
    t.bigint "created_by_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "permissions", default: [], array: true
    t.index ["active"], name: "index_users_on_active"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["default_location_id"], name: "index_users_on_default_location_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id", "role"], name: "index_users_on_organization_id_and_role"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "organizations"
  add_foreign_key "inventory_items", "locations"
  add_foreign_key "inventory_items", "organizations"
  add_foreign_key "inventory_items", "products"
  add_foreign_key "inventory_transactions", "locations", column: "destination_location_id"
  add_foreign_key "inventory_transactions", "locations", column: "source_location_id"
  add_foreign_key "inventory_transactions", "organizations"
  add_foreign_key "inventory_transactions", "products"
  add_foreign_key "inventory_transactions", "users"
  add_foreign_key "locations", "locations", column: "parent_location_id"
  add_foreign_key "locations", "organizations"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "organizations"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "organizations"
  add_foreign_key "payments", "users"
  add_foreign_key "products", "organizations"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "organizations"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "sales_order_items", "products"
  add_foreign_key "sales_order_items", "sales_orders"
  add_foreign_key "sales_orders", "customers"
  add_foreign_key "sales_orders", "organizations"
  add_foreign_key "sales_orders", "users"
  add_foreign_key "suppliers", "organizations"
  add_foreign_key "user_activities", "organizations"
  add_foreign_key "user_activities", "users"
  add_foreign_key "users", "locations", column: "default_location_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "created_by_id"
end
