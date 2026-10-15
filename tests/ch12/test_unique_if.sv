/*
:name: test_unique_if
:description: Test unique/priority if (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if.expected
*/
// Test unique/priority if (IEEE 1800-2023 Section 12.4.2)

module test_unique_if;
  logic [1:0] sel;
  logic [7:0] result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Unique if first
    sel = 2'b00;
    unique if (sel == 2'b00) result = 8'hAA;
    else if (sel == 2'b01) result = 8'hBB;
    else if (sel == 2'b10) result = 8'hCC;
    else result = 8'hDD;
    if (result == 8'hAA) pass_count++;

    // Test 2: Unique if second
    sel = 2'b01;
    unique if (sel == 2'b00) result = 8'hAA;
    else if (sel == 2'b01) result = 8'hBB;
    else if (sel == 2'b10) result = 8'hCC;
    else result = 8'hDD;
    if (result == 8'hBB) pass_count++;

    // Test 3: Priority if first match
    sel = 2'b00;
    priority if (sel[0] == 1'b0) result = 8'h11;
    else if (sel[1] == 1'b0) result = 8'h22;
    else result = 8'h33;
    if (result == 8'h11) pass_count++;

    // Test 4: Priority if second match
    sel = 2'b01;
    priority if (sel == 2'b10) result = 8'h44;
    else if (sel[0] == 1'b1) result = 8'h55;
    else result = 8'h66;
    if (result == 8'h55) pass_count++;

    $display("Unique/priority if tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Unique/priority if tests");
    end else begin
      $display("FAIL: Some unique/priority tests failed");
    end
  end
endmodule
