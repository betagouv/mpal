// JS for /views/dossiers/dashboard.html.slim

$(document).ready(function() {
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

	dashboardFilterAdvanced();
	dashboardSearchClick();
	dashboardNewTab();
});