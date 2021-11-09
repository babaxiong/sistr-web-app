#!/bin/bash

#inputs (genome paths)
inputfilepaths=(
 {{input_filepaths}}
)

process_status_check (){
    process_id=$1
    status=$(ps -ax  ${process_id} | awk '{print $1}' | grep ${process_id} | wc -l)
    if [ "$status" == "1" ];then
      status_check_result="wait"
    else
      status_check_result="go"
    fi
}

#submit queue via bash
while [ 1 ];do
running_processes=($(cat {{basedir}}/tmp/sistr_process_run.id))
for process_id in ${running_processes[@]};do
        echo "Checking $process_id ..."
        while [ 1 ];do
            process_status_check $process_id
            echo "$process_id - $status_check_result"
            if [ "$status_check_result" == "wait" ];then
               echo "waiting for process $process_id to finish. Waiting 10 seconds before status re-check"
               echo "{{token}} $$ ${#inputfilepaths[@]} QUEUED $(date +%m-%d-%Y-%T)" > {{basedir}}/tmp/"$$_process_status.txt";
               sleep 10;
            else
                break
            fi
        done
done
if [ ${#running_processes[@]} -eq 0 ];then break; fi
done

#record process info
echo "$$" >> {{basedir}}/tmp/sistr_process_run.id
echo "{{token}} $$ ${#inputfilepaths[@]} RUNNING $(date +%m-%d-%Y-%T)" > {{basedir}}/tmp/"$$_process_status.txt"



mkdir -p {{basedir}}/tmp/{{token}}

output_file_names=()
for input_filename in ${inputfilepaths[@]};do
    output_file_name=$(basename -- ${input_filename})
    nice -n 19 sistr -i ${input_filename} ${output_file_name} -f csv  -m --qc -o {{basedir}}/tmp/{{token}}/${output_file_name} &>> {{basedir}}/tmp/{{token}}/run_log.txt
    python3 {{basedir}}/static/python_utils/order_and_merge_sistr_results.py -infile {{basedir}}/tmp/{{token}}/${output_file_name}.csv
    #awk 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")"}{print $8,$11,$9,$10,$12,$13,$14,$15,$1,$2,$3,$4,$5,$6}' OFS='\t' {{basedir}}/tmp/{{token}}/${output_file_name}.csv > {{basedir}}/tmp/{{token}}/tmp.csv
    #mv {{basedir}}/tmp/{{token}}/tmp.csv {{basedir}}/tmp/{{token}}/${output_file_name}.csv
done

mkdir -p {{basedir}}/results/{{token}}

awk -F '\t' 'FNR==1{if (NR==1) print $0; next} {print $0}' {{basedir}}/tmp/{{token}}/*.csv > {{basedir}}/tmp/{{token}}/SISTR_results_token_{{token}}.tsv
cp {{basedir}}/tmp/{{token}}/*.tsv {{basedir}}/tmp/{{token}}/*.txt  {{basedir}}/results/{{token}}/

#ls  /mnt/results/{{token}}/*.csv | grep -v SISTR_results_token_{{token}}.csv | xargs rm
#ls  /mnt/results/{{token}}/*.csv | xargs rm
#rm -rf {{basedir}}/tmp/{{token}}

#delete pid fromt the tracking file
sed -i "/$(echo $$)/d" {{basedir}}/tmp/sistr_process_run.id
if [ "$(wc -l {{basedir}}/tmp/sistr_process_run.id | awk '{print $1}')" == "0" ];then rm -f {{basedir}}/tmp/sistr_process_run.id; fi; #remove file if no entries


rm {{basedir}}/tmp/"$$_process_status.txt"
{{send_email}}