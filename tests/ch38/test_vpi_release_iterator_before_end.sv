/*
:name: test_vpi_release_iterator_before_end
:description: Releasing an unfinished VPI iterator succeeds and a new traversal still sees every instance
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.38 C.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_release_iterator_before_end.c
:expected_stdout: @test_vpi_release_iterator_before_end.expected
*/
// The VPI application stops its first traversal after one child.
module release_leaf;
endmodule

module test_vpi_release_iterator_before_end;
  release_leaf first(), second(), third();
  initial #1 $finish;
endmodule
