module src.ShapeGroup;
import src.UltraMesh;
import std.math;
import std.conv;
import std.stdio;

struct ShapeGroup
{
	int firstVertex, lastVertex;
	int firstColor, lastColor;
	int firstIndice, lastIndice;
	UltraMesh ultraMesh;

	float centerX = 0,centerY = 0,centerZ = 0;
	float originX = 0,originY = 0,originZ = 0;
	float shapeScaleX = 1.0,shapeScaleY = 1.0,shapeScaleZ = 1.0;
	float rotationX = 0,rotationY = 0,rotationZ = 0;
	static ShapeGroup opCall(int fV, int lV, int fC, int lC, int fI, int lI, UltraMesh uM)
	{
		ShapeGroup vg = ShapeGroup.init;
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
	int getVertexCount() {
		return (lastVertex - firstVertex)/3;
	}
	int getIndiceCount() {
		return (lastIndice - firstIndice)/3;
	}
	int getColorCount() {
		return (lastColor - firstColor)/4;
	}
	float[] getVertexData() {
		float[] vertexData = ultraMesh.getVertexData();
		return vertexData[firstVertex..lastVertex];
	}
	ubyte[] getColorData() {
		ubyte[] colorData = ultraMesh.getColorData();
		return colorData[firstColor..lastColor];
	}
	int[] getIndiceData() {
		int[] indiceData = ultraMesh.getIndiceData();
		return indiceData[firstIndice..lastIndice];
	}
	Point getVertex(int vertexNum) {
		float[] vertexData = ultraMesh.getVertexData();
		return Point(vertexData[firstVertex+vertexNum*3],vertexData[firstVertex+vertexNum*3+1],vertexData[firstVertex+vertexNum*3+2]);
	}
	void setVertex(int vertexNum, Point vertex) {
		float[] vertexData = ultraMesh.getVertexData();
		vertexData[firstVertex+vertexNum*3] = vertex.x;
		vertexData[firstVertex+vertexNum*3+1] = vertex.y;
		vertexData[firstVertex+vertexNum*3+2] = vertex.z;
		ultraMesh.updateVertexBufferPartial(vertexNum, 1*3);
	}
	Color getColor(int num) {
		ubyte[] color = ultraMesh.getColorData();
		return Color(color[firstColor+num*4],color[firstColor+num*4+1],color[firstColor+num*4+2],color[firstColor+num*4+3]);
	}
	void setColor(int num, Color color) {
		ubyte[] colorData = ultraMesh.getColorData();
		colorData[firstColor+num*4] = color.r;
		colorData[firstColor+num*4+1] = color.g;
		colorData[firstColor+num*4+2] = color.b;
		colorData[firstColor+num*4+3] = color.a;
		ultraMesh.updateColorBufferPartial(num, 1*4);
	}
	Indice getIndice(int num) {
		int[] indiceData = ultraMesh.getIndiceData();
		return Indice(indiceData[firstIndice+num*3],indiceData[firstIndice+num*3+1],indiceData[firstIndice+num*3+2]);
	}
	void setIndice(int num, Indice indice) {
		int[] indiceData = ultraMesh.getIndiceData();
		indiceData[firstIndice+num*3] = indice.v1;
		indiceData[firstIndice+num*3+1] = indice.v2;
		indiceData[firstIndice+num*3+2] = indice.v3;
		ultraMesh.updateIndiceBufferPartial(num, 1*3);
	}
	void calculateCenter() {
		float[] vertexData = ultraMesh.getVertexData();
		int vCount = (lastVertex - firstVertex)/3;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			//writeln("X: ", vertexData[i], ", Y: ", vertexData[i+1]);
			centerX += vertexData[i]/vCount;
			centerY += vertexData[i+1]/vCount;
			centerZ += vertexData[i+2]/vCount;
		}
		originX = centerX;
		originY = centerY;
		originZ = centerZ;
	}
	void scaleX(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] = (vertexData[i]-centerX)*scale + centerX;
		}
		shapeScaleX *= scale;
		updateAllVertices();
	}
	void setScaleX(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		float amount = scale / shapeScaleX;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] = (vertexData[i]-centerX)*amount + centerX;
		}
		shapeScaleX = scale;
		updateAllVertices();
	}
	void scaleY(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+1] = (vertexData[i+1]-centerY)*scale + centerY;
		}
		shapeScaleY *= scale;
		updateAllVertices();
	}
	void setScaleY(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		float amount = scale / shapeScaleY;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+1] = (vertexData[i+1]-centerY)*amount + centerY;
		}
		shapeScaleY = scale;
		updateAllVertices();
	}
	void scaleZ(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+2] = (vertexData[i+2]-centerZ)*scale + centerZ;
		}
		shapeScaleZ *= scale;
		updateAllVertices();
	}
	void setScaleZ(float scale) {
		float[] vertexData = ultraMesh.getVertexData();
		float amount = scale / shapeScaleZ;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+2] = (vertexData[i+2]-centerZ)*amount + centerZ;
		}
		shapeScaleZ = scale;
		updateAllVertices();
	}
	void scale(float xScale, float yScale, float zScale) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] = (vertexData[i]-centerX)*xScale + centerX;
			vertexData[i+1] = (vertexData[i+1]-centerY)*yScale + centerY;
			vertexData[i+2] = (vertexData[i+2]-centerZ)*zScale + centerZ;
		}
		shapeScaleX *= xScale;
		shapeScaleY *= yScale;
		shapeScaleZ *= zScale;
		updateAllVertices();
	}
	void setScale(float xScale, float yScale, float zScale) {
		float[] vertexData = ultraMesh.getVertexData();
		float amountX = xScale / shapeScaleX;
		float amountY = yScale / shapeScaleY;
		float amountZ = zScale / shapeScaleZ;

		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] = (vertexData[i]-centerX)*amountX + centerX;
			vertexData[i+1] = (vertexData[i+1]-centerY)*amountY + centerY;
			vertexData[i+2] = (vertexData[i+2]-centerZ)*amountZ + centerZ;
		}
		shapeScaleX = xScale;
		shapeScaleY = yScale;
		shapeScaleZ = zScale;
		updateAllVertices();
	}
	void rotateX(float angle) {
		rotationX += angle;
		rotateXByAngle(angle);
		updateAllVertices();
	}
	void setRotationX(float angle) {
		rotateXByAngle(angle - rotationX);
		rotationX = angle;
		updateAllVertices();
	}
	void rotateY(float angle) {
		rotationY += angle;
		rotateYByAngle(angle);
		updateAllVertices();
	}
	void setRotationY(float angle) {
		rotateYByAngle(angle - rotationY);
		rotationY = angle;
		updateAllVertices();
	}
	void rotateZ(float angle) {
		rotationZ += angle;
		rotateZByAngle(angle);
		updateAllVertices();
	}
	void setRotationZ(float angle) {
		rotateZByAngle(angle - rotationZ);
		rotationZ = angle;
		updateAllVertices();
	}
	void rotate(float angleX, float angleY, float angleZ) {
		rotationX += angleX;
		rotateXByAngle(angleX);
		rotationY += angleY;
		rotateYByAngle(angleY);
		rotationZ += angleZ;
		rotateYByAngle(angleZ);
		updateAllVertices();
	}
	void setRotation(float angleX, float angleY, float angleZ) {
		rotateXByAngle(angleX-rotationX);
		rotateYByAngle(angleY-rotationY);
		rotateZByAngle(angleZ-rotationZ);
		rotationX = angleX;
		rotationY = angleY;
		rotationZ = angleZ;
		updateAllVertices();
	}
	void moveX(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] += value;
		}
		centerX += value;
		updateAllVertices();
	}
	void setPositionX(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		float loc = value-centerX;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] += loc;
		}
		centerX = value;
		updateAllVertices();
	}
	void moveY(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+1] += value;
		}
		centerY += value;
		updateAllVertices();
	}
	void setPositionY(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		float loc = value-centerY;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+1] += loc;
		}
		centerY = value;
		updateAllVertices();
	}
	void moveZ(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+2] += value;
		}
		centerZ += value;
		updateAllVertices();
	}
	void setPositionZ(float value) {
		float[] vertexData = ultraMesh.getVertexData();
		float loc = value-centerZ;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i+2] += loc;
		}
		centerZ = value;
		updateAllVertices();
	}
	void move(float valueX, float valueY, float valueZ) {
		float[] vertexData = ultraMesh.getVertexData();
		centerX += valueX;
		centerY += valueY;
		centerZ += valueZ;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] += valueX;
			vertexData[i+1] += valueY;
			vertexData[i+2] += valueZ;
		}
		updateAllVertices();
	}
	void setPosition(float xPos, float yPos, float zPos) {
		float[] vertexData = ultraMesh.getVertexData();
		float moveX = xPos-centerX;
		float moveY = yPos-centerY;
		float moveZ = zPos-centerZ;
		centerX = xPos;
		centerY = yPos;
		centerZ = zPos;
		for (int i = firstVertex; i < lastVertex; i+= 3) {
			vertexData[i] += moveX;
			vertexData[i+1] += moveY;
			vertexData[i+2] += moveZ;
		}
		updateAllVertices();
	}
	void setAllColor(float r, float g, float b, float a) {
		ubyte[] colorData = ultraMesh.getColorData();
		ubyte rByte = to!ubyte(to!int(r*255));
		ubyte gByte = to!ubyte(to!int(g*255));
		ubyte bByte = to!ubyte(to!int(b*255));
		ubyte aByte = to!ubyte(to!int(a*255));
		for (int i = firstColor; i < lastColor; i += 4) {
			colorData[i] = rByte;
			colorData[i+1] = gByte;
			colorData[i+2] = bByte;
			colorData[i+3] = aByte;
		}
		ultraMesh.updateColorBufferPartial(firstColor, lastColor-firstColor);
	}

	private void rotateXByAngle(float angle) {
		float[] vertexData = ultraMesh.getVertexData();
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float z = vertexData[i+2] - centerZ;
			float y = vertexData[i+1] - centerY;
			vertexData[i+2] = z * c - y * s + centerZ;
			vertexData[i+1] = y * c + z * s + centerY;
		}
	}
	private void rotateYByAngle(float angle) {
		float[] vertexData = ultraMesh.getVertexData();
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float x = vertexData[i] - centerX;
			float z = vertexData[i+2] - centerZ;
			vertexData[i] = x * c - z * s + centerX;
			vertexData[i+2] = z * c + x * s + centerZ;
		}
	}
	private void rotateZByAngle(float angle) {
		float[] vertexData = ultraMesh.getVertexData();
		float s = sin(angle);
		float c = cos(angle);
		for (int i = firstVertex; i < lastVertex; i+=3) {
			float x = vertexData[i] - centerX;
			float y = vertexData[i+1] - centerY;
			vertexData[i] = x * c - y * s + centerX;
			vertexData[i+1] = y * c + x * s + centerY;
		}
	}
	private void updateAllVertices() {
		ultraMesh.updateVertexBufferPartial(firstVertex, lastVertex-firstVertex);
	}
}