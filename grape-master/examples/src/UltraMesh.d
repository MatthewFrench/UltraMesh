module src.UltraMesh;
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

class UltraMesh
{
	Appender!(float[]) vertices;
	Appender!(int[]) indices;
	Appender!(ubyte[]) color;
	bool wireframe;
	ubyte colorR, colorB, colorG, colorA;
	GLuint indiceBuffer;
	GLuint vertexBuffer;
	GLuint colorBuffer;
	GLuint vaoID;
	int indiceBufferSize = 0;
	int vertexBufferSize = 0;
	int colorBufferSize = 0;
	bool updateBuffers = true;
	GLint cameraUniformLocation;
	GLint vertexLocation, colorLocation;
	this()
	{
		if (program is null) {
			initializeShader();
		}
		wireframe = false;
		colorR = to!ubyte(255);
		colorB = to!ubyte(0);
		colorG = to!ubyte(0);
		colorA = to!ubyte(255);
		vertices = appender!(float[]); //Points
		indices = appender!(int[]); //Edges
		color = appender!(ubyte[]);

		glGenVertexArrays(1, &vaoID); // Create our Vertex Array Object  
		glBindVertexArray(vaoID); // Bind our Vertex Array Object so we can use it  

		//Create buffer for indices
		glGenBuffers(1, &indiceBuffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer); 
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, int.sizeof*3, null, GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

		//Create buffer for vertices
		glGenBuffers(1, &vertexBuffer);
		//Bind the buffer so we can work on it
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); 
		glBufferData(GL_ARRAY_BUFFER, float.sizeof*9, null, GL_DYNAMIC_DRAW);
		//Bind to the attribute so we can do stuff to it
		glBindAttribLocation(program, 0, cast(char*)"position");
		//Get the attribute location?
		vertexLocation = glGetAttribLocation(program, cast(char*)"position");
		//Describe the data of the attribute?
		glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, null);
		//Enable it for drawing
		glEnableVertexAttribArray(vertexLocation);
		//Unbind the buffer
		glBindBuffer(GL_ARRAY_BUFFER, 0); 

		//Create buffer for colors
		glGenBuffers(1, &colorBuffer);
		//Bind the buffer so we can work on it
		glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
		glBufferData(GL_ARRAY_BUFFER, byte.sizeof*12, null, GL_DYNAMIC_DRAW);
		//Bind to the attribute so we can do stuff to it
		glBindAttribLocation(program, 1, cast(char*)"color");
		//Get the attribute location?
		colorLocation = glGetAttribLocation(program, cast(char*)"color");
		//Describe the data of the attribute?
		glVertexAttribPointer(colorLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, null);
		//Enable it for drawing
		glEnableVertexAttribArray(colorLocation);
		//Unbind the buffer
		glBindBuffer(GL_ARRAY_BUFFER, 0); 


		cameraUniformLocation = glGetUniformLocation(program, cast(char*)"pvmMatrix"); 

		//glEnableVertexAttribArray(0); // Disable our Vertex Array Object  
		//glBindVertexArray(0); // Disable our Vertex Buffer Object  
	}
	~this() {
		glDeleteBuffers(1, &indiceBuffer);
		glDeleteBuffers(1, &vertexBuffer);
		glDeleteBuffers(1, &colorBuffer);
	}
	void updateAllBuffers() {
		updateIndiceBufferPartial(0, to!int(indices.data.length));
		updateVertexBufferPartial(0, to!int(vertices.data.length));
		updateColorBufferPartial(0, to!int(color.data.length));
	}
	void updateColorBuffer() {
		updateColorBufferPartial(0, to!int(color.data.length));
	}void updateVertexBuffer() {
		updateVertexBufferPartial(0, to!int(vertices.data.length));
	}void updateIndiceBuffer() {
		updateIndiceBufferPartial(0, to!int(indices.data.length));
	}
	void reserveIndiceBuffer(int length) {
		indiceBufferSize = length;
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer); 
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, int.sizeof*length, null, GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
	}
	void updateIndiceBufferPartial(int start, int length) {
		if (indiceBufferSize <= start+length) {
			indiceBufferSize = to!int(indiceBufferSize * 2 + 3);
			if (indiceBufferSize < start+length) {indiceBufferSize=start+length+3;}
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer); 
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, int.sizeof*indiceBufferSize, null, GL_DYNAMIC_DRAW);
			glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, indices.data.length*int.sizeof, indices.data.ptr);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
		} else {
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer);
			glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, start*int.sizeof, length*int.sizeof, indices.data[start..start+length].ptr);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
		}
	}

	void reserveVertexBuffer(int length) {
		vertexBufferSize = length;
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); 
		glBufferData(GL_ARRAY_BUFFER, float.sizeof*length, null, GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	void updateVertexBufferPartial(int start, int length) {
		if (vertexBufferSize <= start+length) {
			vertexBufferSize = to!int(vertexBufferSize * 2 + 9);
			if (vertexBufferSize < start+length) {vertexBufferSize=start+length+9;}
			glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); 
			glBufferData(GL_ARRAY_BUFFER, float.sizeof*vertexBufferSize, null, GL_DYNAMIC_DRAW);
			glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.data.length*float.sizeof, vertices.data.ptr);
			glBindBuffer(GL_ARRAY_BUFFER, 0); 
		} else {
			glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
			glBufferSubData(GL_ARRAY_BUFFER, start*float.sizeof, length*float.sizeof, vertices.data[start..start+length].ptr);
			glBindBuffer(GL_ARRAY_BUFFER, 0); 
		}
	}
	void reserveColorBuffer(int length) {
		colorBufferSize = length;
		glBindBuffer(GL_ARRAY_BUFFER, colorBuffer); 
		glBufferData(GL_ARRAY_BUFFER, byte.sizeof*length, null, GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0); 
	}
	void updateColorBufferPartial(int start, int length) {
		if (colorBufferSize <= start+length) {
			colorBufferSize = to!int(colorBufferSize * 2 + 12);
			if (colorBufferSize < start+length) {colorBufferSize=start+length+12;}
			glBindBuffer(GL_ARRAY_BUFFER, colorBuffer); 
			glBufferData(GL_ARRAY_BUFFER, byte.sizeof*colorBufferSize, null, GL_DYNAMIC_DRAW);
			glBufferSubData(GL_ARRAY_BUFFER, 0, color.data.length*byte.sizeof, color.data.ptr);
			glBindBuffer(GL_ARRAY_BUFFER, 0); 
		} else {
			glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
			glBufferSubData(GL_ARRAY_BUFFER, start*byte.sizeof, length*byte.sizeof, color.data[start..start+length].ptr);
			glBindBuffer(GL_ARRAY_BUFFER, 0); 
		}
	}
	
	
	VertexGroup addTriangle(double triangleX, double triangleY, double triangleZ, double width) {
		if (vertices.capacity() == 0) {
			vertices.reserve(vertices.data.length*2 + 9);
		}
		if (indices.capacity() == 0) {
			indices.reserve(indices.data.length*2 + 3);
		}
		if (color.capacity() == 0) {
			color.reserve(color.data.length*2 + 12);
		}
		int firstVertex = to!int(vertices.data.length);
		int firstIndice = to!int(indices.data.length);
		int firstColor = to!int( color.data.length);

		int n = to!int(vertices.data.length/3);

		vertices.put( [triangleX-width/2.0, triangleY-width/2.0, triangleZ,
			triangleX+width/2.0, triangleY-width/2.0, triangleZ,
			triangleX, triangleY+width/2.0, triangleZ ] );

		//Add the lines to connect vertices
		indices.put( [n, n+1, n+2] );

		//For each vertex we need a color R, G, B, A
		color.put( [colorR, colorG, colorB, colorA,
			colorR, colorG, colorB, colorA,
			colorR, colorG, colorB, colorA] );

		int lastVertex = to!int(vertices.data.length);
		int lastIndice = to!int(indices.data.length);
		int lastColor = to!int(color.data.length);

		if (updateBuffers) {
			updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			updateColorBufferPartial(firstColor, lastColor-firstColor);
		}

		return VertexGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, this);

	}

	VertexGroup addSquare(double squareX, double squareY, double squareZ, double size) {
		if (vertices.capacity() == 0) {
			vertices.reserve(vertices.data.length*2 + 12);
		}
		if (indices.capacity() == 0) {
			indices.reserve(indices.data.length*2 + 6);
		}
		if (color.capacity() == 0) {
			color.reserve(color.data.length*2 + 16);
		}
		int firstVertex = to!int(vertices.data.length);
		int firstIndice = to!int(indices.data.length);
		int firstColor = to!int( color.data.length);

		int n = to!int(vertices.data.length/3);

		vertices.put(
				[ squareX-size/2.0, squareY-size/2.0, squareZ,
				squareX-size/2.0, squareY+size/2.0, squareZ,
				squareX+size/2.0, squareY-size/2.0, squareZ,
				squareX+size/2.0, squareY+size/2.0, squareZ] );
		
		//Add the lines to connect vertices
		indices.put( [n, n+1, n+2, n+3, n+2, n+1] );
		
		//For each vertex we need a color R, G, B, A
		color.put( [colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA] );
		
		int lastVertex = to!int(vertices.data.length);
		int lastIndice = to!int(indices.data.length);
		int lastColor = to!int(color.data.length);

		if (updateBuffers) {
			updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			updateColorBufferPartial(firstColor, lastColor-firstColor);
		}
		
		return VertexGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, this);
		
	}
	VertexGroup addCube(double squareX, double squareY, double squareZ, double size) {
		if (vertices.capacity() == 0) {
			vertices.reserve(vertices.data.length*2 + 12);
		}
		if (indices.capacity() == 0) {
			indices.reserve(indices.data.length*2 + 6);
		}
		if (color.capacity() == 0) {
			color.reserve(color.data.length*2 + 16);
		}
		int firstVertex = to!int(vertices.data.length);
		int firstIndice = to!int(indices.data.length);
		int firstColor = to!int( color.data.length);
		
		int n = to!int(vertices.data.length/3);
		float s = size/2.0;
		vertices.put( 		[ -s+squareX, -s+squareY, s+squareZ,  		s+squareX, -s+squareY, s+squareZ,  		s+squareX, s+squareY, s+squareZ,  		-s+squareX, s+squareY, s+squareZ,  		-s+squareX, -s+squareY, -s+squareZ,  		s+squareX, -s+squareY, -s+squareZ,  		s+squareX, s+squareY, -s+squareZ,  		-s+squareX, s+squareY, -s+squareZ ] ); 

		//Add the lines to connect vertices
		indices.put( [n,n+ 1,n+ 2,n+ 2,n+ 3,n+ 0,n+ 
				3,n+ 2,n+ 6,n+ 6,n+ 7,n+ 3,n+ 
				7,n+ 6,n+ 5,n+ 5,n+ 4,n+ 7,n+ 
				4,n+ 0,n+ 3,n+ 3,n+ 7,n+ 4,n+ 
				0,n+ 1,n+ 5,n+ 5,n+ 4,n+ 0,n+
				1,n+ 5,n+ 6,n+ 6,n+ 2,n+ 1 ] );
		
		//For each vertex we need a color R, G, B, 7
		color.put( [colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA,
				colorR, colorG, colorB, colorA] );
		
		int lastVertex = to!int(vertices.data.length);
		int lastIndice = to!int(indices.data.length);
		int lastColor = to!int(color.data.length);
		
		if (updateBuffers) {
			updateIndiceBufferPartial(firstIndice, lastIndice-firstIndice);
			updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
			updateColorBufferPartial(firstColor, lastColor-firstColor);
		}
		
		return VertexGroup(firstVertex, lastVertex, firstColor, lastColor, firstIndice, lastIndice, this);
		
	}

	void render(Camera camera) {
		program.use();
		
		//Set the camera location uniform
		glUniformMatrix4fv(cameraUniformLocation, 1, GL_FALSE, camera.pvMat4.mat.ptr);

		// Wireframe Checking
		if (wireframe) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
		scope(exit) glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

		//Draw the indices
		//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer);
		glBindVertexArray(vaoID); // Bind our Vertex Array Object  
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer);
		//glDrawArrays(DrawMode.Triangles, 0, to!int(indices.data.length));
		//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		//glBindVertexArray(0); // Unbind our Vertex Array Object  
		glDrawElements(DrawMode.Triangles, to!int(indices.data.length), GL_UNSIGNED_INT, cast(void*)(0) );
		//glDrawElements(DrawMode.Triangles, to!int(indices.data.length), GL_UNSIGNED_INT, indices.data.ptr );
		//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		//glBindVertexArray(0); // Unbind our Vertex Array Object
	}
}
static Shader vs;
static Shader fs;
static ShaderProgram program = null;
static void initializeShader() {
	vs = new Shader(ShaderType.Vertex, vertexShaderSource);
	fs = new Shader(ShaderType.Fragment, fragmentShaderSource);
	program = new ShaderProgram(vs, fs);
}
static immutable vertexShaderSource = q{
	#version 150
	in vec3 position;
	in vec4 color;
	uniform mat4 pvmMatrix;
	out vec4 vColor;
	
	void main() {
		vColor = color;
		gl_Position = pvmMatrix * vec4(position, 1.0);
	}
};

