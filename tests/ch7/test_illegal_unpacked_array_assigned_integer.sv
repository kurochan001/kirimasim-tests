/*
:name: test_illegal_unpacked_array_assigned_integer
:description: an integer value can be assigned to a packed array but not to an unpacked array (IEEE 1800-2023 Section 7.4.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the integer literal 8'd5 is assigned to the unpacked array u
:expected_stderr_regex: test_illegal_unpacked_array_assigned_integer\.sv:28:
*/
// IEEE 1800-2023 §7.4.6: assignment from an integer and use as an integer
// in an expression can be done on packed arrays but not on unpacked arrays.
// The packed arrays p and q of the same 8 bits are assigned integers and the
// legal design prints them; the unpacked array u of 8 bits is assigned the
// integer 8'd5.

module test_illegal_unpacked_array_assigned_integer;
  bit [7:0] p;
  bit [1:0][3:0] q;
  bit u [8];
  initial begin
    p = 8'd5;
    q = 8'hc3;
    $display("%0d %h %h", p, q[1], q[0]);
    u = 8'd5;   // illegal: integer assigned to an unpacked array
  end
endmodule
