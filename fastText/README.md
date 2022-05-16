# FastACP
## cACP-DeepGram: Classification of Anticancer peptides Via Deep neural network and Skip-gram based word embedding model

### Step 1
Install FastText package via the instructions here: https://github.com/shahidakbarcs/cACP-DeepGram/tree/main/fastText

### Step 2
Use "fasttext_generated.py" file to transform FASTA sequence into FastText format
- *python fasttext_generated.py fasta_file fasttext_file*

### Step 3
Print vectors using FastText model:
- *fasttext print-sentence-vectors model.bin < fasttext_file > vector_file*

### Step 4
Use "linux_svm.py" to predict the generated file:
- *python linux_svm.py ACP_Features.csv vector_file_ACP output_file_nonACP

### Step 5
Check in *output_file* for the result:
- '1' is ACP
- '0' is Non ACP
