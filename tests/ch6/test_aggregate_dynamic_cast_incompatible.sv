/*
:name: test_aggregate_dynamic_cast_incompatible
:description: A dynamic cast of a non-singular source to a non-singular destination that is not assignment compatible fails and leaves the destination unchanged, although a static bit-stream cast of the same bits succeeds (IEEE 1800-2023 Section 6.24.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_aggregate_dynamic_cast_incompatible.expected
*/
// IEEE 1800-2023 §6.24.2: the $cast function returns 0 and makes no
// assignment when the arguments are not singular and are not assignment
// compatible. The static bit-stream cast rules of 6.24.3 do not make the
// assignment compatible. src_t and dst_t are different unpacked structures
// with the same total width, so a static bit-stream cast converts them, but
// $cast must refuse the assignment. The destination keeps the value it had
// before the failed cast.
//
// Icarus Verilog 13.0 does not support unpacked structures and the 5.052
// release of Verilator stops on a bit-stream cast of an unpacked structure,
// so the expectation follows 6.24.2.

typedef struct {
  bit [7:0] a;
} src_t;

typedef struct {
  bit [3:0] b;
  bit [3:0] c;
} dst_t;

module test_aggregate_dynamic_cast_incompatible;
  src_t s;
  dst_t d, prior;
  int ok;

  initial begin
    s.a = 8'hA5;
    prior.b = 4'h1;
    prior.c = 4'h2;
    d = prior;
    ok = $cast(d, s);
    $display("castfn=%0d d=%h%h", ok, d.b, d.c);
    d = dst_t'(s);
    $display("bitstream=%h%h", d.b, d.c);
  end
endmodule
