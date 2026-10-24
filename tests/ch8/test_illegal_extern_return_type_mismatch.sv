/*
:name: test_illegal_extern_return_type_mismatch
:description: the return type of an out-of-block method declaration has to match its prototype (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of get returns shortint where the prototype returns int
:expected_stderr_regex: test_illegal_extern_return_type_mismatch\.sv:(23|31):
*/
// IEEE 1800-2023 §8.24: an out-of-block method declaration shall match the
// prototype exactly, apart from the listed exceptions, none of which changes
// a return type. put matches its prototype; get returns int in the prototype
// and shortint in the out-of-block declaration. The mismatch can be
// reported at the out-of-block declaration or at the prototype.
// Icarus Verilog 13.0 does not support out-of-block methods.

class store_c;
  int last;
  extern function int get();   // (or reported here)
  extern function void put(int v);
endclass

function void store_c::put(int v);
  last = v;
endfunction

function shortint store_c::get();   // illegal: return type differs
  return last;
endfunction

module test_illegal_extern_return_type_mismatch;
  store_c s = new;
  initial s.put(1);
endmodule
