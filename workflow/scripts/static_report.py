# Referencing https://plotly.com/python/v3/html-reports/#step-2-generate-html-reportas-a-string-and-write-to-file

import plotly.graph_objects as go
import plotly.io as pio
import pandas as pd
import base64

######################################################################################
## HARCODE IN DEV
data_root = "/home/nbx0/FLU_SC2_SEQUENCING"
run = "20230824_paris_flu_"
mira_logo = "/home/nbx0/repos/MIRA/assets/mira-logo-midjourney_20230526_rmbkgnd.png"
css = "/home/nbx0/repos/MIRA/assets/stylesheet-oil-and-gas.css"
##
######################################################################################

# read MIRA barcode distribution pie
bdp_html = pio.read_json(f"{data_root}/{run}/dash-json/barcode_distribution.json").to_html()

# read MIRA pass fail heatmap json and make html string
pfhm_html = pio.read_json(
    f"{data_root}/{run}/dash-json/pass_fail_heatmap.json"
).to_html()

# read MIRA irma summary table json and make html string
irma_sum_html = pd.read_json(
    f"{data_root}/{run}/dash-json/irma_summary.json", orient="split"
).to_html()

# base64 encode MIRA logo
binary_logo = open(f"{mira_logo}", "rb").read()
base64_logo = base64.b64encode(binary_logo).decode("utf-8")

# Make sure Black formatter does not mess up html block.
# fmt: off
html_string ='''
<html>
    <head>
        <title>MIRA Summary</title>
        <link rel="icon" type="image/x-icon" href="data:image/png;base64,'''+f'{base64_logo}'+ '''">
        <img src="data:image/png;base64,'''+f'{base64_logo}'+ '''">
        <h1>MIRA Summary</h1>
    </head>
    <body>
        <h2>Barcode Assignment</h2>
        '''+f'{bdp_html}'+'''
            <p>The ideal result would be a similar number of reads assigned to each test and positive 
            control. However, it is ok to not have similar read numbers per sample. Samples with a low 
            proportion of reads may indicate higher Ct of starting material or less performant PCR 
            during library preparation. What is most important for sequencing assembly is raw count of 
            reads and their quality.</p>            
        <h2>Automatic Quality Control Decisions</h2>
        '''+f'{pfhm_html}'+ '''
            <p>MIRA requires a minimum median coverage of 50x, a minimum coverage of the reference 
            length of 90%, and less than 10 minor variants >=5%. These are marked in yellow to orange 
            according to the number of these failure types. Samples that failed to generate any assembly 
            are marked in red. In addition, premature stop codons are flagged in yellow. CDC does not 
            submit sequences with premature stop codons, particularly in HA, NA or SARS-CoV-2 Spike. 
            Outside of those genes, premature stop codons near the end of the gene may be ok for 
            submission. Hover your mouse over the figure to see individual results.</p>
        '''+ f'{irma_sum_html}'+'''
    </body>
</html>'''
# fmt: on


html_sring = html_string.replace(
    "Download plot as a png", "Download plot as a svg"
).replace('format:e.format||"png"', 'format:e.format||"svg"')


with open(f"MIRA-summary-{run}.html", "w") as out:
    out.write(f"{html_string}")
