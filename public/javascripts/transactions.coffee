# Class that helps to do all calculations
# This is encharged for all configuration in the transactions
class Transaction
  # default configuration with ids from the form
  conf: {
    'currency_id': '#income_currency_id',
    'discount_id': '#income_discount',
    'taxes_id': '#taxes',
    'subtotal_id': '#subtotal',
    'discount_percentage_id': '#discount_percentage',
    'discount_total_id': '#discount_total',
    'taxes_total_id': '#taxes_total',
    'taxes_percentage_id': '#taxes_percentage'
  },
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {})->
    self = this
    @conf = $.extend(@conf, conf)
    self.set_events()
  # Sets the events
  set_events: ->
    this.set_taxes_event()
    this.set_item_change_event("table select.item", "input.price")
    this.set_price_quantity_change_event("table", "input.price", "input.quantity")
    #set_product_change('')
  # Sets the events for calculating taxes, triggering body
  # with arguments: Ej. [{checked: true, rate: 12.3}]
  # @param String id
  set_taxes_event: (id = @conf.taxes_id)->
    self = this
    $(id).find("input:checkbox").live('click', ->
      sum = 0
      sum += 1 * $(k).siblings("span").data("rate") for k in $(@conf.taxes_id).find("input:checkbox:checked")
      $(@conf.taxes_percentage_id).html("#{_b.ntc(sum)} %").data("val", sum)
      self.calculate_taxes()
    )
    #$(self.trigger).trigger("tax:calculated", [taxes_subtotal] )
  # Sets the item change event
  set_item_change_event: (item_sel, price_sel)->
    self = this
    $(item_sel).live("change", ->
      id = $(this).val()
      item = self.search_item(id)
      $(item_sel).parents("tr:first").find(price_sel).val( item.price ).trigger("change")
      #$(self.trigger).trigger("item:change", [this, item])
    )
  # triggers the price and qunaitty change
  set_price_quantity_change_event: (grid_sel, price_sel, quantity_sel)->
    self = this
    $(grid_sel).find("#{price_sel}, #{quantity_sel}").live("change", ->
      self.calculate_total_row(this, "input.price,input.quantity", "td.total_row")
    )
  # Calculates the total for a row in the grid
  # @param DOM el
  # @param String selectors "input.price,input.name"
  calculate_total_row: (el, selectors, res)->
    tot = 1
    $tr = $(el).parents("tr:first")
    $tr.find(selectors).each((i, el)->
      tot = tot * $(el).val()
    )
    $tr.find(res).html(_b.ntc(tot)).data("val", tot)

    this.calculate_subtotal("table #{res}")
  # Calculates the subtotal price for all items
  calculate_subtotal: (selector)->
    sum = 0
    $(selector).each((i, el)->
      sum += $(el).data("val")
    )
    $(@conf.subtotal_id).html(_b.ntc(sum)).data("val", sum)
    this.calculate_discount()
  # Calculates the total taxes
  # Calculates the total amount of discount
  calculate_discount: ->
    val = ( 1 * $(@conf.discount_id).val() )/100 * $(@conf.subtotal_id).data("val")
    $(@conf.discount_percentage_id).html(_b.ntc(val)).data("val", val)
    this.calculate_taxes()
  # Event to capture the percentage and calculate
  # @param String tax_id
  # @param String tax_subtotal_id
  calculate_taxes: ()->
    val = ($(@conf.subtotal_id).data("val") - $(@conf.discount_percentage_id).data("val")) * $(@conf.discount_percentage_id).data("val")
    $(@conf.taxes_total_id).html(_b.ntc(val)).data("val", val)
    console.log(sum)
  # returns the item from a list
  search_item: (id)->
    id = parseInt(id)
    for k in @items
      return k if id == k.id

window.Transaction = Transaction
