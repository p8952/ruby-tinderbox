$(function() {
	var datasets = {
		"uptodate": {
			label: "Up-to-date",
			data: [[1, $('td[id="uptodate"]').text()]],
			color: 3
		},
		"outdated": {
			label: "Outdated",
			data: [[1, $('td[id="outdated"]').text()]],
			color: 2
		}
	};

	var choiceContainer = $("#outdated-gems-options");
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
		$.plot("#outdated-gems-plot", data, {
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
				rotateTicks: 145,
				ticks: ticks
			}
		});
	}

	plotAccordingToChoices();
});
