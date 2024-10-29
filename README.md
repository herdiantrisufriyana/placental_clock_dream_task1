# Placental Clock DREAM Challenge 2024 (Task 1)

## System requirements

Install Docker desktop once in your machine. Start the service every time you build this project image or run the container.

## Installation guide

Build the project image once for a new machine (currently support AMD64 and ARM64).

```{bash}
docker build -t placental_clock_dream_task1 --load .
```

Run the container every time you start working on the project. Change left-side port numbers for either Rstudio or Jupyter lab if any of them is already used by other applications.

In terminal:

```{bash}
docker run -d -p 8787:8787 -p 8888:8888 -v "$(pwd)":/home/rstudio/project --name placental_clock_dream_task1_container placental_clock_dream_task1
```

In command prompt:

```{bash}
docker run -d -p 8787:8787 -p 8888:8888 -v "%cd%":/home/rstudio/project --name placental_clock_dream_task1_container placental_clock_dream_task1
```

## Instructions for use

### Rstudio

Change port number in the link, accordingly, if it is already used by other applications.

Visit http://localhost:8787.
Username: rstudio
Password: 1234

Your working directory is ~/project.

### Jupyter lab

Use terminal/command prompt to run the container terminal.

```{bash}
docker exec -it placental_clock_dream_task1_container bash
```

In the container terminal, run jupyter lab using this line of codes.

```{bash}
jupyter-lab --ip=0.0.0.0 --no-browser --allow-root
```

Click a link in the results to open jupyter lab in a browser. Change port number in the link, accordingly, if it is already used by other applications.

## Source codes of data analysis

All the source codes are included in [**index.Rmd**](https://github.com/herdiantrisufriyana/placental_clock_dream_task1/blob/master/index.Rmd) and [**index.ipynb**](https://github.com/herdiantrisufriyana/placental_clock_dream_task1/blob/master/index.ipynb) for R- and Python-related codes, respectively. The HTML preview of index.Rmd is shown [**here**](https://herdiantrisufriyana.github.io/placental_clock_dream_task1/index.html).






