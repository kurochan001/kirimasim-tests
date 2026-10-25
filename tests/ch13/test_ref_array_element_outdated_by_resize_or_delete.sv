/*
:name: test_ref_array_element_outdated_by_resize_or_delete
:description: An array element passed by reference becomes an outdated reference when its dynamic array is resized with new[] or by assignment or is deleted, or when its associative array entry is deleted; the task still reads the element, but its later writes are not seen by the caller (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_array_element_outdated_by_resize_or_delete.expected
*/
// IEEE 1800-2023 §13.5.2: an element of a dynamic or associative array that
// is passed by reference keeps existing for the called subroutine until it
// completes, but once the array is resized with an implicit or explicit
// new[], or deleted with delete(), or the referenced associative entry is
// deleted, the reference is outdated: changes made through it afterwards
// are not visible outside the subroutine.
//
// hold(e) writes 10 through the reference at time 0, which the caller sees
// at time 1. At time 1 the caller changes the array; at time 2 hold reads
// e, which still has 10, and writes 20, which the caller does not see. The
// four phases change the array by d = new[5](d) (the copy keeps 10), by
// assigning a 4-element array (d[1] becomes 42), by d.delete() followed by
// d = new[3] (d[1] becomes 0), and by aa.delete(5) followed by aa[5] = 7.
//
// Simulator notes: Icarus Verilog 13.0 rejects the design (no ref formals,
// no associative array with an int index here). Verilator 5.052 does not
// accept an associative array element as a ref actual, and without that
// phase it keeps the reference attached to the resized or new array: the
// task reads 42 and 0 there and its write of 20 shows up in d[1].

`timescale 1ns/1ns

module test_ref_array_element_outdated_by_resize_or_delete;
  int d [];
  int other [];
  int aa [int];
  int seen;

  task automatic hold(ref int e, output int read_back);
    e = 10;
    #2;
    read_back = e;
    e = 20;
    #1;
  endtask

  initial begin
    d = new[3];
    fork
      hold(d[1], seen);
      begin
        #1 $display("new[5](d): at 1 d[1]=%0d", d[1]);
        d = new[5](d);
      end
    join
    $display("new[5](d): after the task size=%0d d[1]=%0d, task read %0d", d.size(), d[1], seen);

    d = new[3];
    other = new[4];
    other[1] = 42;
    fork
      hold(d[1], seen);
      begin
        #1 $display("assignment: at 1 d[1]=%0d", d[1]);
        d = other;
      end
    join
    $display("assignment: after the task size=%0d d[1]=%0d, task read %0d", d.size(), d[1], seen);

    d = new[3];
    fork
      hold(d[1], seen);
      begin
        #1 $display("delete(): at 1 d[1]=%0d", d[1]);
        d.delete();
        d = new[3];
      end
    join
    $display("delete(): after the task size=%0d d[1]=%0d, task read %0d", d.size(), d[1], seen);

    aa[5] = 1;
    fork
      hold(aa[5], seen);
      begin
        #1 $display("assoc delete(5): at 1 aa[5]=%0d", aa[5]);
        aa.delete(5);
        aa[5] = 7;
      end
    join
    $display("assoc delete(5): after the task aa[5]=%0d, task read %0d", aa[5], seen);
  end
endmodule
