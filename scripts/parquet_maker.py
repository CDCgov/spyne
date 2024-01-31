#!/usr/bin/env python

import pandas as pd
import argparse
from pathlib import Path
import pyarrow as pa
import pyarrow.parquet as pq

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--file")
parser.add_argument("-o", "--outputname")
parser.add_argument("-r", "--runid")
parser.add_argument("-i", "--instrument")

inputarguments = parser.parse_args()

if inputarguments.file:
    infi = inputarguments.file
else:
    exit(0)

if inputarguments.outputname:
    outfi = inputarguments.outputname
else:
    exit(0)

if inputarguments.runid:
    run_id = inputarguments.runid
else:
    run_id = Path.cwd()
    run_id = str(run_id).split('/')[-1]

if inputarguments.instrument:
    instrument = inputarguments.instrument
else:
    instrument = "testInstrument"


if ".csv" in infi:
    table = pd.read_csv(infi, header=0)
elif ".xls" in infi:
    table = pd.read_excel(infi, header=0)
elif ".txt" in infi or ".tsv" in infi:
    table = pd.read_csv(infi, sep="/t", header=0)

table['runid'] = run_id

table['instrument'] = instrument

#file I/O
pd.DataFrame.to_csv(table, "temp.csv", sep='\t', index=False)
chunksize = 100_000
# modified from https://stackoverflow.com/questions/26124417/how-to-convert-a-csv-file-to-parquet
csv_stream = pd.read_csv("temp.csv", sep='\t', chunksize=chunksize, low_memory=False)
for i, chunk in enumerate(csv_stream):
    print("Chunk", i)
    if i == 0:
        # Guess the schema of the CSV file from the first chunk
        parquet_schema = pa.Table.from_pandas(df=chunk).schema
        # Open a Parquet file for writing
        parquet_writer = pq.ParquetWriter(outfi, parquet_schema, compression='snappy', version='1.0')
    # Write CSV chunk to the parquet file
    table = pa.Table.from_pandas(chunk, schema=parquet_schema)
    parquet_writer.write_table(table)

parquet_writer.close()
