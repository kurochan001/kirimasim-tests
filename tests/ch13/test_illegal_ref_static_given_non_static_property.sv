/*
:name: test_illegal_ref_static_given_non_static_property
:description: a ref static argument can be passed a static class property but not a non-static one (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2 8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-static property own of the object obj is passed to the ref static argument of bump
:expected_stderr_regex: test_illegal_ref_static_given_non_static_property\.sv:40:
*/
// IEEE 1800-2023 §13.5.2: a ref static argument shall be passed only objects
// of static lifetime, and not non-static class properties, which live only
// as long as their object. §8.9: a static property is shared by the class
// and exists for the whole simulation. The first call passes the static
// property item_c::shared, which is legal, and the legal design prints it
// after the increment: 1. The second call passes obj.own, a non-static
// property, although the handle obj itself is a static module variable.
// Icarus Verilog 13.0 does not support ref arguments, and the 5.052 release
// of Verilator does not support ref static ones; both stop at a task header.

module test_illegal_ref_static_given_non_static_property;
  class item_c;
    static int shared;
    int own;
  endclass

  item_c obj;

  task automatic bump(ref static int r);
    r++;
  endtask

  initial begin
    obj = new;
    bump(item_c::shared);
    $display("%0d", item_c::shared);
    bump(obj.own);   // illegal: a non-static class property for a ref static argument
  end
endmodule
