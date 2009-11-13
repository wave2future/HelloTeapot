//
//  GLViewController.h
//  HelloTeapot
//
//  Created by turner on 4/30/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import "GLViewController.h"
#import "GLView.h"
#import "BoundingBox.h"
#import "teapot.h"
#import "JLMMatrixLibrary.h"

@implementation GLViewController

@synthesize bbox = _bbox;

- (void)dealloc {
	
    [_bbox release], _bbox = nil;
    [super dealloc];
}

// The Stanford Pattern
- (void)loadView {
	
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	GLView *glView = nil;
	
	glView = [[[GLView alloc] initWithFrame:applicationFrame] autorelease];
	glView.drawingDelegate = self;
	
	self.view = glView;

}

// The Stanford Pattern
- (void)viewDidLoad {
	
	// Do stuff	
	self.bbox = [[[BoundingBox alloc] init] autorelease];	
	[self teapotBoundingBox];
	
}

// The Stanford Pattern
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// Do stuff
	GLView *glView = (GLView *)self.view;
	
	glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
	
	//	[self beginLoadingDataFromWeb];
	//	[self showLoadingProgress];
	
}

// The Stanford Pattern
- (void)viewWillDisappear:(BOOL)animated {
	
	//	[self rememberState];
	//	[self saveStateToDisk];
	
	[super viewWillDisappear:animated];
}

- (void) doTeapotBoundingBox:(BoundingBox *)b {
	
	int i;
	int x, y, z;
	float exe, wye, zee;
	
	for(i = 0, x = 0, y = 1, z = 2; i < num_teapot_vertices; i++, x += 3, y += 3, z += 3) {
		
		if (i == 0) {
			
			b.maxX = teapot_vertices[x];
			b.maxY = teapot_vertices[y];
			b.maxZ = teapot_vertices[z];
			
			b.minX = b.maxX;
			b.minY = b.maxY;
			b.minZ = b.maxZ;
			
		}
		
		exe = teapot_vertices[x];
		wye = teapot_vertices[y];
		zee = teapot_vertices[z];
		
		if (exe < b.minX) b.minX = exe;
		if (wye < b.minY) b.minY = wye;
		if (zee < b.minZ) b.minZ = zee;
		
		if (exe > b.maxX) b.maxX = exe;
		if (wye > b.maxY) b.maxY = wye;
		if (zee > b.maxZ) b.maxZ = zee;
		
	}
	
	[b calculateCentroid];
	
}

- (void) teapotBoundingBox {
	
	int i;
	int x, y, z;
	
	// Initial teapot bbox before recentering 
	[self doTeapotBoundingBox:self.bbox];
	//	NSLog(@"Teapot %@", bbox);
	
	// Center teapot
	for(i = 0, x = 0, y = 1, z = 2; i < num_teapot_vertices; i++, x += 3, y += 3, z += 3) {
		
		teapot_vertices[x] -= self.bbox.cX;
		teapot_vertices[y] -= self.bbox.cY;
		teapot_vertices[z] -= self.bbox.cZ;
		
	}
	
	// Re-calculate teapot self.bbox
	[self doTeapotBoundingBox:self.bbox];
	//	NSLog(@"Teapot Centered %@", self.bbox);
	
}

- (void)perspectiveProjectionWithFieldOfViewY:(GLfloat)fieldOfViewY 
				   aspectRatioWidthOverHeight:(GLfloat)aspectRatioWidthOverHeight 
										 near:(GLfloat)near 
										  far:(GLfloat)far {
	
	GLfloat xmin, xmax, ymin, ymax;
	
	ymax = near * tanf(fieldOfViewY * M_PI / 360.0);
	ymin = -ymax;
	xmin = ymin * aspectRatioWidthOverHeight;
	xmax = ymax * aspectRatioWidthOverHeight;
	glFrustumf(xmin, xmax, ymin, ymax, near, far);
	//	NSLog(@" glFrustumf xmin: %f xmax: %f ymin: %f ymax: %f", xmin, xmax, ymin, ymax);
}

