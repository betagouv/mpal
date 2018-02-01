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

	function appendToTableHead(infoLength, info_api, dataText) {
		if (infoLength > 0) {
			for (var tab in info_api) {
				if (null !== tab && undefined !== tab) 
					$("#infos_api_particulier_table_head_row").append('<th> ' + dataText + ' [' + tab + '] </th>');
			}
		} else {
			$("#infos_api_particulier_table_head_row").append('<th> ' + dataText + ' [0] </th>');
		}
	}

	function infos_api_particulier_generate_table(infos_api_particulier_avis, infos_api_particulier_old) {
		// List of expected data
		var infos_api_particulier_tab = [
			"numero_fiscal",
			"reference_avis",
			"annee",
			"revenu_fiscal_reference",
			"declarant_1",
			"declarant_2",
			"nombre_personnes_charge"
		];

		var oldLength = infos_api_particulier_old.length;
		var newLength = infos_api_particulier_avis.length;

		// changing pop-in_container css
		$('.popin__container').css({
			width: "650px",
			height: "370px"
		});
		$('.popin__p').css({ "margin-top": "0" });

		// emptying field before injecting data in it.
		$("#text__p").empty();

		// generating table.
		$("#text__p").append('<div id="infos_api_particulier_fixed">' +
				'<table>' +
					'<thead>' +
						'<tr>' +
							'<th>Données</th>' +
						'</tr>' +
					'</thead>' +
					'<tbody>' +
						'<tr><td><b>Numéro fiscal</b></td></tr>' +
						'<tr><td><b>Références avis</b></td></tr>' +
						'<tr><td><b>Année</b></td></tr>' +
						'<tr><td><b>Revenu fiscal de référence</b></td></tr>' +
						'<tr><td><b>Déclarant 1</b></td></tr>' +
						'<tr><td><b>Déclarant 2</b></td></tr>' +
						'<tr><td><b>Personnes à charge</b></td></tr>' +
					'</tbody>' +
				'</table>' +
			'</div>' +
			'<div id="infos_api_particulier_table_container">' +
				'<table id="infos_api_particulier_table">' +
					'<thead id="infos_api_particulier_table_head">' +
						'<tr id="infos_api_particulier_table_head_row">' +
						'</tr>' +
					'</thead>' +
					'<tbody id="infos_api_particulier_table_body">' +
						'<tr id="numero_fiscal"></tr>' +
						'<tr id="reference_avis"></tr>' +
						'<tr id="annee"></tr>' +
						'<tr id="revenu_fiscal_reference"></tr>' +
						'<tr id="declarant_1"></tr>' +
						'<tr id="declarant_2"></tr>' +
						'<tr id="nombre_personnes_charge"></tr>' +
					'</tbody>' +
				'</table>' +
			'</div>');

		// generating table head for "old" data.
		appendToTableHead(oldLength, infos_api_particulier_old, "Ancienne données");
		appendToTableHead(newLength, infos_api_particulier_avis, "Nouvelle données");

		// main loop for getting key entry from infos_api_particulier_tab.
		for (var key in infos_api_particulier_tab) {
			if (null !== key && undefined !== key) {
				var index = key;
				var keyText = infos_api_particulier_tab[key];

				// looping through all infos_api_particulier_old tab (in case there's multiple one).
				appendToTable(oldLength, infos_api_particulier_old, keyText);
				appendToTable(newLength, infos_api_particulier_avis, keyText);
			}
		}
	}

	function bindPopins() {
		$(".popin").click(function(e) {
			// List of unclickable elements
			var element1 = document.getElementById("infos_api_particulier_table_container");
			var element2 = document.getElementById("infos_api_particulier_fixed");
			// Prevent click on element and sub child
			if (undefined !== element1 && null !== element1 && undefined !== element2 && null !== element2) {
				if (element1.contains(e.target) || element2.contains(e.target)) return ;
			}
			if ($(this).has("#api-particulier")) {
				// restaure of default popin value
				$("#text__p").text("Les données d'avis d'impositions et d'occupants du projet vont être mis à jour.");
				$('.popin__container').css({
					width: "600px",
					height: "286px"
				});
				$('.popin__p').css({
					"margin-top": "1em"
				});
				$(".api-particulier_confirm").css("display", "inline-block");
				$(".api-particulier-close").text("Annuler");
				location.reload();
			}
			$(this).hide();
		});
		$(".js-popin").click(function(e) {
			var element = $(this);
			var target = $(element.data('target'));
			var content = $(element.data('content'))[0];
			$(".api-particulier_confirm").attr("data-content", content);
			if (target.length) {
				target.show();
			}
		});
		$(".api-particulier_confirm").click(function(e) {
			var element = $(this);
			var content = $(element.data('content'))[0];
			e.stopPropagation();
			$.get( "/api/particulier/refresh/" + content)
				.done(function( data ) {
					if (data.status == 0) {
						info = $(".popin__container")
						var infos_api_particulier = JSON.stringify(data);
						var infos_api_particulier_old = data.old;
						var infos_api_particulier_avis = data.avis;
						infos_api_particulier_generate_table(infos_api_particulier_avis, infos_api_particulier_old);
						$(".api-particulier-close").text("Fermer");
						$(".api-particulier_confirm").css("display", "none");
					}
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
			
			var searchParam = preserveSearch();
			var url = "/dossiers" + searchParam;
			window.history.replaceState(null, null, url);
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
		});
	}

	function preserveSearch() {
		var advanced = false;
		var currentTab = $('.dashboardContainer ul.dashboardTabContainer li').index($('.current'));
		var searchParam = "?utf8=✓";

		// Catch Type d'intervention
		var intervType = $('.dashboardFilterStatus select').find(":selected").text();
		if (intervType == "Type d'intervention" || intervType == "")
			intervType = "";
		searchParam += "&search[type]=" + intervType;

		// Catch Etat du dossier
		var status = $('.dashboardFilterState select').find(":selected").val();
		if (status == "Etat du dossier" || status == "")
			status = "";
		searchParam += "&search[status]=" + status;

		// If advanced filter is on
		if ($(".dashboardFilterAdvancedCheckbox").is(':checked')) {
			advanced = true;
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

			// Catch N° dossier
			var freeSearchFNum = $('.dashboardFilterFolderNumber input').val();
			searchParam += "&search[folder]=" + freeSearchFNum;

			// Catch nom Propriétaire
			var freeSearchTenant = $('.dashboardFilterTenantName input').val();
			searchParam += "&search[tenant]=" + freeSearchTenant;

			// Catch Lieu / programme
			var freeSearchLocation = $('.dashboardFilterLocation input').val();
			searchParam += "&search[location]=" + freeSearchLocation;

			// Catch Intervenant
			var freeSearchInterv = $('.dashboardFilterInterv input').val();
			searchParam += "&search[interv]=" + freeSearchInterv;

			// Catch date from
			var freeSearchInterv = $('.dashboardFilterFrom input').val();
			searchParam += "&search[from]=" + freeSearchInterv;

			// Catch date to
			var freeSearchInterv = $('.dashboardFilterTo input').val();
			searchParam += "&search[to]=" + freeSearchInterv;

			searchParam += "&search[sort_by]=" + filterOrderBy + " " + filterOrderOrder;
		}
		// If advanced filter is off catch free search
		else {
			var freeSearch = $('.dashboardFilterFreeSearch input').val();
			searchParam += "&search[query]=" + freeSearch;
		}

		if (advanced)
			searchParam += "&search[advanced]=true";
		else
			searchParam += "&search[advanced]=false";
		searchParam += "&search[activeTab]=" + currentTab;

		return searchParam;
	}

	function dashboardSearchClick() {
		$('.dashboardFilterSearchButton').click(function(e) {
			
			var searchParam = preserveSearch();
			var url = "/dossiers" + searchParam;
			document.location = url;
		});
	}
	
	intervenantsModal();
	dashboardFilterAdvanced();
	dashboardSearchClick();
	dashboardNewTab();
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


