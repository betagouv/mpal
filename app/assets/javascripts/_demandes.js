// JS for /views/demandes/show.html.slim

$('.btn-validate-submit').click(function(e) {
  e.preventDefault();
  var currYear = new Date().toString().match(/(\d{4})/)[1];
  var radio = false;
  var validDate = true;

  var radioTrue = $('input[id=demande_date_achevement_15_ans_true]:checked').val();
  radio = radioTrue != undefined ? true : false;

  var annee = $('#demande_annee_construction').val();
  if (undefined != annee && null != annee && "" != annee) {
    annee = parseInt(annee);
    if (annee < 1500 || annee > currYear)
      validDate = false;
  }
  if (radio && validDate)
    if (annee > currYear - 16)
      validDate = false;
  if (validDate)
    $('.simple_form').submit();
  else
    $('.invalidDate').css("display", "block");
});