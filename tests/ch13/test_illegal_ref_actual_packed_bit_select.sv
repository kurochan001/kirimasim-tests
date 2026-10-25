/*
:name: test_illegal_ref_actual_packed_bit_select
:description: A bit-select of a packed vector cannot be the actual argument of a ref formal, while an element of an unpacked array can (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select of a packed vector variable is passed to a ref formal
:expected_stderr_regex: test_illegal_ref_actual_packed_bit_select\.sv:33:
*/
// IEEE 1800-2023 §13.5.2: only a variable, a class property, a member of an
// unpacked structure or an element of an unpacked array can be passed by
// reference. A bit-select of a packed vector is none of these; the call
// with an element of an unpacked array of the same element type is legal.
// Icarus Verilog 13.0 does not support ref formals at all, so its
// rejection does not count.

module test_illegal_ref_actual_packed_bit_select;
  logic [3:0] vec;
  logic arr [4];

  task automatic set(ref logic a);
    a = 1'b1;
  endtask

  initial begin
    vec = 4'b0000;
    arr[2] = 1'b0;
    set(arr[2]);
    set(vec[2]);   // illegal: a bit-select of a packed vector passed by reference
    $display("%b %b", vec, arr[2]);
  end
endmodule
