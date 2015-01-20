$(function() {
	var datasets = {
		"ruby_1.9_amd64": {
			label: "Ruby 1.9 amd64",
			data: [[1, $('td[id="ruby_1.9_amd64"]').text()]]
		},
		"ruby_1.9_~amd64": {
			label: "Ruby 1.9 ~amd64",
			data: [[1, $('td[id="ruby_1.9_~amd64"]').text()]]
		},
		"ruby_2.0_amd64": {
			label: "Ruby 2.0 amd64",
			data: [[1, $('td[id="ruby_2.0_amd64"]').text()]]
		},
		"ruby_2.0_~amd64": {
			label: "Ruby 2.0 ~amd64",
			data: [[1, $('td[id="ruby_2.0_~amd64"]').text()]]
		},
		"ruby_2.1_amd64": {
			label: "Ruby 2.1 amd64",
			data: [[1, $('td[id="ruby_2.1_amd64"]').text()]]
		},
		"ruby_2.1_~amd64": {
			label: "Ruby 2.1 ~amd64",
			data: [[1, $('td[id="ruby_2.1_~amd64"]').text()]]
		},
		"ruby_2.2_amd64": {
			label: "Ruby 2.2 amd64",
			data: [[1, $('td[id="ruby_2.2_amd64"]').text()]]
		},
		"ruby_2.2_~amd64": {
			label: "Ruby 2.2 ~amd64",
			data: [[1, $('td[id="ruby_2.2_~amd64"]').text()]]
		}
	};

	var i = 0;
	$.each(datasets, function(key, val) {
		val.color = i;
		++i;
	});

	var choiceContainer = $("#package-targets-options");
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
		$.plot("#package-targets-plot", data, {
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
