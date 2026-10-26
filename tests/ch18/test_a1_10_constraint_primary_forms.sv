/*
:name: test_a1_10_constraint_primary_forms
:description: A constraint primary written with the implicit class handle this, with a class scope, and with the parenthesized array method size() restricts the random values it names, and randomize() returns values that satisfy the constraints (IEEE 1800-2023 Sections 18.5 and 18.5.1, A.1.10 and A.10)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5 18.5.1 A.1.10 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a1_10_constraint_primary_forms.expected
*/
// IEEE 1800-2023 A.1.10: a constraint primary is an optional implicit class
// handle (this) or class scope, a hierarchical identifier and a select.
// Clarification 12: parentheses in a constraint primary are allowed only when
// the primary is an array built-in method such as size().
//
// holder has the static constant LIMIT, the fixed array arr, the dynamic array
// dyn of four elements and the random variable a. One constraint primary reads
// this.a and holder::LIMIT, another calls dyn.size(). The print shows that a
// satisfies 0 <= a <= LIMIT, that dyn still has four elements, and that arr[2]
// is the initialized 3; the values of a itself are not printed because the
// constraints leave them open.

`timescale 1ns/1ns
module test_a1_10_constraint_primary_forms;
  class holder;
    static const int LIMIT = 5;
    int arr [4] = '{1, 2, 3, 4};
    int dyn [];
    rand int a;

    function new();
      dyn = new [4];
      foreach (dyn[i]) dyn[i] = i;
    endfunction

    constraint c_this {
      this.a >= 0;
      this.a <= holder::LIMIT;
    }

    constraint c_size {
      dyn.size() == 4;
    }
  endclass

  holder h;

  initial begin
    h = new;
    if (h.randomize() == 1) begin
      $display("a in range %0d", h.a >= 0 && h.a <= holder::LIMIT);
      $display("size %0d %0d", h.dyn.size(), h.arr[2]);
    end else begin
      $display("randomize failed");
    end
  end
endmodule