//
//	Aiming the OpenGL camera involves a matrix inversion. 
//
//	On p. 25 of Robot Manipulators: Mathematics, Programming, and Control by Richard Paul (old reliable) there is a
// simple and computationally cheap way to do the inversion. On Google Books here: http://bit.ly/39QfMr
//
//	We must represent the camera frame in eye space, the space within which OpenGL rendering is done.
//
//	Given C - the camera transformation in world space we need C' it's inverse. We needn't do a full 
// blown matrix inverse because of the special case of this frame. It has an orthonormal upper 3x3. 
// So C' can be calculated thusly:
//
//	C =
//	nx ox ax px
//	ny oy ay py
//	nz oz az pz
//
//	C' =
//	nx ny nz -p.n
//	ox oy oz -p.o
//	ax ay az -p.a
//
- (void)placeCameraAtLocation:(M3DVector3f)location 
					   target:(M3DVector3f)target 
						   up:(M3DVector3f)up {
	
	// We use the Richard Paul matrix notation of n, o, a, and p 
	// for x, y, z axes of orientation and p as translation
	
	M3DVector3f n; // x-axis
	M3DVector3f o; // y-axis
	M3DVector3f a; // z-axis
	M3DVector3f p; // translation vector
	
	// The camera is always pointed along the -z axis. So the "a" vector = -(target - eye)
	m3dLoadVector3f(a, -(target[0] - location[0]), -(target[1] - location[1]), -(target[2] - location[2]));
	m3dNormalizeVectorf(a);
	
	// The up parameter is assumed approximate. It corresponds to the y-axis or "o" vector.
	M3DVector3f o_approximate;
	m3dCopyVector3f(o_approximate, up);
	m3dNormalizeVectorf(o_approximate);
	
	//	n = o_approximate X a
	m3dCrossProductf(n, o_approximate, a);
	m3dNormalizeVectorf(n);
	
	// Calculate the exact up vector from the cross product
	// of the other basis vectors which are indeed orthogonal:
	//
	// o = a X n
	//
	m3dCrossProductf(o, a, n);
	
	// The translation vector - location - is the eye location.
	// It is the where the camera is positioned in world space.
	// Copy it into the "p" vector
	m3dCopyVector3f(p, location);
	
	// Build camera transform matrix from column vectors: n, o, a, p
	m3dLoadIdentity44f(_cameraTransform);
	MatrixElement(_cameraTransform, 0, 0) = n[0];
	MatrixElement(_cameraTransform, 1, 0) = n[1];
	MatrixElement(_cameraTransform, 2, 0) = n[2];
	
	MatrixElement(_cameraTransform, 0, 1) = o[0];
	MatrixElement(_cameraTransform, 1, 1) = o[1];
	MatrixElement(_cameraTransform, 2, 1) = o[2];
	
	MatrixElement(_cameraTransform, 0, 2) = a[0];
	MatrixElement(_cameraTransform, 1, 2) = a[1];
	MatrixElement(_cameraTransform, 2, 2) = a[2];
	
	MatrixElement(_cameraTransform, 0, 3) = p[0];
	MatrixElement(_cameraTransform, 1, 3) = p[1];
	MatrixElement(_cameraTransform, 2, 3) = p[2];
	
	// echo the camera transformation frame
	//	nx ox ax px
	//	ny oy ay py
	//	nz oz az pz
	//	NSLog(@"Camera Transformation");
	//	NSLog(@"nx ox ax px %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 0, 0),
	//		  MatrixElement(_cameraTransform, 0, 1),
	//		  MatrixElement(_cameraTransform, 0, 2),
	//		  MatrixElement(_cameraTransform, 0, 3));
	//	
	//	NSLog(@"ny oy ay py %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 1, 0),
	//		  MatrixElement(_cameraTransform, 1, 1),
	//		  MatrixElement(_cameraTransform, 1, 2),
	//		  MatrixElement(_cameraTransform, 1, 3));
	//	
	//	NSLog(@"nz oz az pz %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 2, 0),
	//		  MatrixElement(_cameraTransform, 2, 1),
	//		  MatrixElement(_cameraTransform, 2, 2),
	//		  MatrixElement(_cameraTransform, 2, 3));
	//
	//	NSLog(@".");

	
	// Build upper 3x3 of OpenGL style "view" transformation from transpose of camera orientation
	// This is the inversion process. Since these 3x3 matrices are orthonormal a transpose is 
	// sufficient to invert
	m3dLoadIdentity44f(_openGLCameraInverseTransform);	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			MatrixElement(_openGLCameraInverseTransform, i, j) = MatrixElement(_cameraTransform, j, i);
		}
	}
	
	// Complete building OpenGL camera transform by inserting the translation vector
	// as described in Richard Paul.
	MatrixElement(_openGLCameraInverseTransform, 0, 3) = -m3dDotProductf(p, n);
	MatrixElement(_openGLCameraInverseTransform, 1, 3) = -m3dDotProductf(p, o);
	MatrixElement(_openGLCameraInverseTransform, 2, 3) = -m3dDotProductf(p, a);
	
	// Use this to inspect current transform in the debugger
