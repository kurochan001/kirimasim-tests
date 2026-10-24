/*
:name: test_enum_next_prev_from_non_member
:description: next() and prev() on a value that is not a member return the default initial value of the enum, 0 for an int base and x for a logic base, even though it is not a member (IEEE 1800-2023 Sections 6.19.5.3 and 6.19.5.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.3 6.19.5.4 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_next_prev_from_non_member.expected
*/
// IEEE 1800-2023 §6.19.5.3 and §6.19.5.4: when the value of the variable is
// not a member, next() and prev() return the default initial value of the
// enum (§6.8, Table 6-7: that of its base type). For t_t, whose base is int
// and whose members are 1, 2 and 3, that value is 0, which is no member, so
// name() of the result is empty. For l_t, with a logic [2:0] base, it is
// 3'bxxx. A member value steps and wraps as usual, for comparison. The
// non-member values are put into the variables with casts.
// For the non-member 7, Verilator 5.052 returns members (next A, prev B,
// next(2) B), and P for the logic value 6, instead of the default value.

module test_enum_next_prev_from_non_member;
  typedef enum {A = 1, B = 2, C = 3} t_t;
  typedef enum logic [2:0] {P = 1, Q = 2} l_t;
  t_t v, r;
  l_t lv, lr;

  initial begin
    v = C;
    r = v.next();
    $display("member C: next=%s", r.name());
    v = A;
    r = v.prev();
    $display("member A: prev=%s", r.name());
    v = t_t'(7);
    r = v.next();
    $display("7: next=%0d name=\"%s\"", r, r.name());
    r = v.prev();
    $display("7: prev=%0d name=\"%s\"", r, r.name());
    r = v.next(2);
    $display("7: next(2)=%0d", r);
    v = t_t'(0);
    r = v.prev();
    $display("0: prev=%0d", r);
    lv = l_t'(3'd6);
    lr = lv.next();
    $display("logic 6: next=%b", lr);
    lr = lv.prev();
    $display("logic 6: prev=%b", lr);
  end
endmodule
