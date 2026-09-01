# Quality Assessment Framework for Rule-Based Assembly Knowledge Bases

This repository contains the prototype implementation developed for the paper:

> Sahota, H., and Klodowski, A.
> *Quality Assessment Framework for Rule-Based Assembly Knowledge Bases*.

## Overview

The repository provides a prototype implementation of a quality assessment framework for symbolic assembly planning knowledge bases represented using Answer Set Programming (ASP).

The framework combines traditional structural verification techniques with engineering-specific quality assessment criteria to evaluate both:

- Structural Quality
  - Consistency
  - Knowledge Completeness
  - Redundancy
  - Circularity
  - Reachability

- Engineering Knowledge Quality
  - Domain Coverage
  - Operation Modelling Completeness
  - Decision Knowledge Validation
  - Engineering Rule Coverage

The implementation generates assessment reports that support the identification of structural anomalies, missing engineering knowledge, and potential quality issues in symbolic assembly planning knowledge bases.

## Repository Structure

| File | Description |
|--------|-------------|
| `ASP_Ruleset.lp` | Example symbolic assembly planning knowledge base |
| `KnowledgeBaseQualityAssessment.ipynb` | Prototype implementation of the assessment framework |
| `Decision_Knowledge_Test_Input.lp` | Example validation scenarios for decision knowledge assessment |
| `Engineering_Rule_Coverage_Test_Input.lp` | Example inputs for engineering rule coverage assessment |

## Requirements

The prototype was developed using:

- Python 3.x
- Clingo (ASP Solver)
- Jupyter Notebook

## Running the Assessment

1. Install the required dependencies.
2. Open `KnowledgeBaseQualityAssessment.ipynb`.
3. Execute the notebook cells sequentially.
4. Review the generated assessment reports.

## Purpose

This implementation is provided to support reproducibility of the research results presented in the associated publication and to facilitate further research on quality assurance for symbolic engineering knowledge bases.

## License

This project is released under the MIT License.
