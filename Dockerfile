
# Create an argument to pull a particular version of irma image
ARG irma_image
ARG irma_image=${irma_image:-cdcgov/irma:latest}

# Create an argument to pull a particular version of dias image
ARG dais_image
ARG dais_image=${dais_image:-cdcgov/dais-ribosome:latest}

############# base image ##################
FROM --platform=$BUILDPLATFORM ubuntu:focal AS base

# local apt mirror support
# start every stage with updated apt sources
ARG APT_MIRROR_NAME=
RUN if [ -n "$APT_MIRROR_NAME" ]; then sed -i.bak -E '/security/! s^https?://.+?/(debian|ubuntu)^http://'"$APT_MIRROR_NAME"'/\1^' /etc/apt/sources.list && grep '^deb' /etc/apt/sources.list; fi
RUN apt-get update --allow-releaseinfo-change --fix-missing

############# irma image ##################
FROM ${irma_image} as irma
RUN echo "Getting irma image"

############# dias image ##################
FROM ${dais_image} as dais
RUN echo "Getting dias image"

############# final image ##################
FROM base as final

# copy irma build to final image
COPY --from=irma / /

# copy dias build to final image
COPY --from=dais / /

# Create a working directory variable
ENV WORKDIR=/data

# Set up volume directory 
VOLUME ${WORKDIR}

# Set up working directory 
WORKDIR ${WORKDIR}

# set a project directory
ENV PROJECT_DIR=/spyne

# Set up volume directory in docker
VOLUME ${PROJECT_DIR}

# Copy all scripts to docker images
COPY . /spyne

# Define a system argument
ARG DEBIAN_FRONTEND=noninteractive

############# Install Java ##################
RUN apt-get update --allow-releaseinfo-change --fix-missing \
  && apt-get install --no-install-recommends -y \
  build-essential \ 
  iptables \
  python3.7\
  python3-pip \
  python3-setuptools \
  default-jre \
  default-jdk \
  dos2unix 

############# Install bbtools ##################

# Copy all files to docker images
COPY bbtools ${PROJECT_DIR}/bbtools

# Copy all files to docker images
COPY bbtools/install_bbtools.sh ${PROJECT_DIR}/bbtools/install_bbtools.sh

# Convert bash script from Windows style line endings to Unix-like control characters
RUN dos2unix ${PROJECT_DIR}/bbtools/install_bbtools.sh

# Allow permission to excute the bash script
RUN chmod a+x ${PROJECT_DIR}/bbtools/install_bbtools.sh

# Execute bash script to wget the file and tar the package
RUN bash ${PROJECT_DIR}/bbtools/install_bbtools.sh

# Remove bbtools folder from final image
RUN rm -rf ${PROJECT_DIR}/bbtools

############# Install python packages ##################

# Copy all files to docker images
COPY requirements.txt ${PROJECT_DIR}/requirements.txt

# Install python requirements
RUN pip3 install --no-cache-dir -r ${PROJECT_DIR}/requirements.txt

# Remove requirements.txt from final image
RUN rm -rf ${PROJECT_DIR}/requirements.txt

############# Run spyne ##################

# Copy all files to docker images
COPY snake-kickoff ${PROJECT_DIR}/snake-kickoff

# Convert spyne from Windows style line endings to Unix-like control characters
RUN dos2unix ${PROJECT_DIR}/snake-kickoff

# Allow permission to excute the bash scripts
RUN chmod a+x ${PROJECT_DIR}/snake-kickoff

# Allow permission to read and write files to spyne directory
RUN chmod -R a+rwx ${PROJECT_DIR}

# Clean up and remove unwanted files
RUN apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Export dais-ribosome script to path
ENV PATH "$PATH:/dais-ribosome"

# Export irma script to path
ENV PATH "$PATH:/flu-amd"

# Export snake-kickoff script to path
ENV PATH "$PATH:${PROJECT_DIR}"
