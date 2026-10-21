/*
:name: test_array_reduction_element_type
:description: Array reduction methods in constraints compute in the element type when there is no with clause, so a sum wraps, and sum with a with clause, product, xor, and and or constrain the elements to single values (IEEE 1800-2023 Section 18.5.7.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.2 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_element_type.expected
*/
// IEEE 1800-2023 §18.5.7.2: in a constraint, an array reduction method
// (7.12.3) stands for its operator applied over all the elements, with a
// result of the element type, or of the type of the with expression when
// there is one. Each constraint here leaves a single solution:
// - a.sum() of two 4-bit elements is 4 bits wide, so with a[0] == 9 and a
//   sum of 1 the sum wraps and a[1] is 8 (as an int sum it could not be 1);
// - e.sum() with (int'(item == 7)) counts the elements equal to 7, and a
//   count of 4 makes all four of them 7;
// - c.product() == 30 with ascending elements in [2:5] gives 2, 3 and 5;
// - b.xor() == 'hFF with b[0] == 'h0F and b[1] == 'hF0 gives b[2] == 0;
// - d.and() and d.or() both 4'b0001 make every element 4'b0001.

class are_obj;
  rand bit [3:0] a[2];
  rand bit [3:0] e[4];
  rand int c[3];
  rand bit [7:0] b[3];
  rand bit [3:0] d[3];
  constraint c_a { a[0] == 4'd9; a.sum() == 4'd1; }
  constraint c_e { e.sum() with (int'(item == 4'd7)) == 4; }
  constraint c_c {
    foreach (c[i]) c[i] inside {[2:5]};
    c[0] < c[1]; c[1] < c[2];
    c.product() == 30;
  }
  constraint c_b { b[0] == 8'h0F; b[1] == 8'hF0; b.xor() == 8'hFF; }
  constraint c_d { d.and() == 4'b0001; d.or() == 4'b0001; }
endclass

module test_array_reduction_element_type;
  are_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d", ok);
    $display("sum wraps in 4 bits: a[1]=%0d", o.a[1]);
    $display("sum with: e = %0d %0d %0d %0d", o.e[0], o.e[1], o.e[2], o.e[3]);
    $display("product: c = %0d %0d %0d", o.c[0], o.c[1], o.c[2]);
    $display("xor: b[2]=%0h", o.b[2]);
    $display("and, or: d = %b %b %b", o.d[0], o.d[1], o.d[2]);
  end
endmodule
