/*
:name: test_ref_static_accepted_actuals
:description: a ref static argument accepts a module variable, a package variable, a static class property, a member of a static unpacked structure, an element of a static fixed-size array, a static variable of an automatic task and another ref static argument, and a nonblocking assignment through it writes that object (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 6.21 10.4.2 8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_static_accepted_actuals.expected
*/
// IEEE 1800-2023 §13.5.2: a ref static argument shall be passed only
// variables, class properties, structure members or array elements of static
// lifetime, or another ref static argument; unlike a plain ref argument it may
// be used where automatic variables may not, such as on the left of a
// nonblocking assignment (§6.21, §10.4.2). put writes its argument with a
// nonblocking assignment, so the writes take effect in the NBA region: the
// line printed right after the calls still shows the initial zeros. The
// actuals are the module variable mod_var (1), the package variable
// rs_pkg::pkg_var (2), the static property tally_c::total (3, §8.9), the
// member hi of the static unpacked structure pr (4, lo stays 0), the elements
// arr[2] (5) and, through relay, which passes its own ref static argument on
// to put, arr[3] (6), and the static variable kept of the automatic task
// keep_local (7), read by its hierarchical name (§6.21). One time unit later
// all the writes are seen, each in its own object.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support ref arguments, and the 5.052 release of Verilator does not
// support ref static ones.

package rs_pkg;
  int pkg_var;
endpackage

class tally_c;
  static int total;
endclass

module test_ref_static_accepted_actuals;
  typedef struct { int lo; int hi; } pair_t;
  int mod_var;
  pair_t pr;
  int arr[4];

  task automatic put(ref static int r, input int v);
    r <= v;
  endtask

  task automatic relay(ref static int r, input int v);
    put(r, v);
  endtask

  task automatic keep_local(input int v);
    static int kept;
    put(kept, v);
  endtask

  initial begin
    put(mod_var, 1);
    put(rs_pkg::pkg_var, 2);
    put(tally_c::total, 3);
    put(pr.hi, 4);
    put(arr[2], 5);
    relay(arr[3], 6);
    keep_local(7);
    $display("after calls: %0d %0d %0d %0d %0d %0d %0d", mod_var, rs_pkg::pkg_var,
             tally_c::total, pr.hi, arr[2], arr[3], keep_local.kept);
    #1;
    $display("mod_var=%0d pkg_var=%0d total=%0d pr=%0d,%0d arr=%0d,%0d,%0d,%0d kept=%0d",
             mod_var, rs_pkg::pkg_var, tally_c::total, pr.lo, pr.hi, arr[0], arr[1], arr[2],
             arr[3], keep_local.kept);
  end
endmodule
