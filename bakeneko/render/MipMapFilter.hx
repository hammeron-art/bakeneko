package bakeneko.render;

enum MipMapFilter {
	NoMipFilter;
	PointMipFilter;
	LinearMipFilter; //linear texture filter + linear mip filter -> trilinear filter
}
