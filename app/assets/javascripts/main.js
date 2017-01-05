$(document).ready(function() {

    // show/hide diffrent demandeur
    $(".dem-diff").hide();
    $(".dem-contact input:radio").change(function(){
        if ($("#contact-diff").is(':checked')){
            $(".dem-diff").slideDown("fast");
        } else {
            $(".dem-diff").slideUp("fast");
        }
    });


    // Tobggle block page projet
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
        var wtf    = $('.chat-container');
        var height = wtf[0].scrollHeight;
        wtf.scrollTop(height);
    });

    // Open by defaut last block
    $(".block").last().children().addClass("is-open").slideDown(0);

    // Layout
    $(".col-left").css("min-height", $(window).height()-60);

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

    // Select operator
    $(".choose-operator .btn").click(function(){
        if ( $(this).parent().hasClass("is-active") ){
            $(this).parent().removeClass("is-active");
        } else {
            $(".choose-operator li").removeClass("is-active");
            $(this).parent().addClass("is-active");
            $(".operator").text($(this).prevAll("h3").text());
        }
        return false;
    });

    // Popin confirm operator
    $(".open-popin").click(function(){
        var cible = $(this).attr("name");
        $("html").css("overflow", "hidden");
        $(".layer").fadeIn("fast");
        $("#"+cible).fadeIn("fast");
        return false;
    });
    $(".layer, .popin .close").click(function(){
        $("html").attr("style", "");
        $(".layer, .popin").fadeOut("fast");
        return false;
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

    // Same height choose operator
    var eHeight =  $(".choose-operator label");

    var mHeight = function(eHeight) {
        return Math.max.apply(null, eHeight.map(function() {
            return $(this).outerHeight()
        }).get())
    };
    $(".choose-operator label").outerHeight(mHeight($(".choose-operator label")));





    // change taux
    $(".change-taux").click(function(){
        $(this).parent().nextAll().children("div").toggle(0)
        return false;
    });

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

    function updateSubmitButton() {
      var isChecked = $(".engagement").prop("checked");
      console.log("checked: ", isChecked);
      var submit_btn = $('input[type="submit"]');
      if (isChecked) {
        submit_btn.removeProp('disabled');
      } else {
        submit_btn.prop('disabled', true);
      }
    }

    var engagement = $(".engagement");
    if (engagement.length) {
      updateSubmitButton();
      engagement.click(updateSubmitButton);
    }

});
