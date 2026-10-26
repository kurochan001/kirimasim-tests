/*
:name: test_illegal_ref_argument_type
:description: Passing a value to a ref argument is not assignment-like, so the actual has to be equivalent to the formal; passing a byte to a ref int is an error although an input int would accept it (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.8 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref formal is int and the actual is the byte b, which is not equivalent
:expected_stderr_regex: test_illegal_ref_argument_type\.sv:37:
*/
// IEEE 1800-2023 §10.8: the passing of a value to a ref argument is not an
// assignment-like context, so the implicit conversions of assignment
// compatibility do not apply. §13.5.2: a ref argument shall be matched with
// an equivalent type and no cast is permitted. The call set_int(i) passes an
// int to an int, and set_byte(b) passes a byte to a byte; both are legal. The
// call set_int(b) passes a byte to a ref int, which is illegal, although an
// input int formal would accept the byte by assignment compatibility.

module test_illegal_ref_argument_type;
  int i = 0;
  byte b = 0;

  task automatic set_int(ref int v);
    v = 7;
  endtask

  task automatic set_byte(ref byte v);
    v = 8;
  endtask

  initial begin
    set_int(i);
    set_byte(b);
    set_int(b);                // illegal: byte actual, ref int formal
    $display("i=%0d b=%0d", i, b);
  end
endmodule
