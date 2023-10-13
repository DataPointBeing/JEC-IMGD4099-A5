import { default as seagulls } from './seagulls/seagulls.js'

const canvas = document.getElementsByTagName('canvas')[0];

const sg = await seagulls.init(),
   frag = await seagulls.import( './frag.wgsl' ),
   compute = await seagulls.import( './compute.wgsl' ),
   render = seagulls.constants.vertex + frag,
   GRID_SIZE = 20,
   NUM_AGENTS = 15,
   width = Math.round( window.innerWidth  / GRID_SIZE ),
   height = Math.round( window.innerHeight  / GRID_SIZE );

const pheromones = new Float32Array(width * height);
const vants_draw = new Float32Array(width * height);
const vants = new Float32Array(NUM_AGENTS * 4);

for(let i = 0; i < NUM_AGENTS * 4; i += 4) {
   vants[i]   = Math.floor( (.25+Math.random()/2) * width);
   vants[i+1] = Math.floor( (.25+Math.random()/2) * height);
   vants[i+2] = 0; // Direction
   vants[i+3] = Math.floor(Math.random() * 5); // Behavior
}

for(let i = 0; i < width * height; i += 1) {
   pheromones[i] = Math.floor( Math.random()); //*5);
}

sg.buffers({vants, pheromones, vants_draw})
   .backbuffer(false)
   .uniforms({
      res: [width, height],
      gridSize: GRID_SIZE
   })
   .compute(
      compute,
      [2, 2, 1],
   )
   .render(render)
   .onframe( ()=> sg.buffers.vants_draw.clear() )
   .run(1, 90)
