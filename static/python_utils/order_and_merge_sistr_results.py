#! /usr/bin/python3
import pandas as pd
import argparse

def arguments():


    parser = argparse.ArgumentParser(
        description="Oder and aggregate SISTR results")
    parser.add_argument('-infile',
                        help='Input csv file')



    args = parser.parse_args()

    return args

args = arguments()
data=pd.read_csv(args.infile)
order_list=["genome","o_antigen", "h1","h2","serogroup","serovar",
"serovar_antigen","serovar_cgmlst",
"cgmlst_ST","cgmlst_distance","cgmlst_found_loci",
"cgmlst_matching_alleles", "cgmlst_genome_match", "cgmlst_subspecies", "mash_distance",
"mash_genome","mash_match","mash_serovar","mash_subspecies", "qc_messages"]

data[order_list].to_csv(args.infile, sep="\t",encoding="utf-8",index=False)
