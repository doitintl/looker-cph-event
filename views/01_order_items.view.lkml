include: "/views/02_order_facts.view"

    view: order_items {
      sql_table_name: looker-private-demo.ecomm.order_items ;;
      view_label: "Order Items"
      ########## IDs, Foreign Keys, Counts ###########

      dimension: id {
        label: "ID"
        primary_key: yes
        type: number
        sql: ${TABLE}.id ;;
        value_format: "00000"
      }

      dimension: inventory_item_id {
        label: "Inventory Item ID"
        type: number
        hidden: yes
        sql: ${TABLE}.inventory_item_id ;;
      }

      dimension: user_id {
        label: "User Id"
        type: number
        hidden: yes
        sql: ${TABLE}.user_id ;;
      }

      measure: count {
        label: "Count"
        type: count

      }

      measure: count_last_28d {
        label: "Count Sold in Trailing 28 Days"
        type: count_distinct
        sql: ${id} ;;
        hidden: yes
        filters:
        {field:created_date
          value: "28 days"
        }}

      measure: order_count {
        view_label: "Orders"
        type: count_distinct

        sql: ${order_id} ;;
      }

      measure: first_purchase_count {
        view_label: "Orders"
        type: count_distinct
        sql: ${order_id} ;;
        filters: {
          field: order_facts.is_first_purchase
          value: "Yes"
        }

      }

     dimension: order_id_no_actions {
        label: "Order ID No Actions"
        type: number
        hidden: yes
        sql: ${TABLE}.order_id ;;
      }

      dimension: order_id {
        label: "Order ID"
        type: number
        sql: ${TABLE}.order_id ;;
        action: {
          label: "Send this to slack channel"
          url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"
          param: {
            name: "user_dash_link"
            value: "/dashboards/ayalascustomerlookupdb?Email={{ users.email._value}}"
          }
          form_param: {
            name: "Message"
            type: textarea
            default: "Hey,
            Could you check out order #{{value}}. It's saying its {{status._value}},
            but the customer is reaching out to us about it.
            ~{{ _user_attributes.first_name}}"
          }
          form_param: {
            name: "Recipient"
            type: select
            default: "zevl"
            option: {
              name: "zevl"
              label: "Zev"
            }
            option: {
              name: "slackdemo"
              label: "Slack Demo User"
            }
          }
          form_param: {
            name: "Channel"
            type: select
            default: "cs"
            option: {
              name: "cs"
              label: "Customer Support"
            }
            option: {
              name: "general"
              label: "General"
            }
          }
        }
        action: {
          label: "Create Order Form"
          url: "https://hooks.zapier.com/hooks/catch/2813548/oosxkej/"
          form_param: {
            name: "Order ID"
            type: string
            default: "{{ order_id._value }}"
          }

          form_param: {
            name: "Name"
            type: string
            default: "{{ users.name._value }}"
          }

          # form_param: {
          #   name: "Email"
          #   type: string
          #   default: "{{ _user_attributes.email }}"
          # }

          # form_param: {
          #   name: "Item"
          #   type: string
          #   default: "{{ products.item_name._value }}"
          # }

          # form_param: {
          #   name: "Price"
          #   type: string
          #   default: "{{ order_items.sale_price._rendered_value }}"
          # }

          # form_param: {
          #   name: "Comments"
          #   type: string
          #   default: " Hi {{ users.first_name._value }}, thanks for your business!"
          # }
        }
        value_format: "00000"
      }

      ########## Time Dimensions ##########

      dimension_group: returned {
        type: time
        timeframes: [time, date, week, month, raw]
        sql: ${TABLE}.returned_at ;;

      }

      dimension_group: shipped {
        type: time
        timeframes: [date, week, month, raw]
        sql: CAST(${TABLE}.shipped_at AS TIMESTAMP) ;;

      }

      dimension_group: delivered {
        type: time
        timeframes: [date, week, month, raw]
        sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;

      }

      dimension_group: created {
        type: time
        timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year,month_name]
        sql: ${TABLE}.created_at ;;

      }

      dimension: reporting_period {
        group_label: "Order Date"
        sql: CASE
                  WHEN EXTRACT(YEAR from ${created_raw}) = EXTRACT(YEAR from CURRENT_TIMESTAMP())
                  AND ${created_raw} < CURRENT_TIMESTAMP()
                  THEN 'This Year to Date'

          WHEN EXTRACT(YEAR from ${created_raw}) + 1 = EXTRACT(YEAR from CURRENT_TIMESTAMP())
          AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
          THEN 'Last Year to Date'

          END
          ;;
      }

      dimension: days_since_sold {
        label: "Days Since Sold"
        hidden: yes
        sql: TIMESTAMP_DIFF(${created_raw},CURRENT_TIMESTAMP(), DAY) ;;
      }

      dimension: months_since_signup {
        label: "Months Since Signup"
        view_label: "Orders"
        type: number
        sql: CAST(FLOOR(TIMESTAMP_DIFF(${created_raw}, ${users.created_raw}, DAY)/30) AS INT64) ;;
      }

