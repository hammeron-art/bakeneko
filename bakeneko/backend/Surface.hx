package bakeneko.backend;

import bakeneko.asset.Texture;
import bakeneko.backend.RenderDriver;
import bakeneko.backend.opengl.GL;
import bakeneko.core.Application;
import bakeneko.utils.Utils;
import bakeneko.render.pass.Types;

/**
 * Handles custom framebuffers.
 * Texture edition and drawing
 */
@:access(bakeneko.backend.RenderDriver)
class Surface {

	public var framebuffer:Framebuffer;
	// depth and stencil attachment for the framebuffer
	var renderBuffer:Renderbuffer;
	// color attachment for the framebuffer
	public var colorTexture:Texture;

	static public var currentlyBound(default, null):Surface = null;

	public var width(default, null):Int;
	public var height(default, null):Int;

	public var driver:RenderDriver;

	public function new(width:Int, height:Int) {
		driver = Application.get().renderSystem.driver;

		this.width = width;
		this.height = height;

		framebuffer = driver.createFramebuffer();
		renderBuffer = driver.createRenderbuffer();

		/**
		 * TODO: Investigate the follow error for web target when wrap mode is linear:
		 * WebGL: A texture is going to be rendered as if it were black, as per the OpenGL ES 2.0.24 spec section 3.8.2,
		 * because it is a 2D texture, with a minification filter not requiring a mipmap, with its width or height not a power of two,
		 * and with a wrap mode different from CLAMP_TO_EDGE.
		 */
		colorTexture = new Texture( {
			id: Utils.uniqueID(),
			props: {
				wrapS: Wrap.Clamp,
				wrapT: Wrap.Clamp,
				minFilter: Filter.Linear,
				magFilter: Filter.Linear,
			}
		});
		colorTexture.build(null, width, height);
		
		setupFramebuffer();
	}

	function setupFramebuffer() {
		bind();

		colorTexture.bind();
		driver.framebufferTexture2D(Target.Framebuffer, Attachment.Color0, GL.TEXTURE_2D, colorTexture.textureID, 0);

		driver.bindRenderbuffer(Target.Renderbuffer, renderBuffer);
		driver.renderbufferStorage(Target.Renderbuffer, GL.DEPTH_COMPONENT16, width, height);
		driver.bindRenderbuffer(Target.Renderbuffer, null);
		driver.framebufferRenderbuffer(Target.Framebuffer, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderBuffer);
		
		checkStatus();
	}

	function checkStatus() {
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);

        switch (status) {
            case GL.FRAMEBUFFER_COMPLETE:

            case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
                throw("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_ATTACHMENT");

            case GL.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
                throw("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");

            case GL.FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
                throw("Incomplete framebuffer: FRAMEBUFFER_INCOMPLETE_DIMENSIONS");

            case GL.FRAMEBUFFER_UNSUPPORTED:
                throw("Incomplete framebuffer: FRAMEBUFFER_UNSUPPORTED");

            default:
                throw("Incomplete framebuffer: " + status);
        }
	}

	public function bind() {
		if (currentlyBound != this)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
			GL.viewport(0, 0, width, height);
			currentlyBound = this;
		}
	}
	
	static public function bindDefault() {
		if (currentlyBound != null)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);

			GL.viewport(0, 0, Application.core.window.width, Application.core.window.height);
			currentlyBound = null;
		}
	}

	public function clear() {
		colorTexture.clear();

		if (renderBuffer != null) {
			GL.deleteRenderbuffer(renderBuffer);
			renderBuffer = null;
		}
		if (framebuffer != null) {
			GL.deleteFramebuffer(framebuffer);
			framebuffer = null;
		}

		if (currentlyBound == this) {
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
			currentlyBound = null;
		}
	}
	
}