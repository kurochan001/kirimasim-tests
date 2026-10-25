/*
:name: test_svdpi_h_user_data
:description: svPutUserData stores a user pointer for a scope and a key and returns 0, returns -1 for a NULL scope or a NULL pointer, svGetUserData gives the stored pointer back and NULL for a key that was never stored, for a NULL scope and for the key of a call that failed (IEEE 1800-2023 Section 35.3.2, I.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_user_data.c
:expected_stdout: @test_svdpi_h_user_data.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.9.3: svPutUserData stores the userData pointer for a scope and a
// userKey that the user keeps unique, returns -1 for every error case and 0
// when it stored the pointer; a NULL scope and a NULL userData pointer are
// errors. svGetUserData returns the pointer that was stored for the same
// scope and key, and NULL for every error case and when no call of
// svPutUserData for that scope and key was made before.
//
// The import is called twice, by two instances of dpi_data_unit, at 1 and 2
// time units, so the lines of the two calls follow each other in a fixed
// order. c_data stores the value of its instance under a first key, reads it
// back, reads a second key that was never stored, tries svPutUserData with a
// NULL scope and with a NULL data pointer under a third key, and reads that
// third key, which the two failing calls must not have stored. Each line
// prints the result the routine gives and, for the stored pointer, the int
// behind it.

module dpi_data_unit #(parameter int VALUE = 0, parameter int DELAY = 0) ();
  import "DPI-C" context function void c_data(input int value);

  initial #(DELAY) c_data(VALUE);
endmodule

module test_svdpi_h_user_data;
  dpi_data_unit #(.VALUE(42), .DELAY(1)) u1();
  dpi_data_unit #(.VALUE(7), .DELAY(2)) u2();
endmodule
