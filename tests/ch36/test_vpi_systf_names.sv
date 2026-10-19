/*
:name: test_vpi_systf_names
:description: User-defined system task names may contain letters, digits, underscores and dollar signs, are case sensitive, and keep all their characters significant (IEEE 1800-2023 Section 36.3)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3 36.3.1 38.37.1 5.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_names.c
:expected_stdout: @test_vpi_systf_names.expected
*/
// IEEE 1800-2023 §36.3: after its first character, $, the name of a
// user-defined system task may have letters, digits, underscores and further
// dollar signs (also 5.6.3); case matters, and every character is significant.
// §36.3.1, §38.37.1: the names are defined by registering them with
// vpi_register_systf. The application registers six tasks: two names that
// differ only in case, one with dollar signs inside, one with digits, and two
// 72-character names that differ only in their last character. Each task
// prints the name it was registered under, passed as its user_data.

module test_vpi_systf_names;
  initial begin
    $vt_Case;
    $vt_case;
    $vt_dollar$in$name;
    $vt_digits_0123456789;
    $vt_a_long_name_that_goes_on_well_past_the_usual_length_of_identifiers_x;
    $vt_a_long_name_that_goes_on_well_past_the_usual_length_of_identifiers_y;
  end
endmodule
