module grape.camera;

import derelict.opengl3.gl3;
import std.math;
import std.stdio;
import grape.math;
import grape.window : WINDOW_WIDTH, WINDOW_HEIGHT;
import gl3n.linalg;





//I need to move and rotate the camera relative to the direction it is facing.




class CameraOld {
  public :
    /**
     * 位置、姿勢の設定
     *
     * GLUTのgluLookAtと同じです。
     * eye:    視点
     * center: 注視点
     * up:     上方向
     */
	void moveForward(float speed)
	{
		Vec3 vVector = mView - mPos;

		mPos = Vec3(mPos.x + vVector.x * speed, mPos.y + vVector.y * speed,mPos.z + vVector.z * speed);
		mView = Vec3(mView.x + vVector.x * speed, mView.y + vVector.y * speed, mView.z + vVector.z * speed);

		look_at(mPos, mView, mUp);
	}
	void moveSide(float speed) {
		Vec3 vVector = mView-mPos;
		
		mPos = Vec3(mPos.x + vVector.x * speed, mPos.y - vVector.y * speed,mPos.z);
		mView = Vec3(mView.x + vVector.x * speed, mView.y - vVector.y * speed, mView.z);
		
		look_at(mPos, mView, mUp);
	}

	void rotateX(float speed)
	{
		Vec3 vVector = mView - mPos;    // Get the view vector
		
		float s = sin(speed);
		float c = cos(speed);

		float y = vVector.y;
		float z = vVector.z;
		
		mView = Vec3(mView.x,
			y * c - z * s +  mPos.y,
			z * c + y * s + mPos.z);
		
		look_at(mPos, mView, mUp);
	}
	
	void rotateZ(float speed)
	{
		Vec3 vVector = mView - mPos;    // Get the view vector

		float s = sin(speed);
		float c = cos(speed);

		float x = vVector.x;
		float y = vVector.y;

		mView = Vec3(x * c + y * s + mPos.x,
			y * c - x * s +  mPos.y,
			mView.z);
			
		look_at(mPos, mView, mUp);
	}
	
	
	void moveCameraHorizontal(float speed)    // MOVE LEFT AND RIGHT
	{
		Vec3 vVector = mView - mPos;    // Get the view vector
		
		Vec3 vOrthoVector; // Orthogonal vector for the view vector

		vOrthoVector = Vec3(-vVector.z, 0, vVector.x);

		mPos = Vec3(mPos.x + vOrthoVector.x * speed,
			0,
			mPos.z + vOrthoVector.z * speed);
		mView = Vec3(mView.x + vOrthoVector.x * speed,
			0,
			mView.z + vOrthoVector.z * speed);
			
		look_at(mPos, mView, mUp);
	}
    void look_at(Vec3 eye, Vec3 center, Vec3 up) {
		mPos = eye;
		mView = center;
		mUp = up;
      Vec3 f = Vec3(center.x-eye.x, center.y-eye.y, center.z-eye.z);

      f.normalize;
      up.normalize;

		Vec3 s = cross(f,up);
		Vec3 u = cross(s,f);

      _view = Mat4( s.x, u.x, -f.x, 0,
                    s.y, u.y, -f.y, 0,
                    s.z, u.z, -f.z, 0,
                    0, 0, 0, 1 ).translate(-eye.x, -eye.y, -eye.z);
    }

    @property {
      /**
       * view, projection行列を掛け合わせたMat4型を返す
       *
       * 基本的にこれをuniformのpvmMatrixに送ります。
       */
      Mat4 pvMat4() {
        return _proj*_view;
      }
    }

  protected:
    Mat4 _proj, _view;
	Vec3 mPos, mView, mUp;
}

class PerspectiveCamera : CameraOld {
  public:
	this(in float fovy, in float width, in float height, in float near, in float far) {
      perspective(fovy, width, height, near, far);
    }

    /**
     * 視界の設定
     *
     * GLUTのgluPerspectiveと同じです。
     * fovy:    視野角
     * aspect:  縦横比(通常は[画面幅/高さ]です）
     * near:   一番近いz座標
     * far:    一番遠いz座標
     */
    void perspective(in float fovy, in float width, in float height, in float near, in float far) {
      // translate to grape.math

		_proj=mat4.perspective(width, height, fovy, near, far);
		/*
      auto cot = delegate float(float x){ return 1 / tan(x); };
      auto f = cot(fovy/2);

      _proj.set( f/aspect, 0, 0, 0,
                 0, f, 0, 0,
                 0, 0, (far+near)/(near-far), -1,
                 0, 0, (2*far*near)/(near-far), 0 );(*/
    }
}

class OrthographicCamera : CameraOld {
  this(in float left, in float right, in float top, in float bottom, in float near, in float far) {
    orthographic(left, right, top, bottom, near, far);
  }

  void orthographic(in float left, in float right, in float top, in float bottom, in float near, in float far) {
		_proj = mat4.orthographic(left, right, bottom, top, near, far);
		/*
    auto a = 2 / (right - left);
    auto b = 2 / (top - bottom);
    auto c = -2 / (far - near);
    auto tx = -(right + left) / (right - left);
    auto ty = -(top + bottom) / (top - bottom);
    auto tz = -(far + near) / (far - near);


    _proj.set( a, 0, 0, 0,
               0, b, 0, 0,
               0, 0, c, 0,
               tx, ty, tz, 1 );*/
  }

}

/*
class Camera {
  public :
    this() {
      Vec3 eye = Vec3(0, 0, 1);
      Vec3 center = Vec3(0, 0, 0);
      Vec3 up = Vec3(0, 1, 0);

      perspective(45.0, cast(float)WINDOW_WIDTH/WINDOW_HEIGHT, 0.1, 100);
      look_at(eye, center, up);
    }

    this(in float near, in float far) {
      Vec3 eye = Vec3(0, 0, 1);
      Vec3 center = Vec3(0, 0, 0);
      Vec3 up = Vec3(0, 1, 0);

      perspective(45.0, cast(float)WINDOW_WIDTH/WINDOW_HEIGHT, near, far); //TODO
      look_at(eye, center, up);
    }


  private:
    void set(Vec3 eye, Vec3 center, Vec3 up) {
      //_manip = Manip(eye); // TODO 毎回作ってる
      _center = center;
      //_manip.add(up); // TODO Manipを毎回作ってないと危険
    }

    Mat4 _proj, _view;
    Vec3 _center;
}
*/

