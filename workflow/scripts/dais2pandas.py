import pandas as pd
from os.path import dirname, realpath, basename, isfile
from glob import glob
from re import findall, sub

repo_path = realpath(dirname(dirname(__file__)))

# https://www.bioinformatics.org/sms/iupac.html
nt_code = {
    'A':['A'],
    'C':['C'],
    'G':['G'],
    'T':['T'],
    'U':['U'],
    'R':['A', 'G'],
    'Y':['C', 'T'],
    'S':['G', 'C'],
    'W':['A', 'T'],
    'K':['G', 'T'],
    'M':['A', 'C'],
    'B':['C', 'G', 'T'],
    'D':['A', 'G', 'T'],
    'H':['A', 'C', 'T'],
    'V':['A', 'C', 'G'],
    'N':['A', 'C', 'G', 'T']
}

codon = {
    "GCT": "A", "GCC": "A", "GCA": "A", "GCG": "A",
    "TGT": "C", "TGC": "C",
    "GAT": "D", "GAC": "D",
    "GAA": "E", "GAG": "E",
    "TTT": "F", "TTC": "F",
    "GGT": "G", "GGC": "G", "GGA": "G", "GGG": "G",
    "CAT": "H", "CAC": "H",
    "ATA": "I", "ATT": "I", "ATC": "I",
    "AAA": "K", "AAG": "K",
    "TTA": "L", "TTG": "L", "CTT": "L", "CTC": "L", "CTA": "L", "CTG": "L",
    "ATG": "M",
    "AAT": "N", "AAC": "N",
    "CCT": "P", "CCC": "P", "CCA": "P", "CCG": "P",
    "CAA": "Q", "CAG": "Q",
    "CGT": "R", "CGC": "R", "CGA": "R", "CGG": "R", "AGA": "R", "AGG": "R",
    "TCT": "S", "TCC": "S", "TCA": "S", "TCG": "S", "AGT": "S", "AGC": "S",
    "ACT": "T", "ACC": "T", "ACA": "T", "ACG": "T",
    "GTT": "V", "GTC": "V", "GTA": "V", "GTG": "V",
    "TGG": "W",
    "TAT": "Y", "TAC": "Y",
    "TAA": "*", "TAG": "*", "TGA": "*"
}

def fasta2dic(fasta, dais_ref_format=False):
    seq_dic = {}
    with open(fasta, "r") as d:
        for line in d.readline():
            if line[0] == ">":
                if dais_ref_format:
                    seq_handle = "|".join(line[1:].strip().split("|")[:2])
                else:
                    seq_handle = line[1:].strip()
                seq_dic[seq_handle] = ""
            else:
                seq_dic[seq_handle] += line.strip()
    return seq_dic

inscols = [
    "ID",
    "C_type",
    "Ref_ID",
    "Protein",
    "Upstream_aa",
    "Inserted_nucleotides",
    "Inserted_residues",
    "Upstream_nt",
    "Codon_shift",
]
inscols_rename = {
    "ID": "Sample",
    "Ref_ID": "Reference",
    "Protein": "Protein",
    "Upstream_aa": "Upstream AA Position",
    "Inserted_nucleotides": "Inserted Nucleotides",
    "Inserted_residues": "Inserted AAs",
    "Upstream_nt": "Upstream NT",
    "Codon_shift": "In Frame",
}
delcols = [
    "ID",
    "C_type",
    "Ref_ID",
    "Protein",
    "VH",
    "Del_AA_start",
    "Del_AA_end",
    "Del_AA_len",
    "In_frame",
    "CDS_ID",
    "Del_CDS_start",
    "Del_CDS_end",
    "Del_CDS_len",
]
delcols_rename = {
    "ID": "Sample",
    "Ref_ID": "Reference",
    "Protein": "Protein",
    "Del_AA_start": "Del Start AA Position",
    "Del_AA_end": "Del End AA Position",
    "Del_AA_len": "Del AA Length",
    "In_frame": "In Frame",
    "Del_CDS_start": "Del Start CDS Posistion",
    "Del_CDS_end": "Del End CDS Posistion",
}
seqcols = [
    "ID",
    "C_type",
    "Ref_ID",
    "Protein",
    "VH",
    "AA_seq",
    "AA_aln",
    "CDS_id",
    "Insertion",
    "Shift_Insert",
    "CDS_seq",
    "CDS_aln",
    "Query_nt_coordinates",
    "CDS_nt_coordinates",
]
seqcols_rename = {
    "ID": "Sample",
    "Ref_ID": "Reference",
    "Protein": "Protein",
    "AA_seq": "AA Sequence",
    "AA_aln": "Aligned AA Sequence",
    "Insertion": "Insertion",
    "Shift_Insert": "Insertion Shifts Frame",
    "CDS_seq": "CDS Sequence",
    "CDS_aln": "Aligned CDS Sequence",
    "Query_nt_coordinates": "Reference NT Positions",
    "CDS_nt_coordinates": "Sample NT Positions",
}


