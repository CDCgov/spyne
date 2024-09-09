

# SPYNE

Command line interface (CLI) for running `MIRA` (an interactive dashboard for Influenza and SARS-COV-2 Spike-Gene Genome Assembly and Curation) using a `Snakemake` workflow.

### 1. Run `spyne` locally

#### (i) Clone this respitory

```
git clone https://github.com/CDCgov/spyne.git
```

#### (ii) Navigate to `spyne` folder 

```
cd spyne
```

#### (iii) Check out `single_spyne_container` branch

```
git checkout single_spyne_container 
```

#### (iv) Run the `spyne` workflows

__NOTE:__ In the `spyne` directory, there is a `MIRA.sh` file that would execute the `spyne` workflows.

```bash
bash MIRA.sh -s {path to samplesheet.csv} -r <run_id> -e <experiment_type> <OPTIONAL: -p amplicon_library> <OPTIONAL: -c CLEANUP-FOOTPRINT> <OPTIONAL: -n> 
```

`Experiment type options`: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina, RSV-illumina, RSV-ONT <br>
`Primer Schema options for SC2`: articv3, articv4, articv4.1, articv5.3.2, qiagen, swift, swift_211206 <br>
`Primer Schema options for RSV`: RSV_CDC_8amplicon_230901, dong_et_al <br>

### 2. Run `spyne` with Docker

### Requirements

- Git version >= 2.21.0
- Docker version >= 18

#### (i) Clone this respitory

```
git clone https://github.com/CDCgov/spyne.git
```

#### (ii) Navigate to `spyne` folder 

```
cd spyne
```

#### (iii) Check out `single_spyne_container` branch

```
git checkout single_spyne_container 
```

#### (iv) Build the `spyne` image

__NOTE:__ In the `spyne` directory, there is a `Dockerfile` that contains a list of instructions on how to build and run the `spyne` container.

```
docker build -t spyne:latest .
```

**`-t`**: add a tag to an image such as the version of the application, e.g. *spyne:v1.0.0* or *spyne:latest* <br>
**`.`**: current working directory of where the Dockerfile is stored <br>

After the build is completed, you can check if the image is built successfully

```
docker images

REPOSITORY      TAG        IMAGE ID        CREATED        SIZE
spyne           latest     2c22887402d3    2 hours ago    1.98GB
```

#### (v) Run the `spyne` container

```    
docker run -v /path/to/data:/data --name spyne -t -d spyne:latest
```

**NOTE:** <br>
- Change __/path/to/data__ to your local directory where it contains all data files needed to feed into the `spyne` workflows. This directory is mounted to `/data` directory inside the container. <br>

**`-t`**: allocate a pseudo-tty <br>
**`-d`**: run the container in detached mode <br>
**`-v`**: mount code base and data files from host directory to container directory **[host_div]:[container_dir]**. By exposing the host directory to docker container, docker will be able to access data files within that mounted directory and use it to fire up the `spyne` workflows.  <br>
**`--`name**: give an identity to the container <br>

