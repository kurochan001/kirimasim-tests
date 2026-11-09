/*
:name: test_coverage_toggle_both_values
:description: Toggle coverage counts a bit as covered once it has had both the values 0 and 1, so $coverage_get gives the number of such bits, which stays below $coverage_get_max while some bits never changed, and toggling a covered bit again adds nothing (IEEE 1800-2023 Sections 40.2.2 and 40.3.2.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.2.2 40.3.2.3 40.3.2.2 40.3.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_toggle_both_values.expected
*/
// IEEE 1800-2023 §40.2.2: the primitive of toggle coverage is one bit of a
// signal, covered when that bit has had both a 0 and a 1 value; over an
// instance the coverage number is the sum of its primitives. §40.3.2.2:
// $coverage_get_max gives the number of coverable items, here the 4 bits of t,
// the only signal of the instance u. §40.3.2.3: a positive value of
// $coverage_get is the number of items covered so far, not the maximum.
//
// Bits 0 and 1 of u.t go from 0 to 1 and back to 0, bits 2 and 3 stay 0, so
// two of the four bits are covered. Bit 0 then goes through 1 again, which
// covers nothing new: the value is the number of covered bits, not a count of
// changes. Which parts of a design have toggle coverage depends on the tool
// (40.3.2.1), so the numbers are checked only where a check of u gives
// SV_COV_OK; elsewhere each line holds as well. A tool that returned the
// maximum from $coverage_get would print no on the lines about 2 bits, and one
// that counted value changes would print no on them too.

`timescale 1ns/1ns

module test_coverage_toggle_both_values_unit;
  logic [3:0] t = 4'b0000;
endmodule

module test_coverage_toggle_both_values;
  test_coverage_toggle_both_values_unit u();

  int check, max0, max1, cur0, cur1, cur2;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    #1;
    check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_MODULE, u);
    max0 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    cur0 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    u.t[0] = 1'b1;
    #1 u.t[0] = 1'b0;
    #1 u.t[1] = 1'b1;
    #1 u.t[1] = 1'b0;
    #1 cur1 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    u.t[0] = 1'b1;
    #1 u.t[0] = 1'b0;
    #1 cur2 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    max1 = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    $display("check is not ERROR: %s", yes_no(check != `SV_COV_ERROR));
    $display("with toggle coverage of u, the maximum is its 4 bits: %s",
             yes_no(check != `SV_COV_OK || (max0 == 4 && max1 == 4)));
    $display("with toggle coverage of u, no bit is covered before any change: %s",
             yes_no(check != `SV_COV_OK || cur0 == 0));
    $display("with toggle coverage of u, the 2 bits that were 0 and 1 are covered: %s",
             yes_no(check != `SV_COV_OK || cur1 == 2));
    $display("with toggle coverage of u, toggling a covered bit again adds nothing: %s",
             yes_no(check != `SV_COV_OK || cur2 == 2));
    $display("with toggle coverage of u, the current value is below the maximum: %s",
             yes_no(check != `SV_COV_OK || cur2 < max1));
  end
endmodule
