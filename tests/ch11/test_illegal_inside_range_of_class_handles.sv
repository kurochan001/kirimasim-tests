/*
:name: test_illegal_inside_range_of_class_handles
:description: the bounds of a range in an inside set have to be of a singular type for which <= and >= are defined, so they cannot be class handles (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the range [h1:h2] of the inside set has class handles as bounds, for which the relational operators are not defined
:expected_stderr_regex: test_illegal_inside_range_of_class_handles\.sv:33:
*/
// IEEE 1800-2023 §11.4.13: when a range is given in an inside set, its bounds
// shall be of a singular type for which the relational operators <= and >=
// are defined. Class handles in the set without a range, compared with ==,
// and a range of strings are legal; a range with class handles as bounds is
// not, since handles have no <= or >= (8.4).
// Icarus Verilog 13.0 does not support inside, and the design is accepted by
// the 5.052 release of Verilator.

class obj_c;
endclass

module test_illegal_inside_range_of_class_handles;
  obj_c h = new, h1 = new, h2 = new;
  string s = "dog";
  bit r1, r2, r3;

  initial begin
    r1 = h inside {h1, h2};
    r2 = s inside {["cat":"eel"]};
    r3 = h inside {[h1:h2]};   // illegal: class handles as range bounds
    $display("%b %b", r1, r2);
  end
endmodule
