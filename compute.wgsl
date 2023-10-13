struct Vant {
  pos: vec2f,
  direction: f32,
  flag: f32
}

@group(0) @binding(0) var<uniform> res: vec2f;

@group(0) @binding(2) var<storage, read_write> vants: array<Vant>;
@group(0) @binding(3) var<storage, read_write> pheromones: array<f32>;
@group(0) @binding(4) var<storage, read_write> render: array<f32>;


fn vantIndex( cell:vec3u ) -> u32 {
  let size : u32 = 8;
  return cell.x + (cell.y * size);
}

fn pheromoneIndex( vant_pos: vec2f ) -> u32 {
  let width = res.x;
  return u32( abs( vant_pos.y % res.y ) * width + vant_pos.x );
}

fn hashNoise(p : vec2f) -> vec2f {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

@compute
@workgroup_size(8, 8, 1)
fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let pi2 = 6.283185;
  let index = vantIndex(cell);
  var vant : Vant = vants[index];

  let pIndex = pheromoneIndex( vant.pos );
  let pheromone = pheromones[pIndex];


  if (vant.flag < 2) {
    if(pheromone != 0.) {
      vant.direction += select(.25, -.25, vant.flag == 0.); // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 0.;  // set pheromone flag
    }
    else{
      vant.direction += select(-.25, .25, vant.flag == 0.); // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 1.;  // unset pheromone flag
    }
  }
  else if (vant.flag == 2) {
    if(pheromone != 0.) {
      vant.direction += select(.25, -.25, vant.flag == 0.); // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 0.;  // set pheromone flag

      vant.pos = hashNoise(vant.pos + vant.direction) * res;
    }
    else{
      pheromones[pIndex] = 1.;  // unset pheromone flag
      vant.direction += .005;
    }
  }
  else if (vant.flag == 3) {
    if(pheromone != 0.) {
      vant.direction += hashNoise(vant.pos + vant.direction).x + hashNoise(vant.pos + vant.direction).y; // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 0.;  // set pheromone flag
    }
    else{
      vant.direction += .5; // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 1.;  // unset pheromone flag
    }
  }
  else if (vant.flag == 4) {
    if(pheromone != 0.) {
      vant.direction += -.333; // turn 90 degrees counter-clockwise
      pheromones[pIndex] = 0.;  // set pheromone flag
    }
    else{
      vant.direction += .0333;
      pheromones[pIndex] = 1.;  // unset pheromone flag
    }
  }

  // calculate direction based on vant heading
  let dir = vec2f(sin(vant.direction * pi2), cos(vant.direction * pi2));
  vant.pos = round(vant.pos + dir);

  vants[index] = vant;

  // we'll look at the render buffer in the fragment shader
  // if we see a value of one a vant is there and we can color
  // it accordingly. in our JavaScript we clear the buffer on every
  // frame.
  render[pIndex] = vant.flag + 1;
}