For more information about the Docker syntax, see [Docker run reference](https://docs.docker.com/engine/reference/run/)

To check if the container is built successfully

```
docker container ps

CONTAINER ID    IMAGE           COMMAND        CREATED         STATUS        PORTS      NAMES
b37b6b19c4e8    spyne:latest    "bash"         5 hours ago     Up 5 hours               spyne
```

#### (vi) Execute the `spyne` workflows inside the container

```
docker exec -w /data spyne bash MIRA.sh -s {path to samplesheet.csv} -r <run_id> -e <experiment_type> <OPTIONAL: -p amplicon_library> <OPTIONAL: -c CLEANUP-FOOTPRINT>
```

**`-w`**: working directory inside the container. DEFAULT: /data.<br>
`Experiment type options`: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina, RSV-illumina, RSV-ONT <br> 
`Primer Schema options for SC2`: articv3, articv4, articv4.1, articv5.3.2, qiagen, swift, swift_211206 <br>
`Primer Schema options for RSV`: RSV_CDC_8amplicon_230901, dong_et_al <br>

### 3. Run `spyne` with Compose

### Requirements

- Git version >= 2.21.0
- Docker version >= 18
- Docker Compose Version >= 1.29

#### (i) Clone `spyne` repo

```bash
git clone https://github.com/CDCgov/spyne.git
```

#### (ii) Navigate to `spyne` folder 

```bash
cd spyne
```

#### (iii) Check out `single_spyne_container` branch

```
git checkout single_spyne_container 
```

#### (iv) Edit `docker-compose.yml` file in the `spyne` folder to link the data inputs, irma, and dais-ribosome images to run the `spyne` container

```bash
version: "3.9"

x-irma-image:
  &irma-image
  irma_image: cdcgov/irma-dev:rsv-support

x-dais-image:
  &dais-image
  dais_image: cdcgov/dais-ribosome:v1.5.4

x-data-volume:
  &data-volume
  type: bind
  source: /home/snu3/irma-testings/rsv-support/FLU_SC2_SEQUENCING
  target: /data

services:
  spyne: 
    container_name: spyne
    image: spyne:latest
    build:
      context: .
      dockerfile: Dockerfile
      args:
        << : [*irma-image, *dais-image]
    restart: always
    volumes:
      - *data-volume
    command: tail -f /dev/null
```

#### (v) Start up the `spyne` container

```bash
docker compose up -d 
```

**`-d`**: run the container in detached mode <br>
  
For more information about the docker compose syntax, see <a href="https://docs.docker.com/engine/reference/commandline/compose_up/" target="_blank">docker-compose up reference</a>

#### (vi) How to run the `spyne` container

```bash
docker exec -w /data spyne bash MIRA.sh -s {path to samplesheet.csv} -r <run_id> -e <experiment_type> <OPTIONAL: -p amplicon_library> <OPTIONAL: -c CLEANUP-FOOTPRINT> 
```

`Experiment type options`: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina, RSV-illumina, RSV-ONT <br> 
`Primer Schema options for SC2`: articv3, articv4, articv4.1, articv5.3.2, qiagen, swift, swift_211206 <br>
`Primer Schema options for RSV`: RSV_CDC_8amplicon_230901, dong_et_al <br>

### 4. Push Docker Images to a Registry

You can push docker images to a public registry of choices (e.g. DockerHub, Quay, AWS ECR, etc.). Here, we will authenticate and push `spyne` image to `cdcgov` DockerHub account. 

#### (i) Authenticate and log into your DockerHub account

```bash
docker login --username <your_username> --password-stdin
```

**`--password-stdin`**: provide a password through STDIN. Using STDIN prevents the password from ending up in the shell's history, or log-files.

#### (ii) Create another tag for your image. Make sure the tag has your or your organization's account associated with it (e.g., `cdcgov`). This is useful if you want to tag your image with a `latest` tag and then another with a specific `version` of the image.

```bash
docker tag spyne:latest cdcgov/spyne:latest
```

Here, `spyne:latest` is the local image that you just built, and `cdcgov/spyne:latest` is an alias image of `spyne:latest` but with `cdcgov` account attached.

#### (iii) See a new list of available images

```bash
docker images

REPOSITORY      TAG         IMAGE ID        CREATED        SIZE
spyne           latest      d9e2578d2211    2 weeks ago    1.98GB
cdcgov/spyne    latest      d9e2578d2211    2 weeks ago    1.98GB
```

#### (iv) Finally, push `cdcgov/spyne:latest` image to `cdcgov` DockerHub

```
docker image push cdcgov/spyne:latest
```

<br>

[Click Here](https://hub.docker.com/r/cdcgov/spyne/tags) to see a list of available images of `spyne` on the `cdcgov` Dockerhub account.

Any questions or issues? Please report them on our [github issues](https://github.com/cdcgov/spyne/issues)

<br>


