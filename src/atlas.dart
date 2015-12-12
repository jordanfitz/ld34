import "dart:html";

import "texture.dart";
import "utils.dart" as utils;

class Atlas {
	static Map countryCodes = {
		"0,0,0": "NONE",
		"241,185,214": "NORWAY",
		"191,211,160": "FINLAND",
		"179,177,216": "SWEDEN",
		"235,207,204": "DENMARK",
		"255,251,167": "RUSSIA",
		"246,152,153": "UNITED_KINGDOM",
		"168,207,88": "IRELAND",
		"254,205,103": "FRANCE",
		"105,189,68": "BELGIUM",
		"251,244,156": "NETHERLANDS",
		"252,226,103": "GERMANY",
		"227,251,173": "POLAND",
		"203,154,199": "LITHUANIA",
		"105,189,88": "LATVIA",
		"254,199,129": "BELARUS",
		"203,151,101": "ESTONIA",
		"203,154,157": "SPAIN",
		"253,255,172": "PORTUGAL",
		"254,204,153": "CZECH_REP.",
		"159,186,84": "AUSTRIA",
		"246,235,21": "SWITZERLAND",
		"206,193,223": "UKRAINE",
		"135,209,212": "SLOVAKIA",
		"253,255,171": "HUNGARY",
		"226,226,252": "ITALY",
		"231,191,251": "SLOVENIA",
		"240,239,157": "CROATIA",
		"203,159,75": "BOSNIA",
		"195,226,221": "SERBIA",
		"248,133,138": "MONTENEGRO",
		"179,169,192": "ALBANIA",
		"234,213,192": "KOSOVO",
		"246,215,21": "MACEDONIA",
		"133,156,70": "GREECE",
		"199,247,189": "TURKEY",
		"254,220,146": "ARMENIA",
		"247,229,207": "GEORGIA",
		"246,152,131": "ROMANIA",
		"189,150,94": "BULGARIA",
		"250,247,194": "MOLDOVA"
	};

	static Map countryNames = {
		"NORWAY": "Norway",
		"FINLAND": "Finland",
		"SWEDEN": "Sweden",
		"DENMARK": "Denmark",
		"RUSSIA": "Russia",
		"UNITED_KINGDOM": "United Kingdom",
		"IRELAND": "Ireland",
		"FRANCE": "France",
		"BELGIUM": "Belgium",
		"NETHERLANDS": "Netherlands",
		"GERMANY": "Germany",
		"POLAND": "Poland",
		"LITHUANIA": "Lithuania",
		"LATVIA": "Latvia",
		"BELARUS": "Belarus",
		"ESTONIA": "Estonia",
		"SPAIN": "Spain",
		"PORTUGAL": "Portugal",
		"CZECH_REP.": "Czech Rep.",
		"AUSTRIA": "Austria",
		"SWITZERLAND": "Switzerland",
		"UKRAINE": "Ukraine",
		"SLOVAKIA": "Slovakia",
		"HUNGARY": "Hungary",
		"ITALY": "Italy",
		"SLOVENIA": "Slovenia",
		"CROATIA": "Croatia",
		"BOSNIA": "Bosnia",
		"SERBIA": "Serbia",
		"MONTENEGRO": "Montenegro",
		"ALBANIA": "Albania",
		"KOSOVO": "Kosovo",
		"MACEDONIA": "Macedonia",
		"GREECE": "Greece",
		"TURKEY": "Turkey",
		"ARMENIA": "Armenia",
		"GEORGIA": "Georgia",
		"ROMANIA": "Romania",
		"BULGARIA": "Bulgaria",
		"MOLDOVA": "Moldova"
	};

	Point offset = new Point(0, 0);

	Texture visibleMap = new Texture("images/map_friendly.png");
	Texture coloredMap = new Texture("images/map_colors.png");

	CanvasElement colorsCanvas = new CanvasElement();
	CanvasRenderingContext2D colorsContext;

	String baseCountry = null;

	num width = 0;
	num height = 0;

	Atlas(this.width, this.height) {
		colorsCanvas.width = width;
		colorsCanvas.height = height;

		colorsContext = colorsCanvas.context2D;
	}

	String getCountry(num x, num y) {
		List<int> data = colorsContext.getImageData(x, y, 1, 1).data;

		String colorCode = "${data[0]},${data[1]},${data[2]}";
		String countryCode = countryCodes[colorCode];

		if (countryCode == "NONE" || !countryCodes.containsKey(colorCode)) return null;

		return countryCodes[colorCode];
	}

	render(CanvasRenderingContext2D context) {
		if (offset.x < 0) offset = new Point(0, offset.y);
		if (offset.y < 0) offset = new Point(offset.x, 0);

		if (offset.x > visibleMap.image.width - width) offset = new Point(visibleMap.image.width - width, offset.y);
		if (offset.y > visibleMap.image.height - height) offset = new Point(offset.x, visibleMap.image.height - height);

		Rectangle destination = new Rectangle(0, 0, width, height);
		Rectangle source = new Rectangle(offset.x, offset.y, width, height);

		colorsContext.clearRect(0, 0, width, height);

		colorsContext.drawImageToRect(coloredMap.image, destination, sourceRect: source);
		context.drawImageToRect(visibleMap.image, destination, sourceRect: source);

		if (baseCountry == null) {
			utils.drawText(context, "Select a base country", 21, 21, "Propaganda", 30, "rgba(255, 255, 255, 0.6)", false);
			utils.drawText(context, "Select a base country", 20, 20, "Propaganda", 30, "#000", false);

			utils.drawText(context, "Use middle mouse button to pan", 21, 56, "Propaganda", 21, "rgba(255, 255, 255, 0.6)", false);
			utils.drawText(context, "Use middle mouse button to pan", 20, 55, "Propaganda", 21, "#000", false);
		} else {
			utils.drawText(context, baseCountry, 21, 21, "Propaganda", 30, "rgba(255, 255, 255, 0.6)", false);
			utils.drawText(context, baseCountry, 20, 20, "Propaganda", 30, "#000", false);
		}
	}
}