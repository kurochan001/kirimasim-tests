/*
:name: test_soft_packed_union
:description: The members of a soft packed union can have different sizes; the union is as wide as the largest, and each member lies in its low bits (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_packed_union.expected
*/
// IEEE 1800-2023 §7.3.1: with soft, the members of a packed union do not have
// to be of the same size; the size of the union is that of its largest member,
// and every member is right-justified, in the low bits. Here wide has 12 bits,
// so the union has 12; writing narrow changes only the low 4 bits, which the
// packed structure mid (§7.2.1) then shows in its low byte.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023.

module test_soft_packed_union;
  typedef union soft {
    logic [11:0] wide;
    logic [3:0] narrow;
    struct packed { logic [1:0] hi; logic [5:0] lo; } mid;
  } u_t;
  u_t u;
  initial begin
    u.wide = 12'h5c3;
    u.narrow = 4'ha;
    $display("wide=%h narrow=%h", u.wide, u.narrow);
    $display("mid.hi=%b mid.lo=%h", u.mid.hi, u.mid.lo);
    $display("$bits=%0d", $bits(u_t));
  end
endmodule
