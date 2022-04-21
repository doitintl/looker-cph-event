- dashboard: cph_demo_lml
  title: CPH DEMO LML
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  elements:
  - title: CPH DEMO LML
    name: CPH DEMO LML
    model: cph_workshop_dry_run
    explore: order_items
    type: looker_area
    fields: [order_items.created_date, inventory_items.product_category, order_items.count]
    pivots: [inventory_items.product_category]
    fill_fields: [order_items.created_date]
    filters:
      inventory_items.product_category: "-NULL"
    sorts: [order_items.count desc 0, inventory_items.product_category]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: monotone
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    color_application:
      collection_id: aed851c8-b22d-4b01-8fff-4b02b91fe78d
      palette_id: c36094e3-d04d-4aa4-8ec7-bc9af9f851f4
      options:
        steps: 5
        reverse: false
    series_types: {}
    series_colors: {}
    ordering: none
    show_null_labels: false
    defaults_version: 1
    listen:
      Is Returned (Yes / No): order_items.is_returned
    row: 4
    col: 0
    width: 24
    height: 12
  - title: New Tile
    name: New Tile
    model: cph_workshop_dry_run
    explore: order_items
    type: single_value
    fields: [order_items.total_sale_price]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: progress_percentage
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    color_application:
      collection_id: b43731d5-dc87-4a8e-b807-635bef3948e7
      palette_id: fb7bb53e-b77b-4ab6-8274-9d420d3d73f3
      options:
        steps: 5
        reverse: false
    conditional_formatting: [{type: equal to, value: !!null '', background_color: !!null '',
        font_color: !!null '', color_application: {collection_id: b43731d5-dc87-4a8e-b807-635bef3948e7,
          palette_id: 1e4d66b9-f066-4c33-b0b7-cc10b4810688}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    series_types: {}
    point_style: circle
    series_colors: {}
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: monotone
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    ordering: none
    show_null_labels: false
    defaults_version: 1
    listen:
      Is Returned (Yes / No): order_items.is_returned
    row: 0
    col: 0
    width: 6
    height: 4
  - title: Untitled
    name: Untitled
    model: cph_workshop_dry_run
    explore: order_items
    type: single_value
    fields: [order_items.return_rate]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    defaults_version: 1
    listen:
      Is Returned (Yes / No): order_items.is_returned
    row: 0
    col: 6
    width: 4
    height: 4
  filters:
  - name: Is Returned (Yes / No)
    title: Is Returned (Yes / No)
    type: field_filter
    default_value: Yes,No
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: popover
      options:
      - 'Yes'
      - 'No'
    model: cph_workshop_dry_run
    explore: order_items
    listens_to_filters: []
    field: order_items.is_returned
