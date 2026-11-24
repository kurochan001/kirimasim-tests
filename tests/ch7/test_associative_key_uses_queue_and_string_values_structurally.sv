/*
:name: test_associative_key_uses_queue_and_string_values_structurally
:description: A user-defined associative key compares variable-length queue and string contents
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5 7.10 11.4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_key_uses_queue_and_string_values_structurally.expected
*/
module test_associative_key_uses_queue_and_string_values_structurally;
  typedef struct {
    string label_text;
    byte samples[$];
  } assay_key;
  int data[assay_key];

  initial begin
    assay_key first, copied, shorter, other_label;
    first.label_text = "sensor";
    first.samples = {8'd2, 8'd4};
    copied.label_text = {"sen", "sor"};
    copied.samples.push_back(8'd2);
    copied.samples.push_back(8'd4);
    shorter = copied;
    shorter.samples.delete(1);
    other_label = copied;
    other_label.label_text = "spare";
    data[first] = 81;
    data[shorter] = 33;
    data[other_label] = 66;
    data[copied]++;
    first.samples[0] = 9;
    $display("keys=%0d same=%0d short=%0d other=%0d mutated=%b",
             data.num(), data[copied], data[shorter], data[other_label], data.exists(first));
  end
endmodule