//	GLfloat crapola[16];
	
	// Set the camera transformation in OpenGL
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity(); 
//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
	glLoadMatrixf(_openGLCameraInverseTransform);
//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
}

-(void)setupView:(GLView*)view {
  	
	// Let there be lighting
	glEnable(GL_LIGHTING);	
	
	// Set material properties
	const GLfloat diffuseMaterial[] = {1.0, 1.0, 1.0, 1.0};	
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, diffuseMaterial);
	
	glShadeModel(GL_FLAT);
//	glShadeModel(GL_SMOOTH);
	
	glEnable(GL_DEPTH_TEST);
	
	// Handle ingestion of teapot model
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glVertexPointer(3 ,GL_FLOAT, 0, teapot_vertices);
	glNormalPointer(GL_FLOAT, 0, teapot_normals);
	glEnable(GL_NORMALIZE);	
	

	// Viewing frustrum administrativa
	const GLfloat near	= 0.01; 
	const GLfloat far	= 1000.0; 
	const GLfloat fov	= 45.0 * 0.75; 
	
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	
	GLfloat size = near * tanf(DEGREES_TO_RADIANS(fov) / 2.0);
	
	GLfloat w = view.bounds.size.width;
	GLfloat h = view.bounds.size.height;
	
	glFrustumf(-size, size, -size / (w/h), size / (w/h), near, far); 
	glViewport(0, 0, w, h);  
	
	glClearColor(0.25, 0.25, 0.25, 1.0f);
	
	// Aim the camera
	M3DVector3f eye, target, up;
	m3dLoadVector3f(eye,	0.0, 0.0, 9.0);
	m3dLoadVector3f(target, 0.0, 0.0, 0.0);
	m3dLoadVector3f(up,		0.0, 1.0, 0.0);
	
	M3DMatrix44f rote;
	TIESetRotationY(rote, DEGREES_TO_RADIANS(45));
	
	TIEMatrix4x4MulPoint3(rote, eye);
	
	[self placeCameraAtLocation:eye	target:target up:up];
	
}

