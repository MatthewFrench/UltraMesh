import grape;
import std.conv;
import std.stdio;
import grape.shader;
import std.math;
import std.stdio;
import std.traits;
import std.conv;
import std.algorithm;
import std.array;
import std.range;
import std.random;

import src.ShapeCreator;
import src.UltraMesh;
import src.ShapeGroup;

Window window;
PerspectiveCamera camera;
//OrthographicCamera camera;

double width = (1280);
double height = (800-22);
bool loop = true;
bool pressedLeft = false, pressedRight = false, pressedDown = false, pressedUp = false, zoomIn = false, zoomOut = false;
double cameraX = 0.0;
double cameraY = 0.0;
double cameraZ = 0.0;
ShapeGroup[] groups = [];
Vec3[] vel = [];
Random gen;
UltraMesh ultraMesh;

void main() {
  init();
  animate();
}

void init() {
	initCore();
	initUltraMesh();
}
void initCore() {
	window = new Window("example", to!int(width), to!int(height));
	//camera = new OrthographicCamera(-100, 100, 100, -100, 0.01, 200);
	camera = new PerspectiveCamera(45, width/height, 0.1, 200);
	Vec3 cameraPosition = Vec3(4,3,3);
	Vec3 cameraLookingAt = Vec3(0, 0, 0);
	Vec3 cameraUp = Vec3(0,0,1);
	camera.look_at(cameraPosition, cameraLookingAt, cameraUp);
	
	Input.key_down(KEY_Q, {loop = false;});
	Input.key_down(KEY_LEFT, { pressedLeft = true; });
	Input.key_up(KEY_LEFT, { pressedLeft = false; });
	Input.key_down(KEY_UP, { pressedUp = true; });
	Input.key_up(KEY_UP, { pressedUp = false; });
	Input.key_down(KEY_DOWN, { pressedDown = true; });
	Input.key_up(KEY_DOWN, { pressedDown = false; });
	Input.key_down(KEY_RIGHT, { pressedRight = true; });
	Input.key_up(KEY_RIGHT, { pressedRight = false; });

	Input.key_down(KEY_Z, { zoomIn = true; });
	Input.key_up(KEY_Z, { zoomIn = false; });
	Input.key_down(KEY_X, { zoomOut = true; });
	Input.key_up(KEY_X, { zoomOut = false; });
}

void initUltraMesh() {
	ultraMesh = new UltraMesh();

	ultraMesh.setAutoUpdateBuffers(false);
	double cubeSize = 1.0;
	for (int i = 0; i < 50; i++) {
		for (int y = 0; y < 50; y ++) {
			double zOff = uniform(0, 1000, gen)/1000.0/2;
			for (int z = -10; z < 0; z++) {
				double cubeX = -i+5;
				double cubeY = -y+5;
				double cubeZ = zOff+z;
				ShapeGroup cube = ShapeCreator.makeSphere(ultraMesh, cubeX, cubeY, cubeZ, cubeSize, 10);
					//makeCube(ultraMesh, cubeX, cubeY, cubeZ, cubeSize);
				cube.setScale(0.15, 0.15, 0.15);
				groups ~= cube;
				vel ~= Vec3(uniform(0, 1000, gen)/10000.0-0.05, uniform(0, 1000, gen)/10000.0-0.05, uniform(0, 1000, gen)/10000.0-0.05);
			}
		}
	}
	writeln("Shape Count: ", groups.length);
	ultraMesh.updateAllBuffers();
	ultraMesh.setWireframe(false);
}

void animate() {
	float rot = 0;
	bool scaleIncreasing = false;
	float scale = 1.0;
	float scaleSpeed = 0.01;
	while (loop) {
		Input.poll();
		if (pressedLeft) cameraX += 0.1;
		if (pressedRight) cameraX -= 0.1;
		if (pressedUp) cameraY -= 0.1;
		if (pressedDown) cameraY += 0.1;
		if (zoomIn) cameraZ -= 0.1;
		if (zoomOut) cameraZ += 0.1;
		if (pressedLeft || pressedRight || pressedDown || pressedUp || zoomIn || zoomOut) {
			Vec3 cameraPosition = Vec3(cameraX+4, cameraY+3, cameraZ+3);
			Vec3 cameraLookingAt = Vec3(cameraX, cameraY, cameraZ);
			Vec3 cameraUp = Vec3(0, 0, 1);
			camera.look_at(cameraPosition, cameraLookingAt, cameraUp);
		}
		rot += 0.1;
		/*
		if (scaleIncreasing) {
			scale += scaleSpeed;
			if (scale > 1.0) {
				scale = 1.0;
				scaleIncreasing = false;
			}
		} else {
			scale -= scaleSpeed;
			if (scale < 0.01) {
				scale = 0.01;
				scaleIncreasing = true;
			}
		}*/
		for (int i = 0; i < groups.length; i++) {
			//groups[i].setScale(scale, scale, scale);

			//groups[i].setRotation(rot, rot, rot);
			groups[i].setRotationZ(rot/2);

			//groups[i].rotateX(0.005);
			//groups[i].rotateX(uniform(0, 1000, gen)/1000.0);
			//groups[i].rotateY(uniform(0, 1000, gen)/1000.0);
			/*
			groups[i].moveX(vel[i].x);
			groups[i].moveY(vel[i].y);
			groups[i].moveZ(vel[i].z);
			if (groups[i].centerX < -45) {
				groups[i].setPosition(-45, groups[i].centerY, groups[i].centerZ);
				vel[i] = Vec3(-vel[i].x,vel[i].y,vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}
			if (groups[i].centerX > 5) {
				groups[i].setPosition(5, groups[i].centerY, groups[i].centerZ);
				vel[i] = Vec3(-vel[i].x,vel[i].y,vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}
			if (groups[i].centerY > 5) {
				groups[i].setPosition(groups[i].centerX, 5, groups[i].centerZ);
				vel[i] = Vec3(vel[i].x,-vel[i].y,vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}
			if (groups[i].centerY < -45) {
				groups[i].setPosition(groups[i].centerX, -45, groups[i].centerZ);
				vel[i] = Vec3(vel[i].x,-vel[i].y,vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}
			if (groups[i].centerZ > 0) {
				groups[i].setPosition(groups[i].centerX, groups[i].centerY, 0);
				vel[i] = Vec3(vel[i].x,vel[i].y,-vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}
			if (groups[i].centerY < -45) {
				groups[i].setPosition(groups[i].centerX, groups[i].centerY, -45);
				vel[i] = Vec3(vel[i].x,vel[i].y,-vel[i].z);
				groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
			}*/
		}
		ultraMesh.updateVertexBuffer();
		ultraMesh.updateColorBuffer();
		ultraMesh.render(camera);
		window.update();
		// check OpenGL error
		GLenum err;
		while ((err = glGetError()) != GL_NO_ERROR) {
			writeln("OpenGL Error: ", err);
		}
	}
}