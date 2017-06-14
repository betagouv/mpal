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
    var wtf  = $('.chat-container');
    var height = wtf[0].scrollHeight;
    wtf.scrollTop(height);
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
      $(this).hide();
    });
    $(".js-popin").click(function(e) {
      var element = $(this);
      var target = $(element.data('target'));
      if (target.length) {
        target.show();
      }
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

  function sumPublicHelps() {
    var helps = Array.from($(".js-public-help"));
    var sum = helps.reduce(parseAmountAndSum, 0).toFixed(2);
    $("#js-public-helps-sum")[0].value = sum.toString().replace('.', ',');
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

  var public_helps = $(".js-public-help");
  if (public_helps.length) {
    sumPublicHelps();
    public_helps.keyup(sumPublicHelps);
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
});

