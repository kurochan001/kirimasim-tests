/*
:name: test_edge_sign_ext
:description: Signed values sign-extend and unsigned values zero-extend when assigned to int
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.2 6.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_sign_ext.expected
*/
module edge_sign_ext;
  logic signed [3:0] sa = -1; // 4'b1111
  logic        [3:0] ua = -1; // 4'b1111 (unsigned)
  int i1;
  int i2;

  initial begin
    // Assigned here so the result does not depend on the order of static initializers.
    i1 = sa;
    i2 = ua;
    if (i1 !== -1) $fatal(1, "signed value should sign-extend to -1");
    if (i2 !== 15) $fatal(1, "unsigned value should zero-extend to 15");
    $display("PASS: sign extension vs zero extension verified");
    $finish;
  end
endmodule
