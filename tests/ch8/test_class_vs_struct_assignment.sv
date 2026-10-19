/*
:name: test_class_vs_struct_assignment
:description: Assigning a class handle shares one object, while assigning a structure copies its value (IEEE 1800-2023 Section 8.28)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.28 8.12 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_vs_struct_assignment.expected
*/
// IEEE 1800-2023 §8.28: a structure is a value and a class variable holds a
// handle to an object. Assigning one structure variable to another copies the
// members (7.2), so later changes do not affect the copy. Assigning one class
// handle to another makes both refer to the same object (8.12), so a change
// through either is seen through both, while new with a handle argument makes a
// separate shallow copy.

typedef struct {
  int a;
  int b;
} pair_s;

class pair_c;
  int a;
  int b;
endclass

module test_class_vs_struct_assignment;
  pair_s s1, s2;
  pair_c c1, c2, c3;

  initial begin
    s1.a = 1; s1.b = 2;
    s2 = s1;
    s1.a = 10;
    $display("struct: s1.a=%0d s2.a=%0d", s1.a, s2.a);
    c1 = new;
    c1.a = 1; c1.b = 2;
    c2 = c1;
    c3 = new c1;
    c1.a = 10;
    $display("class: c1.a=%0d c2.a=%0d copy c3.a=%0d", c1.a, c2.a, c3.a);
    $display("same object: c1==c2 %0d, c1==c3 %0d", c1 == c2, c1 == c3);
  end
endmodule
