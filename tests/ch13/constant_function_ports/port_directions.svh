// Each body is identical so only the second formal direction varies.
function automatic int port_input(input int seed, input int slot);
  return seed + 1;
endfunction

function automatic int port_output(input int seed, output int slot);
  return seed + 1;
endfunction

function automatic int port_inout(input int seed, inout int slot);
  return seed + 1;
endfunction

function automatic int port_ref(input int seed, ref int slot);
  return seed + 1;
endfunction
