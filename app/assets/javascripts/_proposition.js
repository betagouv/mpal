// JS for views/projets/proposition.html.slim

$('.btn-validate-submit').click(function(e) {
  e.preventDefault();
  var currYear = new Date().toString().match(/(\d{4})/)[1];
  var validDate = true;

  var annee = $('#projet_demande_attributes_annee_construction').val();
  if (undefined != annee && null != annee && "" != annee) {
    annee = parseInt(annee);
    if (annee < 1500 || annee > currYear)
      validDate = false;
  }

  if (validDate)
    $('.simple_form').submit();
  else
    $('.invalidDate').css("display", "block");
});