/*
:name: test_class_array_property_nonzero_range
:description: A fixed-size array property of a class with a range that does not start at 0 keeps every element (IEEE 1800-2023 Section 7.4.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 7.4.5 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_array_property_nonzero_range.expected
*/
// IEEE 1800-2023 §8.3: a class property can be a fixed-size unpacked array,
// declared with any range. §7.4.5: its elements are selected by the declared
// indices, so int v[5:6] has the elements 5 and 6, and int v[1:2] the
// elements 1 and 2, as for an array declared in a module. The query
// functions of 20.7 report the declared bounds.

class c56;
  int v[5:6];
endclass

class c12;
  int v[1:2];
endclass

module test_class_array_property_nonzero_range;
  c56 a;
  c12 b;
  int m[5:6];

  initial begin
    a = new;
    b = new;
    a.v[5] = 17;
    a.v[6] = 23;
    b.v[1] = 31;
    b.v[2] = 37;
    m[5] = 41;
    m[6] = 43;
    $display("class [5:6]: %0d %0d, $left=%0d $right=%0d", a.v[5], a.v[6], $left(a.v),
             $right(a.v));
    $display("class [1:2]: %0d %0d", b.v[1], b.v[2]);
    $display("module [5:6]: %0d %0d", m[5], m[6]);
  end
endmodule
