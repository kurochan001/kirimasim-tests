/*
:name: test_struct_member
:description: Test struct member access (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_member.expected
*/
// Test struct member access (IEEE 1800-2023 Section 7.2)

module test_struct_member;
  typedef struct {
    logic [7:0] a;
    logic [7:0] b;
    int c;
  } my_struct_t;

  my_struct_t s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Write struct member
    s.a = 8'hAB;
    if (s.a == 8'hAB) pass_count++;

    // Test 2: Write another member
    s.b = 8'hCD;
    if (s.b == 8'hCD) pass_count++;

    // Test 3: Write int member
    s.c = 42;
    if (s.c == 42) pass_count++;

    // Test 4: Check all members
    if (s.a == 8'hAB && s.b == 8'hCD && s.c == 42) pass_count++;

    $display("Struct member tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Struct member tests");
    end else begin
      $display("FAIL: Some struct member tests failed");
    end
  end
endmodule
