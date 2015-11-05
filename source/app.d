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
import src.Camera;

Window window;
Camera camera;

double width = (1280)/2;
double height = (800-22)/2;
bool loop = true;
bool pressedLeft = false, pressedRight = false, pressedDown = false, pressedUp = false, pressedZ = false, pressedX = false;
bool pressedW = false, pressedS = false, pressedD = false, pressedA = false;
Random gen;
UltraMesh ultraMesh;
ShapeGroup ground;

/*
What do I want to build with this?
*/

void main() {
  init();
}

void init() {
	initCore();
	//initUltraMesh();
	
	animate();
}
void initCore() {
	window = new Window("example", to!int(width), to!int(height));
	//camera = new OrthographicCamera(-100, 100, 100, -100, 0.01, 200);
	camera = new Camera( Vec3(-4,-3,3) ,width, height, 45, 0.1, 6000);
	Vec3 cameraLookingAt = Vec3(0, 0, 0);
	camera.look_at(cameraLookingAt);
	
	Input.key_down(KEY_Q, {loop = false;});
	Input.key_down(KEY_LEFT, { pressedLeft = true; });
	Input.key_up(KEY_LEFT, { pressedLeft = false; });
	Input.key_down(KEY_UP, { pressedUp = true; });
	Input.key_up(KEY_UP, { pressedUp = false; });
	Input.key_down(KEY_DOWN, { pressedDown = true; });
	Input.key_up(KEY_DOWN, { pressedDown = false; });
	Input.key_down(KEY_RIGHT, { pressedRight = true; });
	Input.key_up(KEY_RIGHT, { pressedRight = false; });

	Input.key_down(KEY_W, { pressedW = true; });
	Input.key_up(KEY_W, { pressedW = false; });
	Input.key_down(KEY_S, { pressedS = true; });
	Input.key_up(KEY_S, { pressedS = false; });
	Input.key_down(KEY_A, { pressedA = true; });
	Input.key_up(KEY_A, { pressedA = false; });
	Input.key_down(KEY_D, { pressedD = true; });
	Input.key_up(KEY_D, { pressedD = false; });

	Input.key_down(KEY_Z, { pressedZ = true; });
	Input.key_up(KEY_Z, { pressedZ = false; });
	Input.key_down(KEY_X, { pressedX = true; });
	Input.key_up(KEY_X, { pressedX = false; });
}

void initUltraMesh() {
	ultraMesh = new UltraMesh();

	Point[] vertices = [];
	Indice[] indices = [];
	Color[] colors = [];
	//Lets make a giant mesh that stretches far
	int width = 100;
	int height = 100;
	Random gen;

	/*
	-----|--|-----------|--|-----
	-----|--|-----------|--|-----Neon BLue
         |  |           |  |
         |  |  black?   |  |
         |  |           |  |
         |  |           |  |
	-----|--|-----------|--|-----
	-----|--|-----------|--|-----Neon BLue
	 *///Neon Blue

	//Lets make a lattice now
	for (int x = -500/2; x < 500/2; x++) {
		for (int y = -500/2; y < 500/2; y++) {
			ShapeGroup shape = ShapeCreator.makeRectangle(ultraMesh, Point(x, y, 0), 0.5, 0.5);
		}
	}

	writeln("Triangle Count: ", ultraMesh.getTriangleCount());
	writeln("Vertex Count: ", ultraMesh.getVertexCount());
	ultraMesh.updateAllBuffers();
	ultraMesh.setWireframe(false);
}

void animate() {
	Random gen;
	float height = 0.8;
	while (loop) {
		Input.poll();
		if (pressedLeft) {
			camera.strafe_left(0.1);
		}

		if (pressedRight) {
			camera.strafe_right(0.1);
		}
		if (pressedUp) {
			camera.move_forward(0.1);
		}
		if (pressedDown) {
			camera.move_backward(0.1);
		}
		if (pressedA) {
			camera.rotatex(2);
		}
		if (pressedD) {
			camera.rotatex(-2);
		}
		if (pressedW) {
			camera.rotatey(-2);
		}
		if (pressedS) {
			camera.rotatey(2);
		}
		if (pressedZ) {
			camera.move_down(0.1);
		}
		if (pressedX) {
			camera.move_up(0.1);
		}
		/*
		float[] vertexData = ground.getVertexData();
		ubyte[] colorData = ground.getColorData();
		for (int i = 0; i < ground.getVertexCount(); i+=1) {
			float x = vertexData[i*3];
			float y = vertexData[i*3+1];
			if (x%3 == 0 && y%3 == 0) {
				float zMove = (uniform(0, 1000, gen)/1000.0 - 0.5)/100;
				float z = vertexData[i*3+2];
				z += zMove;
				if (z < 0) {z = 0;}
				if (z > height) {z = height;}
				colorData[i*4] = to!ubyte(to!int(z/height*255));
				colorData[i*4+1] = to!ubyte(to!int(z/height*255));
				colorData[i*4+2] = to!ubyte(255-to!int(z/height/2.0*255));
				vertexData[i*3+2] = z;
			}
		}*/

		//ultraMesh.updateVertexBuffer();
		//ultraMesh.updateColorBuffer();

		//ultraMesh.render(camera);
		if (ultraMesh) {
			ultraMesh.render(camera);
		}
		window.update();
		// check OpenGL error
		GLenum err;
		while ((err = glGetError()) != GL_NO_ERROR) {
			writeln("OpenGL Error: ", err);
		}
	}
}