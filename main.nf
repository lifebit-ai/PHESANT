#!/usr/bin/env nextflow



/*
 * Check all required inputs
 */

// Check if user provided phenofile
if (!params.phenofile) exit 1, "Phenofile was not specified. Please provide it with the option: --phenofile [file]."

// Check if user provided traitofinterestfile
if (!params.traitofinterestfile) exit 1, "Traitofinterestfile was not specified. Please provide it with the option: --traitofinterestfile [file]."

// Check if user provided variablelistfile
if (!params.phenofile) exit 1, "Variablelistfile was not specified. Please provide it with the option: --variablelistfile [file]."

// Check if user provided datacodingfile
if (!params.phenofile) exit 1, "Datacodingfile was not specified. Please provide it with the option: --datacodingfile [file]."

// Check if user provided traitofinterest
if (!params.traitofinterest) exit 1, "Trait of interest was not specified. Please provide it with the option: --traitofinterest [string]."


Channel.fromPath(params.phenofile)
    .ifEmpty { exit 1, "Phenotypes csv file not found: ${params.phenofile}" }
    .set { pheno }
Channel.fromPath(params.traitofinterestfile)
    .ifEmpty { exit 1, "Trait of interest csv file not found: ${params.traitofinterestfile}" }
    .set { traitfile }
Channel.fromPath(params.variablelistfile)
    .ifEmpty { exit 1, "Variable list tsv file not found: ${params.variablelistfile}" }
    .into { variablelist; variablelist_processing }
Channel.fromPath(params.datacodingfile)
    .ifEmpty { exit 1, "Data coding txt file not found: ${params.datacodingfile}" }
    .set { datacoding }


process phenomeScan {
    publishDir "${params.resDir}/phenomeScan", mode: 'copy'

    input:
    file pheno from pheno
    file traitfile from traitfile
    file variablelist from variablelist
    file datacoding from datacoding

    output:
    file('*') into results

    script:
    """
    mkdir ./results
    
    phenomeScan.r \
    --phenofile=${pheno} \
    --traitofinterestfile=${traitfile} \
    --variablelistfile=${variablelist} \
    --datacodingfile=${datacoding} \
    --traitofinterest=${params.traitofinterest} \
    --resDir="./" \
    --userId=${params.userId}
    """
}

process resultsProcessing {
    publishDir "${params.resDir}", mode: 'copy'

    input:
    file results from results
    file variablelist from variablelist_processing

    output:
    file('*') into resultsProcessing

    script:
    """
    mainCombineResults.r \
    --resDir="./" \
    --variablelistfile="$variablelist" 
    """
}

process visualisations {
    publishDir "${params.resDir}/Visualisations", mode: 'copy'

    container 'lifebitai/vizjson:latest'

    input:
    file plots from resultsProcessing

    output:
    file '.report.json' into viz

    script:
    """
    for image in \$(ls *png); do
        prefix="\${image%.*}"

        if [[ \$prefix == "forest-binary" ]]; then
            title="Forest Binary"
        elif [ \$prefix == "forest-continuous" ]; then
            title="Forest Continuous"
        elif [ \$prefix == "forest-ordered-logistic" ]; then
            title="Forest Ordered Logistic"
        elif [ \$prefix == "qqplot" ]; then
            title="QQ Plot"
        fi

        img2json.py "${params.resDir}/\$image" "\$title" \${prefix}.json
    done
    
    table=\$(ls *.txt)
    prefix=\${table%.*}
    tsv2csv.py < \${prefix}.txt > \${prefix}.csv
    csv2json.py \${prefix}.csv "Combined Results" 'results-combined.json'
    
    combine_reports.py .
    """
}