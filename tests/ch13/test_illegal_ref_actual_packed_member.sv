/*
:name: test_illegal_ref_actual_packed_member
:description: A member of a packed structure cannot be the actual argument of a ref formal, while a member of an unpacked structure can (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a member of a packed structure is passed to a ref formal
:expected_stderr_regex: test_illegal_ref_actual_packed_member\.sv:45:
*/
// IEEE 1800-2023 §13.5.2: only a variable, a class property, a member of an
// unpacked structure or an element of an unpacked array can be passed by
// reference. A member of a packed structure is none of these (it is a part
// of a packed vector); the call with a member of an unpacked structure of
// the same type is legal.
// Icarus Verilog 13.0 does not support unpacked structures, so its
// rejection does not count.

module test_illegal_ref_actual_packed_member;
  typedef struct packed {
    logic [7:0] hi;
    logic [7:0] lo;
  } packed_t;

  typedef struct {
    logic [7:0] hi;
    logic [7:0] lo;
  } unpacked_t;

  packed_t p;
  unpacked_t u;

  task automatic clear(ref logic [7:0] a);
    a = 8'h00;
  endtask

  initial begin
    p = 16'hABCD;
    u.hi = 8'h12;
    u.lo = 8'h34;
    clear(u.lo);
    clear(p.lo);   // illegal: a member of a packed structure passed by reference
    $display("%h %h", p, u.lo);
  end
endmodule
