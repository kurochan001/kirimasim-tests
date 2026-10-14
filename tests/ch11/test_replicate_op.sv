/*
:name: test_replicate_op
:description: Test replication operator (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_replicate_op.expected
*/
// Test replication operator (IEEE 1800-2023 Section 11.4.12)

module test_replicate_op;
  logic [7:0] val8;
  logic [15:0] val16;
  logic [31:0] val32;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: {2{4'hA}} = 8'hAA
    val8 = {2{4'hA}};
    if (val8 == 8'hAA) pass_count++;

    // Test 2: {4{4'h5}} = 16'h5555
    val16 = {4{4'h5}};
    if (val16 == 16'h5555) pass_count++;

    // Test 3: {8{4'hF}} = 32'hFFFFFFFF
    val32 = {8{4'hF}};
    if (val32 == 32'hFFFFFFFF) pass_count++;

    if ({3{1'b1}} == 3'd7) pass_count++;

    $display("Replicate op tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Replicate op tests");
    end else begin
      $display("FAIL: Some replicate op tests failed");
    end
  end
endmodule
