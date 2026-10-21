/*
:name: test_disable_soft_direct_reference
:description: disable soft in a constraint block drops the lower-priority soft constraints in which the variable, or the size of an array, appears, keeps those that do not name it, and keeps the soft constraints of higher priority (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.2 18.5.13.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_soft_direct_reference.expected
*/
// IEEE 1800-2023 §18.5.13.2: disable soft x drops every soft constraint of
// lower priority in which x itself appears, whether or not it contradicts
// another one; soft constraints that only reach x through other variables
// stay, and so do the soft constraints of higher priority (18.5.13.1: a later
// block has higher priority). disable soft can also name the size of an
// array, written a.size or a.size() (the parentheses are optional, A.1.9).
// Here c3 drops soft x == y and soft a.size() == n of c2, but not soft y == 7
// and soft n == 5 of c1, and c4 comes after c3. So x is 2, y 7, a.size() 3
// and n 5. If c2 were kept, c4 and c2 would make y == 2 and n == 3, and the
// lowest constraints, of c1, would be the ones dropped.
// In Verilator 5.052, disable soft drops every soft constraint of lower
// priority, also soft y == 7 and soft n == 5, which do not name x or a.size.

class dsd_obj;
  rand int x, y, n;
  rand byte a[];
  constraint c1 { soft y == 7; soft n == 5; }
  constraint c2 { soft x == y; soft a.size() == n; }
  constraint c3 { disable soft x; disable soft a.size; }
  constraint c4 { soft x == 2; soft a.size() == 3; }
endclass

module test_disable_soft_direct_reference;
  dsd_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d x=%0d y=%0d size=%0d n=%0d", ok, o.x, o.y, o.a.size(), o.n);
  end
endmodule
