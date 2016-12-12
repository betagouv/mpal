
$(document).on('click', ".plan_travaux", function () {
  var prestationId = $(this).data('prestation-id');
  var url = $(this).parent().data('url');
  var checkbox = $(this).children().first("checkbox");
  var attributeName = checkbox.val();
  var value = checkbox.prop("checked");
  console.log("prestation: " + prestationId);
  console.log("url: " + url);

  $.post(url, {prestation_id: prestationId, attributeName: attributeName, value: value}, function (data) {
    console.log("ok");
  }, function (data) {
    console.log("ko ?");
  });
});


$(document).on('change', ".aide", function () {
  console.log("Changement");
  var aideId = $(this).attr('name');
  var value = $(this).val();
  var url = $(this).parent().parent().data('url');

  $.post(url, {aide_id: aideId, montant: value}, function (data) {
    console.log("ok");
  }, function (data) {
    console.log("ko ?");
  });
});

$(document).on('click', ".engagement", function () {
  var isChecked = $(this).prop("checked");
  console.log("checked: " + isChecked);
  submit_btn = $('input[type="submit"]')
  submit_btn.prop('disabled', !(isChecked));
});
