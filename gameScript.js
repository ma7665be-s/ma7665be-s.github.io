const pi = BABYLON.Scalar.TwoPi / 2;

var canvas = document.getElementById("canvas");
var engine = new BABYLON.Engine(canvas, true);



var createScene = function() {
  var scene = new BABYLON.Scene(engine);

  scene.clearColor = new BABYLON.Color3(0.05,0.05,0.09);
  var camera = new BABYLON.ArcRotateCamera("Camera", pi / 2, pi / 2, 5, new BABYLON.Vector3(0, 0, 0), scene);
  camera.setTarget(BABYLON.Vector3.Zero());
  camera.attachControl(canvas, true);
  camera.keysUp.push(87);
  camera.keysDown.push(83);
  camera.keysLeft.push(65);
  camera.keysRight.push(68);
  var depthRend = scene.enableDepthRenderer();
  var geoRend = scene.enableGeometryBufferRenderer();

  var shaderMaterial = new BABYLON.ShaderMaterial("shader", scene, {
    vertexElement: "vertexShaderCode",
    fragmentElement: "fragmentShaderCode",
  }, {
    attributes: ["position", "normal", "uv"],
    uniforms: ["world", "worldView", "worldViewProjection", "view", "projection"]
  });


  var lightPosition = new BABYLON.Vector3(1, 5, 1);
  BABYLON.SceneLoader.ImportMesh("", "/", "louvre-demosthenes-photoscan.obj", scene, function(newMeshes) {

    var mesh = newMeshes[0];
    console.log(mesh);
    mesh.material = shaderMaterial;

    mesh.rotation.z += pi / 2;
    mesh.position.z -= 5;
  });

  scene.onBeforeRenderObservable.add(() => {
    shaderMaterial.setVector3("lightPosition", lightPosition);
    shaderMaterial.setVector3("cameraPosition", camera.position);
    var canvasInvRes = new BABYLON.Vector2(1 / canvas.width, 1 / canvas.height);
    shaderMaterial.setVector2("invRes", canvasInvRes);
    shaderMaterial.setTexture("depthmap", depthRend.getDepthMap());
    shaderMaterial.setTexture("normalmap", geoRend.getGBuffer().textures[1]);
  });
  return scene;
}

var scene = createScene();
engine.runRenderLoop(function() {
  scene.render();
});

window.addEventListener("resize", function () {
        engine.resize();
});
