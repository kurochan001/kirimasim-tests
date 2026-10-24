/*
:name: test_class_handle_default_null_and_case_equality
:description: class handles and chandles start as null, and === and !== on class handles give the same results as == and != for the same object, a different object with equal contents and null (IEEE 1800-2023 Section 8.4)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 6.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_handle_default_null_and_case_equality.expected
*/
// IEEE 1800-2023 §8.4: an uninitialized object handle is null, as is a chandle
// (Table 8-1, §6.14), which comparison with null shows. Handles can be
// compared with == and != and with === and !==, which have the same semantics:
// two handles are equal when they refer to the same object, so two objects
// with equal property values are not equal, and a handle equals null only
// when it is null.
// Icarus Verilog 13.0 does not support chandle variables.

module test_class_handle_default_null_and_case_equality;
  class pkt_c;
    int v;
  endclass

  pkt_c h1, h2, h3, n1, n2;
  chandle ch;

  initial begin
    $display("defaults: h1==null=%0d h1===null=%0d ch==null=%0d n1===n2=%0d",
             h1 == null, h1 === null, ch == null, n1 === n2);
    h1 = new;
    h2 = new;
    h3 = h1;
    h1.v = 5;
    h2.v = 5;
    $display("same object: == %0d === %0d != %0d !== %0d", h1 == h3, h1 === h3, h1 != h3,
             h1 !== h3);
    $display("other object, same contents: == %0d === %0d != %0d !== %0d", h1 == h2,
             h1 === h2, h1 != h2, h1 !== h2);
    $display("object and null: == %0d === %0d != %0d !== %0d", h1 == null, h1 === null,
             h1 != null, h1 !== null);
  end
endmodule
