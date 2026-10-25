/*
:name: test_illegal_extern_type_name_resolves_differently
:description: an identifier in an out-of-block method header has to resolve to the same declaration as in the prototype (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: word_t in the prototype of put is the typedef imported from defs_pkg, while in the out-of-block header it is the typedef of pack_c declared after the prototype
:expected_stderr_regex: test_illegal_extern_type_name_resolves_differently\.sv:(35|39):
*/
// IEEE 1800-2023 §8.24: a prototype sees only the class types declared
// before it, while the header of the out-of-block declaration sees all the
// declarations of the class; it shall be an error if an identifier in the
// prototype resolves to another declaration than the same identifier in that
// header. In the prototype of put, tag_t is pack_c::tag_t, declared before
// it, and word_t is the one imported from defs_pkg, since pack_c declares its
// own word_t only after the prototype. In the header of pack_c::put, tag_t is
// again pack_c::tag_t (legal) but word_t is pack_c::word_t. The error can be
// reported at the header or at the prototype.
// Icarus Verilog 13.0 does not support out-of-block methods, and its syntax
// error on the header does not count; Verilator 5.052 accepts the design.

package defs_pkg;
  typedef byte word_t;
endpackage

import defs_pkg::word_t;

class pack_c;
  typedef bit [3:0] tag_t;
  int total;
  extern function void put(tag_t t, word_t w);   // (or reported here)
  typedef shortint word_t;
endclass

function void pack_c::put(tag_t t, word_t w);   // illegal: word_t is pack_c::word_t here
  total = t + w;
endfunction

module test_illegal_extern_type_name_resolves_differently;
  initial $display("done");
endmodule
