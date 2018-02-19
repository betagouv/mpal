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

	// Toggle block
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

	function appendToTable(infoLength, info_api, key) {
		if (infoLength > 0) {
			for (var tab in info_api) {
				// fetching from each tab the current key to see if it exist or not.
				if (null !== tab && undefined !== tab) {
					if (info_api[tab].hasOwnProperty(key)) {
						$("#" + key).append("<td>" + info_api[tab][key] + "</td>");
					} else {
						$("#" + key).append("<td>-</td>");
					}
				}
			}
		} else {
			$("#" + key).append("<td>-</td>");
		}
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
	
	bindReliablePersonForm();
	bindSmoothScrolling();
	bindLoginHelpers();
	

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
