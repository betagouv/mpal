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

	function sumTTC() {
		var global_ttc_parts = Array.from($(".js-global-ttc-part"));
		var sum = global_ttc_parts.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-global-ttc-sum")[0].value = sum.toString().replace('.', ',');
	}

	function sumHT() {
		var global_ttc_parts = Array.from($(".js-global-ht-part"));
		var sum = global_ttc_parts.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-global-ht-sum")[0].value = sum.toString().replace('.', ',');
	}

	function sumPublicAids() {
		var aids = Array.from($(".js-public-aid"));
		var sum = aids.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-public-aids-sum")[0].value = sum.toString().replace('.', ',');
	}

	function sumFundings() {
		var fundings = Array.from($(".js-funding"));
		var fundings_private = Array.from($(".js-private-aid"));
		var sum = fundings.reduce(parseAmountAndSum, 0).toFixed(2);
		var sum_private = fundings_private.reduce(parseAmountAndSum, 0).toFixed(2);
		sum = (parseFloat(sum) + parseFloat(sum_private)).toFixed(2);
		$("#js-fundings-sum")[0].value = sum.toString().replace('.', ',');
	}

	function remainingSum() {
		var fundings = Array.from($("#js-fundings-sum"));
		var charge = Array.from($("#js-global-ttc-sum"));
		var sum = fundings.reduce(parseAmountAndSum, 0).toFixed(2);
		var sum_paying = charge.reduce(parseAmountAndSum, 0).toFixed(2);
		sum = (parseFloat(sum_paying) - parseFloat(sum)).toFixed(2);
		$("#js-remaining-sum")[0].value = sum.toString().replace('.', ',');
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

	var global_ht_parts = $(".js-global-ht-part");
	if (global_ht_parts.length) {
		sumHT();
		global_ht_parts.keyup(sumHT);
	}

	var public_aids = $(".js-public-aid");
	if (public_aids.length) {
		sumPublicAids();
		public_aids.keyup(sumPublicAids);
	}

	var private_aids = $(".js-private-aid");
	if (private_aids.length) {
		sumFundings();
		private_aids.keyup(sumFundings);
	}

	var fundings = $(".js-funding");
	if (fundings.length) {
		sumFundings();
		fundings.keyup(sumFundings);
	}

	if (global_ttc_parts.length && (private_aids || public_aids || fundings)) {
		remainingSum();
		fundings.keyup(remainingSum);
	}

	function intervenantsModal() {
			var modal = document.getElementById('modalIntervenants');
			if (undefined !== modal && null !== modal) {
					var no_redirect = document.getElementsByClassName("modalIntervenants-cancel")[0];
					no_redirect.onclick = function(e ) {
							e.preventDefault();
							modal.style.display = "none";
					};
					$(".confirm-intervenants-js").click(function(e) {
							e.preventDefault();
							var checked = intervenantsCaptureCheckbox().split(",");
							$(".modal-text").empty();
							$(".modal-text").append("<div id='displayIntervenantsContainer'></div>");
							$("#displayIntervenantsContainer").append("<p>Souhaitez-vous vraiment associer ces intervenants au projet ?</p>");
							for (var i in checked) {
									if (checked.hasOwnProperty(i))
											if (i < checked.length - 1)
													$("#displayIntervenantsContainer").append("<div class='displayIntervenants'>" + checked[i] + "</div>");
							}
							modal.style.display = "block";
					});
					window.onclick = function(event) {
							if (event.target == modal)
									modal.style.display = "none";
					}
			}
	}

	function intervenantsCaptureCheckbox() {
			var blkIntervenants = $(".block-intervenants");
			var result = "";

			blkIntervenants.each(function(index, element) {
					var role = $(element).find("h3").text();
					var checkbox = $(element).find("input:checked");

					checkbox.each(function(index, element) {
							var elementText = $(element).parent().text();
							result += role + " " + elementText + ",";
					});
			});
			return (result);
	}

	function dashboardNewTab() {
		$('.dashboardContainer ul.dashboardTabContainer').addClass('active').find('> li:eq(0)').addClass('current');

		$('.dashboardContainer ul.dashboardTabContainer li a').click(function (e) { 
			
			var tab = $(this).closest('.dashboardContainer'), 
					index = $(this).closest('li').index();
			
			tab.find('ul.dashboardTabContainer > li').removeClass('current');
			$(this).closest('li').addClass('current');
			
			tab.find('.tab_content').find('div.tabs_item').not('div.tabs_item:eq(' + index + ')').hide();;
			tab.find('.tab_content').find('div.tabs_item:eq(' + index + ')').show();
			
			preserveSearch();
			e.preventDefault();
		} );
	}

	function dashboardFilterAdvanced() {
		$(".dashboardFilterContainerAdvanced").slideUp();
		$(".dashboardFilterAdvancedCheckbox").change(function(e) {
			if ($(this).is(':checked')) {
				$(".dashboardFilterContainerAdvanced").slideDown();
				$(".dashboardFilterFreeSearch input").attr('disabled','disabled');
			} else {
				$(".dashboardFilterContainerAdvanced").slideUp();
				$(".dashboardFilterFreeSearch input").removeAttr('disabled');
			}
			preserveSearch();
		});
	}

	function preserveSearch() {
		var advanced = false,
			currentTab = $('.dashboardContainer ul.dashboardTabContainer li').index($('.current')),
			searchParam = {};

		searchParam["utf8"] = "✓";

		// Catch Type d'intervention
		var intervType = $('.dashboardFilterStatus select').find(":selected").text();
		if (intervType == "Type d'intervention" || intervType == "")
			intervType = "";
		searchParam["search[type]"] = intervType;

		// Catch Etat du dossier
		var status = $('.dashboardFilterState select').find(":selected").val();
		if (status == "Etat du dossier" || status == "")
			status = "";
		searchParam["search[status]"] = status;

		// If advanced filter is on
		if ($(".dashboardFilterAdvancedCheckbox").is(':checked')) {
			searchParam["search[advanced]"] = "true";
			// Catch Trier par Date de creation / Date de depot
			var filterOrderBy = $(".OrderBy input[type='radio']:checked").attr("id");
			if (filterOrderBy == "dateDeCreation")
				filterOrderBy = "created";
			else
				filterOrderBy = "depot";

			// Catch trier par Ordre croissant / Ordre decroissant
			var filterOrderOrder = $(".OrderOrder input[type='radio']:checked").attr("id");
			if (filterOrderOrder == "ascend")
				filterOrderOrder = "ASC";
			else
				filterOrderOrder = "DESC";

			searchParam["search[sort_by]"] = filterOrderBy + " " + filterOrderOrder;

			// Catch N° dossier
			var freeSearchFNum = $('.dashboardFilterFolderNumber input').val();
			searchParam["search[folder]"] = freeSearchFNum;

			// Catch nom Propriétaire
			var freeSearchTenant = $('.dashboardFilterTenantName input').val();
			searchParam["search[tenant]"] = freeSearchTenant;

			// Catch Lieu / programme
			var freeSearchLocation = $('.dashboardFilterLocation input').val();
			searchParam["search[location]"] = freeSearchLocation;

			// Catch Intervenant
			var freeSearchInterv = $('.dashboardFilterInterv input').val();
			searchParam["search[interv]"] = freeSearchInterv;

			// Catch date from
			var freeSearchFrom = $('.dashboardFilterFrom input').val();
			searchParam["search[from]"] = freeSearchFrom;

			// Catch date to
			var freeSearchTo = $('.dashboardFilterTo input').val();
			searchParam["search[to]"] = freeSearchTo;
		}
		// If advanced filter is off catch free search
		else {
			searchParam["search[advanced]"] = "false";
			var freeSearch = $('.dashboardFilterFreeSearch input').val();
			searchParam["search[query]"] = freeSearch;
		}
		searchParam["search[activeTab]"] = currentTab;

		$.urlLib.urlBulkUpdCrtParam(searchParam);

		$('.pagination a')
			.each(function() {
				var uri = decodeURIComponent($(this).prop("href")).split("?")[1],
					sURLVariables = uri.split('&'),
					sParameterName,
					newURL,
					i;

				for (i = 0; i < sURLVariables.length; i++) {
					sParameterName = sURLVariables[i].split('=');

					if (sParameterName[0] === "search[activeTab]")
						sURLVariables[i] = sParameterName[0] + "=" + $.urlLib.urlGetParamValue("search[activeTab]");
				}
				sURLVariables = sURLVariables.join("&");
				newURL = $(this).prop("href").split(window.location.pathname)[0] + window.location.pathname + "?" + sURLVariables;

				$(this).prop("href", newURL);
			});
	}

	function dashboardSearchClick() {
		$('.dashboardFilterSearchButton').click(function(e) {
			preserveSearch();
			$.urlLib.urlLoad();
		});
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
