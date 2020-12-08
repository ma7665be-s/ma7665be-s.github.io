
const pi = BABYLON.Scalar.TwoPi/2;

window.addEventListener("DOMContentLoaded", function(){
  var canvas = document.getElementById("canvas");
  var engine = new BABYLON.Engine(canvas, true);


  var createScene = function(){
    var scene = new BABYLON.Scene(engine);
    scene.clearColor = new BABYLON.Color3.White();
    var camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0,20,-20),scene);
    camera.setTarget(BABYLON.Vector3.Zero());
    camera.attachControl(canvas, true);
    camera.keysUp.push(87);
    camera.keysDown.push(83);
    camera.keysLeft.push(65);
    camera.keysRight.push(68);

    var shaderMaterial = new BABYLON.ShaderMaterial("shader", scene, {
        vertexElement: "vertexShaderCode",
        fragmentElement: "fragmentShaderCode",
    },
    {
        attributes: ["position", "normal", "uv"],
        uniforms: ["world", "worldView", "worldViewProjection", "view", "projection"]
    });


    //var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(1, 10, -5), scene);
    var light = new BABYLON.SpotLight("spotLight", new BABYLON.Vector3(10, 10, 10), new BABYLON.Vector3(-1, -1, -1), pi/3, 1, scene);

    BABYLON.SceneLoader.ImportMesh("","https://models.babylonjs.com/", "Chair/Chair.obj", scene, function (newMeshes) {
    // do something with the scene


    var mesh = newMeshes[0];
    mesh.material = shaderMaterial;

    console.log(mesh.material);


    });

    light.specular = BABYLON.Color3.Red();

    var box = BABYLON.MeshBuilder.CreateBox("box",{size:4.0},scene);
    var materialBox = new BABYLON.StandardMaterial("materialBox", scene);
    materialBox.specularColor = BABYLON.Color3.Red();
    materialBox.diffuseColor = BABYLON.Color3.Yellow();
    box.material = shaderMaterial;


    //camera.parent = player;
    scene.onBeforeRenderObservable.add(()=> {
      //box.rotation.y += 0.01;
      //box.rotation.x += 0.01;
      //box.rotation.z += 0.01;
      shaderMaterial.setVector3("lightposition", light.position);
      shaderMaterial.setVector3("lightdirection", light.direction);
      shaderMaterial.setVector3("cameraposition", camera.position);
    });

    return scene;
  }

  var scene = createScene();
  engine.runRenderLoop(function(){
    scene.render();
  });
});
