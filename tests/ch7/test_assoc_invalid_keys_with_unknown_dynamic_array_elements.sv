/*
:name: test_assoc_invalid_keys_with_unknown_dynamic_array_elements
:description: Unknown bits inside a dynamic array nested in an associative key cannot identify or create an entry
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5 7.8.6 7.9.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_invalid_keys_with_unknown_dynamic_array_elements.expected
*/
module test_assoc_invalid_keys_with_unknown_dynamic_array_elements;
  typedef logic [3:0] sample_t;
  typedef struct {
    string name;
    sample_t samples[];
  } key_t;
  logic [15:0] entries[key_t];
  key_t reference_key, known_copy, bad_x, bad_z, other;
  logic [15:0] value_x, value_z;

  initial begin
    reference_key.name = "bank";
    reference_key.samples = '{4'b1011, 4'b0010, 4'b0100};
    known_copy = reference_key;
    bad_x = reference_key;
    bad_z = reference_key;
    other = reference_key;
    bad_x.samples[1] = 4'bx010;
    bad_z.samples[2] = 4'b010z;
    other.samples[2] = 4'b0101;
    entries[reference_key] = 16'h8193;
    entries[other] = 16'h6274;
    value_x = entries[bad_x];
    value_z = entries[bad_z];
    entries[bad_x] = 16'ha1b2;
    entries[bad_z] = 16'hc3d4;
    $display("invalid=%h/%h exists=%0d/%0d size=%0d",
             value_x, value_z, entries.exists(bad_x), entries.exists(bad_z), entries.num());
    $display("known=%h/%h preserved_source=%b/%b", entries[known_copy], entries[other],
             reference_key.samples[1], reference_key.samples[2]);
    $finish(0);
  end
endmodule
