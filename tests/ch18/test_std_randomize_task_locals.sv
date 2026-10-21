/*
:name: test_std_randomize_task_locals
:description: std::randomize() with constraints, called in a task, randomizes the local variables, the module variable and the array it lists, while the task argument and the variables it does not list are state variables (IEEE 1800-2023 Section 18.12.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12.1 18.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_randomize_task_locals.expected
*/
// IEEE 1800-2023 §18.12.1: std::randomize(...) with { ... } makes its
// arguments the random variables and every other variable of the
// constraints a state variable. In the task fill, the argument cap (30) is a
// state variable. The first loop randomizes the three locals step, first and
// last, which every result must relate as the constraints say. The second
// loop lists only last: first and step, set to 7 and 5, keep their values
// and are used as constants, so last is 7 + 5 + 30 = 42 every time. An
// argument can also be a variable of the module (total) or an unpacked
// array (marks), whose elements the foreach constraint fixes (18.12:
// std::randomize works on the variables of the current scope).

module test_std_randomize_task_locals;
  int total;
  int marks[4];

  task automatic fill(int cap);
    int step, first, last;
    int ok;
    int bad = 0;
    repeat (30) begin
      ok = std::randomize(step, first, last) with {
        step inside {[2:9]}; first inside {[0:20]}; last == first + step * 3; last <= cap;
      };
      if (ok != 1 || !(step inside {[2:9]}) || !(first inside {[0:20]})
          || last != first + step * 3 || last > cap) bad++;
    end
    first = 7;
    step = 5;
    repeat (30) begin
      ok = std::randomize(last) with { last == first + step + cap; };
      if (ok != 1 || first != 7 || step != 5 || last != 42) bad++;
    end
    $display("cap=%0d, 60 calls: violations=%0d first=%0d step=%0d last=%0d",
             cap, bad, first, step, last);
    ok = std::randomize(total, step) with { step == cap / 5; total == step * 2; };
    $display("module variable: ok=%0d total=%0d step=%0d", ok, total, step);
    ok = std::randomize(marks) with { foreach (marks[i]) marks[i] == cap - i; };
    $display("array: ok=%0d marks = %0d %0d %0d %0d", ok, marks[0], marks[1], marks[2], marks[3]);
  endtask

  initial fill(30);
endmodule
