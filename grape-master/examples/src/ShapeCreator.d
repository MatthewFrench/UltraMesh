module src.ShapeCreator;
import src.UltraMesh;
import src.ShapeGroup;

class ShapeCreator
{
	static ShapeGroup makeTriangle(UltraMesh mesh, double triangleX, double triangleY, double triangleZ, double width) {
		if (mesh.vertices.capacity()-9 <= 0) {
			mesh.vertices.reserve(mesh.vertices.data.length*2 + 9);
		}
		if (mesh.indices.capacity()-3 <= 0) {
			mesh.indices.reserve(mesh.indices.data.length*2 + 3);
		}
		if (mesh.color.capacity()-12 <= 0) {
			mesh.color.reserve(mesh.color.data.length*2 + 12);
		}
		int firstVertex = to!int(mesh.vertices.data.length);
		int firstIndice = to!int(mesh.indices.data.length);
		int firstColor = to!int(mesh.color.data.length);
		
		int n = to!int(mesh.vertices.data.length/3);
		
		mesh.vertices.put( [triangleX-width/2.0, triangleY-width/2.0, triangleZ,
				triangleX+width/2.0, triangleY-width/2.0, triangleZ,
				triangleX, triangleY+width/2.0, triangleZ ] );
		
		//Add the lines to connect vertices
		mesh.indices.put( [n, n+1, n+2] );
		
		//For each vertex we need a color R, G, B, A
		mesh.color.put( [colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA] );
		
		int lastVertex = to!int(mesh.vertices.data.length);
		int lastIndice = to!int(mesh.indices.data.length);
		int lastColor = to!int(mesh.color.data.length);
		
		if (mesh.updateBuffers) {
			mesh.updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			mesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			mesh.updateColorBufferPartial(firstColor, lastColor-firstColor);
		}
		
		return ShapeGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, mesh);
		
	}
	
	static ShapeGroup makeSquare(UltraMesh mesh, double squareX, double squareY, double squareZ, double size) {
		if (mesh.vertices.capacity()-12 <= 0) {
			mesh.vertices.reserve(mesh.vertices.data.length*2 + 12);
		}
		if (mesh.indices.capacity()-6 <= 0) {
			mesh.indices.reserve(mesh.indices.data.length*2 + 6);
		}
		if (mesh.color.capacity() - 16 <= 0) {
			mesh.color.reserve(mesh.color.data.length*2 + 16);
		}
		int firstVertex = to!int(mesh.vertices.data.length);
		int firstIndice = to!int(mesh.indices.data.length);
		int firstColor = to!int(mesh.color.data.length);
		
		int n = to!int(mesh.vertices.data.length/3);

		mesh.vertices.put(
			[ squareX-size/2.0, squareY-size/2.0, squareZ,
				squareX-size/2.0, squareY+size/2.0, squareZ,
				squareX+size/2.0, squareY-size/2.0, squareZ,
				squareX+size/2.0, squareY+size/2.0, squareZ] );

		//Add the lines to connect vertices
		mesh.indices.put( [n, n+1, n+2, n+3, n+2, n+1] );
		
		//For each vertex we need a color R, G, B, A
		mesh.color.put( [colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA] );
		
		int lastVertex = to!int(mesh.vertices.data.length);
		int lastIndice = to!int(mesh.indices.data.length);
		int lastColor = to!int(mesh.color.data.length);

		if (mesh.updateBuffers) {
			mesh.updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			mesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			mesh.updateColorBufferPartial(firstColor, lastColor-firstColor);
		}
		
		return ShapeGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, mesh);
		
	}
	static ShapeGroup makeCube(UltraMesh mesh, double squareX, double squareY, double squareZ, double size) {
		if (mesh.vertices.capacity() - 24 <= 0) {
			mesh.vertices.reserve(mesh.vertices.data.length*2 + 24);
		}
		if (mesh.indices.capacity() - 36 <= 0) {
			mesh.indices.reserve(mesh.indices.data.length*2 + 36);
		}
		if (color.capacity() - 24 <= 0) {
			mesh.color.reserve(mesh.color.data.length*2 + 24);
		}
		int firstVertex = to!int(mesh.vertices.data.length);
		int firstIndice = to!int(mesh.indices.data.length);
		int firstColor = to!int(mesh.color.data.length);
		
		int n = to!int(mesh.vertices.data.length/3);
		float s = size/2.0;
		mesh.vertices.put(
			[ -s+squareX, -s+squareY, s+squareZ, 
				s+squareX, -s+squareY, s+squareZ, 
				s+squareX, s+squareY, s+squareZ, 
				-s+squareX, s+squareY, s+squareZ, 
				-s+squareX, -s+squareY, -s+squareZ, 
				s+squareX, -s+squareY, -s+squareZ, 
				s+squareX, s+squareY, -s+squareZ, 
				-s+squareX, s+squareY, -s+squareZ ] );
		
		
		//Add the lines to connect vertices
		mesh.indices.put( [n,n+ 1,n+ 2,n+ 2,n+ 3,n+ 0,n+ 
				3,n+ 2,n+ 6,n+ 6,n+ 7,n+ 3,n+ 
				7,n+ 6,n+ 5,n+ 5,n+ 4,n+ 7,n+ 
				4,n+ 0,n+ 3,n+ 3,n+ 7,n+ 4,n+ 
				0,n+ 1,n+ 5,n+ 5,n+ 4,n+ 0,n+
				1,n+ 5,n+ 6,n+ 6,n+ 2,n+ 1 ] );
		
		//For each vertex we need a color R, G, B, 7
		mesh.color.put( [colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA] );
		
		int lastVertex = to!int(mesh.vertices.data.length);
		int lastIndice = to!int(mesh.indices.data.length);
		int lastColor = to!int(mesh.color.data.length);
		
		if (mesh.updateBuffers) {
			mesh.updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			mesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			mesh.updateColorBufferPartial(firstColor, lastColor-firstColor);
		}
		
		return ShapeGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, mesh);
		
	}
}

