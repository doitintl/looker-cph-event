connection: "looker_partner_demo"

include: "/views/**/*.view" # include all the views


############ Model Configuration #############

datagroup: ecommerce_etl {
  sql_trigger: SELECT max(created_at) FROM ecomm.events ;;
  max_cache_age: "24 hours"
}

explore: order_items {
  label: "(1) Orders, Items and Users"
  description: "Use this explore to answer questions about orders"
  view_name: order_items

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
    view_label: "Inventory Items"
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }
}

# Place in `cph_workshop_dry_run` model
explore: +order_items {
  aggregate_table: rollup__created_date__inventory_items_product_category__0 {
    query: {
      dimensions: [created_date, inventory_items.product_category]
      measures: [count]
      filters: [
        inventory_items.product_category: "-NULL",
        # "order_items.is_returned" was filtered by dashboard. The aggregate table will only optimize against exact match queries.
        order_items.is_returned: "Yes,No"
      ]
    }
    materialization: {
      datagroup_trigger: ecommerce_etl
    }
  }

  aggregate_table: rollup__total_sale_price__1 {
    query: {
      measures: [total_sale_price]
      filters: [
        # "order_items.is_returned" was filtered by dashboard. The aggregate table will only optimize against exact match queries.
        order_items.is_returned: "Yes,No"
      ]
    }

    materialization: {
      datagroup_trigger: ecommerce_etl
    }
  }

  aggregate_table: rollup__return_rate__2 {
    query: {
      measures: [return_rate]
      filters: [
        # "order_items.is_returned" was filtered by dashboard. The aggregate table will only optimize against exact match queries.
        order_items.is_returned: "Yes,No"
      ]
    }

    materialization: {
      datagroup_trigger: ecommerce_etl
    }
  }
}

# Place in `cph_workshop_dry_run` model
explore: +order_items {
  aggregate_table: rollup__total_sale_price {
    query: {
      measures: [total_sale_price]
      filters: [order_items.created_date: "300 days"]
    }

     materialization: {
      datagroup_trigger: ecommerce_etl
    }
  }
}
