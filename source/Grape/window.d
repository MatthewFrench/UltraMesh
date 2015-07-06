module grape.window;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;

import std.exception : enforce;
import std.stdio;

shared int WINDOW_WIDTH;
shared int WINDOW_HEIGHT;

enum WindowFlags {
  FullScreen = SDL_WINDOW_FULLSCREEN,
  FullScreenDesktop = SDL_WINDOW_FULLSCREEN_DESKTOP,
  OpenGL = SDL_WINDOW_OPENGL,
  Shown = SDL_WINDOW_SHOWN,
  Hidden = SDL_WINDOW_HIDDEN,
  Borderless = SDL_WINDOW_BORDERLESS,
  Resizable = SDL_WINDOW_RESIZABLE,
  Minimized = SDL_WINDOW_MINIMIZED,
  Maximized = SDL_WINDOW_MAXIMIZED,
  Grabbed = SDL_WINDOW_INPUT_GRABBED,
  InputFocus = SDL_WINDOW_INPUT_FOCUS,
  MouseFocus = SDL_WINDOW_MOUSE_FOCUS,
  Foreign = SDL_WINDOW_FOREIGN
}

// TODO Windowと合体させるか。マルチウィンドウに対応する。
private final class WindowUnit {
  public:
    this(in string name, in int x, in int y, in int w, in int h, in WindowFlags flag) {
      _flag = flag;

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE); // it looks like we always get a core context anyway.
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
		
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 32);
		
		SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
		SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16);
		
		SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1); 

	
      _window = SDL_CreateWindow(cast(char*)name, x, y, w, h, flag);
      if (_flag == WindowFlags.OpenGL) {
        _context = SDL_GL_CreateContext(_window);
        load_opengl();
      }
      enforce(_window, "create_window() faild");
    }

    ~this() {
      debug(tor) writeln("WindowsUnit dtor");
      if (_flag == WindowFlags.OpenGL)
        SDL_GL_DeleteContext(_context); 
      SDL_DestroyWindow(_window);
    }

    void swap() {
      SDL_GL_SwapWindow(_window);
    }

    // TODO 関数追加

  private:
    void load_opengl() {
		//SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
		//SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

      DerelictGL.load();
      DerelictGL.reload(); // You must create OpenGL Context before calling this function
      DerelictGL3.load();
		//immutable GLVersion glver = 
			DerelictGL3.reload(); // You must create OpenGL Context before calling this function
		//const char* glverstr = glGetString(GL_VERSION);
		//writeln("Derelict loaded GL version: ",DerelictGL3.loadedVersion," (",glver,"), available GL version: ", glverstr);

		//glEnable(GL_ALPHA_TEST);
		//glEnable(GL_BLEND);
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glEnable(GL_DEPTH_TEST);
		glEnable(GL_MULTISAMPLE);

		//Set blending
		glEnable( GL_BLEND );
		//glDisable( GL_DEPTH_TEST );
		glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
		
		//Set antialiasing/multisampling
		glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
		glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST );
		glEnable( GL_LINE_SMOOTH );
		glEnable( GL_POLYGON_SMOOTH );
		glEnable( GL_MULTISAMPLE );

		glDepthFunc(GL_LESS); 

	      //glEnable(GL_POLYGON_SMOOTH);
	      //glEnable(GL_LINE_SMOOTH);
	      //glEnable(GL_POINT_SMOOTH);
	}

    SDL_Window* _window;
    SDL_GLContext _context;
    WindowFlags _flag;
}

/**
 * Windowを管理するクラス
 *
 * TODO:
 * マルチウィンドウ
 */ 
class Window {
  public:
    this(in int w, in int h) {
      this("grape", 0, 0, w, h, WindowFlags.OpenGL);
    }

    this(in string name, in int w, in int h) {
      this(name, 0, 0, w, h, WindowFlags.OpenGL);
    }

    this(in string name, in int x, in int y, in int w, in int h) {
      this(name, x, y, w, h, WindowFlags.OpenGL);
    }

    /**
     * Windowの初期化
     *
     * name: 画面のタイトル
     * x:    画面左上のx座標 
     * y:    画面左上のy座標
     * w:    画面の幅
     * h:    画面の高さ
     */
    this(in string name, in int x, in int y, in int w, in int h, in WindowFlags flag) {
      if (!_initialized) {
        _initialized = true;
        DerelictSDL2.load();

        if (SDL_InitSubSystem(SDL_INIT_VIDEO) != 0)
          throw new Exception("SDL_InitSubSystem(SDL_INIT_VIDEO) failed");
      }

      WINDOW_WIDTH = w;
      WINDOW_HEIGHT = h;

      _window = new WindowUnit(name, x, y, w, h, flag);
      _instance ~= this;

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    ~this() {
      debug(tor) writeln("Windows dtor");
      destroy(_window);
    }

    static ~this() {
      debug(tor) writeln("Windows static dtor");
      if (_initialized) {
        foreach (v; _instance) destroy(v);
        SDL_QuitSubSystem(SDL_INIT_VIDEO);
      }
    }
    
    /**
     * 画面の更新
     */
    void update() {
      _window.swap();
      // other
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    /**
     * Alphaチャンネルの有効化
     * 
     * TODO:
     * 他に移すかも
     */
    void enable_alpha() { //TODO
      glEnable(GL_ALPHA_TEST);
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

      /*
      glEnable(GL_DEPTH_TEST);

      glEnable(GL_POLYGON_SMOOTH);
      glEnable(GL_LINE_SMOOTH);
      glEnable(GL_POINT_SMOOTH);
      */
    }

  private:
    static Window[] _instance;
    WindowUnit _window;
    static bool _initialized = false;
}