########## Logistics ##########

      dimension: status {
        label: "Status"
        sql: ${TABLE}.status ;;
      }

      dimension: days_to_process {
        label: "Days to Process"
        type: number
        sql: CASE
                  WHEN ${status} = 'Processing' THEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
                  WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN TIMESTAMP_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
                  WHEN ${status} = 'Cancelled' THEN NULL
                END
                 ;;
      }


      dimension: shipping_time {
        label: "Shipping Time"
        type: number
        sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;;
      }


      measure: average_days_to_process {
        label: "Average Days to Process"
        type: average
        value_format_name: decimal_2
        sql: ${days_to_process} ;;
      }

      measure: average_shipping_time {
        label: "Average Shipping Time"
        type: average
        value_format_name: decimal_2
        sql: ${shipping_time} ;;
      }

########## Financial Information ##########

      dimension: sale_price {
        label: "Sale Price"
        type: number
        value_format_name: usd
        sql: ${TABLE}.sale_price ;;
      }

      dimension: gross_margin {
        label: "Gross Margin"
        type: number
        value_format_name: usd
        sql: ${sale_price} - ${inventory_items.cost};;
      }

      dimension: item_gross_margin_percentage {
        label: "Item Gross Margin Percentage"
        type: number
        value_format_name: percent_2
        sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
      }

      dimension: item_gross_margin_percentage_tier {
        label: "Item Gross Margin Percentage Tier"
        type: tier
        sql: 100*${item_gross_margin_percentage} ;;
        tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
        style: interval
      }

      measure: total_sale_price {
        label: "Total Sale Price"
        type: sum
        value_format_name: usd
        sql: ${sale_price} ;;

      }

      measure: total_gross_margin {
        label: "Total Gross Margin"
        type: sum
        value_format_name: usd
        sql: ${gross_margin} ;;
        #

      }

      measure: average_sale_price {
        label: "Average Sale Price"
        type: average
        value_format_name: usd
        sql: ${sale_price} ;;

      }

      measure: median_sale_price {
        label: "Median Sale Price"
        type: median
        value_format_name: usd
        sql: ${sale_price} ;;

      }

      measure: average_gross_margin {
        label: "Average Gross Margin"
        type: average
        value_format_name: usd
        sql: ${gross_margin} ;;

      }

      measure: total_gross_margin_percentage {
        label: "Total Gross Margin Percentage"
        type: number
        value_format_name: percent_2
        sql: 1.0 * ${total_gross_margin}/ nullif(${total_sale_price},0) ;;
      }

      measure: average_spend_per_user {
        label: "Average Spend per User"
        type: number
        value_format_name: usd
        sql: 1.0 * ${total_sale_price} / nullif(${users.count},0) ;;

      }

########## Return Information ##########

      dimension: is_returned {
        label: "Is Returned"
        type: yesno
        sql: ${returned_raw} IS NOT NULL ;;
      }

      measure: returned_count {
        label: "Returned Count"
        type: count_distinct
        sql: ${id} ;;
        filters: {
          field: is_returned
          value: "yes"
        }
      }

      measure: returned_total_sale_price {
        label: "Returned Total Sale Price"
        type: sum
        value_format_name: usd
        sql: ${sale_price} ;;
        filters: {
          field: is_returned
          value: "yes"
        }
      }

      parameter: parameter_1 {
        default_value: "100"
        type: number
      }


      parameter: parameter_3 {
        default_value: "{% parameter order_facts.parameter_2.parameter_value %}"
        type: number
      }




      measure: return_rate {
        label: "Return Rate"
        type: number
        value_format_name: percent_2
        #filters: [order_facts.parameter_2: "100"]
        sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
      }
    }
