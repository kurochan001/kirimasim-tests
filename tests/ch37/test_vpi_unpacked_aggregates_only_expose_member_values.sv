/*
:name: test_vpi_unpacked_aggregates_only_expose_member_values
:description: VPI value access distinguishes unpacked structures and unions from their readable members
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.26 38.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_unpacked_aggregates_only_expose_member_values.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^struct read error: [^\n]+)(?=[\s\S]*^struct write error: [^\n]+)(?=[\s\S]*^union read error: [^\n]+)(?=[\s\S]*^union write error: [^\n]+)[\s\S]*\Z
:vpi_c: @test_vpi_unpacked_aggregates_only_expose_member_values.c
*/
module test_vpi_unpacked_aggregates_only_expose_member_values;
  typedef struct {
    int reading;
    int status_code;
  } record_t;
  typedef union {
    int reading;
    int alternative;
  } storage_t;
  record_t record_value;
  storage_t storage_value;

  initial begin
    record_value.reading = 13;
    storage_value.reading = 29;
    $vt_check_aggregate(0);
    $vt_check_aggregate(1);
  end
endmodule
