/*
:name: test_rand_mode_array_element
:description: rand_mode() with an index turns randomization off for one element of a rand unpacked array, which keeps its value, rand_mode() as a function reports the state of one element, and the rand_mode of a static rand property is shared by all instances (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.8 18.4 8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_mode_array_element.expected
*/
// IEEE 1800-2023 §18.8: for a rand unpacked array, rand_mode() on one element
// selected by an index changes only that element; without the index it
// changes all of them. Called as a function, rand_mode() returns 1 while a
// variable is active and 0 when it is not, and needs a single element of an
// array. The rand_mode of a static rand property is static as well, so turning
// it off through one instance turns it off for the other one. Each element
// that stays random has one value its constraint allows, and an inactive one
// keeps the value written to it.

class test_rand_mode_array_element_c;
  rand int a[3];
  static rand int s;
  constraint fix { foreach (a[i]) if (i != 1) a[i] == i + 10; s == 5; }
endclass

module test_rand_mode_array_element;
  test_rand_mode_array_element_c p = new, q = new;
  int ok;

  initial begin
    p.a = '{0, 99, 0};
    p.a[1].rand_mode(0);
    ok = p.randomize();
    $display("ok=%0d a=%0d,%0d,%0d", ok, p.a[0], p.a[1], p.a[2]);
    $display("modes=%0d%0d%0d", p.a[0].rand_mode(), p.a[1].rand_mode(), p.a[2].rand_mode());
    p.a.rand_mode(0);
    $display("modes after a.rand_mode(0)=%0d%0d%0d",
             p.a[0].rand_mode(), p.a[1].rand_mode(), p.a[2].rand_mode());
    q.s.rand_mode(0);
    $display("static s through p=%0d", p.s.rand_mode());
  end
endmodule
