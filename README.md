[![Tutorial](https://img.shields.io/badge/Tutorial-Phylogenomics-red.svg)](https://github.com/eparisis/phylogenomics-demo)
[![GTDB-Tk](https://img.shields.io/badge/GTDB--Tk-2.4.1-orange.svg)](https://github.com/Ecogenomics/GTDBTk)
[![IQ-TREE](https://img.shields.io/badge/IQ--TREE-2.4.0-green.svg)](https://iqtree.github.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)

# Simple Bacterial Phylogenomic reconstruction

## Overview

This is a simple bacterial phylogenomic reconstruction pipeline.

## Running this tutorial with Github Codespaces

You can run this tutorial with Github Codespaces by clicking the button below:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/eparisis/phylogenomics-demo)

## Requirements for local installation

- [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) for windows users.
- [MicroMamba](https://mamba.readthedocs.io/en/latest/) (conda replacement, if you already have conda installed it is recommended to replace it with `Miniforge`).
  - Download and install the latest version of MicroMamba for your operating system from the [MicroMamba github repo](https://github.com/conda-forge/miniforge?tab=readme-ov-file#requirements-and-installers).
  - For windows install the version compatible with your [WSL](https://github.com/conda-forge/miniforge?tab=readme-ov-file#windows-subsystem-for-linux-wsl).
  - For macos do not install the arm64 version (even if you are using an arm64 mac - M chips).
- [VSCode](https://code.visualstudio.com/).
  - [Setup VSCode to run on WSL](https://code.visualstudio.com/docs/remote/wsl) for windows users.

## General steps for phylogenomic reconstruction

1. Gene calling.
2. Identification of homologous genes.
3. Translation of the homologous genes into amino acids.
4. Concatenation of the translated amino acids into a single sequence.
5. Alignment of the concatenated sequences.
6. Phylogenetic method and model selection.
7. Tree inference.
8. Tree visualization.
9. Refinement of the tree.

## Gene identification and alignment with [`GTDB-Tk`](https://github.com/Ecogenomics/GTDBTk)

We will use GTDB-Tk for our:

1. Core gene identification.
2. Core gene extraction.
3. Alignment of core genes.

### Installation

Extract the compressed GTDB-Tk test database:

```bash
tar -xzf gtdbtk_mock_db.tar.gz
```

```bash
mamba create -n phylo -c bioconda python=3.9 gtdbtk=2.4.1
```

Activate the environment and set the database path as instructed by the installation prompt:

```bash
mamba activate phylo
conda env config vars set GTDBTK_DATA_PATH="../gtdbtk_mock_db"
mamba deactivate && mamba activate phylo
```

Move into a newly created `work` directory and check the installation:

```bash
mkdir -p work && cd work
gtdbtk check_install
```

We will get an OK for the software dependencies and a warning about the database since we are using the mock database and not the real GTDB database.

### Running GTDB-Tk

We will follow the [GTDB-Tk tutorial](https://ecogenomics.github.io/GTDBTk/examples/classify_wf.html) to get started.

#### Gene calling (identify)

First we need to identify the core bacterial genes in our genomes.

```bash
gtdbtk identify --genome_dir ../Genomes/ --out_dir gtdbtk_out/identify/ --extension gz --cpus 4
```

#### Gene Alignment (align)

Next we need to align the core genes we identified to the ones in the GTDB database.

We use a heavily subsampled version of the GTDB database in our turorial (`gtdbtk_mock_db`). The full GTDB is aprox. ~140 GB large and needs ~110GB (690 GB when using –full_tree) of memory to run these steps.

```bash
gtdbtk align --identify_dir gtdbtk_out/identify/ --out_dir gtdbtk_out/align/ --cpus 4
```

The `gtdbtk.bac120.user_msa.fasta.gz` file is the alignment file we will use for our phylogenetic reconstruction and consists only of our genomes.

The `gtdbtk.bac120.msa.fasta.gz` file is the alignment consists all genomes in the GTDB database that have been aligned with our genomes.

You can inspect the contents of the alignment file in your code editor or by using a tool like `alv` (command line tool) or `AliView` (GUI tool).

Example for `alv`:

```bash
pip install alv
gunzip gtdbtk_out/align/align/gtdbtk.bac120.msa.fasta.gz
alv -w 100 -k gtdbtk_out/align/align/gtdbtk.bac120.msa.fasta | less -R
```

## Phylogenetic reconstruction with [`IQ-TREE`](https://iqtree.github.io/)

There are 3 main phylogenetic reconstruction methods:

1. **Distance-based methods**: These methods calculate a distance matrix from the sequence data and then build a tree based on the distances. Examples include Neighbor-Joining (NJ) and Unweighted Pair Group Method with Arithmetic Mean (UPGMA).

   - Fast, good for large datasets.
   - May oversimplify evolutionary models; less accurate than model-based methods.

2. **Maximum Likelihood (ML) methods**: These methods estimate the likelihood of the data given a tree and a model of evolution. They search for the tree that maximizes this likelihood. Examples include RAxML, IQ-TREE, and PhyML.

   - High accuracy, can use complex evolutionary models.
   - Computationally intensive, especially for large datasets.

3. **Bayesian methods**: These methods use a probabilistic framework to estimate the posterior distribution of trees given the data and a model of evolution. They sample from this distribution to obtain trees. Examples include MrBayes and BEAST.

   - Gives support values (posterior probabilities), handles model uncertainty well (very high accuracy).
   - Very computationally demanding and slow.

We will use `IQ-TREE` to reconstruct the phylogeny of our genomes. `IQ-TREE` is a fast, accurate and memory-efficient phylogenetic Maximum Likelihood (ML) tree inference program. It supports a wide range of phylogenetic substitution models and can handle large datasets. It has very good documentation and has a large set of other helper tools incorporated which makes it a very versatile tool.

Two of these tools which we are going to use are:

1. Ultrafast bootstrap (`UFBoot`) for faster bootstrapping.
2. Ultrafast model selection (`ModelFinder`) for automated model selection.

### `IQ-TREE` Installation

On the `phylo` environment we are already in use:

```bash
mamba install -c bioconda iqtree=2.4.0
```

Move the alignment file to the work directory and unzip it:

```bash
mv gtdbtk_out/align/align/gtdbtk.bac120.user_msa.fasta.gz . && gunzip gtdbtk.bac120.user_msa.fasta.gz
```

>[!NOTE]
> <small>You can save your conda environment with the following command:
>
> ```bash
> conda env export > env.yml
> ```
>
> To recreate the environment from the `env.yml` file you can use the following command:
>
> ```bash
> mamba env create -f env.yml
> ```
>
> </small>

### Running `IQ-TREE`

`IQ-TREE` will run on our alignment file we created earlier

#### Running ModelFinder (Optional)

As mentioned we can use `ModelFinder` to automatically select the best model for our data. We can also just run `ModelFinder` by itself to get a list of models and their support values.

```bash
iqtree -s gtdbtk.bac120.user_msa.fasta -m TESTONLY
```

`ModelFinder` will output a list of models and their support values. The model with the highest support value is the best model for our data. In our case it is `LG+F+I+R5`.

#### Running IQ-TREE for phylogenetic reconstruction

Infer maximum-likelihood tree from a sequence alignment with the best-fit model automatically selected by ModelFinder:

```bash
iqtree -s gtdbtk.bac120.user_msa.fasta -T 4
```

Infer maximum-likelihood tree from a sequence alignment with the `LG+F+I+R5` model:

```bash
iqtree -s gtdbtk.bac120.user_msa.fasta -m LG+F+I+R5 -T 4
```

The `gtdbtk.bac120.user_msa.fasta.treefile` file is the output tree file in Newick format. You can visualize it with a tool like `FigTree`, `iTOL`, or `Ete3`.

You can use `iTOL` to visualize the tree online here: [iTOL](https://itol.embl.de/).

## Other approaches (Homework)

Create a phylogenetic tree with [BUSCOs](https://busco.ezlab.org/).
An example of this implementation can be found [here](https://academic.oup.com/ismej/article/15/1/211/7474492?login=false).

>[BUSCO Protocols Paper](https://doi.org/10.1002/cpz1.323)
>*Mosè Manni, Matthew R. Berkeley, Mathieu Seppey, Evgeny M. Zdobnov, BUSCO: Assessing Genomic Data Quality and Beyond. Current Protocols,  <https://doi.org/10.1002/cpz1.323>*

## References

> *[GTDB-Tk](https://ecogenomics.github.io/GTDBTk/)*
> <small>*Chaumeil PA, et al. 2022. GTDB-Tk v2: memory friendly classification with the Genome Taxonomy Database. Bioinformatics, btac672.*</small>
> <small>*Chaumeil PA, et al. 2019. GTDB-Tk: A toolkit to classify genomes with the Genome Taxonomy Database. Bioinformatics, btz848.*</small>

> *[IQ-TREE](https://iqtree.github.io/)*
> <small>*Thomas K.F. Wong, Nhan Ly-Trong, Huaiyan Ren, Hector Banos, Andrew J. Roger, Edward Susko, Chris Bielow, Nicola De Maio, Nick Goldman, Matthew W. Hahn, Gavin Huttley, Robert Lanfear, Bui Quang Minh (2025) IQ-TREE 3: Phylogenomic Inference Software using Complex Evolutionary Models. Submitted. <https://ecoevorxiv.org/repository/view/8916/>*</small>

> *[ModelFinder]()*
> <small>*Subha Kalyaanamoorthy, Bui Quang Minh, Thomas KF Wong, Arndt von Haeseler, and Lars S Jermiin (2017) ModelFinder: Fast model selection for accurate phylogenetic estimates. Nat. Methods, 14:587–589. <https://doi.org/10.1038/nmeth.4285>*</small>

> *[Ultrafast bootstrap (UFBoot)]()*
> <small>*Diep Thi Hoang, Olga Chernomor, Arndt von Haeseler, Bui Quang Minh, and Le Sy Vinh (2018) UFBoot2: Improving the ultrafast bootstrap approximation. Mol. Biol. Evol., 35:518–522. <https://doi.org/10.1093/molbev/msx281>*</small>

> *[iTOL](https://itol.embl.de/)*
> <small>*RamLetunic and Bork (2024) Interactive Tree of Life (iTOL) v6: recent updates to the phylogenetic tree display and annotation tool. Nucleic Acids Res doi: 10.1093/nar/gkae268.*</small>

> *[BUSCO](https://busco.ezlab.org/)*
> <small>*Mosè Manni, Matthew R Berkeley, Mathieu Seppey, Felipe A Simão, Evgeny M Zdobnov, BUSCO Update: Novel and Streamlined Workflows along with Broader and Deeper Phylogenetic Coverage for Scoring of Eukaryotic, Prokaryotic, and Viral Genomes, Molecular Biology and Evolution, Volume 38, Issue 10, October 2021, Pages 4647–4654, <https://doi.org/10.1093/molbev/msab199>*</small>
> <small>*Mosè Manni, Matthew R. Berkeley, Mathieu Seppey, Evgeny M. Zdobnov, BUSCO: Assessing Genomic Data Quality and Beyond. Current Protocols,  <https://doi.org/10.1002/cpz1.323>*</small>