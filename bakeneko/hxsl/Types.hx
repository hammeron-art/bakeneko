package bakeneko.hxsl;

#if false

typedef Vec = h3d.Vector;
typedef IVec = Array<Int>;
typedef BVec = Array<Bool>;
typedef Matrix = h3d.Matrix;
typedef Texture = h3d.mat.Texture;
typedef Sampler2D = h3d.mat.Texture;
typedef SamplerCube = h3d.mat.Texture;

#else

typedef Vec = bakeneko.math.Vector4;
typedef IVec = Array<Int>;
typedef BVec = Array<Bool>;
typedef Matrix = bakeneko.math.Matrix4x4;
typedef Texture = bakeneko.asset.Texture;
typedef Sampler2D = bakeneko.asset.Texture;
typedef SamplerCube = bakeneko.asset.Texture;

#end