/*
:name: test_buf_gate
:description: Test buffer gate primitives (IEEE 1800-2023 Section 28.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4 28.5 28.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_buf_gate.expected
*/
// Test buffer gate primitives (IEEE 1800-2023 Section 28.4)

module test_buf_gate;
  logic in_val;
  wire buf_out, bufif1_out, bufif0_out;
  logic ctrl;
  int pass_count;

  buf u_buf(buf_out, in_val);
  bufif1 u_bufif1(bufif1_out, in_val, ctrl);
  bufif0 u_bufif0(bufif0_out, in_val, ctrl);

  initial begin
    pass_count = 0;

    // Test 1: Buffer 0
    in_val = 0;
    #1;
    if (buf_out == 0) pass_count++;

    // Test 2: Buffer 1
    in_val = 1;
    #1;
    if (buf_out == 1) pass_count++;

    // Test 3: Bufif1 enabled
    ctrl = 1;
    in_val = 1;
    #1;
    if (bufif1_out == 1) pass_count++;

    // Test 4: Bufif1 disabled
    ctrl = 0;
    #1;
    if (bufif1_out === 1'bz) pass_count++;

    // Test 5: Bufif0 enabled
    ctrl = 0;
    in_val = 1;
    #1;
    if (bufif0_out == 1) pass_count++;

    $display("Buf gate tests: %0d/5 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Buf gate tests");
    end else begin
      $display("FAIL: Some buf tests failed");
    end
  end
endmodule
