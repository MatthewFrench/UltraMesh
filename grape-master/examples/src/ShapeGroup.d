module src.ShapeGroup;
import src.UltraMesh;

struct ShapeGroup
{
	int firstVertex, lastVertex;
	int firstColor, lastColor;
	int firstIndice, lastIndice;
	UltraMesh ultraMesh;
	float centerX = 0;
	float centerY = 0;
	float centerZ = 0;
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