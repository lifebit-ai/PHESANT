#!/usr/bin/env nextflow

Channel.fromPath(params.pheno)
    .ifEmpty { exit 1, "Phenotypes csv file not found: ${params.pheno}" }
    .set { pheno }
Channel.fromPath(params.traitfile)
    .ifEmpty { exit 1, "Trait of interest csv file not found: ${params.traitfile}" }
    .set { traitfile }
Channel.fromPath(params.variablelist)
    .ifEmpty { exit 1, "Variable list tsv file not found: ${params.variablelist}" }
    .into { variablelist; variablelist_processing }
Channel.fromPath(params.datacoding)
    .ifEmpty { exit 1, "Data coding txt file not found: ${params.datacoding}" }
    .set { datacoding }


process phenomeScan {
    publishDir "${params.outdir}/phenomeScan", mode: 'copy'

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
    --traitofinterest=${params.traitcol} \
    --resDir="./" \
    --userId=${params.userId}
    """
}

process resultsProcessing {
    publishDir "${params.outdir}", mode: 'copy'

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
    publishDir "${params.outdir}/Visualisations", mode: 'copy'

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

        img2json.py "${params.outdir}/\$image" "\$title" \${prefix}.json
    done
    
    table=\$(ls *.txt)
    prefix=\${table%.*}
    tsv2csv.py < \${prefix}.txt > \${prefix}.csv
    csv2json.py \${prefix}.csv "Combined Results" 'results-combined.json'
    
    combine_reports.py .
    """
}