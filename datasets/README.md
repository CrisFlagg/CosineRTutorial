# Datasets: gaitpdb and gaitndd

This folder holds external gait datasets that are downloaded on demand and kept out of version control to avoid committing large binaries. Use the provided script to fetch and extract the data locally.

Contents after download:
- datasets/gaitpdb/ … PhysioNet “Gait in Parkinson’s Disease” (gaitpdb)
- datasets/gaitndd/ … PhysioNet “Gait in Neurodegenerative Disease” (gaitndd)

How to download
- Prerequisite: R (base R is sufficient; no extra packages required).
- From the project root, run:

  Rscript scripts/download_gait_datasets.R

- By default, the script skips datasets that already exist. To force a re-download:

  Rscript scripts/download_gait_datasets.R --force

What you will get

1) Gait in Parkinson’s Disease (gaitpdb)
- Source: PhysioNet (Jeffrey Hausdorff et al.)
- Data: Vertical ground reaction force records from instrumented shoes with 8 sensors per foot (16 channels total), plus per-foot summed force signals.
- Cohort: 93 idiopathic PD patients and 73 healthy controls; some trials include a dual-task condition.
- Sampling: 100 Hz; ~2 minutes per recording.
- Path after extraction: datasets/gaitpdb/gaitpdb-1.0.0/ (multiple .txt files and metadata)
- Home page: https://physionet.org/content/gaitpdb/1.0.0/
- License: Open Data Commons Attribution (ODC-By 1.0)
  https://physionet.org/content/gaitpdb/view-license/1.0.0/
- Citation: Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, et al. PhysioBank, PhysioToolkit, and PhysioNet. Circulation. 2000.

2) Gait in Neurodegenerative Disease (gaitndd)
- Source: PhysioNet (Jeffrey Hausdorff)
- Data: Force-sensitive resistors (footswitch) signals under each foot (left/right) and derived time series of stride, swing, stance, and double support intervals.
- Cohort: PD (n=15), Huntington’s (n=20), ALS (n=13), and healthy controls (n=16).
- Path after extraction: datasets/gaitndd/gaitndd-1.0.0/ (binary .let/.rit foot signals, .ts time series, headers)
- Home page: https://physionet.org/content/gaitndd/1.0.0/
- License: Open Data Commons Attribution (ODC-By 1.0)
  https://physionet.org/content/gaitndd/view-license/1.0.0/
- Citation: Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, et al. PhysioBank, PhysioToolkit, and PhysioNet. Circulation. 2000.

Notes on licensing and use
- Both datasets are licensed under ODC-By 1.0 on PhysioNet and permit academic use with attribution. Review the license pages above before use and include appropriate citations in your reports/publications.

Disk space and network
- gaitpdb ZIP is approximately 288 MB; extracted size is larger.
- gaitndd ZIP is approximately 18 MB.
- Downloads may take several minutes depending on network speed.

Checksums
- The download script also fetches the upstream SHA256SUMS.txt into each dataset subfolder for reference. If you need formal verification, compute checksums locally and compare to the provided list.

Keep data out of version control
- This folder contains a .gitignore that intentionally ignores downloaded dataset content. Do not commit large datasets into the repository.