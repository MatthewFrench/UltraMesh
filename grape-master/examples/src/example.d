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

double width = 640;
double height = 480;
bool loop = true;

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
bool pressedLeft = false, pressedRight = false, pressedDown = false, pressedUp = false, zoomIn = false, zoomOut = false;
double cameraX = 0.0;
double cameraY = 0.0;
double cameraZ = 0.0;
ShapeGroup[] groups = [];

void initUltraMesh() {
	ultraMesh = new UltraMesh();

	Random gen;
	ultraMesh.updateBuffers = false;
	double cubeSize = 1.0;
	int count = 0;
	double xPos = -width/2.0;
	double yPos = -height/2.0;
	for (int z = -10; z < 0; z++) {
		for (int i = 0; i < 100; i++) {
			for (int y = 0; y < 100; y ++) {
				double cubeX = -i+5;
				double cubeY = -y+5;
				double cubeZ = uniform(0, 1000, gen)/1000.0/2+z;
				groups ~= ShapeCreator.makeCube(ultraMesh, cubeX, cubeY, cubeZ, cubeSize);
			}
		}
	}
	writeln("Shape Count: ", groups.length);
	//ultraMesh.updateBuffers = true;
	ultraMesh.updateAllBuffers();

	ultraMesh.wireframe = false;
}

void animate() {
	Vec3 axisX = Vec3(1, 1, 0);
	float rad = -PI/270;

	/*
	int i = 0;
	double triangleWidth = 20;
	double xPos = -width/2.0;
	double yPos = -height/2.0;
	int count = 0;
	int triangleCount = 0;
*/
	float rot = 0;
	Random gen;
	for (int g = 0; g < groups.length; g++) {
		for (int i = groups[g].firstColor; i < groups[g].lastColor; i+= 4) {
			ultraMesh.color.data[i] = to!ubyte(uniform(0, 255, gen));
			ultraMesh.color.data[i+1] = to!ubyte(uniform(0, 255, gen));
			ultraMesh.color.data[i+2] = to!ubyte(uniform(0, 255, gen));
			ultraMesh.color.data[i+3] = to!ubyte(255);
		}
	}
	//ultraMesh.updateVertexBuffer();
	ultraMesh.updateColorBuffer();

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
		for (int i = 0; i < groups.length; i++) {
				//groups[i].setColor(uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, uniform(0, 1000, gen)/1000.0, 1.0);
				//groups[i].rotateZ(0.005);
			//groups[i].rotateX(0.005);
			//groups[i].rotateX(uniform(0, 1000, gen)/1000.0);
			//groups[i].rotateY(uniform(0, 1000, gen)/1000.0);
			/*
			groups[i].translateX(vels[i].x);
			groups[i].translateY(vels[i].y);
			if (groups[i].centerX < -width/2.0) {
				groups[i].setPosition(-width/2.0, groups[i].centerY, groups[i].centerZ);
				vels[i] = Vec3(-vels[i].x,vels[i].y,vels[i].z);
			}
			if (groups[i].centerX > width/2.0) {
				groups[i].setPosition(width/2.0, groups[i].centerY, groups[i].centerZ);
				vels[i] = Vec3(-vels[i].x,vels[i].y,vels[i].z);
			}
			if (groups[i].centerY > height/2.0) {
				groups[i].setPosition(groups[i].centerX, height/2.0, groups[i].centerZ);
				vels[i] = Vec3(vels[i].x,-vels[i].y,vels[i].z);
			}
			if (groups[i].centerY < -height/2.0) {
				groups[i].setPosition(groups[i].centerX, -height/2.0, groups[i].centerZ);
				vels[i] = Vec3(vels[i].x,-vels[i].y,vels[i].z);
			}*/
		}
		//ultraMesh.updateVertexBuffer();
		//ultraMesh.updateColorBuffer();
		/*
		count += 1;
		if (count > 60) {
			count = 0;
			for (int y = 0; y <= i; y ++) {
				ultraMesh.addTriangle(xPos + i*triangleWidth, yPos + y*triangleWidth, 0, triangleWidth);
				triangleCount += 1;
			}
			i += 1;
			writeln("Triangle Count: ", triangleCount);
		}*/

		//cubeG.rotate(axisX, rad);
		//cubeG.yaw(rad);
		ultraMesh.render(camera);

		
		window.update();

		//writeln(ultraMesh.color.data);
		// check OpenGL error
		GLenum err;
		while ((err = glGetError()) != GL_NO_ERROR) {
			writeln("OpenGL Error: ", err);
		}
	}
}