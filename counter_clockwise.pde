PVector center;
PImage shape;
PImage[] shapes;
int shapeIndex = 0;

float triangleRotation = 0;
float triangleRotationStep = 0.1;

int innerRadius = 25;
int radiusStep = 25;

float amplitude = 0.025;
float frequency = 0.3;

float quality = 1;

float slowPhase = 0;
float fastPhase = 0;
float slowPhaseStep = 0.03;
float fastPhaseStep = 0.05;

void setup () {
	size(500, 500);
	center = new PVector(width / 2, height / 2);
	shapes = new PImage[] { getTriangle() , getRect(), getEllipse() };
	shape = shapes[shapeIndex];
	smooth(8);

}


void draw() {
	background(255);
	imageMode(CENTER);

	pushMatrix();
	translate(width/2, height/2);
	rotate(triangleRotation);
	triangleRotation += triangleRotationStep;
	image(shape, 0, 0);
	popMatrix();

	loadPixels();
	shape.pixels = pixels;
	background(0);

	slowPhase += slowPhaseStep;
	fastPhase += fastPhaseStep;

	for (int i = innerRadius; i < 250; i += radiusStep) {
		float phase = i % 2 == 0 ? slowPhase : fastPhase;
		drawCircle(i, phase, amplitude, frequency, quality);
	}

	if (frameCount % 100 == 0) {
		shapeIndex++;
		shapeIndex %= shapes.length;
		shape = shapes[shapeIndex];
	}
}

PImage getTriangle() {
	PGraphics pg;
	pg = createGraphics(width, height);
	pg.noStroke();
	pg.beginDraw();
	pg.fill(0);
	pg.background(255);
	pg.triangle(60, 360, 440, 360, 250, 30);
	pg.filter(BLUR, 15);
	pg.endDraw();
	return pg.get();
}

PImage getRect() {
	PGraphics pg;
	pg = createGraphics(width, height);
	pg.noStroke();
	pg.beginDraw();
	pg.fill(0);
	pg.background(255);
	pg.rectMode(CENTER);
	pg.rect(width / 2, height / 2, 250, 330);
	pg.filter(BLUR, 15);
	pg.endDraw();
	return pg.get();
}

PImage getEllipse() {
	PGraphics pg;
	pg = createGraphics(width, height);
	pg.noStroke();
	pg.beginDraw();
	pg.fill(0);
	pg.background(255);
	pg.ellipse(width / 2, height / 2, 200, 330);
	pg.filter(BLUR, 15);
	pg.endDraw();
	return pg.get();
}

void drawCircle(int radius, float phase, float amplitude, float frequency, float quality) {
	PVector p1 = new PVector();
	PVector p2 = new PVector();
	float angle = 0;

	float brightness = getBrightness(radius, angle);
	float noiseFrequency = getCorrecteNoiseFrequency(radius, frequency);
	float noise = getNoise(brightness, angle, phase, amplitude, noiseFrequency);

	p2 = getNext(center, radius, angle, noise);

	int numSteps = (int) (TWO_PI * quality * radius);
	float step = TWO_PI / (numSteps + 1);

	int points = numSteps * 2 + 2;
	int[] curve = new int[points];

	int curveIndex = 0;
	curve[curveIndex++] = (int) p2.x;
	curve[curveIndex++] = (int) p2.y;

	int currentStep = 0;
	while (true) {
		p1 = p2.copy();

		angle += step;
		currentStep++;
		if (currentStep > numSteps) {
			break;
		}

		brightness = getBrightness(radius, angle);

		noiseFrequency = getCorrecteNoiseFrequency(radius, frequency);
		noise = getNoise(brightness, angle, phase, amplitude, noiseFrequency);
		p2 = getNext(center, radius, angle, noise);

		curve[curveIndex++] = (int) p2.x;
		curve[curveIndex++] = (int) p2.y;

	}
	drawSpline(curve);
}

float getCorrecteNoiseFrequency(float radius, float frequency) {
	float rFreq = radius * frequency;
	float noiseFrequency = rFreq - rFreq % 2;
	return noiseFrequency;
}

float getNoise(float brightness, float angle, float phase, float amplitude, float frequency) {
	return (255 - brightness) * amplitude * sin(frequency * angle + phase);
}

PVector getNext(PVector center, float radius, float angle, float noise)
{
	PVector p = new PVector();

	p.x = center.x + (radius + noise) * cos(angle);
	p.y = center.y + (radius + noise) * sin(angle);

	return p;
}

float getBrightness(float radius, float angle) {
	int x = (int) (center.x + radius * cos(angle));
	int y = (int) (center.y + radius * sin(angle));
	return brightness(shape.get(x, y));
}

void drawLine(PVector p1, PVector p2) {
	noFill();
	stroke(40, 169, 226);
	strokeWeight(2);
	line(p1.x, p1.y, p2.x, p2.y);
}

void drawSpline(int[] curve) {
	noFill();
	stroke(40, 169, 226);
	strokeWeight(4);

	beginShape();

	for (int i = 0; i < curve.length; i += 2) {
		curveVertex(curve[i], curve[i+1]);

		if (curve[i] < 1) {
			println("i: " + i);
			println("length: " + curve.length);
		}
	}

	curveVertex(curve[0], curve[1]);
	curveVertex(curve[2], curve[3]);
	curveVertex(curve[4], curve[5]);

	endShape();
}