def dais2df(results_path, colnames, col_renames, dais_suffix, full=False):
    files = glob(f"{results_path}/*{dais_suffix}")
    if len(files) < 1:
        print(f'the glob "{results_path}/*{dais_suffix}" found no files')
    df = pd.DataFrame()
    for f in files:
        df = pd.concat([df, pd.read_csv(f, sep="\t", names=colnames, keep_default_na=False)])
    if full:
        return df
    else:
        select_cols = [i for i in col_renames.keys()]
        df = df[select_cols]
        df = df.rename(columns=col_renames)
    df = df[df["Protein"] != "\\N"]
    df = df[df["Sample NT Positions"] != "\\N"]
    return df


def dels_df(results_path):
    return dais2df(results_path, delcols, delcols_rename, ".del")


def ins_df(results_path):
    return dais2df(results_path, inscols, inscols_rename, ".ins")


def seq_df(results_path):
    return dais2df(results_path, seqcols, seqcols_rename, ".seq")


def ref_seqs():
    return dais2df(f"{repo_path}/data/references/", seqcols, seqcols_rename, ".seq")


def AAvars(refseq, sampseq):
    vars = []
    pos = 1
    for r, s in zip(refseq, sampseq):
        if r != s:
            vars.append(f"{r}{pos}{s}")
        pos += 1
    if len(vars) >= 1:
        return ", ".join(vars)
    else:
        return ""

def minor_AAvars(refseq, seqs_df, vars_df):
    # Cut off suffix from influenza samples names
    seqs_df['Sample'] = seqs_df['Sample'].apply(lambda x: sub(r'_[1-8]$', '', x))


def compute_dais_variants(results_path, specific_ref=False):
    refs = ref_seqs()
    ref_dic = (
        refs.groupby(["Sample", "Protein"]).agg(lambda x: x.tolist()).to_dict("index")
    )
    seqs = seq_df(results_path)
    seq_dic = (
        seqs.groupby(["Sample", "Protein"]).agg(lambda x: x.tolist()).to_dict("index")
    )
    if not specific_ref:
        seqs["AA Variants"] = seqs.apply(
            lambda x: AAvars(
                ref_dic[(x["Reference"], x["Protein"])]["Aligned AA Sequence"][0],
                seq_dic[(x["Sample"], x["Protein"])]["Aligned AA Sequence"][0],
            ),
            axis=1,
        )
    else:
        seqs["AA Variants"] = seqs.apply(
            lambda x: AAvars(
                ref_dic[(specific_ref, x["Protein"])]["Aligned AA Sequence"][0],
                seq_dic[(x["Sample"], x["Protein"])]["Aligned AA Sequence"][0],
            ),
            axis=1,
        )
        seqs["Reference"] = specific_ref
    seqs["AA Variant Count"] = seqs["AA Variants"].map(lambda x: len(x.split(",")) if x != '' else 0)
    seqs = seqs[["Sample", "Reference", "Protein", "AA Variant Count", "AA Variants"]]
    seqs = seqs.sort_values(by=["Protein","Sample","AA Variant Count"]).drop_duplicates(subset=["Sample", "Protein"], keep="first")
    return seqs
