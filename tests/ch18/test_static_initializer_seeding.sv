/*
:name: test_static_initializer_seeding
:description: Static initializers and static processes take their seeds from the initialization RNG of their module instance, so two static objects and two initial processes get different streams (IEEE 1800-2023 Section 18.14.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14.1 18.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_initializer_seeding.expected
*/
// IEEE 1800-2023 §18.14.1: each module instance has one initialization RNG.
// A class object created by a static declaration initializer and a static
// process are both seeded with the next value of that RNG, so the four first
// values of the test (two static objects and two initial blocks) come from
// four successive seeds and differ from each other. The default seed itself
// is implementation dependent and is not printed.

class si_obj;
  rand bit [31:0] v;
endclass

module test_static_initializer_seeding;
  si_obj so1 = new;
  si_obj so2 = new;
  bit [31:0] p1, p2, v1, v2;

  initial begin : first_process
    p1 = $urandom;
  end

  initial begin : second_process
    p2 = $urandom;
  end

  initial begin
    #1;
    void'(so1.randomize());
    v1 = so1.v;
    void'(so2.randomize());
    v2 = so2.v;
    $display("static objects differ %0d", v1 != v2);
    $display("static processes differ %0d", p1 != p2);
    $display("all four streams differ %0d",
             v1 != p1 && v1 != p2 && v2 != p1 && v2 != p2 && v1 != v2 && p1 != p2);
  end
endmodule
