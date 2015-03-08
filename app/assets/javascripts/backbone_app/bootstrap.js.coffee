jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $.datepicker.setDefaults({ dateFormat: 'dd/mm/yy' })
