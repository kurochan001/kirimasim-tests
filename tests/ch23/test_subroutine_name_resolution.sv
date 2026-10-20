/*
:name: test_subroutine_name_resolution
:description: A call of a task or function looks for the name upwards through the enclosing scopes first, then in the whole compilation unit, also at a declaration after the call, before any wildcard import is used (IEEE 1800-2023 Section 23.8.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8.1 23.8 26.3 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_name_resolution.expected
*/
// IEEE 1800-2023 §23.8.1: a task or function name is resolved like an upward
// hierarchical name (23.8), but after the scopes that enclose the call the
// whole compilation unit is searched (3.12.1), so a call in $unit can name a
// function declared after it. In the generate block g, the call of which()
// finds the function declared in g itself, not the one that the wildcard
// import of the package would provide (26.3).

package test_subroutine_name_resolution_pkg;
  function string which();
    return "the package";
  endfunction
endpackage

task automatic test_subroutine_name_resolution_unit_task(output int r);
  r = test_subroutine_name_resolution_later(4);
endtask

function automatic int test_subroutine_name_resolution_later(int y);
  return y + 1;
endfunction

module test_subroutine_name_resolution;
  import test_subroutine_name_resolution_pkg::*;

  if (1) begin : g
    function string which();
      return "the generate block";
    endfunction

    initial $display("which: %s", which());
  end

  initial begin
    int r;
    #1 test_subroutine_name_resolution_unit_task(r);
    $display("unit task: %0d", r);
  end
endmodule
