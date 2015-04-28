module src.ShapeCreator;
import src.UltraMesh;
import src.ShapeGroup;
import std.conv;
import std.random;
import std.math;
import std.stdio;
import std.algorithm: canFind;
import std.traits;
import std.typecons;

class ShapeCreator
{
	static ShapeGroup makeShape(UltraMesh mesh, Point[] vertices, Indice[] indices, Color[] colors) {
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeTriangle(UltraMesh mesh, Point position, double width) {
		Point[] vertices = [Point(position.x-width/2.0, position.y-width/2.0, position.z),
			Point(position.x+width/2.0, position.y-width/2.0, position.z),
			Point(position.x, position.y+width/2.0, position.z) ];
		
		Indice[] indices = [Indice(0, 1, 2)];

		Color[] colors = [];

		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	
	static ShapeGroup makeSquare(UltraMesh mesh, Point position, double size) {
		Point[] vertices = 
		[ Point(position.x-size/2.0, position.y-size/2.0, position.z),
			Point(position.x-size/2.0, position.y+size/2.0, position.z),
			Point(position.x+size/2.0, position.y-size/2.0, position.z),
			Point(position.x+size/2.0, position.y+size/2.0, position.z)];

		//Add the lines to connect vertices
		Indice[] indices = [Indice(0, 1, 2), Indice(3, 2, 1)];

		Color[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeCube(UltraMesh mesh, Point position, double size) {
		float s = size/2.0;
		Point[] vertices = [ Point(-s+position.x, -s+position.y, s+position.z), 
			Point(s+position.x, -s+position.y, s+position.z), 
			Point(s+position.x, s+position.y, s+position.z), 
			Point(-s+position.x, s+position.y, s+position.z), 
			Point(-s+position.x, -s+position.y, -s+position.z), 
			Point(s+position.x, -s+position.y, -s+position.z), 
			Point(s+position.x, s+position.y, -s+position.z), 
			Point(-s+position.x, s+position.y, -s+position.z) ];

		
		//Add the lines to connect vertices
		Indice[] indices = [Indice(0, 1, 2), Indice(2, 3, 0), 
			Indice(3, 2, 6),Indice( 6, 7, 3), 
			Indice(7, 6, 5),Indice( 5, 4, 7), 
			Indice(4, 0, 3),Indice( 3, 7, 4), 
			Indice(0, 1, 5),Indice( 5, 4, 0),
			Indice(1, 5, 6),Indice( 6, 2, 1 )];
		
		Color[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makePolygon(UltraMesh mesh, Point position, double radius, int segments) {
		if (segments < 3) {segments = 3;}
		Point[] vertices = [];
		vertices ~= [Point(position.x, position.y, position.z)]; //Center point
		for (int i=0; i < segments; i++)
		{
			float degInRad = i*(PI*2)/segments;
			double x = cos(degInRad)*radius;
			double y = sin(degInRad)*radius;
			vertices ~= [Point(position.x + x, position.y + y, position.z)];
		}
		
		//Add the lines to connect vertices
		Indice[] indices = [];
		for (int i = 0; i < vertices.length-1; i++) {
			indices ~= [Indice(0,
					i,
					i+1)];
		}
		indices ~= [Indice(0, (to!int(vertices.length)-1), 1)]; //Final indice
		
		Color[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}
		
		return mesh.add(vertices, indices, colors);
	}
	static ShapeGroup makeCone(UltraMesh mesh, Point position, double radius, double height, int segments) {
		if (segments < 3) {segments = 3;}
		Point[] vertices = [];
		vertices ~= Point(position.x, position.y, position.z - height/2); //Center point
		for (int i=0; i < segments; i++)
		{
			float degInRad = i*(PI*2)/segments;
			double x = cos(degInRad)*radius;
			double y = sin(degInRad)*radius;
			vertices ~= [Point(position.x + x, position.y + y, position.z - height/2)];
		}
		vertices ~= [Point(position.x, position.y, position.z + height/2)];
		
		//Add the lines to connect vertices
		Indice[] indices = [];
		for (int i = 1; i < vertices.length-2; i++) {
			indices ~= [Indice(0,
					i,
					i+1)];
		}
		indices ~= [Indice(0, (to!int(vertices.length)-2), 1)]; //Final bottom indice

		int topVertex = to!int(vertices.length)-1;
		//Now connect to the top to form a pyramid
		for (int i = 1; i < vertices.length-1; i++) {
			indices ~= [Indice(topVertex,
					i,
					i+1)];
		}
		indices ~= [Indice(topVertex, to!int(vertices.length)-2, 1)]; //Final bottom indice

		
		Color[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}
		
		return mesh.add(vertices, indices, colors);
	}

	static ShapeGroup makeSphere(UltraMesh mesh, Point position, double radius, int subdivision) {
		Point[] vertices = [];

		// create 12 vertices of a icosahedron
		//float t = (1.0 + sqrt(5.0)) / 2.0; //Was 5.0
		/*
		 vertices ~= Point(-1,  t,  0 );
		 vertices ~=  Point( 1,  t,  0 );
		 vertices ~=  Point(-1, -t,  0 );
		 vertices ~=  Point( 1, -t,  0 );
		 
		 vertices ~=  Point( 0, -1,  t );
		 vertices ~=  Point( 0,  1,  t );
		 vertices ~=  Point( 0, -1, -t );
		 vertices ~=  Point( 0,  1, -t );
		 
		 vertices ~=  Point( t,  0, -1 );
		 vertices ~=  Point( t,  0,  1 );
		 vertices ~=  Point(-t,  0, -1 );
		 vertices ~=  Point(-t,  0,  1 );
		 */

		vertices ~= [Point(0,0,-radius),
			Point(0,radius,0),
			Point(-radius,0,0),
			Point(0,-radius,0),
			Point(radius,0,0),
			Point(0,0,radius),
		];
		
		//Add the lines to connect vertices
		Indice[] indices = [
			Indice(0, 1, 2),
			Indice(0, 2, 3),
			Indice(0, 3, 4),
			Indice(0, 4, 1),
			
			Indice(5, 2, 1),
			Indice(5, 3, 2),
			Indice(5, 4, 3),
			Indice(5, 1, 4)
		];

		
		/*
		 // 5 faces around point 0
		 indices ~= Indice(0, 11, 5 );
		 indices ~= Indice(0, 5, 1 );
		 indices ~= Indice(0, 1, 7 );
		 indices ~= Indice(0, 7, 10 );
		 indices ~= Indice(0, 10, 11 );
		 
		 // 5 adjacent faces
		 indices ~= Indice(1, 5, 9 );
		 indices ~= Indice(5, 11, 4 );
		 indices ~= Indice(11, 10, 2 );
		 indices ~= Indice(10, 7, 6 );
		 indices ~= Indice(7, 1, 8 );
		 
		 // 5 faces around point 3
		 indices ~= Indice(3, 9, 4 );
		 indices ~= Indice(3, 4, 2 );
		 indices ~= Indice(3, 2, 6 );
		 indices ~= Indice(3, 6, 8 );
		 indices ~= Indice(3, 8, 9 );
		 
		 // 5 adjacent faces
		 indices ~= Indice(4, 9, 5 );
		 indices ~= Indice(2, 4, 11 );
		 indices ~= Indice(6, 2, 10 );
		 indices ~= Indice(8, 6, 7 );
		 indices ~= Indice(9, 8, 1 );
		 */

		for (int i = 0; i < subdivision; i++) {
			Tuple!(Point[], Indice[]) data = subdivide(vertices, indices);
			vertices = data[0];
			indices = data[1];
		}

		Color[] colors = [];
		//For each vertex we need a color R, G, B, A
		Random gen;
		for (int i = 0; i < vertices.length; i++) {
			ubyte r = to!ubyte(uniform(0, 256, gen));
			ubyte g = to!ubyte(uniform(0, 256, gen));
			ubyte b = to!ubyte(uniform(0, 256, gen));
			ubyte a = to!ubyte(255);
			colors ~= [Color(r, g, b, a)];
		}

		//Move the vertices
		Point center = Point(0,0,0);
		for (int i = 0; i < vertices.length; i++) {
			vertices[i] = normalize(vertices[i]);
			vertices[i].x = vertices[i].x + position.x;
			vertices[i].y = vertices[i].y + position.y;
			vertices[i].z = vertices[i].z + position.z;
		}

		return mesh.add(vertices, indices, colors);
	}

	

	
	static int GetNewVertex(int i1, int i2, ref uint[int] newVertices, ref Point[] vertices)
	{
		// We have to test both directions since the edge
		// could be reversed in another triangle
		uint t1 = (cast(uint)i1 << 16) | cast(uint)i2;
		uint t2 = (cast(uint)i2 << 16) | cast(uint)i1;
		if ((t2 in newVertices) !is null)
			return newVertices[t2];
		if ((t1 in newVertices) !is null)
			return newVertices[t1];
		// generate vertex:
		int newIndex = to!int(vertices.length);
		newVertices[t1] = newIndex;

		// calculate new vertex
		vertices ~= Point((vertices[i1].x + vertices[i2].x) * 0.5,(vertices[i1].y + vertices[i2].y) * 0.5, (vertices[i1].z + vertices[i2].z) * 0.5);
		//vertices~=((vertices[i1] + vertices[i2]) * 0.5f);

		return newIndex;
	}

	public static Tuple!(Point[], Indice[]) subdivide(Point[] vertices, Indice[] oldIndices)
	{
		uint[int] newVertices;

		Indice[] indices = [];

		for (int i = 0; i < oldIndices.length; i += 1)
		{
			int i1 = oldIndices[i].v1;
			int i2 = oldIndices[i].v2;
			int i3 = oldIndices[i].v3;
			
			int a = GetNewVertex(i1, i2, newVertices, vertices);
			int b = GetNewVertex(i2, i3, newVertices, vertices);
			int c = GetNewVertex(i3, i1, newVertices, vertices);
			indices~=Indice(i1,a,c);
			indices~=Indice(i2,b,a);
			indices~=Indice(i3,c,b);
			indices~=Indice(a,b,c); // center triangle
		}
		return tuple(vertices, indices);
	}
	static Point normalize(Point p){
		Point vector;
		double length = sqrt((p.x)*(p.x) + (p.y)*(p.y) + (p.z)*(p.z));
		if(length != 0){
			vector.x = p.x/length;
			vector.y = p.y/length;
			vector.z = p.z/length;
		}
		length = sqrt((vector.x)*(vector.x) + (vector.y)*(vector.y) + (vector.z)*(vector.z));
		
		return vector;
	}
	//returns a point collinear to A and B, a given distance away from A. 
	static Point normalize(Point a, Point b, double length) {
		//get the distance between a and b along the x and y axes
		double dx = b.x - a.x;
		double dy = b.y - a.y;
		double dz = b.z - a.z;
		//right now, sqrt(dx^2 + dy^2) = distance(a,b).
		//we want to modify them so that sqrt(dx^2 + dy^2) = the given length.
		double dist = distance(a,b);
		dx = dx * length / dist;
		dy = dy * length / dist;
		dz = dz * length / dist;
		Point c = Point(a.x + dx, a.y + dy, a.z + dz);
		return c;
	}
	static double distance(Point a, Point b) { //Cube root
		return cbrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y) + (a.z-b.z)*(a.z-b.z));
	}
}