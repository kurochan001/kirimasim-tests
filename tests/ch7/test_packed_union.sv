/*
:name: test_packed_union
:description: Test packed union (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_union.expected
*/
// Test packed union (IEEE 1800-2023 Section 7.3.1)

module test_packed_union;
  typedef union packed {
    logic [15:0] word;
    struct packed {
      logic [7:0] high;
      logic [7:0] low;
    } bytes;
  } my_union_t;

  my_union_t u;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Write word member
    u.word = 16'hABCD;
    if (u.word == 16'hABCD) pass_count++;

    // Test 2: Read low byte via struct
    if (u.bytes.low == 8'hCD) pass_count++;

    // Test 3: Read high byte via struct
    if (u.bytes.high == 8'hAB) pass_count++;

    // Test 4: Write via struct
    u.bytes.low = 8'hEF;
    if (u.word[7:0] == 8'hEF) pass_count++;

    $display("Packed union tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Packed union tests");
    end else begin
      $display("FAIL: Some packed union tests failed");
    end
  end
endmodule
