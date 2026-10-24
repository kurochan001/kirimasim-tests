/*
:name: test_illegal_struct_pattern_default_not_castable
:description: the value of a default key in a structure assignment pattern has to be castable to the type of each member it applies to (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default value 3 also applies to the member h, a class handle, to which an int cannot be cast
:expected_stderr_regex: test_illegal_struct_pattern_default_not_castable\.sv:39:
*/
// IEEE 1800-2023 §10.9.2: a default:value applies to the members not set by a
// member name or type key, and for a member that is not an array or structure
// the value is evaluated as an assignment to it and shall be castable to its
// type, or an error is generated. With h set by name, the default 3 applies
// to the int and real members, which is legal; without it, the default also
// applies to the class handle h.
// Icarus Verilog 13.0 does not support unpacked structures, so its errors do
// not count.
// The 5.052 release of Verilator accepts the design and then writes C++ code
// that does not compile.

class obj_c;
endclass

module test_illegal_struct_pattern_default_not_castable;
  typedef struct {
    int a;
    real r;
    obj_c h;
  } mix_t;
  mix_t s;

  initial begin
    s = '{a:1, r:2.5, h:null};
    s = '{h:null, default:3};
    s = '{default:3};   // illegal: 3 is not castable to the class handle h
    $display("%0d %0.1f", s.a, s.r);
  end
endmodule
