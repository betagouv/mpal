$(document).ready(function() {
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

	intervenantsModal();
	bindPopins();
});