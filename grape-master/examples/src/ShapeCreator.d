module src.ShapeCreator;
import src.UltraMesh;
import src.ShapeGroup;
import std.conv;
import std.random;
import std.math;
import std.stdio;

class ShapeCreator
{
	static ShapeGroup makeShape(UltraMesh mesh, float[] vertices, int[] indices, ubyte[] colors) {
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeTriangle(UltraMesh mesh, double triangleX, double triangleY, double triangleZ, double width) {
		float[] vertices = 
			[triangleX-width/2.0, triangleY-width/2.0, triangleZ,
			triangleX+width/2.0, triangleY-width/2.0, triangleZ,
			triangleX, triangleY+width/2.0, triangleZ ];
			
		int[] indices = [0, 1, 2];

		ubyte[] colors = [];

		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	
	static ShapeGroup makeSquare(UltraMesh mesh, double squareX, double squareY, double squareZ, double size) {
		float[] vertices = 
			[ squareX-size/2.0, squareY-size/2.0, squareZ,
				squareX-size/2.0, squareY+size/2.0, squareZ,
				squareX+size/2.0, squareY-size/2.0, squareZ,
				squareX+size/2.0, squareY+size/2.0, squareZ];

		//Add the lines to connect vertices
		int[] indices = [0, 1, 2, 3, 2, 1];

		ubyte[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a] ;
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeCube(UltraMesh mesh, double squareX, double squareY, double squareZ, double size) {
		float s = size/2.0;
		float[] vertices = [ -s+squareX, -s+squareY, s+squareZ, 
				s+squareX, -s+squareY, s+squareZ, 
				s+squareX, s+squareY, s+squareZ, 
				-s+squareX, s+squareY, s+squareZ, 
				-s+squareX, -s+squareY, -s+squareZ, 
				s+squareX, -s+squareY, -s+squareZ, 
				s+squareX, s+squareY, -s+squareZ, 
				-s+squareX, s+squareY, -s+squareZ ];
		
		
		//Add the lines to connect vertices
		int[] indices = [0, 1, 2, 2, 3, 0, 
				3, 2, 6, 6, 7, 3, 
				7, 6, 5, 5, 4, 7, 
				4, 0, 3, 3, 7, 4, 
				0, 1, 5, 5, 4, 0,
				1, 5, 6, 6, 2, 1 ];
		
		//For each vertex we need a color R, G, B, A
		ubyte[] colors = [];
		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makePolygon(UltraMesh mesh, double posX, double posY, double posZ, double radius, int segments) {
		if (segments < 3) {segments = 3;}
		float[] vertices = [];
		vertices ~= [posX, posY, posZ]; //Center point
		for (int i=0; i < segments; i++)
		{
			float degInRad = i*(PI*2)/segments;
			double x = cos(degInRad)*radius;
			double y = sin(degInRad)*radius;
			vertices ~= [posX + x, posY + y, posZ];
		}
		
		//Add the lines to connect vertices
		int[] indices = [];
		for (int i = 3; i < vertices.length-3; i+=3) {
			indices ~= [0,
						i/3,
						i/3+1];
		}
		indices ~= [0, (to!int(vertices.length)-3)/3, 1]; //Final indice
		
		//For each vertex we need a color R, G, B, A
		ubyte[] colors = [];
		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeCone(UltraMesh mesh, double posX, double posY, double posZ, double radius, double height, int segments) {
		if (segments < 3) {segments = 3;}
		float[] vertices = [];
		vertices ~= [posX, posY, posZ - height/2]; //Center point
		for (int i=0; i < segments; i++)
		{
			float degInRad = i*(PI*2)/segments;
			double x = cos(degInRad)*radius;
			double y = sin(degInRad)*radius;
			vertices ~= [posX + x, posY + y, posZ - height/2];
		}
		vertices ~= [posX, posY, posZ + height/2];
		
		//Add the lines to connect vertices
		int[] indices = [];
		for (int i = 3; i < vertices.length-6; i+=3) {
			indices ~= [0,
				i/3,
				i/3+1];
		}
		indices ~= [0, (to!int(vertices.length)-6)/3, 1]; //Final bottom indice

		int topVertex = to!int(vertices.length)/3-1;
		//Now connect to the top to form a pyramid
		for (int i = 3; i < vertices.length-3; i+=3) {
			indices ~= [topVertex,
				i/3,
				i/3+1];
		}
		indices ~= [topVertex, to!int(vertices.length)/3-2, 1]; //Final bottom indice

		
		//For each vertex we need a color R, G, B, A
		ubyte[] colors = [];
		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a];
		}
		
		return mesh.add(vertices, indices, colors);
	}

	static ShapeGroup makeSphere(UltraMesh mesh, double posX, double posY, double posZ, double radius, int subdivision) {
		float[] vertices = [];

		// create 12 vertices of a icosahedron
		float t = (1.0 + sqrt(5.0)) / 2.0; //Was 5.0
		
		vertices ~= [-1,  t,  0 ];
		vertices ~= [ 1,  t,  0 ];
		vertices ~= [-1, -t,  0 ];
		vertices ~= [ 1, -t,  0 ];
		
		vertices ~= [ 0, -1,  t ];
		vertices ~= [ 0,  1,  t ];
		vertices ~= [ 0, -1, -t ];
		vertices ~= [ 0,  1, -t ];
		
		vertices ~= [ t,  0, -1 ];
		vertices ~= [ t,  0,  1 ];
		vertices ~= [-t,  0, -1 ];
		vertices ~= [-t,  0,  1 ];
		
		//Add the lines to connect vertices
		int[] indices = [];
		
		// 5 faces around point 0
		indices ~= [0, 11, 5 ];
		indices ~= [0, 5, 1 ];
		indices ~= [0, 1, 7 ];
		indices ~= [0, 7, 10 ];
		indices ~= [0, 10, 11 ];
		
		// 5 adjacent faces
		indices ~= [1, 5, 9 ];
		indices ~= [5, 11, 4 ];
		indices ~= [11, 10, 2 ];
		indices ~= [10, 7, 6 ];
		indices ~= [7, 1, 8 ];
		
		// 5 faces around point 3
		indices ~= [3, 9, 4 ];
		indices ~= [3, 4, 2 ];
		indices ~= [3, 2, 6 ];
		indices ~= [3, 6, 8 ];
		indices ~= [3, 8, 9 ];
		
		// 5 adjacent faces
		indices ~= [4, 9, 5 ];
		indices ~= [2, 4, 11 ];
		indices ~= [6, 2, 10 ];
		indices ~= [8, 6, 7 ];
		indices ~= [9, 8, 1 ];
		
		//For each vertex we need a color R, G, B, A
		ubyte[] colors = [];
		Random gen;
		for (int i = 0; i < vertices.length/3; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [r, g, b, a];
		}

		//Move the vertices
		for (int i = 0; i < vertices.length; i+=3) {
			vertices[i] = vertices[i]*radius + posX;
			vertices[i+1] = vertices[i+1]*radius + posY;
			vertices[i+2] = vertices[i+2]*radius + posZ;
		}

		return mesh.add(vertices, indices, colors);
	}
}