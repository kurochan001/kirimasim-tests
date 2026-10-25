/*
:name: test_function_array_formals_inherit_type
:description: A function can have unpacked array formals, and a formal without a data type takes the element type of the formal before it while keeping its own unpacked dimensions (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_array_formals_inherit_type.expected
*/
// IEEE 1800-2023 §13.4: an array can be specified as a formal argument of a
// function, and a formal argument without a data type takes the type of the
// argument before it (logic when it has its own direction or is the first).
// The unpacked dimensions written after a formal's name belong to that
// formal alone.
//
// total(input [3:0] e [2], f [3]) has e, an array of two logic [3:0]
// elements, and f, which takes the element type logic [3:0] with its own
// dimension [3]. $bits of an element is 4 for both, $size is 2 and 3, and
// the sum of all five elements, with 15 counted as unsigned, is returned.
// A second function, with a byte element type, shows the inherited element
// type is signed there: its sum with an element -1 is negative.

module test_function_array_formals_inherit_type;
  logic [3:0] ea [2];
  logic [3:0] fa [3];
  byte ba [2];
  byte bb [3];

  function automatic int total(input [3:0] e [2], f [3]);
    int s;
    $display("total: element bits e=%0d f=%0d, sizes e=%0d f=%0d",
             $bits(e[0]), $bits(f[0]), $size(e), $size(f));
    s = 0;
    foreach (e[i]) s += e[i];
    foreach (f[i]) s += f[i];
    return s;
  endfunction

  function automatic int total_bytes(input byte e [2], f [3]);
    int s;
    $display("total_bytes: element bits e=%0d f=%0d, sizes e=%0d f=%0d",
             $bits(e[0]), $bits(f[0]), $size(e), $size(f));
    s = 0;
    foreach (e[i]) s += e[i];
    foreach (f[i]) s += f[i];
    return s;
  endfunction

  initial begin
    ea[0] = 4'd1;
    ea[1] = 4'd2;
    fa[0] = 4'd15;
    fa[1] = 4'd4;
    fa[2] = 4'd8;
    $display("total = %0d", total(ea, fa));
    ba[0] = 8'sd3;
    ba[1] = 8'sd4;
    bb[0] = -8'sd1;
    bb[1] = -8'sd10;
    bb[2] = 8'sd2;
    $display("total_bytes = %0d", total_bytes(ba, bb));
  end
endmodule
