module src.Camera;
import grape.math;
import grape.math;
import gl3n.linalg;
import gl3n.math;
import std.stdio;

class Camera {
	vec3 _position = vec3(0.0f, 0.0f, 0.0f);
	vec3 forward = vec3(0.0f, 1.0f, 0.0f);
	float fov = 65.0f;
	float near = 1.0f;
	float far = 400.0f;
	vec3 up = vec3(0.0f, 0.0f, 1.0f);
	float width = 100;
	float height = 100;
	
	@property vec3 position() { return _position; }
	@property void position(vec3 position) { _position = position; }
	
	this() {}
	
	this(vec3 position) {
		_position = position;
	}
	
	this(vec3 position, float width, float height, float fov, float near, float far) {
		this._position = position;
		this.fov = fov;
		this.near = near;
		this.far = far;
		this.width = width;
		this.height = height;
	}
	
	void look_at(vec3 position) {
		forward = (position - _position).normalized;
	}
	
	void rotatex(float angle) { // degrees
		mat4 rotmat = mat4.rotation(radians(-angle), up);
		forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
	}

	void rotatey(float angle) { // degrees
		//float oldZ = forward.z;
		vec3 vcross = cross(up, forward);
		mat4 rotmat = mat4.rotation(radians(-angle), vcross);
		forward = vec3(rotmat * vec4(forward, 2.0f)).normalized;
		//This code makes it so we can forever spin on the y
		if (abs(forward.z) >= 0.999836) {
			up.z *= -1;
			forward.x *= -1;
			forward.y *= -1;
		}
	}
	
	quat get_rotation(vec3 comparison) {
		vec3 axis = cross(forward, comparison).normalized;
		float angle = to!float(asin(dot(forward, comparison)));
		return quat(angle, axis);
	}
	//Yaw is down and left
	//Pitch is left and right
	//Roll did nothing
	void set_rotation(vec3 forward, float yaw, float pitch, float roll) {
		quat rotation = quat.euler_rotation(yaw, pitch, 0);
		forward = vec3(rotation.to_matrix!(3, 3) * forward).normalized;
		look_at(position + forward);
	}
	
	void move_forward(float delta) { // W
		_position = _position + forward*delta;
	}
	
	void move_backward(float delta) { // S
		_position = _position - forward*delta;
	}

	void move_down(float delta) { // z
		_position = _position - up*delta;
	}

	void move_up(float delta) { // x
		_position = _position + up*delta;
	}
	
	void strafe_left(float delta) { // A
		vec3 vcross = cross(up, forward).normalized;
		_position = _position + (vcross*delta);
	}
	
	void strafe_right(float delta) { // D
		vec3 vcross = cross(up, forward).normalized;
		_position = _position - (vcross*delta);
	}
	
	@property mat4 camera() {
		vec3 target = _position + forward;
		return mat4.look_at(_position, target, up);
	}
	Mat4 perspectiveView() {
		Mat4 proj = mat4.perspective(width, height, fov, near, far);
		Mat4 view = camera();
		return proj*view;
	}
}