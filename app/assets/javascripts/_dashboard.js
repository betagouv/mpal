// JS for /views/dossiers/dashboard.html.slim

$(document).ready(function() {
	function dashboardNewTab() {
		$('.dashboard-container ul.dashboard-tab-container').addClass('active').find('> li:eq(0)').addClass('current');

		$('.dashboard-container ul.dashboard-tab-container li a').click(function (e) {

			var tab = $(this).closest('.dashboard-container'),
					index = $(this).closest('li').index();

			tab.find('ul.dashboard-tab-container > li').removeClass('current');
			$(this).closest('li').addClass('current');

			tab.find('.tab-content').find('div.tabs-item').not('div.tabs-item:eq(' + index + ')').hide();;
			tab.find('.tab-content').find('div.tabs-item:eq(' + index + ')').show();

			var searchParam = preserveSearch();
			var url = "/dossiers" + searchParam;
			window.history.replaceState(null, null, url);
			e.preventDefault();
		} );
	}

	function dashboardFilterAdvanced() {
		$(".dashboard-filter-container-advanced").slideUp();
		$(".dashboardFilterAdvancedCheckbox").change(function(e) {
			if ($(this).is(':checked')) {
				$(".dashboard-filter-container-advanced").slideDown();
				$(".dashboard-filter-free-search input").attr('disabled','disabled');
			} else {
				$(".dashboard-filter-container-advanced").slideUp();
				$(".dashboard-filter-free-search input").removeAttr('disabled');
			}
		});
	}

	function preserveSearch() {
		var advanced = false;
		var currentTab = $('.dashboard-container ul.dashboard-tab-container li').index($('.current'));
		var searchParam = "?utf8=✓";

		// Catch Type d'intervention
		var intervType = $('.dashboard-filter-status select').find(":selected").text();
		if (intervType == "Type d'intervention" || intervType == "")
			intervType = "";
		searchParam += "&search[type]=" + intervType;

		// Catch Etat du dossier
		var status = $('.dashboard-filter-state select').find(":selected").val();
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
			var freeSearch = $('.dashboard-filter-free-search input').val();
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

	dashboardFilterAdvanced();
	dashboardSearchClick();
	dashboardNewTab();
});