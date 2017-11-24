$(document).ready(function() {
  function bindReliablePersonForm() {
    if (!$("#js-reliable-person-select-yes").is(":checked")) {
      $(".js-reliable-person-form").hide();
    }
    $(".js-reliable-person-select input:radio").change(function() {
      if ($("#js-reliable-person-select-yes").is(":checked")) {
        $(".js-reliable-person-form").slideDown("fast");
      } else {
        $(".js-reliable-person-form").slideUp("fast");
      }
    });
  }

  // Toggle block page projet
  $(".block h3").each( function(index) {
    if ( !$(this).hasClass("is-open") ){
      $(this).parent().find(".content-block").slideUp(0);
    }
  })
  $(".block h3").click(function(){
    if ( $(this).hasClass("is-open") ){
      $(this).removeClass("is-open");
      $(this).parent().find(".content-block").slideUp("fast");
    } else {
      $(this).parent().find(".content-block").slideDown("fast");
      $(this).addClass("is-open");
    }
  });

  // Open by default last block
  $(".block").last().children().addClass("is-open").slideDown(0);

  // Smooth scroll anchor
  function bindSmoothScrolling() {
    $('a[href*="#"]:not([href="#"])').click(function() {
      if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
          $('html, body').animate({
            scrollTop: target.offset().top
          }, 500);
          history.pushState(null, null, this.href);
          return false;
        }
      }
    });
  }

  // Input file custom
  var $fileInput = $('.file-input');
  var $droparea = $('.file-drop-area');
  $(".like-label").click(function(){
    $fileInput.click();
  });
  $fileInput.on('dragenter focus click', function() {
    $droparea.addClass('is-active');
  });
  $fileInput.on('dragleave blur drop', function() {
    $droparea.removeClass('is-active');
  });
  $fileInput.on('change', function() {
    var filesCount = $(this)[0].files.length;
    var $textContainer = $(this).prev('.js-set-number');
    if (filesCount === 1) {
      $textContainer.text($(this).val().split('\\').pop());
    } else {
      $textContainer.text(filesCount + ' fichiers sélectionnés');
    }
  });

  // change taux
  $(".change-taux").click(function(){
    $(this).parent().nextAll().children("div").toggle(0)
    return false;
  });

  function bindLoginHelpers() {
    $(".js-login-helpers").click(function (e) {
      var target = $(e.target);
      var link = target.closest('.js-login-helper');
      if (!link.length) {
        return;
      }
      e.preventDefault();
      e.stopPropagation();
      $("#projet_numero_fiscal").val(link.data("numero-fiscal"));
      $("#projet_reference_avis").val(link.data("reference-avis"));
      $("html, body").animate({
        scrollTop: $("#js-login-form").offset().top
      }, 500);
    });
  }

  function bindPopins() {
    $(".popin").click(function(e) {
      console.log($(this));
      if ($(this).has("#api-particulier"))
        $("#text__p").text("Les données d'avis d'impositions et d'occupants du projet vont être mis a jour.");
      $(this).hide();
    });
    $(".js-popin").click(function(e) {
      var element = $(this);
      var target = $(element.data('target'));
      if (target.length) {
        target.show();
      }
    });
    $(".api-particulier_confirm").click(function(e) {
      e.stopPropagation();
      $.get( "/testi/" + "1")
        .done(function( data ) {
          info = $(".popin__container")
          $("#text__p").text(JSON.stringify(data));

        });
    });
  }

  function updateSubmitButton() {
    var isChecked = $("input[type=checkbox].js-engagement").prop("checked");
    var submit_btn = $('button.js-engagement');
    if (isChecked) {
      submit_btn.removeProp('disabled');
    } else {
      submit_btn.prop('disabled', true);
    }
  }

  $('.js-document__file')
    .each(displayFileNameAndToggleSendButton)
    .change(displayFileNameAndToggleSendButton);

  function displayFileNameAndToggleSendButton(){
    var filePath = this.value;
    var fileName = filePath.replace(/^.*(\\|\/|\:)/, '');
    $(this).siblings('.js-document__send-button').prop('disabled', filePath == "");
    $(this).siblings('.js-document__file-added').text(fileName);
  }

  function sumTTC() {
    var global_ttc_parts = Array.from($(".js-global-ttc-part"));
    var sum = global_ttc_parts.reduce(parseAmountAndSum, 0).toFixed(2);
    $("#js-global-ttc-sum")[0].value = sum.toString().replace('.', ',');
  }

  function sumPublicAids() {
    var aids = Array.from($(".js-public-aid"));
    var sum = aids.reduce(parseAmountAndSum, 0).toFixed(2);
    $("#js-public-aids-sum")[0].value = sum.toString().replace('.', ',');
  }

  function sumFundings() {
    var fundings = Array.from($(".js-funding"));
    var sum = fundings.reduce(parseAmountAndSum, 0).toFixed(2);
    $("#js-fundings-sum")[0].value = sum.toString().replace('.', ',');
  }

  function parseAmountAndSum(accumulator, element) {
    var field_value = parseFloat(element.value.replace(',', '.').replace(' ', ''));
    field_value = isNaN(field_value) ? 0 : field_value;
    return accumulator + field_value;
  }

  var global_ttc_parts = $(".js-global-ttc-part");
  if (global_ttc_parts.length) {
    sumTTC();
    global_ttc_parts.keyup(sumTTC);
  }

  var public_aids = $(".js-public-aid");
  if (public_aids.length) {
    sumPublicAids();
    public_aids.keyup(sumPublicAids);
  }

  var fundings = $(".js-funding");
  if (fundings.length) {
    sumFundings();
    fundings.keyup(sumFundings);
  }

  bindReliablePersonForm();
  bindSmoothScrolling();
  bindLoginHelpers();
  bindPopins();
  var engagement = $(".js-engagement");
  if (engagement.length) {
    updateSubmitButton();
    engagement.click(updateSubmitButton);
  }

  function toggle_beneficiary() {
    var beneficiary = $(".js-beneficiary");
    $("#payment_procuration_true")[0].checked ? beneficiary.show() : beneficiary.hide();
  }

  var procuration = $(".js-procuration");
  if (procuration.length) {
    toggle_beneficiary();
    procuration.click(toggle_beneficiary);
  }
});

