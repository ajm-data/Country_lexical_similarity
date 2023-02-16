import xlsxwriter as xlsx
import csv

# Convert Lexical Similarity TSV file into Excel Workbook for SQL use
tsv_file = "lexical_similarity.tsv"     # Input file path
xlsx_file = "lexical_similarity.xlsx"   # Output file path


# Create XlsxWriter workbook object
workbook = xlsx.Workbook(xlsx_file)
worksheet = workbook.add_worksheet()

# Reading the tsv file
read_tsv = csv.reader(open(tsv_file, 'r'), delimiter = '\t')


for row, data, in enumerate(read_tsv):
    worksheet.write_row(row, 0, data)
workbook.close()