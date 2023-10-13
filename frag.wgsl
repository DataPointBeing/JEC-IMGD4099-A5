@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<uniform> gridSize: f32;

@group(0) @binding(3) var<storage> pheromones: array<f32>;
@group(0) @binding(4) var<storage> render: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let grid_pos = floor(pos.xy / gridSize);
  let local_pos = (pos.xy/gridSize) - grid_pos;

  let pidx = grid_pos.y  * res.x + grid_pos.x;
  let p = (1. - pheromones[u32(pidx)]) * 0.028 + 0.160;
  let v = render[u32(pidx)];

  let lpc = local_pos - 0.5;

  var mask = true;

  mask = mask && abs(lpc.x) < 0.4 && abs(lpc.y) < 0.4;

  mask = mask && ((abs(lpc.x) < 0.3 || abs(lpc.y) < 0.3) || distance(abs(lpc), vec2f(0.3)) < 0.1);

  var antColor = vec3f(0);
  switch(i32(v)) {
    case 1: {
      antColor = vec3f(.957, .471, .169);
      mask = mask && (distance(abs(lpc), vec2f(0.2)) > 0.2 || (abs(lpc.x) > 0.2 || abs(lpc.y) > 0.2));
      break;
    }
    case 2: {
      antColor = vec3f(.937, .922, .259);
      mask = mask && (distance(abs(lpc), vec2f(0.1)) > 0.1 || (abs(lpc.x) > 0.1 && abs(lpc.y) > 0.1));
      break;
    }
    case 3: {
      antColor = vec3f(.631, .788, .227);
      mask = mask && (distance(abs(lpc), vec2f(0.05)) > 0.1 && (abs(lpc.x) > 0.05 && abs(lpc.y) > 0.05));
      break;
    }
    case 4: {
      antColor = vec3f(.416, .596, .729);
      mask = mask && ((abs(lpc.x) > 0.2 || abs(lpc.y) > 0.2));
      break;
    }
    case 5: {
      antColor = vec3f(.529, .341, .557);
      mask = mask && (distance(abs(lpc), vec2f(0.1)) > 0.1);
      break;
    }
    default: {

    }
  }

  let out = select(vec3(p), antColor, v >= 1. && mask);

  return vec4f( out, 1. );
}
