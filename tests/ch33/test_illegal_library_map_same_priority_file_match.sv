/*
:name: test_illegal_library_map_same_priority_file_match
:description: A source file matching two libraries at the same path priority is illegal
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.3.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: ambiguity_config
:should_fail_because: two wildcard filenames assign the same source to different libraries
:expected_stderr_regex: ^error: '[^']*[/]choiceA\.sv': file matches multiple libraries \('firstLib' and 'secondLib'\)$
:files: libmap_ambiguity/conflicting.map libmap_ambiguity/resolved.map libmap_ambiguity/src/choiceA.sv
*/
module ambiguity_top;
  choice candidate();
endmodule

config ambiguity_config;
  design work.ambiguity_top;
  instance ambiguity_top.candidate use firstLib.choice;
endconfig
