connection: "looker_partner_demo"

include: "/views/**/*.view" # include all the views
include: "/dashboards/*"

############ Model Configuration #############

access_grant: can_view_order_items {
  user_attribute: pleo_demo_department
  allowed_values: ["CRE"]
}

access_grant: can_view_order_facts {
  user_attribute: pleo_demo_business_unit
  allowed_values: ["US"]
}

datagroup: ecommerce_etl {
  sql_trigger: SELECT max(created_at) FROM ecomm.events ;;
  max_cache_age: "24 hours"
}

explore: order_items {
  label: "(1) Orders, Items and Users"
  description: "Use this explore to answer questions about orders"
  view_name: order_items
  required_access_grants: [can_view_order_items]

  join: order_facts {
    type: left_outer
    view_label: "Orders"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: users {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: inventory_items {
    required_access_grants: [can_view_order_facts]
    view_label: "Inventory Items"
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }
}
