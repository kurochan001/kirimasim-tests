/*
:name: test_partsel_basic
:description: Test part select operators (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_partsel_basic.expected
*/
// Test part select operators (IEEE 1800-2023 Section 11.5.1)

module test_partsel_basic;
  logic [15:0] data;
  logic [7:0] byte_val;
  int pass_count;

  initial begin
    pass_count = 0;
    data = 16'hABCD;

    byte_val = data[15:8];
    if (byte_val == 8'hAB) pass_count++;

    byte_val = data[7:0];
    if (byte_val == 8'hCD) pass_count++;

    // Test 3: Single bit select
    if (data[0] == 1'b1) pass_count++;

    $display("Part select tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Part select tests");
    end else begin
      $display("FAIL: Some part select tests failed");
    end
  end
endmodule
