$(function() {
	var datasets = {
		"succeeded": {
			label: "Succeeded",
			data: [[1, $('td[id="succeeded"]').text()]],
			color: 3
		},
		"failed": {
			label: "Failed",
			data: [[1, $('td[id="failed"]').text()]],
			color: 2,
		},
		"timed_out": {
			label: "Timed Out",
			data: [[1, $('td[id="timed_out"]').text()]],
			color: 1
		}
	};

	var choiceContainer = $("#build-result-options");
	$.each(datasets, function(key, val) {
		choiceContainer.append("<br/><input type='checkbox' name='" + key +
			"' checked='checked' id='id" + key + "'></input>" +
			"<label for='id" + key + "'>"
			+ val.label + "</label>");
	});

	choiceContainer.find("input").click(plotAccordingToChoices);

	function plotAccordingToChoices() {
		var data = [];
		var ticks = [];
		var i = 1;
		choiceContainer.find("input:checked").each(function () {
			var key = $(this).attr("name");
			datasets[key].data[0][0] = i;
			ticks.push([i, datasets[key].label]);
			++i;
			if (key && datasets[key]) {
				data.push(datasets[key]);
			}
		});
		$.plot("#build-result-plot", data, {
			legend: {
				show: false
			},
			bars: {
				align: "center",
				barWidth: 0.9,
				fill: 0.9,
				show: true
			},
			xaxis: {
				max: i,
				min: 0,
				rotateTicks: 35,
				ticks: ticks
			}
		});
	}

	plotAccordingToChoices();
});
