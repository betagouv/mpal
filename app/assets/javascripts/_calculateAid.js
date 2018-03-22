function sumTTC() {
	if ($("#js-global-ttc-sum").length) {
		var global_ttc_parts = Array.from($(".js-global-ttc-part"));
		var sum = global_ttc_parts.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-global-ttc-sum")[0].value = sum.toString().replace('.', ',');
		remainingSum();
	}
}

function sumHT() {
	if ($("#js-global-ht-sum").length) {
		var global_ttc_parts = Array.from($(".js-global-ht-part"));
		var sum = global_ttc_parts.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-global-ht-sum")[0].value = sum.toString().replace('.', ',');
	}
}

function sumPublicAids() {
	if ($("#js-public-aids-sum").length) {
		var aids = Array.from($(".js-public-aid"));
		var sum = aids.reduce(parseAmountAndSum, 0).toFixed(2);
		$("#js-public-aids-sum")[0].value = sum.toString().replace('.', ',');
	}
}

function sumFundings() {
	if ($("#js-fundings-sum").length) {
		var fundings = Array.from($(".js-funding"));
		var fundings_private = Array.from($(".js-private-aid"));
		var sum = fundings.reduce(parseAmountAndSum, 0).toFixed(2);
		var sum_private = fundings_private.reduce(parseAmountAndSum, 0).toFixed(2);
		sum = (parseFloat(sum) + parseFloat(sum_private)).toFixed(2);
		$("#js-fundings-sum")[0].value = sum.toString().replace('.', ',');
		remainingSum();
	}
}

function remainingSum() {
	if ($("#js-remaining-sum").length) {
		var fundings = Array.from($("#js-fundings-sum"));
		var charge = Array.from($("#js-global-ttc-sum"));
		var sum = fundings.reduce(parseAmountAndSum, 0).toFixed(2);
		var sum_paying = charge.reduce(parseAmountAndSum, 0).toFixed(2);
		sum = (parseFloat(sum_paying) - parseFloat(sum)).toFixed(2);
		$("#js-remaining-sum")[0].value = sum.toString().replace('.', ',');
	}
}

function parseAmountAndSum(accumulator, element) {
	var field_value = parseFloat(element.value.replace(',', '.').replace(' ', ''));
	field_value = isNaN(field_value) ? 0 : field_value;
	return accumulator + field_value;
}

$(document).ready(function() {

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
		private_aids.on('keyup', function() {
			sumFundings();
		});
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
});