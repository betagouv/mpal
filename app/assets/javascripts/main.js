$(document).ready(function() {
  // show/hide personne de confiance
  if (!$("#contact-diff").is(':checked')) {
    $(".dem-diff").hide();
  }
  $(".dem-contact input:radio").change(function() {
    if ($("#contact-diff").is(':checked')) {
      $(".dem-diff").slideDown("fast");
    } else {
      $(".dem-diff").slideUp("fast");
    }
  });

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

  // Open by defaut last block
  $(".block").last().children().addClass("is-open").slideDown(0);

  // Smouth scroll anchor
  $('a[href*="#"]:not([href="#"])').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html, body').animate({
          scrollTop: target.offset().top
        }, 500);
        return false;
      }
    }
  });

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
      $("#form-nf").val(link.data("numero-fiscal"));
      $("#form-ra").val(link.data("reference-avis"));
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
    var helps = document.getElementsByClassName('js-public-help');
    var sum = 0;
    for(var i = 0; i < helps.length; i++) {
      var value = parseFloat(helps[i].value.replace(',', '.'));
      if(value > 0)
        sum += value;
    }
    document.getElementById('js-public-helps-sum').value = sum.toString().replace('.',',');
  }

  function sumFundings() {
    var fundings = document.getElementsByClassName('js-funding');
    var sum = 0;
    for(var i = 0; i < fundings.length; i++) {
      var value = parseFloat(fundings[i].value.replace(',', '.'));
      if(value > 0)
        sum += value;
    }
    document.getElementById('js-fundings-sum').value = sum.toString().replace('.',',');
  }

  var public_helps = $(".js-public-help");
  if (public_helps.length) {
    sumPublicHelps();
    public_helps.change(sumPublicHelps);
  }

  var fundings = $(".js-funding");
  if (fundings.length) {
    sumFundings();
    fundings.change(sumFundings);
  }

  bindLoginHelpers();
  bindPopins();
  var engagement = $(".js-engagement");
  if (engagement.length) {
    updateSubmitButton();
    engagement.click(updateSubmitButton);
  }
});

