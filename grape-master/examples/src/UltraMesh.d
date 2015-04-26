﻿module src.UltraMesh;
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

		glBindVertexArray(0); // Disable our Vertex Array Object  
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

	void render(Camera camera) {
		program.use();
		
		//Set the camera location uniform
		glUniformMatrix4fv(cameraUniformLocation, 1, GL_FALSE, camera.pvMat4.mat.ptr);

		// Wireframe Checking
		if (wireframe) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
		scope(exit) glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

		//Draw the indices
		glBindVertexArray(vaoID); // Bind our Vertex Array Object  
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indiceBuffer);
		glDrawElements(DrawMode.Triangles, to!int(indices.data.length), GL_UNSIGNED_INT, cast(void*)(0) );
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