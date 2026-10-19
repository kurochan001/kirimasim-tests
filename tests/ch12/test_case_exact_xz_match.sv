/*
:name: test_case_exact_xz_match
:description: A case statement matches x and z bits exactly, while casex and casez treat them as don't-care (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_exact_xz_match.expected
*/
// IEEE 1800-2023 §12.5: a case statement compares the case expression with each
// item bit by bit, and an x bit matches only an x bit and a z bit only a z bit,
// the same comparison as ===. x and z in a case item are not don't-care bits;
// only casex and casez (12.5.1) treat them so.

module test_case_exact_xz_match;
  int fails = 0;
  int m;

  initial begin
    static logic [3:0] v  = 4'b10x1;
    static logic [3:0] w  = 4'bxxxx;
    static logic [3:0] zz = 4'b10z1;

    // (1) an expression matches itself, as v === v is 1
    m = 0;
    case (v) v: m = 1; default: m = 0; endcase
    if (m != (v === v)) begin
      $display("FAIL case-self x: case-match=%0d (v===v)=%0d", m, (v === v)); fails++;
    end

    // (2) a constant item with the same x bit
    m = 0;
    case (v) 4'b10x1: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL x item did not match"); fails++; end

    // (3) all bits x
    m = 0;
    case (w) 4'bxxxx: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL all-x item did not match"); fails++; end

    // (4) a constant item with the same z bit
    m = 0;
    case (zz) 4'b10z1: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL z item did not match"); fails++; end

    // (5) an x bit does not match a 1
    m = 0;
    case (v) 4'b1011: m = 1; default: m = 0; endcase
    if (m != 0) begin $display("FAIL x matched a known item"); fails++; end

    // (6) known values
    m = 0;
    case (4'b1010) 4'b1010: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL known value did not match"); fails++; end

    // (7) casex: x in an item is a don't-care bit
    m = 0;
    casex (4'b1011) 4'b101x: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL casex x item did not match"); fails++; end

    // (8) casez: z in an item is a don't-care bit
    m = 0;
    casez (4'b1011) 4'b101z: m = 1; default: m = 0; endcase
    if (m != 1) begin $display("FAIL casez z item did not match"); fails++; end

    if (fails == 0)
      $display("TEST PASSED: case matches x and z exactly");
    else
      $display("TEST FAILED: %0d check(s) failed", fails);
    $finish;
  end
endmodule
