import "dart:html";
import "dart:async";

import "utils.dart" as utils;
import "mouse.dart" as mouse;
import "texture.dart";
import "applicant.dart";
import "atlas.dart";

CanvasElement canvas = querySelector("canvas#canvas");
CanvasRenderingContext2D context = canvas.context2D;

const num WIDTH = 1280;
const num HEIGHT = 720;

num backgroundOpacity = 0.0;
bool backgroundDirection = false;

enum GameState {
	MENU, MAP, INTERVIEW
}

GameState gameState = GameState.MAP;

Map keys = new Map<num, bool>();
Map keycodes = {
	"w": 87,
	"a": 65,
	"s": 83,
	"d": 68
};

Map textures = new Map<String, Texture>();
Map textureRects = new Map<String, Rectangle>();
Map textureSizes = new Map<String, Point>();
Map textureLocations = new Map<String, Rectangle>();

num lastDelta = 0;

Rectangle playButton = new Rectangle(WIDTH / 2 - (150), 400, 300, 50);

Applicant applicant = new Applicant();

Atlas atlas = new Atlas(WIDTH, HEIGHT);

update(num d) {
	num delta = d - lastDelta;

	if (backgroundDirection) {
		if (backgroundOpacity < 0.3) {
			backgroundOpacity += 0.06 / delta;
		} else {
			backgroundDirection = false;
		}
	} else {
		if (backgroundOpacity > 0) {
			backgroundOpacity -= 0.06 / delta;
		} else {
			backgroundDirection = true;
		}
	}

	if (gameState == GameState.MENU && utils.withinBox(mouse.x, mouse.y, playButton) && mouse.down) {
		gameState = GameState.MAP;
	}

	if(gameState == GameState.MAP) {
		if(keys.containsKey(keycodes["w"])) {
			atlas.offset += new Point(0, -0.5 * delta);
		}

		if(keys.containsKey(keycodes["s"])) {
			atlas.offset += new Point(0, 0.5 * delta);
		}

		if(keys.containsKey(keycodes["a"])) {
			atlas.offset += new Point(-0.5 * delta, 0);
		}

		if(keys.containsKey(keycodes["d"])) {
			atlas.offset += new Point(0.5 * delta, 0);
		}
	}

	lastDelta = d;
}

draw() {
	context.clearRect(0, 0, WIDTH, HEIGHT);

	if (gameState == GameState.MENU) {
		context.fillStyle = "rgba(0, 0, 0, $backgroundOpacity)";
		context.fillRect(0, 0, WIDTH, HEIGHT);

		utils.drawText(context, "TwoButtons,", WIDTH / 2, 250, "Propaganda", 60, "#000", true);
		utils.drawText(context, "Controls", WIDTH / 2, 300, "Propaganda", 60, "#000", true);

		if (utils.withinBox(mouse.x, mouse.y, playButton)) {
			utils.drawBox(context, playButton, "rgba(0, 0, 0, 0.7)");
		} else {
			utils.drawBox(context, playButton, "rgba(0, 0, 0, 0.6)");
		}

		utils.drawText(context, "PLAY", WIDTH / 2, 418, "Propaganda", 25, "#fff", true);
	} else if (gameState == GameState.MAP) {
		atlas.render(context);

		String country = Atlas.countryNames[atlas.getCountry(mouse.x, mouse.y)];

		if (country != null) {
			if(mouse.down && mouse.button == 1) {
				atlas.baseCountry = country;
			}

			utils.drawText(context, country, mouse.x + 1, mouse.y - 39, "Propaganda", 20, "rgba(255, 255, 255, 0.6)", true);
			utils.drawText(context, country, mouse.x, mouse.y - 40, "Propaganda", 20, "#000", true);
		}
	} else if (gameState == GameState.INTERVIEW) {
		utils.drawRect(context, 0, 0, WIDTH, HEIGHT, "#4D4D4D");

		applicant.render(context, 650, HEIGHT - 150);

		utils.drawRect(context, 0, 0, WIDTH, 35, "#C4C4C4");
		utils.drawRect(context, 0, 0, 35, HEIGHT, "#C4C4C4");
		utils.drawRect(context, WIDTH - 35, 0, 35, HEIGHT, "#C4C4C4");
		utils.drawRect(context, 0, HEIGHT - 150, WIDTH, 150, "#C4C4C4");

		context.globalAlpha = 0.9;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["acceptButton"])) {
			context.globalAlpha = 1;
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["acceptButton"], sourceRect: textureRects["acceptButton"]);

		context.globalAlpha = 0.9;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["denyButton"])) {
			context.globalAlpha = 1;
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["denyButton"], sourceRect: textureRects["denyButton"]);

		context.globalAlpha = 1;
	}
}

tick(num delta) {
	update(delta);
	draw();

	window.animationFrame.then(tick);
}

init() {
	canvas.width = WIDTH;
	canvas.height = HEIGHT;

	window.onKeyDown.listen((e) {
		keys[e.keyCode] = true;
	});

	window.onKeyUp.listen((e) {
		keys.remove(e.keyCode);
	});

	canvas.onMouseMove.listen((e) {
		mouse.x = e.offset.x;
		mouse.y = e.offset.y;
	});

	canvas.onMouseDown.listen((e) {
		mouse.down = true;
		mouse.button = e.which;

		num downX = e.offset.x;
		num downY = e.offset.y;

		StreamSubscription mouseMoveStream = canvas.onMouseMove.listen((e) {
			num moveX = e.offset.x;
			num moveY = e.offset.y;

			if (e.which == 2) {
				downX = e.offset.x;
				downY = e.offset.y;
			}
		});

		window.onMouseUp.listen((e) {
			mouseMoveStream.cancel();
		});
	});

	window.onMouseUp.listen((e) {
		mouse.down = false;
	});

	textures["spritesheet"] = new Texture("images/spritesheet.png");

	textureRects["acceptButton"] = new Rectangle(0, 0, 249, 230);
	textureLocations["acceptButton"] = new Rectangle(425, HEIGHT - 115, 83, 77);

	textureRects["denyButton"] = new Rectangle(249, 0, 249, 230);
	textureLocations["denyButton"] = new Rectangle(WIDTH - 425 - 83, HEIGHT - 112.5, 83, 77);

	applicant.randomize();

	window.animationFrame.then(tick);
}

main() {
	init();
}
