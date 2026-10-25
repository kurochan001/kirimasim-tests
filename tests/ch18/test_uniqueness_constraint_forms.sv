/*
:name: test_uniqueness_constraint_forms
:description: A uniqueness constraint takes a range list of singular variables and of an array variable, and randomization then gives each its own value: three int variables in 0:2 are a permutation and the three elements of a fixed array in 0:2 differ too (IEEE 1800-2023 Sections 18.5.4 and 18.5 and footnote 13 of A.10)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.4 18.5 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uniqueness_constraint_forms.expected
*/
// IEEE 1800-2023 footnote 13 of A.10: the range list of a uniqueness
// constraint holds only expressions that denote singular or array variables,
// as §18.5.4 describes. §18.5: the constraint of the class takes part in
// randomize, and unique {a, b, c} makes the three singular variables differ
// while unique {arr} makes the elements of the array differ.
//
// The three variables a, b and c are inside 0:2, so the only assignment that
// keeps them different is a permutation of 0, 1 and 2, and each of the three
// comparisons prints 1. The elements of arr are also inside 0:2 under unique
// {arr}, so all three of their comparisons print 1, and randomize returns 1.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 carries out a uniqueness
// constraint, so this expected output follows the standard.

module test_uniqueness_constraint_forms;
  class u;
    int a, b, c;
    int arr [3];

    constraint cu {
      unique {a, b, c};
      a inside {[0:2]};
      b inside {[0:2]};
      c inside {[0:2]};
    }

    constraint cv {
      unique {arr};
      arr[0] inside {[0:2]};
      arr[1] inside {[0:2]};
      arr[2] inside {[0:2]};
    }
  endclass

  u o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok %0d", ok);
    $display("uniq %0d %0d %0d", o.a != o.b, o.b != o.c, o.a != o.c);
    $display("arr %0d %0d %0d", o.arr[0] != o.arr[1], o.arr[1] != o.arr[2],
             o.arr[0] != o.arr[2]);
  end
endmodule
