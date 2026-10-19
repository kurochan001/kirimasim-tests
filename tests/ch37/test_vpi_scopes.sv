/*
:name: test_vpi_scopes
:description: vpiInternalScope gives the named blocks, tasks and functions of a module and the named fork inside a block, a variable of a named block has that block as its scope, and tasks and functions give their lifetime, size, return variable and io declarations (IEEE 1800-2023 Sections 37.12, 37.41 and 37.13)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.41 37.13 37.17 13.3 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_scopes.c
:expected_stdout: @test_vpi_scopes.expected
*/
// IEEE 1800-2023 §37.12: vpi_iterate(vpiInternalScope) over the module gives
// its named block blk, its tasks and its functions; the named fork fk is inside
// blk, so it is an internal scope of blk. A named block is always a scope
// (detail 1), and the variable v declared in it has blk as its vpiScope
// (37.17). §37.41: tk is automatic and fn static (vpiAutomatic); vpiSize of a
// function is that of its return variable, 6 for fn, and 0 for the void
// function vf (detail 12); vpiReturn gives the return variable (detail 3).
// §37.13: vpi_iterate(vpiIODecl) over tk gives its arguments with their
// direction and size. The application sorts the lists by name.

module test_vpi_scopes;
  int n = 1;
  logic [3:0] o4;

  task automatic tk(input int a, output logic [3:0] o, inout int io);
    o = a[3:0];
    io = io + 1;
  endtask

  function logic [5:0] fn(input logic [2:0] q);
    return {3'b000, q};
  endfunction

  function void vf();
  endfunction

  initial begin : blk
    logic v;
    v = 1'b1;
    tk(5, o4, n);
    vf();
    fork : fk
      #1 v = fn(3'd2) == 6'd2;
    join
    $vt_scopes;
  end
endmodule
