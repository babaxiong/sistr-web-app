#!/bin/bash

#SBATCH -A SISTR
#SBATCH -J {{token}}
#SBATCH -o {{basedir}}/tmp/{{token}}/slurm-%x.out.txt
#SBATCH -t 0:30:00
#SBATCH -p sistr
#SBATCH -n 1

inputfilepaths=(
 {{input_filepaths}}
)

mkdir -p {{basedir}}/tmp/{{token}}

for input_filename in ${inputfilepaths[@]};do
    output_file_name=$(basename -- ${input_filename})
    sistr -i ${input_filename} ${output_file_name} -f csv -m --qc -o {{basedir}}/tmp/{{token}}/${output_file_name}
    python3 {{basedir}}/static/python_utils/order_and_merge_sistr_results.py -infile {{basedir}}/tmp/{{token}}/${output_file_name}.csv

    #mv {{basedir}}/tmp/{{token}}/tmp.csv {{basedir}}/tmp/{{token}}/${output_file_name}.csv
    #echo $(sistr -V) && echo $command
    #eval $command
done

mkdir -p {{basedir}}/results/{{token}}

awk -F '\t' 'FNR==1{if (NR==1) print $0; next} {print $0}' {{basedir}}/tmp/{{token}}/*.csv > {{basedir}}/tmp/{{token}}/SISTR_results_token_{{token}}.tsv
cp {{basedir}}/tmp/{{token}}/*.tsv {{basedir}}/tmp/{{token}}/*.txt  {{basedir}}/results/{{token}}/

ls  /mnt/results/{{token}}/*.csv | grep -v SISTR_results_token_{{token}}.csv | xargs rm
{{send_email}}

