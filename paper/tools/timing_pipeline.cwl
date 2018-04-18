cwlVersion: v1.0
class: Workflow


requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
inputs:
  guide_count: int
  allowed_mismatches: int
  iteration: int
  
outputs:
  outputcasoff: 
    type: File
    outputSource: casoff/outputerror
  outputflashfry: 
    type: File
    outputSource: flashfry/outputerror
  outputcrisprseek: 
    type: File
    outputSource: crisprseek/outputerror

steps:
  random_guides:
    run: flashfry_random.cwl
    in:
      count: guide_count
      iter: iteration
      output_fasta:
        valueFrom: $("flashfry" + inputs.count + "_i" + inputs.iter + ".fasta")
      random_count: guide_count
    out: [output]

  crisprseek:
    run: crisprseek.cwl
    in:
      count: guide_count
      fasta: random_guides/output
      mismatches: allowed_mismatches
      iter: iteration
      outputFilename:
        valueFrom: $("crisprSeek" + inputs.count + "_i" + inputs.iter + ".output")
      std_out: 
        valueFrom: $("crisprSeek" + inputs.count + "_i" + inputs.iter +  ".stdout")
      std_err: 
        valueFrom: $("crisprSeek" + inputs.count + "_i" + inputs.iter + ".stderr")
    out: [outcalls,stdoutput,outputerror]

  flashfry:
    run: flashfry_off_target.cwl
    in:
      count: guide_count
      fasta: random_guides/output
      mismatches: allowed_mismatches
      iter: iteration
      output_scores: 
        valueFrom: $("flashfry" + inputs.count + "_i" + inputs.iter + ".output")
      std_out: 
        valueFrom: $("flashfry" + inputs.count + "_i" + inputs.iter + ".stdout")
      std_err: 
        valueFrom: $("flashfry" + inputs.count + "_i" + inputs.iter + ".stderr")
    out: [outputscores,output,outputerror]

  casoffPrep:
    run: convert_to_cas_off_finder.cwl
    in:
      mismatches: allowed_mismatches
      fasta: random_guides/output
      iter: iteration
      casFile:  
        valueFrom: $("casoff" + inputs.count + "_i" + inputs.iter + ".input")
      mismatches: guide_count
    out: [output]

  casoff:
    run: cas-off.cwl
    in:
      count: guide_count
      input: casoffPrep/output
      iter: iteration
      output_ots:  
        valueFrom: $("casoff" + inputs.count + "_i" + inputs.iter +  ".output")
      std_out:  
        valueFrom: $("casoff" + inputs.count + "_i" + inputs.iter + ".stdout")
      std_err:  
        valueFrom: $("casoff" + inputs.count + "_i" + inputs.iter + ".stderr")
    out: [stdoutput,outputerror,outcalls]