static float angle = 0.0;
- (void)drawView:(GLView*)view {
	
	//Clear framebuffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// Set camera
	M3DVector3f eye, target, up;
	
//	m3dLoadVector3f(eye,	0.0, 3.0, 3.0);
	m3dLoadVector3f(eye,	0.0, 0.0, 8.0);
	m3dLoadVector3f(target, 0.0, 0.0, 0.0);
	m3dLoadVector3f(up,		0.0, 1.0, 0.0);
	
	M3DMatrix44f rote;
	TIESetRotationY(rote, DEGREES_TO_RADIANS(angle));
//	TIESetRotationY(rote, DEGREES_TO_RADIANS(0.0));
	
	TIEMatrix4x4MulPoint3(rote, eye);
	
	[self placeCameraAtLocation:eye	target:target up:up];
	
	
	
	
	// red light is stationary in the scene
	const GLfloat redLight[]			= {  1.0f, 0.0f, 0.0f, 1.0f };
	const GLfloat redLightPosition[]	= { 10.0f, 0.0f, 0.0f, 1.0f }; 
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, redLight);	
	glLightfv(GL_LIGHT0, GL_POSITION, redLightPosition);
	
	
	
	
	// green light is stationary in the scene
	const GLfloat greenLight[]			= { 0.0f,  1.0f, 0.0f, 1.0f };
	const GLfloat greenLightPosition[]	= { 0.0f, 10.0f, 0.0f, 1.0f }; 
	glEnable(GL_LIGHT1);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, greenLight);	
	glLightfv(GL_LIGHT1, GL_POSITION, greenLightPosition);
	
	
	
	
	// blue light is stationary in the scene
	const GLfloat blueLight[]			= { 0.0f, 0.0f,  1.0f, 1.0f };
	const GLfloat blueLightPosition[]	= { 0.0f, 0.0f, 10.0f, 1.0f }; 
	glEnable(GL_LIGHT2);
	glLightfv(GL_LIGHT2, GL_DIFFUSE, blueLight);	
	glLightfv(GL_LIGHT2, GL_POSITION, blueLightPosition);
	
	// Inspect the current transform
//	GLfloat crapola[16];
//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
	glPushMatrix();
	glMultMatrixf(_cameraTransform);	
	
//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
	// A white spotlight for a camera headlight	
	const GLfloat spotLight[]			= { 1.0, 1.0,  1.0, 1.0 };
	const GLfloat spotLightPosition[]	= { 0.0, 0.0,  2.0, 1.0 }; 
	const GLfloat spotLightDirection[]	= { 0.0, 0.0, -1.0, 1.0 }; 
	const GLfloat spotCutOff			= 2.0f/0.75f;
	
	glEnable(GL_LIGHT3);
	glLightfv(GL_LIGHT3, GL_DIFFUSE, spotLight);	
	glLightfv(GL_LIGHT3, GL_POSITION, spotLightPosition);
	glLightfv(GL_LIGHT3, GL_SPOT_DIRECTION, spotLightDirection);
	glLightf(GL_LIGHT3, GL_SPOT_CUTOFF, spotCutOff);
	
	glPopMatrix();	
//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
	
//	glDisable(GL_LIGHT0);
//	glDisable(GL_LIGHT1);
//	glDisable(GL_LIGHT2);
//	glDisable(GL_LIGHT3);
	
	
	
	// Inflate the teapot
	const GLfloat inflation = 8.0/ 0.55;
	
	glPushMatrix();
	
	static JLMMatrix3D r;
	static JLMMatrix3D s;
	JLMMatrix3DSetZRotationUsingDegrees(r, -45.0f);
	JLMMatrix3DSetScaling(s, inflation, inflation, inflation);
	
	static JLMMatrix3D acc;
	JLMMatrix3DMultiply(r, s, acc);
	glMultMatrixf(acc);
//	glMultMatrixf(s);
	
//	glScalef(inflation, inflation, inflation);
	
	for(int i = 0; i < num_teapot_indices; i += new_teapot_indicies[i] + 1) {
		glDrawElements(GL_TRIANGLE_STRIP, new_teapot_indicies[i], GL_UNSIGNED_SHORT, &new_teapot_indicies[i+1]);
	}
	glPopMatrix();
	
	angle += 5.0 * (45.0/100.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

@end
