// JS for /views/dossiers/dashboard.html.slim

function forceSelect(selboxLabel) {
	var txt = $(selboxLabel).text();
	var index = $(selboxLabel).index();

	var tab = $('.dashboard-container');

	tab.find('.tab-content').find('div.tabs-item').not('div.tabs-item:eq(' + index + ')').hide();;
	tab.find('.tab-content').find('div.tabs-item:eq(' + index + ')').show();
	// preserveSearch();

	$(selboxLabel).siblings('.sel-box-options').removeClass('selected');
	$(selboxLabel).addClass('selected');

	var $currentSel = $(selboxLabel).closest('.sel');
	// $currentSel.children('.sel-placeholder').text(txt);
	$currentSel.children('select').prop('selectedIndex', index + 1);
}

$(document).ready(function() {
	$('.select-group .sel').each(function() {
		$(this).children('select').css('display', 'none');

		var $current = $(this);

		$(this).find('option').each(function(i) {
			if (i == 0) {
				$current.prepend($('<div>', {
					class: $current.attr('class').replace(/sel/g, 'sel-box')
				}));

				var placeholder = $(this).text();
				$current.prepend($('<span>', {
					class: $current.attr('class').replace(/sel/g, 'sel-placeholder'),
					text: placeholder,
					'data-placeholder': placeholder
				}));

				return;
			}

			$current.children('div').append($('<span>', {
				class: $current.attr('class').replace(/sel/g, 'sel-box-options') + ' ' + $(this).attr('class'),
				text: $(this).text()
			}));
		});
	});

	$('.select-group-filter .sel').each(function() {
		$(this).children('select').css('display', 'none');

		var $current = $(this);

		$(this).find('option').each(function(i) {
			if (i == 0) {
				$current.prepend($('<div>', {
					class: $current.attr('class').replace(/sel/g, 'sel-box')
				}));

				var placeholder = $(this).text();
				$current.prepend($('<span>', {
					class: $current.attr('class').replace(/sel/g, 'sel-placeholder'),
					text: placeholder,
					'data-placeholder': placeholder
				}));

				return;
			}

			$current.children('div').append($('<span>', {
				class: $current.attr('class').replace(/sel/g, 'sel-box-options') + ' ' + $(this).attr('class'),
				name: $(this).attr('name'),
				text: $(this).text()
			}));
		});
	});

	$('.select-group-filter .sel-box-options').click(function() {
		var txt = $(this).text();
		var index = $(this).index();
		// preserveSearch();

		$(this).siblings('.sel-box-options').removeClass('selected');
		$(this).addClass('selected');

		var $currentSel = $(this).closest('.sel');
		$currentSel.children('.sel-placeholder').text(txt);
		$currentSel.children('select').prop('selectedIndex', index + 1);
	});

	// Toggling the `.active` state on the `.sel`.
	$('.select-group .sel').click(function() {
		$(this).toggleClass('active');
	});

	$('.select-group-filter .sel').click(function() {
		$(this).toggleClass('active');
	});

	// Toggling the `.selected` state on the options.
	$('.select-group .sel-box-options').click(function() {
		var txt = $(this).text();
		var index = $(this).index();

		var tab = $('.dashboard-container');

		tab.find('.tab-content').find('div.tabs-item').not('div.tabs-item:eq(' + index + ')').hide();;
		tab.find('.tab-content').find('div.tabs-item:eq(' + index + ')').show();
		// preserveSearch();

		$(this).siblings('.sel-box-options').removeClass('selected');
		$(this).addClass('selected');

		var $currentSel = $(this).closest('.sel');
		// $currentSel.children('.sel-placeholder').text(txt);
		$currentSel.children('select').prop('selectedIndex', index + 1);
	});

	function dashboardNewTab() {
		$('.dashboard-container ul.dashboard-tab-container').addClass('active').find('> li:eq(0)').addClass('current');

		$('.dashboard-container ul.dashboard-tab-container li a').click(function (e) {

			var tab = $(this).closest('.dashboard-container'),
				index = $(this).closest('li').index();

			tab.find('ul.dashboard-tab-container > li').removeClass('current');
			$(this).closest('li').addClass('current');

			tab.find('.tab-content').find('div.tabs-item').not('div.tabs-item:eq(' + index + ')').hide();;
			tab.find('.tab-content').find('div.tabs-item:eq(' + index + ')').show();

			preserveSearch();
			e.preventDefault();
		});
	}

	function dashboardFilterAdvanced() {
		$(".global-advanced").slideUp();
		$(".dashboardFilterAdvancedCheckbox").change(function(e) {
			if ($(this).is(':checked')) {
				$(".global-advanced").slideDown();
				$(".free-search-input").prop('disabled', true);
			} else {
				$(".global-advanced").slideUp();
				$(".free-search-input").prop('disabled', false);
			}
		});
	}

	function preserveSearch() {
		var advanced = $('input[name="advanced"]').is(":checked"),
			currentTab = $('.sel.sel-tab select[name="select-active-tab"]').find(":selected").attr('class'),
			searchParam = {};

		searchParam["utf8"] = "✓";

		// Catch HMA
		var hmaActive = $('.dashboardFilterHMACheckbox').is(":checked");
		searchParam["search[hma]"] = hmaActive;

		if (advanced) {
			// Catch Type d'intervention
			var intervType = $('.select-group-type .sel span.selected').text();
			if (intervType == "Type d'intervention" || intervType == "")
				intervType = "";
			searchParam["search[type]"] = intervType;

			// Catch Etat du dossier
			var status = $('.select-group-status .sel select option:selected').val();
			var statusText = $('.select-group-status .sel .sel-placeholder').text();
			if (undefined == status || status == "Etat du dossier" || status == "" || statusText === "Etat du dossier")
				status = "";
			searchParam["search[status]"] = status;

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
			var freeSearchFNum = $('.search-folder-number').val();
			searchParam["search[folder]"] = freeSearchFNum;

			// Catch nom Propriétaire
			var freeSearchTenant = $('.search-tenant-name').val();
			searchParam["search[tenant]"] = freeSearchTenant;

			// Catch Lieu
			var freeSearchLocation = $('.search-location').val();
			searchParam["search[location]"] = freeSearchLocation;

			// Catch Programme
			var freeSearchOP = $('.search-programme').val();
			searchParam["search[operation_programmee]"] = freeSearchOP;

			// Catch Intervenant
			var freeSearchInterv = $('.search-intervenant').val();
			searchParam["search[interv]"] = freeSearchInterv;

			// Catch date from
			var freeSearchFrom = $('.search-date-from').val();
			searchParam["search[from]"] = freeSearchFrom;

			// Catch date to
			var freeSearchTo = $('.search-date-to').val();
			searchParam["search[to]"] = freeSearchTo;
		} else {

			// Catch free search
			var freeSearch = $('.free-search-input').val();
			searchParam["search[query]"] = freeSearch;
		}

		searchParam["search[advanced]"] = advanced;
		searchParam["search[activeTab]"] = currentTab;

		$.urlLib.urlDeleteAllParam();
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
		$('.new-btn-search').click(function(e) {
			preserveSearch();
			$.urlLib.urlLoad();
		});
	}

	forceSelect($('span.tabAll'));
	dashboardFilterAdvanced();
	dashboardSearchClick();
	dashboardNewTab();
});