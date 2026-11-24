/*
:name: test_assoc_packed_struct_key_xz_cannot_alias_valid_entries
:description: An associative key with unknown bits in either nested field cannot create or overwrite an entry
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5 7.8.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_packed_struct_key_xz_cannot_alias_valid_entries.expected
*/
module test_assoc_packed_struct_key_xz_cannot_alias_valid_entries;
  typedef struct packed {
    logic [1:0] mode;
    logic valid;
  } payload_t;
  typedef struct packed {
    bit bank;
    payload_t payload;
  } key_t;

  int entries[key_t];
  key_t known, bad_x, bad_z;

  initial begin
    known = 4'b1101;
    bad_x = 4'b11x1;
    bad_z = 4'b110z;
    entries[known] = 37;
    entries[bad_x] = 61;
    entries[bad_z] = 79;
    $display("keys=%0d known=%0d x=%0d z=%0d",
             entries.num(), entries[known], entries.exists(bad_x), entries.exists(bad_z));
  end
endmodule
