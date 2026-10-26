/*
:name: test_array_reduction_with_size
:description: With a size constraint and an array reduction constraint on the same random dynamic array, the size is solved first and the reduction is then applied over the resized array (IEEE 1800-2023 Section 18.5.7.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.2 18.5.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_with_size.expected
*/
// IEEE 1800-2023 §18.5.7.2: an array reduction method in a constraint is an
// expression iterated over the elements, and when the same array also has a
// size constraint the size is solved first. Array a starts empty and must
// grow to four elements whose bytes sum to 260, which no sum over zero
// elements can satisfy, so every successful call proves that the size was
// solved before the reduction. Queue q has 2 to 4 elements that sum to 10.
// In Verilator 5.052 a reduction method in a constraint is not supported,
// so every call fails.

class ar_obj;
  rand bit [7:0] a[];
  constraint c_size { a.size == 4; }
  constraint c_sum { a.sum() with (int'(item)) == 260; }
endclass

class aq_obj;
  rand int q[];
  constraint c_size { q.size inside {[2:4]}; }
  constraint c_sum { q.sum() == 10; }
endclass

module test_array_reduction_with_size;
  ar_obj oa = new;
  aq_obj oq = new;
  int afail, qfail;

  initial begin
    afail = 0;
    repeat (200) begin
      if (!oa.randomize()) afail++;
      else if (oa.a.size() != 4) afail++;
      else if (oa.a.sum() with (int'(item)) != 260) afail++;
    end
    $display("dynamic array: failures %0d", afail);
    qfail = 0;
    repeat (200) begin
      if (!oq.randomize()) qfail++;
      else if (oq.q.size() < 2 || oq.q.size() > 4) qfail++;
      else if (oq.q.sum() != 10) qfail++;
    end
    $display("queue: failures %0d", qfail);
  end
endmodule
