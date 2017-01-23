{literal}
    <script type="application/javascript" src="/sites/default/files/civicrm/ext/ca.scibrazeau.ciccrm.tools/js/jquery.js"></script>
    <script type="application/javascript" src="/sites/default/files/civicrm/ext/ca.scibrazeau.ciccrm.tools/js/jquery.validate.js"></script>
    <script type="application/javascript" src="/sites/default/files/civicrm/ext/ca.scibrazeau.ciccrm.tools/js/additional-methods.js"></script>

    <script>

          function clear(id) {
              CRM.$('input[name=price_' + id + ']:checked').prop('checked', false);
              CRM.$('input[name=price_' + id + ']').each(
                      function () {
                          cj(this).data('line_raw_total', 0);
                      }
              );
          }

          function addTrigger(id1, id2, id3) {
              CRM.$('input[name=price_' + id1 + ']').change(function () {
                  clear(id2);
                  clear(id3);
                  display(calculateTotalFee());
              });
          }

          $( function() {

              // User has to pick a price set option.  Remove "none"
              CRM.$(".price-set-option-content input[value=0]").parent().parent().hide()

              // When picking from price 541, uncheck 542/543
              addTrigger(541, 542, 543);
              addTrigger(542, 541, 543);
              addTrigger(543, 541, 542);

              var $eventForm = $('form#Register');

              $.validator.addMethod("registration_required", function (value, element)
              {
                  var ps1 = $('input[name=price_541]:checked').val() || 0;
                  var ps2 = $('input[name=price_542]:checked').val() || 0;
                  var ps3 = $('input[name=price_543]:checked').val() || 0;
                  return ps1 != 0 || ps2 != 0 || ps3 != 0;
              }, "Please pick an event option.");

              $eventForm.validate(
                      {
                          ignore: [],
                          rules: {
                              'price_541': 'registration_required'
                          },
                          messages: {
                              'price_541' : 'Please pick an event option'
                          },
                      errorPlacement : function(error, element)
                      {
                          var elName = element[0].name;
                          if (error.attr('id') == 'price_541-error') {
                              CRM.$('div#priceset').prepend(error);
                          }
                          // look for anything "for", typically a label, but could be H3
                          var label = $('[for="'+elName+'"]');
                          if(label.length <= 0) {
                              // find parent label
                              var parentEle = element.parent();
                              if (parentEle.attr("class") == "wiz_content") {
                                  var prev = parentEle.prev();
                                  if (prev.attr("class") == "wiz_label") {
                                      label = prev;
                                  }
                              }
                          }
                          var insertAfter = label;
                          if (label.children().last().attr("class")== "crm-marker") {
                              insertAfter = label.children().last();
                          } else if (label.next().attr("class") == "crm-marker") {
                              insertAfter = label.next();
                          }
                          error.insertAfter(insertAfter);
                      }
                    }
              );

          });

    </script>
{/literal}