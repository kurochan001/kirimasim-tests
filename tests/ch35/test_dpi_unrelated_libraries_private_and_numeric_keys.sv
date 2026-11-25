/*
:name: test_dpi_unrelated_libraries_private_and_numeric_keys
:description: Independent C and C++ libraries keep address keys private and share the same numeric key
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.3 J.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: dpi_user_keys/library_b.cpp
:dpi_c: @dpi_user_keys/library_a.c
:expected_stdout: @test_dpi_unrelated_libraries_private_and_numeric_keys.expected
*/
module test_dpi_unrelated_libraries_private_and_numeric_keys;
  import "DPI-C" context function int user_keys_a_put(input int slot);
  import "DPI-C" context function int user_keys_b_put(input int slot);
  import "DPI-C" context function int user_keys_a_private();
  import "DPI-C" context function int user_keys_b_private();
  import "DPI-C" context function int user_keys_a_numeric();
  import "DPI-C" context function int user_keys_b_numeric();

  initial begin
    $display("keys A put=%0d", user_keys_a_put(0));
    $display("keys before private=%0d,%0d B numeric=%0d",
             user_keys_a_private(), user_keys_b_private(), user_keys_b_numeric());
    $display("keys B put=%0d", user_keys_b_put(0));
    $display("keys after private=%0d,%0d numeric=%0d,%0d",
             user_keys_a_private(), user_keys_b_private(),
             user_keys_a_numeric(), user_keys_b_numeric());
  end
endmodule
