/*
:name: test_struct_packed
:description: Test packed structs (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 10.9.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_packed.expected
*/
// Test packed structs (IEEE 1800-2023 Section 7.2)

module test_struct_packed;
  typedef struct packed {
    logic [7:0] field_a;
    logic [7:0] field_b;
    logic [7:0] field_c;
    logic [7:0] field_d;
  } quad_t;

  quad_t q;
  logic [31:0] raw;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Field assignment
    q.field_a = 8'hAA;
    q.field_b = 8'hBB;
    q.field_c = 8'hCC;
    q.field_d = 8'hDD;
    if (q.field_a == 8'hAA) pass_count++;

    // Test 2: Struct to raw
    raw = q;
    if (raw == 32'hAABBCCDD) pass_count++;

    // Test 3: Raw to struct
    raw = 32'h11223344;
    q = raw;
    if (q.field_d == 8'h44) pass_count++;

    // Test 4: Struct comparison
    begin
      quad_t q2;
      q2 = q;
      if (q == q2) pass_count++;
    end

    // Test 5: Partial update
    q.field_b = 8'hFF;
    if (q.field_b == 8'hFF && q.field_a == 8'h11) pass_count++;

    // Test 6: Struct initialization
    q = '{8'h01, 8'h02, 8'h03, 8'h04};
    if (q.field_a == 8'h01) pass_count++;

    $display("Struct packed tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Struct packed tests");
    end else begin
      $display("FAIL: Some struct packed tests failed");
    end
  end
endmodule
