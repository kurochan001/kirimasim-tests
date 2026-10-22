/*
:name: test_assoc_signed_boundary_order
:description: Signed integral associative keys iterate in signed numerical order across zero (IEEE 1800-2023 Section 7.8.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_signed_boundary_order.expected
*/
// IEEE 1800-2023 7.8.4: Foreach must use the signed order of integral
// keys, and assigning an existing key replaces its value without growing the
// array.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not reproduce the clause-derived output.

module test_assoc_signed_boundary_order;
  int a[int];
  initial begin
    a[2] = 20; a[-3] = 30; a[0] = 40; a[-3] = 31;
    foreach (a[k]) $display("key=%0d value=%0d", k, a[k]);
    $display("size=%0d", a.num());
  end
endmodule