static immutable fragmentShaderSource = q{
	#version 150
	in vec4 vColor;
	out vec4 FragColor;
	
	void main() {
		FragColor = vColor;
	}
};
struct VertexGroup {
	int firstVertex, lastVertex;
	int firstColor, lastColor;
	int firstIndice, lastIndice;
	UltraMesh ultraMesh;
	float centerX = 0;
	float centerY = 0;
	float centerZ = 0;
	static VertexGroup opCall(int fV, int lV, int fC, int lC, int fI, int lI, UltraMesh uM)
	{
		VertexGroup vg = VertexGroup.init;
		vg.firstVertex = fV;
		vg.lastVertex = lV;
		vg.firstColor = fC;
		vg.lastColor = lC;
		vg.firstIndice = fI;
		vg.lastIndice = lI;
		vg.ultraMesh = uM;
		vg.calculateCenter();
		return vg;
	}
	void calculateCenter() {
		int vCount = (lastVertex - firstVertex)/3;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			//writeln("X: ", ultraMesh.vertices.data[i], ", Y: ", ultraMesh.vertices.data[i+1]);
			centerX += ultraMesh.vertices.data[i]/vCount;
			centerY += ultraMesh.vertices.data[i+1]/vCount;
			centerZ += ultraMesh.vertices.data[i+2]/vCount;
		}
	}
	void rotateX(float angle) {
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float z = ultraMesh.vertices.data[i+2] - centerZ;
			float y = ultraMesh.vertices.data[i+1] - centerY;
			ultraMesh.vertices.data[i+2] = z * c - y * s + centerZ;
			ultraMesh.vertices.data[i+1] = y * c + z * s + centerY;
		}
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void rotateY(float angle) {
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float x = ultraMesh.vertices.data[i] - centerX;
			float z = ultraMesh.vertices.data[i+2] - centerZ;
			ultraMesh.vertices.data[i] = x * c - z * s + centerX;
			ultraMesh.vertices.data[i+2] = z * c + x * s + centerZ;
		}
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void rotateZ(float angle) {
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float x = ultraMesh.vertices.data[i] - centerX;
			float y = ultraMesh.vertices.data[i+1] - centerY;
			ultraMesh.vertices.data[i] = x * c - y * s + centerX;
			ultraMesh.vertices.data[i+1] = y * c + x * s + centerY;
		}
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void translateX(float value) {
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			ultraMesh.vertices.data[i] += value;
		}
		centerX += value;
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void translateY(float value) {
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			ultraMesh.vertices.data[i+1] += value;
		}
		centerY += value;
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void translateZ(float value) {
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			ultraMesh.vertices.data[i+2] += value;
		}
		centerZ += value;
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void setPosition(float xPos, float yPos, float zPos) {
		float moveX = xPos-centerX;
		float moveY = yPos-centerY;
		float moveZ = zPos-centerZ;
		centerX = xPos;
		centerY = yPos;
		centerZ = zPos;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			ultraMesh.vertices.data[i] += moveX;
			ultraMesh.vertices.data[i+1] += moveY;
			ultraMesh.vertices.data[i+2] += moveZ;
		}
		if (ultraMesh.updateBuffers) ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
	void setColor(float r, float g, float b, float a) {
		ubyte rByte = to!ubyte(to!int(r*255));
		ubyte gByte = to!ubyte(to!int(g*255));
		ubyte bByte = to!ubyte(to!int(b*255));
		ubyte aByte = to!ubyte(to!int(a*255));
		for (int i = firstColor; i < lastColor; i += 4) {
			ultraMesh.color.data[i] = rByte;
			ultraMesh.color.data[i+1] = gByte;
			ultraMesh.color.data[i+2] = bByte;
			ultraMesh.color.data[i+3] = aByte;
		}
		if (ultraMesh.updateBuffers) ultraMesh.updateColorBufferPartial(firstColor, lastColor-firstColor);
	}
}