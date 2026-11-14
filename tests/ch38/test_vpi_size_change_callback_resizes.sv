/*
:name: test_vpi_size_change_callback_resizes
:description: A cbSizeChange callback comes after each change of the size of a dynamic array, an associative array, a queue and a string, growing or shrinking, with the new size as its value and as vpiSize, and not when an element changes without a change of size (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_size_change_callback_resizes.c
:expected_stdout: @test_vpi_size_change_callback_resizes.expected
*/
// IEEE 1800-2023 §38.36.1: a cbSizeChange callback occurs after a dynamic
// array, an associative array, a queue or a string has been resized.
// §37.17 (details 9 and 14): the value passed to the callback is the new
// size, and vpiSize of an array is its number of elements and of a string
// its number of characters.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application places a cbSizeChange callback with
// vpiSimTime and vpiIntVal on each of da, aa, q and s. From 10 on, one
// statement runs in each time unit: da gets 3 elements, then one element is
// written, then da grows to 5; aa gets the key 4, the key 4 again, the key 9,
// and loses the key 4; q gets an element, the element is written, and q
// loses it; s gets "abc" and then "abcde". Each callback prints the time,
// the object, the value it received and vpiSize of the object; the element
// writes at 11, 14 and 18 change no size. The release 13.0 of Icarus Verilog
// has no cbSizeChange in its headers and does not compile the associative
// array, and the 5.054 release of Verilator gives no handle for the dynamic
// array, so the expected output follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_size_change_callback_resizes;
  int da [];
  int aa [int];
  int q [$];
  string s;

  initial begin
    #10 da = new[3];
    #1 da[1] = 7;
    #1 da = new[5] (da);
    #1 aa[4] = 1;
    #1 aa[4] = 2;
    #1 aa[9] = 3;
    #1 aa.delete(4);
    #1 q.push_back(1);
    #1 q[0] = 5;
    #1 void'(q.pop_front());
    #1 s = "abc";
    #1 s = "abcde";
    #1 $finish;
  end
endmodule
